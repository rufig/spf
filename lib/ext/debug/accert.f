\ ~day 11.02.2001
\ В ACCERT удобно выводить лог, например
\ ACCERT( 2DUP LOG )
\ проверять значения на правильность, выводить отладочную
\ информацию
\ Уровни ACCERT-LEVEL:
\ 0 - не компилировать ACCERTION
\ 1 - компилировать все ACCERTION
\ 2 - компилировать ACCERT уровня выше 1
\ 3 - компилировать ACCERT уровня выше 2

VARIABLE ACCERT-LEVEL
1 ACCERT-LEVEL !

: _LINE_
\ компилирует строковый литерал - u - номер текущей строки
  CURSTR @ 0 <# #S #> [COMPILE] SLITERAL
; IMMEDIATE

: _FILE_
\ компилирует строковый литерал - имя текущего файла трансляции
  CURFILE @ ASCIIZ> [COMPILE] SLITERAL
; IMMEDIATE

: ACCERT-EV ( addr u n -- )
   ACCERT-LEVEL @ 1- > IF EVALUATE ELSE 2DROP THEN
;

: _ACCERT( ( n -- )
\ компилирует текст до ) если n > ACCERT-LEVEL-1
\ иначе пропускает его
  >R
  BEGIN
    [CHAR] ) PARSE 2DUP + C@ [CHAR] ) = 0=
  WHILE
    R@ ACCERT-EV
    REFILL 0= IF RDROP EXIT THEN
  REPEAT R> ACCERT-EV
; IMMEDIATE

: ACCERT1( 1 [COMPILE] _ACCERT( ; IMMEDIATE
: ACCERT2( 2 [COMPILE] _ACCERT( ; IMMEDIATE
: ACCERT3( 3 [COMPILE] _ACCERT( ; IMMEDIATE
: ACCERT( [COMPILE] ACCERT1( ; IMMEDIATE

\EOF
\ пример

2 ACCERT-LEVEL !
: test
  ACCERT3( _FILE_ TYPE [CHAR] : EMIT _LINE_ TYPE 
  SPACE S" hi, this is accertion!" TYPE )
;
 test