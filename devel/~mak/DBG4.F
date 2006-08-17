( interactive debugger for )
( Mihail Maksimov 2001     )

REQUIRE DISASSEMBLER lib\ext\disasm.f 
REQUIRE CASE         ~MAK\case.f 
REQUIRE [IF]         lib\include\tools.f 
ALSO DISASSEMBLER

VARIABLE &EIP
VARIABLE &ESP
VARIABLE &NEXTEIP
VARIABLE C_NAME

VECT VTR

0 VALUE RANGE

: GO  0xE9 RANGE C! &EIP @ RANGE - 5 - RANGE 1+ !  ;

0 VALUE J_SHORT_V
: JSHRT
  &EIP @ C@ J_SHORT_V C!
         &ESP @
     [  0xFF C, 0x70 C, -9 CELLS C, \ PUSH [EAX-9*4]
        0x9D C,        \ POPFD
        HERE TO J_SHORT_V 2 ALLOT HERE 1- ]
          2
     [ HERE BRANCH,
       HERE OVER - 1- SWAP C!  >MARK 2 ]
            &EIP @ 1+ C@ C>S  2+
       THEN  &EIP +! DROP RDROP ;
0 VALUE J_SNEAR_V
: JNEAR
  &EIP @ W@ J_SNEAR_V W!
         &ESP @
     [  0xFF C, 0x70 C, -9 CELLS C, \ PUSH [EAX-9*4]
        0x9D C,        \ POPFD
        HERE TO J_SNEAR_V 6 ALLOT >MARK 1 ]
          6
       ELSE
            &EIP @ 2+ @  6 +
       THEN &EIP +! DROP RDROP ;

