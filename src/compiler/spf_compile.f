( Компиляция чисел и строк в словарь.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999, март 2000
)

HEX

: _COMPILE,  \ 94 CORE EXT
\ Интерпретация: семантика не определена.
\ Выполнение: ( xt -- )
\ Добавить семантику выполнения определения, представленого xt, к
\ семантике выполнения текущего определения.
  SetOP
  0E8 C,              \ машинная команда CALL
  HERE CELL+ - ,
  HERE TO LAST-HERE
;

: COMPILE,  \ 94 CORE EXT
\ Интерпретация: семантика не определена.
\ Выполнение: ( xt -- )
\ Добавить семантику выполнения определения, представленого xt, к
\ семантике выполнения текущего определения.
    CON>LIT 
    IF  MACRO?
      IF     MACRO,
      ELSE   _COMPILE,
      THEN
    THEN
;

: BRANCH, ( ADDR -> ) \ скомпилировать инструкцию ADDR JMP
  E9 C,
  HERE CELL+ - ,
;

: RET, ( -> ) \ скомпилировать инструкцию RET
  C3 C,
;

: LIT, ( W -> )
  ['] DUP  MACRO,
  OPT_INIT
  SetOP 0B8 C,  , OPT  \ MOV EAX, #
  OPT_CLOSE
;

: DLIT, ( D -> )
  89 C, 45 C, FC C,        \ mov -4 [ebp], eax
  C7 C, 45 C, F8 C, SWAP , \ mov -8 [ebp], # low
\  HERE TO :-SET
  SetOP  B8 C, ,                  \ mov eax, # high
  SetOP  8D C, 6D C, F8 C,        \ lea ebp, -8 [ebp]
  HERE TO LAST-HERE
;

: RLIT, ( u -- )
\ Скомпилировать следующую семантику:
\ Положить на стек возвратов литерал u
   68 C, ,  \ push dword #
;

: ?BRANCH, ( ADDR -> ) \ скомпилировать инструкцию ADDR ?BRANCH
  084 TO J_COD
  OPT_INIT SetOP 0xC00B W,    \ OR EAX, EAX
  OPT? 
  IF BEGIN ?BR-OPT-STEP
     UNTIL
  THEN
\  OPT_CLOSE
  EVEN-EBP
  HERE TO :-SET
  HERE TO LAST-HERE
  ['] DROP MACRO,
  0F C, J_COD C,   \  JZ
  HERE CELL+ - ,
;

DECIMAL

: ", ( A -> ) \ компиляция строки со счетчиком, заданной адресом A
  HERE OVER C@ 1+ DUP ALLOT QCMOVE
;

: S", ( addr u -- ) \ компиляция строки, заданной addr u, в виде строки со счетчиком
  DUP C, HERE SWAP DUP ALLOT QCMOVE
;

\ orig - a, 1 (short) или a, 2 (near)
\ dest - a, 3

: >MARK ( -> A )
  HERE 4 -
;

: >RESOLVE1 ( A -> )
  HERE OVER - 4 -
  SWAP !
;

: <MARK ( -> A )
  HERE
;

: >RESOLVE ( A, N -- )
  DUP 1 = IF   DROP >RESOLVE1
          ELSE 2 <> IF -2007 THROW THEN \ ABORT" Conditionals not paired"
               >RESOLVE1
          THEN
;

\ Слова для выравнивания (ALOGN*) в SPF не используются.
\ Оставлены для соответствия стандарту ANS 94.

USER ALIGN-BYTES

: ALIGNED ( addr -- a-addr ) \ 94
\ a-addr - первый выровненный адрес, больший или равный addr.
  ALIGN-BYTES @ 2DUP
  MOD DUP IF - + ELSE 2DROP THEN
;
: ALIGN ( -- ) \ 94
\ Если указатель пространства данных не выровнен -
\ выровнять его.
  HERE ALIGNED HERE - ALLOT
;

: ALIGN-NOP ( n -- )
\ выровнять HERE на n и заполнить NOP
  HERE DUP ROT 2DUP
  MOD DUP IF - + ELSE 2DROP THEN
  OVER - DUP ALLOT 0x90 FILL
;
