\ $Id$
\ Work in spf3, spf4
\ LOCALS стандарта 94.
\ Объявление -
\ LOCALS| n1 n2 n3 |

REQUIRE { ~MAK\locals1.f

GET-CURRENT ALSO vocLocalsSupport DEFINITIONS

: CompileANSLocInit
  uPrevCurrent @ SET-CURRENT
  uLocalsUCnt @ ?DUP
  IF NEGATE CELLS R_ALLOT,
  THEN
  uLocalsCnt @ uLocalsUCnt @ - ?DUP 
  IF DUP CELLS NEGATE uAddDepth +!
     DUP  0 
     DO uLocalsCnt @ uLocalsUCnt @ - I - 1-
        LIT,  S"  PICK >R " EVALUATE LOOP
        0  DO POSTPONE DROP LOOP
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
