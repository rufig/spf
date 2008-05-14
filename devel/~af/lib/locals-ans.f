\ Work in spf3, spf4
\ LOCALS from ANS 94.
\ Use -
\ LOCALS| n1 n2 n3 |

REQUIRE { ~af/lib/locals.f

GET-CURRENT ALSO vocLocalsSupport DEFINITIONS

VERSION 400000 < [IF] \ spf3
  : CompileANSLocInit
    uPrevCurrent @ SET-CURRENT
    uLocalsCnt @ ?DUP IF
      0 DO S" >R" EVALUATE -1 CELLS uAddDepth +! LOOP
    THEN
  ;;
[ELSE] \ spf4
  : CompileANSLocInit
    uPrevCurrent @ SET-CURRENT
    uLocalsCnt @ ?DUP IF
      DUP
      0x50 C, \ PUSH EAX 
      1- 0 ?DO 0xFF C, 0x75 C, I CELLS C, ( PUSH XX [EBP]) LOOP
      0 DO S" DROP" EVALUATE LOOP
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
