\ $Id$
\ Work in spf3, spf4
\ LOCALS from ANS 94.
\ Use -
\ LOCALS| n1 n2 n3 |

REQUIRE { devel\~af\lib\locals.f

GET-CURRENT ALSO vocLocalsSupport DEFINITIONS

: CompileANSLocInit
  uPrevCurrent @ SET-CURRENT
  uLocalsCnt @ ?DUP IF
    0 DO  S" >R " EVALUATE -1 CELLS uAddDepth +! LOOP
  THEN
;;

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
