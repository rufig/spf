\ –абота со строками
\ Ќаписана под сильным вли€нием ~ac\lib\str.f
\ ќписание читайте там же
\ ¬се строки хран€тс€ в стеке строк
\ –абота с ним аналогично R> >R только S> >S S@ ...

USER-CREATE STR-STACK
100 CELLS USER-ALLOT
USER STR-TOP

: HOLDS ( addr u -- ) \ from eserv src
  SWAP OVER + SWAP 0 ?DO DUP I - 1- C@ HOLD LOOP DROP
;

: SHEAP-COPY ( c-addr u -- c-addr1 )
   DUP 0 < ABORT" Wrong string!"
   DUP CELL+ 1+ ALLOCATE THROW
   2DUP ! 2DUP + CELL+ 0 SWAP C!
   DUP >R CELL+ SWAP CMOVE
   R>
;

: SLATTER
   STR-TOP @ STR-STACK +
;

: SDEPTH ( -- u )
   STR-TOP @ 2 RSHIFT
;

: SPUSH ( str -- )
   SLATTER !
   CELL STR-TOP +!
;

: >S ( addr u -- )
   SHEAP-COPY
   SPUSH
;

: SDROP
   STR-TOP @ 0= ABORT" String stack was exhausted"
   CELL NEGATE STR-TOP +!
   SLATTER @ FREE THROW
;

: S@ ( -- addr u )
   SLATTER CELL- @ CELL+ DUP CELL- @
;

: SFETCH ( -- str )
   SLATTER CELL- @
;

: STR@  ( str -- addr u )
   CELL+ DUP CELL- @
;

: STRFREE ( str )
   FREE THROW
;

: SPOP ( -- str )
   SFETCH
   CELL NEGATE STR-TOP +!
;

: S> ( -- addr u )
\ ѕереносит строку с вершины стека строк в PAD (макс. размер 1024)
   S@ DUP >R
   PAD SWAP CMOVE
   0 PAD R@ + C!
   PAD R>
   SDROP
;

: SSWAP
   SLATTER CELL- >R
   R@ @ R@ CELL- @
   R@ ! R> CELL- !
;

: SPICK ( u -- )
  CELLS SLATTER SWAP - CELL-
  @ CELL+ DUP CELL- @ >S
;

: SOVER
   1 SPICK
;

: SDUP 
   0 SPICK
;

: SROT
  SLATTER CELL- >R
  R@ @ R@ CELL- @
  R@ CELL- CELL- @
  R@ ! R@ CELL- CELL- !
  R> CELL- !
;

: .SS
\ –аспечатывает содержимое стека строк. јналог .S
   STR-STACK STR-TOP @ OVER + SWAP
   ?DO
      I @ CELL+ DUP CELL- @ TYPE ."  <--" CR
   CELL +LOOP
   ." top of string stack" CR
;

: SSCLEAR
\ ќчистить стек строк
   STR-STACK STR-TOP @ OVER + SWAP
   ?DO
      I @ FREE THROW
   CELL +LOOP STR-TOP 0!
;

: StrLen
   S@ NIP
;

: StrAddr
   S@ DROP
;

: SGROW ( u -- )
   DUP S@ SWAP CELL-
   SWAP CELL+ 1+ ROT +
   RESIZE THROW
   TUCK +!
   DUP @ OVER + CELL+ 0 SWAP C!
   SLATTER CELL- !
;

: StrCat ( c-addr u -- )
\ ƒобавить строку c-addr к строке на стеке строк
   DUP 0= IF 2DROP EXIT THEN
   StrLen OVER SGROW
   SLATTER CELL- @
   CELL+ + SWAP CMOVE
;

: ""
  PAD 0 >S
;  

USER sp_save \ указатель стека данных при STR-EVAL

USER _''

GET-CURRENT
VOCABULARY VOC-MACROS
ALSO VOC-MACROS DEFINITIONS

USER CURR-STR

: CRLF
   LT 2
;

: %SYM ( с -- addr u1 )
\ ƒобавить к разбираемой строке символ, код которого лежит на стеке
  _'' ! _'' 1
  CELL sp_save +!
;

: '' [CHAR] " _'' ! _'' 1 ;

: %U ( u -- addr u1 )
\ ƒобавить к разбираемой строке число со стека данных в DECIMAL без знака
  BASE @ >R
  DECIMAL
  0 <# #S #>
  R> BASE !
  CELL sp_save +!
;

: %D ( n -- addr u1 ) 
\ ƒобавить к разбираемой строке число со стека данных в DECIMAL со знаком
  BASE @ >R
  DECIMAL DUP >R ABS
  0 <# #S R> SIGN #>
  R> BASE !
  CELL sp_save +!
;

: %H ( u -- addr u1 )
\ ƒобавить к разбираемой строке число со стека данных в HEX
  BASE @ >R
  HEX
  0 <# #S #>
  R> BASE !
  CELL sp_save +!
;

: %S ( addr u -- addr u )
\ ƒобавить к разбираемой строке строку addr u
  2 CELLS sp_save +!
;

SET-CURRENT

: STR-EVAL ( addr u S: s -- S: s )
   SFETCH CURR-STR !
   ALSO VOC-MACROS
   SP@ sp_save !
   ['] EVALUATE CATCH 
   ?DUP IF NIP NIP
           BASE @ >R DECIMAL
           DUP >R ABS 0 <# [CHAR] ) HOLD #S R> SIGN S" (ERROR: " HOLDS #>
           SP@ sp_save ! R> BASE !
        THEN
   SP@ sp_save @ - DUP
     \ разница=0, если возвращены два числа - адрес и длина строки
     \ =1 если возвращено число
     \ =8 - ничего не делать
   4 =
   IF DROP 0 <# #S #>  \ преобразовать в текущей системе счислени€
      StrCat
   ELSE 0 = IF StrCat THEN
   THEN
   PREVIOUS
;

: (") ( addr u -- S: s )
  "" TIB >R #TIB @ >R >IN @ >R
  #TIB ! TO TIB >IN 0!
  BEGIN
    >IN @ #TIB @ <           
  WHILE
    [CHAR] { PARSE  
    StrCat
    [CHAR] } PARSE ?DUP
    IF STR-EVAL
    ELSE DROP THEN
  REPEAT
  R> >IN ! R> #TIB ! R> TO TIB
;

: _STRLITERAL ( -- str )
  R> DUP CELL+ SWAP @ 2DUP + CHAR+ >R
  (")
;

: STRLITERAL ( str -- )
  \ похоже на SLITERAL, но длина строки не ограничена 255
  \ и компилируема€ строка при выполнении "разворачиваетс€" по (")
  DUP STR@
  STATE @ IF
             ['] _STRLITERAL COMPILE,
             DUP ,
             HERE SWAP DUP ALLOT MOVE 0 C,
          ELSE
              ROT >R (") R>
          THEN
          STRFREE
; IMMEDIATE

: PARSE" ( -- str )
  [CHAR] " PARSE
  2DUP + C@ [CHAR] " <>
  IF \ „итаем построчно
    >S
    BEGIN
      REFILL
    WHILE
      CRLF StrCat
      [CHAR] " PARSE >R R@ StrCat
      R> #TIB @ <>
      IF SPOP EXIT
      THEN
    REPEAT
  ELSE >S SPOP
  THEN
;

PREVIOUS

: " ( "ccc" -- )
   PARSE" POSTPONE STRLITERAL
; IMMEDIATE

\ Example
(
12
" dima{CRLF}
wrote
this
test {%D}
"
S> TYPE
)

