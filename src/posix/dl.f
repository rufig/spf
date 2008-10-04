\ $Id$
\ 
\ Подключение динамических библиотек
\ Ю. Жиловец, 22.04.2007

VARIABLE dlopen-adr
VARIABLE dlsym-adr
VARIABLE dlerror-adr
VARIABLE realloc-adr
VARIABLE write-adr

\ REQUIRE SEE lib/ext/disasm.f
\ REQUIRE s. ~yz/lib/common.f

\ ------------------------------

: (DLOPEN) ( file mode -- h)
  2 dlopen-adr @ C-CALL
;

: (DLSYM) ( h name -- a)
  2 dlsym-adr @ C-CALL
;

: DLERROR ( -- z/0)
  0 dlerror-adr @ C-CALL
;
: DLOPEN ( addr u -- h ) DROP 9 (DLOPEN) ;
: DLSYM ( addr u h -- api-xt ) NIP SWAP (DLSYM) ;

0 VALUE global-symbol-object

VECT library-not-found-error
VECT symbol-not-found-error

: write-dlerror ( z -- )
  DROP
  2 DLERROR ASCIIZ> 3 write-adr @ C-CALL DROP
  10 >R 2 RP@ 1 3 write-adr @ C-CALL DROP RDROP
;

' write-dlerror DUP
    ' library-not-found-error TC-VECT!   
    ' symbol-not-found-error  TC-VECT!

: dlopen2 ( file -- )
  DUP 0x9 ( rtld_lazy|rtld_global) (DLOPEN)
  0= IF
    library-not-found-error
  ELSE
    DROP
  THEN
;

: dlsym2 ( name -- a )
  global-symbol-object OVER (DLSYM)
  ?DUP IF
    NIP
  ELSE
    symbol-not-found-error
  THEN
;

: dlrealloc ( adr size -- adr2)
  2 realloc-adr @ C-CALL ?DUP 0= IF
    2 S" dlrealloc: cannot allocate memory" 3 write-adr @ C-CALL DROP
  THEN
;

\ ------------------------------
\ Формат таблицы строк
\  0 cell Размер занятого пространства (в байтах)
\ +4 ...  строки

: enter-into-strtab ( a n strtab -- n )
  >R
  R@ @ 1000 MOD 950 > IF
    R> DUP @ 1000 + dlrealloc >R
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
    I dl-rec# * + @ DUP 0< IF NEGATE THEN + szcompare IF
      2DROP 2DROP I TRUE UNLOOP EXIT
    THEN
  LOOP
  2DROP 2DROP FALSE
;

: table-enter ( library? a # -- sym# )
  dl-second# 100 MOD 0= IF
    \ расширяем таблицу еще на 100 записей
    dl-second dl-second# 100 + dl-rec# * 
    dlrealloc TO dl-second
  THEN
  dl-second-strtab enter-into-strtab SWAP IF NEGATE THEN
  dl-second dl-second# dl-rec# * + DUP 2 CELLS ERASE !
  dl-second# DUP 1+ TO dl-second# dl-first# +
;

: name-lookup ( a # library? -- sym# )
  -ROT 2DUP 
  dl-first-strtab dl-first dl-first# table-lookup IF
    NIP NIP NIP EXIT
  THEN
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
  get-symbol-record >R
  R@ CELL+ @ ?DUP 0= IF
    R@ @ + dlsym2 DUP R@ CELL+ !
  ELSE
    NIP
  THEN
  RDROP
;

: symbol-call ( ... n sym# -- res )
  symbol-address C-CALL
;

: symbol-call2 ( ... n sym# -- dres )
  symbol-address C-CALL2
;

' symbol-call  TO symbol-call-adr
' symbol-call2 TO symbol-call2-adr

\ ------------------------------

\ Загружает все библиотеки, описанные 
\ в статической таблице компоновки dl-first
\ и очищает адреса функций

: load-libraries
  dl-first dl-first# dl-rec# * OVER + SWAP ?DO
    I @ 0< IF 
      I @ NEGATE dl-first-strtab + dlopen2 
    ELSE 
      I CELL+ 0! 
    THEN
  dl-rec# +LOOP
;

: dl-init
  0 0x09 (DLOPEN) TO global-symbol-object
  0 1000 dlrealloc TO dl-second-strtab
  4 dl-second-strtab !
  0 TO dl-second#
  load-libraries
;

\ ------------------------------------

USER ((-stack
USER (__ret2) 

: (( ( -- ) SP@ ((-stack !  (__ret2) 0! ;
: <( ( n -- ) 1+ CELLS SP@ + ((-stack !  (__ret2) 0! ;

: ())) ( -- n ) SP@ ((-stack @ SWAP - >CELLS ;
: __ret2 ( -- ) TRUE (__ret2) ! ; IMMEDIATE

' ())) TO ()))-adr