C" REL!" FIND NIP 0=
[IF] : REL! ( ADDR' ADDR  --  )  TUCK - SWAP ! ;
[THEN]

: CLITERAL-CODE_DO
      &EIP @ 5 + DUP COUNT + 1+ &EIP ! ;

: SLITERAL-CODE_DO
  CLITERAL-CODE_DO COUNT ;

BASE @ HEX
: STEP  ( -- )
  &EIP @
  DUP C@      \  CFA  N'
  DUP   0C3 = IF 058F RANGE W!  &EIP RANGE 2+ !  EXIT THEN  \ RET


\  JO JNO JB JAE JE JNE JBE JA JS JNS JP JNP JL JGE JLE JG
\ 0111.XXXX
  DUP  F0 AND 70 = IF  JSHRT   THEN

   DUP   0E9 = IF DROP 1+ @  5 + &EIP +!  EXIT  THEN  \  JMP NEAR
   DUP   0E8 = IF RANGE C!
                  1+ REL@
                  DUP &EIP @ 1+ REL@ CELL+ CLITERAL-CODE =
                  IF DROP ['] CLITERAL-CODE_DO 4 - RANGE 1+ REL! EXIT THEN

                  DUP &EIP @ 1+ REL@ CELL+ SLITERAL-CODE =
                  IF DROP ['] SLITERAL-CODE_DO 4 - RANGE 1+ REL! EXIT THEN

                  RANGE 1+ REL!
                  5 &EIP +!   EXIT THEN  \  CALL
   DUP   0EB = IF &EIP @ 1+ C@ C>S 2+ &EIP +!  EXIT  THEN  \  JMP  SHORT

  DROP
  DUP W@
\  JO JNO JB JAE JE JNE JBE JA JS JNS JP JNP JL JGE JLE JG
\ 0111.XXXX
  DUP  F0FF AND 800F = IF  JNEAR THEN

\  1110.0XXX 1111.1111
  DUP F8FF
  AND E0FF   = IF NIP 8 RSHIFT 7 AND 1+ CELLS NEGATE
                  &ESP @ + @   &EIP ! EXIT THEN  \ JMP  E__

  DUP F8FF
  AND D0FF   = IF NIP 8 RSHIFT 7 AND 1+ CELLS NEGATE
                  &ESP @ + @   &EIP ! EXIT THEN  \ CALL E__

  DUP FCFF
  AND 20FF   = IF NIP 8 RSHIFT 7 AND 1+ CELLS NEGATE
                  &ESP @ + @  @ &EIP ! EXIT  THEN  \ JMP [E_X]
  2DROP
  C_NAME  @ [ S" LOOP" DROP @ ] LITERAL =
  C_NAME C@ [CHAR] J = OR IF 
       CR ." Is not introduced in the STEP" EXIT
  THEN
  &EIP @ RANGE  &NEXTEIP @ &EIP @ - CMOVE
  &NEXTEIP @  &EIP !
;

: NST &EIP @ C@ 0xE8 =    \ CALL X
      IF   0x68 RANGE C!      \ PUSH #
           &EIP @  
           DUP  5 + RANGE 1+ !
           1+ @ 5 + &EIP +!  EXIT
      THEN
     &EIP @ F8FF
     AND D0FF   =       \ CALL E__
     IF   0x68 RANGE C!      \ PUSH #
          &EIP @
          DUP  5 + RANGE 1+ !
          8 RSHIFT 7 AND 1+ CELLS NEGATE
             &ESP @ + @    &EIP ! EXIT
     THEN
     STEP
;

BASE !

: .FLAG ( N -- N )
 OVER AND IF ." 1 " ELSE ." 0 " THEN ;

: .REG ( ADDR -- ADDR1 )
   4 - DUP @ 8 H.N SPACE ;

: .RST  &ESP @
       25 >R
    BEGIN
      DUP HANDLER @ CELL+ U< R@ 0 > AND
    WHILE
      STACK-ADDR.
      CELL+ R> 1- >R
    REPEAT DROP RDROP ;

CREATE debugTIB 80 CHARS ALLOT
: eval_debug_statements ( -- )
  \ A simple outer interpreter for interactive input at
  \ debugtime.
        BEGIN
          CR ." > " debugTIB DUP 80 ACCEPT SPACE DUP
        WHILE
          ['] EVALUATE CATCH 
          IF ." Oops!?" CR 2DROP
          THEN
        REPEAT
        2DROP ;

: .ext\n  ( ADDR ADDR1 -- ADDR1 ADDR1 )
    >R C@ 0xC3 = IF ." ( "  &ESP @ @ WordByAddr TYPE ."  )" THEN CR 
    R> DUP
;

: TrDO &EIP @
  DUP C@
\ 001X.X110
  DUP  0xE7 AND 
       0x26 =       \ ES: SS: CS: DS:
\ 0110.01XX
  SWAP 0xFC AND 
       0x64 =  OR   \ FS: GS: D16: A16:
    IF INST CR THEN
  DUP  INST .ext\n  DUP &NEXTEIP ! S-BUF 1+ @ C_NAME !
  &EIP @ C@ 0xE8 =
  IF &EIP @ 1+ REL@ CELL+
     DUP  CLITERAL-CODE <>
     SWAP SLITERAL-CODE <> AND
     IF   ." !!!! STEP can if only return code is follow" CR
     THEN
  THEN
       INST .ext\n
       INST .ext\n
       INST .ext\n 2DROP
 &ESP @
." EAX=" .REG ." ECX=" .REG ." EDX=" .REG ." EBX=" .REG CR
." ESP=" .REG ." EBP=" .REG ." ESI=" .REG ." EDI=" .REG CR
." FLG=" .REG @
    ." C="   0x1   .FLAG
    ." P="   0x4   .FLAG
    ." A="   0x10  .FLAG
    ." Z="   0x40  .FLAG
    ." S="   0x80  .FLAG
    ." T="   0x100 .FLAG
    ." I="   0x200 .FLAG
    ." D="   0x400 .FLAG
    ." O="   0x800 .FLAG
       DROP  CR
." EBP-10:" &ESP @ 6 CELLS - @ 0x10 - 0x30 DUMP CR
  0x90909090 DUP DUP DUP RANGE 2! RANGE CELL+ CELL+ 2! 
  BEGIN  KEY UPC
     CASE
     [CHAR] G OF GO  TRUE  ENDOF
     [CHAR] N OF NST   TRUE  ENDOF
     [CHAR] S OF STEP  TRUE  ENDOF
     [CHAR] A OF ABORT       ENDOF
     [CHAR] R OF .RST FALSE  ENDOF
     [CHAR] F OF eval_debug_statements TRUE  ENDOF
     ." Nest Step Go Abort Rstc" CR TRUE SWAP
     ENDCASE
  UNTIL
;

' TrDO TO VTR

: TRACE
    [ 0x58F W, &EIP , ] \ POP DWORD PTR  [{&EIP}]
    BEGIN
    [ 0x2589 W, &ESP ,  \  MOV DWORD PTR  [{&ESP}], ESP
      0x60 C,        \ PUSHA
      0x9C C,        \ PUSHFD
      0xAD8D W,  0x100 NEGATE , \  LEA EBP, [EBP-100H]
    ]  VTR [
      0xAD8D W,  0x100        , \  LEA EBP, [EBP+100H]
      0x9D C,        \ POPFD
      0x61 C,        \ POPAD
     HERE TO RANGE  0x90909090 DUP DUP DUP , , , ,
    ] AGAIN
;

CREATE BP_SAVE 0 DUP , , 
BP_SAVE VALUE BreakPoint

: BreakPointDo

[ 0x60 C,        \ PUSHA
  0x9C C,        \ PUSHFD
]        BP_SAVE    @ BreakPoint    !
         BP_SAVE 1+ @ BreakPoint 1+ !
[ 0x9D C,        \ POPFD
  0x61 C,        \ POPAD
  0xFF C, 0x35 C, ' BreakPoint >BODY ,   \ PUSH  BreakPoint
  ' TRACE BRANCH, ]        \ JMP TRACE
;

: SETBP  ( CFA -- )   \ BreakPoint  SET
         BP_SAVE    @ BreakPoint    !
         BP_SAVE 1+ @ BreakPoint 1+ !
         DUP TO BreakPoint
             2@ BP_SAVE 2!
         0xE9 BreakPoint C!
         ['] BreakPointDo  5 - BreakPoint - BreakPoint 1+ !
         GO ;

: DBG ( "<spaces>name" -- )
    RDROP ' >R
 [ ' TRACE BRANCH, ]        \ JMP TRACE
;

PREVIOUS

\EOF TEST

: XX  ." xxx" 2 0 DO I . LOOP  ;
HEX
DBG XX 