\ $Id$
\ Work in spf3, spf4
\ LOCALS стандарта 94.
\ ќбъ€вление -
\ LOCALS| n1 n2 n3 |

REQUIRE {	devel\~af\lib\locals.f

GET-CURRENT ALSO vocLocalsSupport DEFINITIONS

\ CODE D>RMOVE ( x1 ... xn n*4 -- R: xn ... x1 )
\      POP  EDX \ адрес возврата
\ @@1: 
\      PUSH [EBP]
\      ADD  EBP, # 4
\      SUB  EAX, # 4
\      JNZ  SHORT @@1
\      MOV  EAX, [EBP]
\      LEA  EBP, 4 [EBP]
\      JMP  EDX
\ END-CODE

: D>RMOVE ( x1 ... xn n*4 -- R: xn ... x1 )
\ перенести n чисел со стека данных на стек возвратов
[ BASE @ HEX
  5A  C,
  4 ALIGN-NOP
  FF  C, 75  C, 0  C,
  83  C, C5  C, 4  C, 83  C,
  E8  C, 4  C, 75  C, F5  C,
  8B  C, 45  C, 0  C, 8D  C,
  6D  C, 4  C, FF  C, E2  C,
BASE ! ]
;;

VERSION 400000 < [IF] \ spf3
  : CompileANSLocInit
    uPrevCurrent @ SET-CURRENT
    uLocalsCnt @ ?DUP IF
      CELLS DUP
      LIT, POSTPONE D>RMOVE
      LIT, POSTPONE >R ['] (LocalsExit) LIT, POSTPONE >R
    THEN
  ;;
[ELSE] \ spf4
  : CompileANSLocInit
    uPrevCurrent @ SET-CURRENT
    uLocalsCnt @ ?DUP IF
      CELLS DUP
      LIT, POSTPONE D>RMOVE
      RLIT, ['] (LocalsExit) RLIT,
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
