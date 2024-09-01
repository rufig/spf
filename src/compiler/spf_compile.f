\ $Id$

( Компиляция чисел и строк в словарь.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999, март 2000
)

HEX

: HERE ( -- addr ) \ 94
\ addr - указатель пространства данных.
  DP @ 
  DUP TO :-SET
  DUP TO J-SET
;

: _COMPILE,  \ 94 CORE EXT
\ Интерпретация: семантика не определена.
\ Выполнение: ( xt -- )
\ Добавить семантику выполнения определения, представленого xt, к
\ семантике выполнения текущего определения.
  ?SET
  SetOP
  0E8 C,              \ машинная команда CALL
  DP @ CELL+ - ,
  DP @ TO LAST-HERE
;

: COMPILE,  \ 94 CORE EXT
\ Интерпретация: семантика не определена.
\ Выполнение: ( xt -- )
\ Добавить семантику выполнения определения, представленого xt, к
\ семантике выполнения текущего определения.
    CON>LIT 
    IF  INLINE?
      IF     INLINE,
      ELSE   _COMPILE,
      THEN
    THEN
;

: BRANCH, ( ADDR -> ) \ скомпилировать инструкцию ADDR JMP
  ?SET SetOP SetJP E9 C,
  DUP IF DP @ CELL+ - THEN ,    DP @ TO LAST-HERE
;

: RET, ( -> ) \ скомпилировать инструкцию RET
  ?SET SetOP 0xC3 C, OPT OPT_CLOSE 
;

: LIT, ( W -> )
  ['] DUP  INLINE,
  OPT_INIT
  SetOP 0B8 C,  , OPT  \ MOV EAX, #
  OPT_CLOSE
;

: 2LIT, ( xd -- )
  SWAP LIT, LIT,
;
: DLIT, ( d|ud -- )
  2LIT,
;

: RLIT, ( u -- )
\ Скомпилировать следующую семантику:
\ Положить на стек возвратов литерал u
   68 C, ,  \ push dword #
;

: ?BRANCH, ( ADDR -> ) \ скомпилировать инструкцию ADDR ?BRANCH
  ?SET
  084 TO J_COD
  ???BR-OPT
  SetJP  SetOP
  J_COD    \  JX без 0x0F
  0x0F     \  кусок от JX
  C, C,
  DUP IF DP @ CELL+ - THEN , DP @ TO LAST-HERE
;

DECIMAL

: S, ( addr u -- )
\ Зарезервировать u символов пространства данных
\ и поместить туда содержимое u символов из addr.
  CHARS DP @ SWAP DUP ALLOT MOVE
;

: S", ( addr u -- ) 
\ Разместить в пространстве данных строку, заданную addr u, 
\ в виде строки со счетчиком.
  DUP 255 U> IF -18 THROW THEN
  DUP C, S,
;

: SLIT, ( a u -- ) 
\ Скомпилировать строку, заданную addr u.
  ['] _SLITERAL-CODE COMPILE,  S", 0 C,
;
: CLIT, ( c-addr -- )
  \ ( run-time: -- c-addr2 )
  ['] _CLITERAL-CODE COMPILE,  COUNT S", 0 C,
;

: ", ( A -> )
\ разместить в пространстве данных строку, заданную адресом A, 
\ в виде строки со счетчиком
  COUNT S",
;

\ orig - a, 1 (short) или a, 2 (near)
\ dest - a, 3

: >MARK ( -> A )
  DP @ DUP TO :-SET 4 - 
;

: <MARK ( -> A )
  HERE
;

: >ORESOLVE1 ( A -> )
  ?SET
  DUP
    DP @ DUP TO :-SET
    OVER - 4 -
    SWAP !
  RESOLVE_OPT
;

: >ORESOLVE ( A, N -- )
  DUP 1 = IF   DROP >ORESOLVE1
          ELSE 2 <> IF -2007 THROW THEN \ ABORT" Conditionals not paired"
               >ORESOLVE1
          THEN
;

: >RESOLVE1 ( A -> )
  HERE OVER - 4 -
  SWAP !
;

: >RESOLVE ( A, N -- )
  DUP 1 = IF   DROP >RESOLVE1
          ELSE 2 <> IF -2007 THROW THEN \ ABORT" Conditionals not paired"
               >RESOLVE1
          THEN
;


\ Слова для выравнивания (ALIGN*) в SPF используются для выравнивания
\ кода форт-слов и данных после CREATE

USER ALIGN-BYTES

: ALIGN-TO ( addr u -- addr1 )
  DUP 16 =
  IF
    \ Try to avoid slow division, 16 is a default align value
    1- + 0xFFFFFFF0 AND
  ELSE
    2DUP MOD DUP IF - + ELSE 2DROP THEN
  THEN
;

: ALIGNED ( addr -- a-addr ) \ 94
\ a-addr - первый выровненный адрес, больший или равный addr.
  ALIGN-BYTES @ ALIGN-TO
;

: ALIGN ( -- ) \ 94
\ Если указатель пространства данных не выровнен -
\ выровнять его.
  DP @ ALIGNED DP @ - ALLOT
;

: ALIGN-NOP ( n -- )
\ выровнять HERE на n и заполнить NOP
  HERE DUP ROT ALIGN-TO
  OVER - DUP ALLOT 0x90 FILL
;
