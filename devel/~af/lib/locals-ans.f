\ $Id$
\ Work in spf3, spf4
\ LOCALS стандарта 94.
\ Объявление -
\ LOCALS| n1 n2 n3 |

REQUIRE {	devel\~af\lib\locals.f

GET-CURRENT ALSO vocLocalsSupport DEFINITIONS

VARIABLE vret
: D>RMOVE ( D: x1 ... xn n -- R: xn ... x1 )
  R> vret !
  BEGIN DUP WHILE SWAP >R 1- REPEAT DROP
  vret @ >R
;;

VERSION 400000 < [IF] \ spf3
  : CompileANSLocInit
    uPrevCurrent @ SET-CURRENT
    uLocalsCnt @ ?DUP IF
      DUP
      LIT, POSTPONE D>RMOVE
      CELLS LIT, POSTPONE >R ['] (LocalsExit) LIT, POSTPONE >R
    THEN
  ;;
[ELSE] \ spf4
  : CompileANSLocInit
    uPrevCurrent @ SET-CURRENT
    uLocalsCnt @ ?DUP IF
      DUP
      LIT, POSTPONE D>RMOVE
      CELLS RLIT, ['] (LocalsExit) RLIT,
    THEN
  ;;
[THEN]

SET-CURRENT

: LOCALS|
  LocalsStartup
  BEGIN
    BL SKIP PeekChar
    [CHAR] | <>
  WHILE
    CREATE LocalsDoes@ IMMEDIATE
  REPEAT
  [CHAR] | PARSE 2DROP
  CompileANSLocInit
;; IMMEDIATE

PREVIOUS
