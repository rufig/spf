: s.  SP@ S0 @ CELL - 2DUP - 
  DUP 4 = IF DROP 2DROP ." Stack is empty" CR EXIT THEN 
  4 > IF 2DROP ." Stack is underflowed" CR EXIT THEN
  DO I @ . CELL NEGATE +LOOP CR ;

CODE -ROT ( x1 x2 x3 -- x3 x1 x2 ) \ 94
\ Прокрутить три верхних элемента стека.
     MOV  EDX, 4 [EBP]
     MOV  4 [EBP], EAX
     MOV  EAX, [EBP]
     MOV  [EBP], EDX
     RET
END-CODE

: CZMOVE ( a # z --) 2DUP + >R SWAP CMOVE R> 0 SWAP C! ;

VARIABLE (__ret2)  (__ret2) 0!

: enter-into-strtab ( a n strtab -- n )
  >R
  R@ @ 1000 MOD 0= IF
\ во время компиляции должно хватить 1000 символов
  ABORT" Больше 1000 байтов для имен внешних функций"
(    R> DUP @ 1000 + dlrealloc >R)
  THEN
  R@ @ 2DUP + 1+ R@ !
  DUP R> + SWAP >R CZMOVE
  R>
;

\ ------------------------------
\ Формат записи таблицы символов
\ +0 cell Строка
\ +4 cell Адрес символа / 0
\ Строка представляется смещением в таблице строк
\ Ссылки на библиотеку заносятся с обратным знаком

2 CELLS CONSTANT dl-rec#

0 VALUE dl-first
0 VALUE dl-first#
0 VALUE dl-first-strtab
0 VALUE dl-second
0 VALUE dl-second#
0 VALUE dl-second-strtab

\ ------------------------------

: szcompare ( a # z -- ? ) ASCIIZ> COMPARE 0= ;

: table-lookup ( a # strtab symtab symtab# -- sym# T / F)
  0 ?DO
    ( a # strtab symtab)
    2OVER 2OVER
    I dl-rec# * + @ + szcompare IF
      2DROP 2DROP I TRUE UNLOOP EXIT
    THEN
  LOOP
  2DROP 2DROP FALSE
;

: table-enter ( library? a # -- sym# )
(  dl-second# 100 MOD 0= IF
    \ расширяем таблицу еще на 100 записей
    dl-second dl-second# 100 + dl-rec# * 
    dlrealloc TO dl-second
  THEN)
  dl-second-strtab enter-into-strtab SWAP IF NEGATE THEN
  dl-second dl-second# dl-rec# * + DUP 2 CELLS ERASE !
  dl-second# DUP 1+ TO dl-second# dl-first# +
;

: name-lookup ( a # library? -- sym# )
  -ROT ( 2DUP 
  dl-first-strtab dl-first dl-first# table-lookup IF
    NIP NIP NIP EXIT
  THEN)
  2DUP
  dl-second-strtab dl-second dl-second# table-lookup IF
    dl-first# + NIP NIP NIP EXIT
  THEN
  table-enter
;

: symbol-lookup ( a # -- sym# )
  FALSE name-lookup
;
 
\ ------------------------------

: get-symbol-record ( sym# -- strtab dlrec)
  DUP dl-first# < IF
    dl-first-strtab dl-first
  ELSE
    dl-first# - dl-second-strtab dl-second
  THEN 
  ROT dl-rec# * +
;

: symbol-address ( sym# -- adr)
ABORT" Вызов symbol-address"
(  get-symbol-record >R
  R@ CELL+ @ ?DUP 0= IF
    R@ @ + dlsym2 DUP R@ CELL+ !
  ELSE
    NIP
  THEN
  RDROP
)
;

0 TO dl-first#
0 TO dl-second#
100 dl-rec# * ALLOCATE THROW TO dl-second
1000 ALLOCATE THROW TO dl-second-strtab
4 dl-second-strtab !
