\ Оптимизирующий макроподстановшик        Максимов М.О.

[UNDEFINED] C>S
[IF]
: C>S ( c -- n )  0xFF AND [ 0x7F INVERT ] LITERAL XOR 0x80 + ;
[THEN]

[UNDEFINED] QCMOVE
[IF]
: QCMOVE CMOVE ;
[THEN]

BASE @ HEX

\ : REL! ( ADDR' ADDR  --  )
\        TUCK - SWAP ! ;

: REL@ ( ADDR -- ADDR' )
         DUP @ + ;


\  FALSE VALUE OPT?
   TRUE VALUE OPT?
  084 VALUE J_COD


: SET-OPT TRUE TO OPT? ;
: SET-OPT_ TRUE TO OPT? ;

: DIS-OPT FALSE TO OPT? ;

MACROVAR
[IF]
0x20 VALUE MM_SIZE

0 VALUE OFF-EBP

0 VALUE OFF-EAX

0 VALUE :-SET

0 VALUE LAST-HERE

[THEN]

0x44 CELLS DUP CONSTANT OpBuffSize


CREATE OP0 HERE DUP , SWAP ALLOT

CELL+ DUP CONSTANT OP1
CELL+ DUP CONSTANT OP2
CELL+ DUP CONSTANT OP3
CELL+ DUP CONSTANT OP4
CELL+ DUP CONSTANT OP5
CELL+ DUP CONSTANT OP6
CELL+ DUP CONSTANT OP7
CELL+ DUP CONSTANT OP8
DROP

: SetOP ( -- )
 OP0 OP1 OpBuffSize CELL- CMOVE>
 HERE OP0 ! ;

: ToOP0 ( OPn -- )
     OP0 OpBuffSize CELL- QCMOVE ;

: ?SET HERE LAST-HERE <> IF HERE TO :-SET THEN ;

: SHORT? ( n -- -129 < n < 128 )
  0x80 + 0x100 U<
;

: EVEN-EAX OFF-EAX
   IF SetOP OFF-EAX DUP SHORT?  
     IF    0408D W, C, 
     ELSE  0808D W,  ,
     THEN   \  LEA   EAX,  OFF-EBP [EAX]
     0 TO OFF-EAX
   THEN
;

: EVEN-EBP OFF-EBP
   IF SetOP  OFF-EBP  06D8D W, C, \   LEA   ebp,  OFF-EBP [EBP]
      0 TO OFF-EBP
   THEN
;

: +>OFF-EBP ( C -- )
   C>S OFF-EBP + TO OFF-EBP ;

: ADD|XOR|OR|AND=  ( W -- FLAG )
  DUP>R  4503 =      \ ADD EAX, X2 [EBP]
      R@ 450B = OR   \  OR
      R@ 4523 = OR   \ AND
      R> 4533 = OR   \ XOR
;

: DUP3B?[EBP]  ( W -- W FLAG )

  DUP  0E7C4 AND 04500 =      \ 010X.X101 00XX.X0XX
\ ADD|OR|ADC|SBB|AND|SUB|XOR|CMP  _L | E_X | X [EBP]  , _L | E_X | X [EBP]

  OVER E7FD AND 4589 = OR  \ 010X.X101 1000.10X1
\ MOV  X [EBP], E(ABCD)X | E(ABCD)X , X [EBP]

  OVER  45DB = OR  \ FILD DWORD FC [EBP]
  OVER  EFFF AND 6DDB = OR  \ FLD | FSTP     EXTENDED 0 [EBP]
  OVER  65F7 = OR  \  MUL  X [EBP]
  OVER  6DF7 = OR  \ IMUL  X [EBP]
  OVER 04587 = OR  \ XCHG EAX , X [EBP]
;

: DUP3B?      ( W -- W FLAG )
\  11XX.X000 1000.0011
   DUP C7FF AND C083 = \ ADD|OR|ADC|SBB|AND|SUB|XOR|CMP  EAX, # X
  OVER 0478B = OR  \ MOV  EAX, X [EDI]
  OVER 0588B = OR  \ MOV  EBX, X [EAX]
  OVER 0588D = OR  \ LEA  EBX, X [EAX]
  OVER 0F8C1 = OR  \ SAR  EAX, # X
  OVER 0E0C1 = OR  \ SHL  EAX, # X
  OVER 0E8C1 = OR  \ SHR  EAX, # X
  OVER 0408D = OR  \ LEA  EAX , X [EAX]
  OVER 0408B = OR  \ MOV  EAX , X [EAX]
;

: DUP2B?      ( W -- W FLAG )

  DUP  0E4C5 AND 0C001 = 
\ ADD|OR|ADC|SBB|AND|SUB|XOR|CMP  E_X , E_X
  OVER 01801 = OR  \ ADD  [EAX],EBX
  OVER 0C0FF AND C085 = OR \ TEST E__ , E__
\ 110X.X0XX  1000.10X1   
  OVER 0E4FC AND 0C088 = OR \  MOV    E(ABCD)X , E(ABCD)X | (ABCD)L , (ABCD)L
\ 00XX.X0XX  1000.100X
  OVER 0C4FE AND 00088 = OR \  MOV  [E(ABCD)X] , E(ABCD)X | (ABCD)(HL)
  OVER 0008B = OR \ MOV EAX, [EAX]
  OVER 0C78B = OR \ MOV EAX,  EDI
  OVER 0F88B = OR \ MOV EDI,  EAX
\ 111X.X0XX  1101.00XX
  OVER E4FC AND 0E0D0 = OR \  S(AH)(LR)  (ABCD)L | E(ABCD)X,  CL | 1
  OVER 0C0DD = OR \ FFREE ST

  OVER  F0FF AND C0D9 = OR \  FLD     ST(X)  | FXCH    ST(X)
\     1100.XXXX.1101.1001
  OVER  FAFF AND E0D9 = OR \  FCHS|FABS|FTST|FXAM
\     1110.0X0X.1101.1001
  OVER  E8FF AND E8D9 =  OR \ FLD1 FLDL2T FLDL2E FLDPI FLDLG2 FLDLN2 FLDZ ???
\     1110.1XXX.1101.1001
  OVER  F0FF AND F0D9 = OR   \ F2XM1 FYL2X FPTAN FPATAN
\     1111.XXXX.1101.1001    \ FXTRACT FPREM1  FDECSTP FINCSTP
                             \ FPREM   FYL2XP1 FSQRT   FSINCOS
                             \ FRNDINT FSCALE  FSIN    FCOS

  OVER  E8FF AND 20DB = OR \  FLD     EXTENDED [E_X]  | FST  EXTENDED [E_X]
\   001X.0XXX.1101.1011

  OVER  E8FF AND 00DD = OR \  FLD    DOUBLE [E_X]  | FST  DOUBLE [E_X]
\   000X.0XXX.1101.1101

  OVER  F0FF AND C0DE = OR \  FADDP   ST(X) | FMULP   ST(X)
  OVER  E0FF AND E0DE = OR \  FSUBRP  ST(X) | FSUBP   ST(X)
\     111X.XXXX.1101.1110  \  FDIVRP  ST(X) | FDIVP   ST(X)

  OVER   00FF = OR \ INC [EAX]
\  OVER 0C0FF = OR \ INC  EAX
\  OVER 0C3FF = OR \ INC  EBX
\  OVER 0C8FF = OR \ DEC  EAX
  OVER 0D0F7 = OR \ NOT EAX
  OVER 0D8F7 = OR \ NEG EAX
  OVER 0E9F7 = OR \ IMUL ECX
  OVER 0F1F7 = OR \  DIV ECX
  OVER 0F9F7 = OR \ IDIV ECX
;
: DUP6B?      ( W -- W FLAG )
  DUP  00501 =    \ ADD  X , EAX
  OVER  0503 = OR \ ADD  EAX,  X 
  OVER  053B = OR \ CMP  EAX,  X
  OVER  873B = OR \ CMP  EAX,  X [EDI]
  OVER  C3FF AND C081 = OR \ ADD|OR|ADC|SBB|AND|SUB|XOR|CMP  EAX, # X

\ X00X.X101 1000.10X1
  OVER  67FD AND 0589 = OR  \ MOV X {[EBP]}, E(ACDB)X | E(ACDB)X , X {[EBP]}
\  OVER  0589 = OR \ MOV X , EAX
\  OVER  058B = OR \ MOV EAX,  X
  OVER  808B = OR \ MOV EAX, X [EAX]
  OVER  808D = OR \ LEA EAX, X [EAX]
  OVER  8703 = OR \ MOV EAX, X [EDI]
  OVER  878B = OR \ MOV EAX, X [EDI]
  OVER  878D = OR \ LEA EAX, X [EDI]
  OVER   0C7 = OR \ MOV [EAX], # X
  OVER  05FF = OR \ INC X


\  OVER  FCFF AND C0C7 = OR \ MOV EAX|EBX|ECX|EDX, # X
;
: DUP5B?      ( C -- C FLAG )
  DUP   0C7 AND   5 =    \  ADD|OR|ADC|SBB|AND|SUB|XOR|CMP  EAX, # X
  OVER  0FC AND 0B8 = OR \  MOV EAX|EBX|ECX|EDX, # X
  OVER  0FD AND 0A1 = OR \  MOV EAX, X  | X , EAX
;

: DUP7B?      ( N -- N FLAG )
\ XX00.0101 0000.0100 1000.10X1
  DUP  3FFFFD AND 050489 =    \  MOV   X [EAX*_] , EAX  | MOV EAX , X [EAX*_]
\ XX00.0101 0000.0100 1000.1X01
  OVER 3FFFFB AND 050489 = OR \  MOV   X [EAX*_] , EAX  | LEA EAX , X [EAX*_]

;


: DEPTH-OPT?  ( N - FLAG )  \ допустиная ли глубина для оптимизации
  :-SET + HERE  U>  ;

: ?EAX=  ( ADDR --  FALSE | TRUE )
   DUP C@
   DUP B8 =    IF  2DROP FALSE  EXIT THEN  \  MOV  EAX, # X 
   DUP A1 =    IF  2DROP FALSE  EXIT THEN  \  MOV  EAX,   X 
   DROP
   DUP W@
   DUP   C033  <>        \  XOR  EAX, EAX
   OVER  C031  <> AND    \  XOR  EAX, EAX
   OVER  C38B  <> AND    \  MOV  EAX, EBX
   OVER  D889 XOR AND    \  MOV  EAX, EBX
                0= IF 2DROP  FALSE  EXIT THEN
   DUP   458B =    IF 2DROP  FALSE  EXIT THEN  \  MOV  EAX, X [EBP]
\   DUP   058B =    IF 2DROP  FALSE  EXIT THEN  \  MOV  EAX, X 
   DUP   878B =    IF 2DROP  FALSE  EXIT THEN  \  MOV  EAX, X [EDI]
   DUP   878D =    IF 2DROP  FALSE  EXIT THEN  \  LEA  EAX, X [EDI]
   DROP
   DUP @ FFFFFF AND
   DUP   24048B =    IF 2DROP  FALSE  EXIT THEN  \  MOV  EAX,  [ESP]
   DUP   24448B =    IF 2DROP  FALSE  EXIT THEN  \  MOV  EAX, X [ESP]
   DUP   24878B =    IF 2DROP  FALSE  EXIT THEN  \  MOV  EAX, X [EDI]
   DUP   24448D =    IF 2DROP  FALSE  EXIT THEN  \  LEA  EAX, X [ESP]
   2DROP  TRUE
;
\   DUP   8B00 =     \  MOV  EAX, [EAX]

: ?2EAX ( -- )
        OP0 @ ?EAX=
        IF OP0 @ C@ 58 ( POP EAX ) <> IF EXIT THEN
        THEN
        OP1 @ ?EAX= IF EXIT THEN
        OP1 @ OP0 @ - ALLOT
        OP0 @ 2@ OP1 @ 2!
        OP1 ToOP0
;
 TRUE VALUE ?C-JMP
\ FALSE VALUE ?C-JMP
\ $ - указывает на фрагмент исходного текста, оптимизируемый
\ данным методом
: OPT-STEP  ( ADDR  -- ADDR' FLAG )

   OP0 @ :-SET U< IF TRUE EXIT THEN

   OP0 @  W@ 408D =  \  LEA   EAX,  X [EAX]
   IF  OP0 @ 2+ C@ C>S OFF-EAX + TO OFF-EAX
       OP1 ToOP0
       FALSE  -3 ALLOT EXIT
   THEN

   OP0 @ C@ 05 =    \ ADD  EAX, # X
   IF  OP0 @ 1+ @ OFF-EAX + TO OFF-EAX
       OP1 ToOP0
       FALSE  -5 ALLOT EXIT
   THEN

   OP0 @  W@ 408D =  \  LEA   EAX,  X [EAX]
   IF  OP0 @ 2+ @ OFF-EAX + TO OFF-EAX
       OP1 ToOP0
       FALSE  -6 ALLOT EXIT
   THEN

   OP0 @ @ 3FFFFF AND
   05048D =      \ LEA  EAX, X [EAX*_]
   IF

\ $ 4444 CELLS

      OP1 @ :-SET U< 0=
      IF   OP1 @ C@ B8 XOR     \ MOV EAX, # X1
           OP0 @ 3 + @         \ X=0
           OR 0=
           IF  OP1 @ 1+ @   OP0 @ @ C00000 AND 16 RSHIFT
               LSHIFT
               OP1 @ 1+ !
               OP2 ToOP0
               FALSE  -7 ALLOT EXIT
           THEN
      THEN

\ $ CELLS 4444 +

       OFF-EAX OP0 @ 3 + +!
       0 TO OFF-EAX

   THEN

   OP0 @  C@ B8 =    \ MOV  EAX, # X
   IF  OFF-EAX OP0 @ 1+ +!
       0 TO OFF-EAX
       OP0 @ 1+ @ 0=         \ MOV  EAX, # 0
       IF  C033 OP0 @  W!    \ XOR EAX, EAX
           -3 ALLOT
\           FALSE   EXIT
       THEN
   THEN


   OP1 @ :-SET U< IF TRUE EXIT THEN

     ?2EAX

   ?C-JMP

   IF     OP0 @  C@ C3 XOR  
          OP1 @  C@ E8 XOR OR 0=    \ CALL X   RET
          IF 
             OP1 @ 1+!
             OP1 ToOP0
             FALSE  -1 ALLOT EXIT 
          THEN
   THEN


 \ CELLS 444 + @
   OP1 @  W@ 38FF AND 008D XOR \ LEA EAX , ____
   OP0 @  W@ 008B XOR  OR 0=   \ MOV EAX , [EAX]
   IF 8B OP1 @ C!
      OP1 ToOP0
      FALSE  -2 ALLOT EXIT  
   THEN

   OP0 @  W@ 4589  XOR  \  MOV  X [EBP], EAX
   OP0 @ 2+ C@
   OP1 @ 2+ C@     XOR OR 0=   \  (FALG &( X1=X ))
    IF
          OP1 @    W@ 458B =   \  MOV  EAX, 1X [EBP] \ $ DROP DUP
          IF   OP1 ToOP0
               FALSE  -3 ALLOT EXIT
          THEN
          OP1 @     W@ ADD|XOR|OR|AND=  \ переворот для дальнейшего
                                        \ удобства оптимизировать
          IF   OP1 @ C@ 2 XOR 
               OP1 @ C!       \ ADD  X [EBP], EAX
            8B OP0 @ C!       \ MOV  EAX, X [EBP]
               FALSE  EXIT
          THEN
    THEN

    OP1 @  C@ B8 =              \ MOV  EAX, # X
    IF  OP0 @  W@
          DUP   D8F7   =   \ NEG EAX
       IF DROP
          OP1 @ 1+ @ NEGATE OP1 @ 1+ !   \  MOV EAX, # -X
          OP1 ToOP0
          FALSE -2 ALLOT EXIT
       THEN
          DUP   D0F7   =   \ NOT EAX
       IF DROP
          OP1 @ 1+ @ INVERT OP1 @ 1+ !   \  MOV EAX, # ~X
          OP1 ToOP0
          FALSE -2 ALLOT EXIT
       THEN
          DUP    008B   =   \ MOV EAX, [EAX]
       IF DROP
          A1 OP1 @ C!   \  MOV EAX, X
          OP1 ToOP0
          FALSE -2 ALLOT EXIT
       THEN

         DROP
    THEN

   OP2 @ :-SET U< IF TRUE EXIT THEN

   OP0 @ C@ 58 XOR
   OP0 @ ?EAX= AND 0=
   IF  OP1 @  C@ 50 =   \ PUSH EAX
     IF
     \  444 >R 
       OP2 @  C@ B8 = \ MOV EAX , # 5
       IF      68 OP2 @ C!
             OP0 @ 2@ OP1 @ 2!
             OP1 ToOP0
           FALSE  -1 ALLOT EXIT  
       THEN
     THEN
     OP1 @  W@ 4589 =   \ MOV X [EBP], EAX
     IF
     \    444 555
       OP2 @  C@ B8 =  \ MOV EAX ,  5
       IF    OP2 @ 1+ @
                   45C7   OP2 @    W!
              OP1 @ 2+ C@ OP2 @ 2+ C!
                          OP2 @ 3 + !
             2 OP1  +!
             OP0 @ 2@ OP1 @ 2!
             OP1 ToOP0
           FALSE  -1 ALLOT EXIT  
       THEN
     THEN
   THEN

\ $ DUP >R
   OP2 @  W@ 4589 XOR           \  MOV     X2 [EBP] , EAX
   OP1 @  C@ 50   XOR       OR  \  PUSH    EAX
   OP0 @  W@ 458B XOR       OR  \  MOV     EAX , X0 [EBP]
   OP2 @  2+ C@ OP0 @  2+  C@ XOR OR 0=  \   X2=X0
     IF 50 OP2 @ C!
        OP2 ToOP0
        -6 ALLOT 
        FALSE EXIT
     THEN
\ $ - -
   OP2 @  @  4503D8F7 XOR           \  NEG EAX  ADD EAX, X [EBP] 
   OP0 @  W@ D8F7     XOR    OR 0=  \ NEG EAX 
     IF  OP1 @ @ 452B OR OP2 @ ! \  SUB EAX, X [EBP] 
         OP2 ToOP0
         -4 ALLOT 
         FALSE EXIT
     THEN


 OP0 @ W@  ADD|XOR|OR|AND= INVERT      \ $  4444  OR
 OP2 @ W@    4589 XOR OR  \ MOV X1 [EBP], EAX
 OP2 @ 2+ C@
 OP0 @ 2+ C@      XOR OR 0=
    IF  OP1 @ W@ 
        DUP  0878B =       \ MOV EAX, X [EDI] 
             IF  DROP
                 OP0 @ C@ 8700 + OP2 @ W!
                 OP1 @ 2+ @ OP2 @ 2+ !
                 OP2 ToOP0
                 FALSE -6 ALLOT EXIT   
             THEN
        FF AND
        DUP  0B8 =       \ MOV EAX, # X
             IF  DROP
                 OP0 @ C@ 2+ OP2 @ C!
                 OP1 @ 1+ @ OP2 @ 1+ !
                 OP2 ToOP0
                 FALSE -6 ALLOT EXIT   
             THEN
        DUP  0A1 =       \ MOV EAX,  X
             IF  DROP
                 OP0 @ C@ 500 + OP2 @ W!
                 OP1 @ 1+ @ OP2 @ 2+ !
                 OP2 ToOP0
                 FALSE -5 ALLOT EXIT   
             THEN
        DROP
    THEN

    OP0 @ W@   4539   =
    IF 
         OP1 @ C@   0B8 XOR      \ MOV EAX, # X
         OP2 @ W@  4589 XOR OR   \ MOV X1 [EBP], EAX
         OP2 @ 2+ C@
         OP0 @ 2+ C@    XOR OR 0= 
         IF  3D OP2 @ C!
             OP1 @ 1+ @ OP2 @ 1+ !
             OP2 ToOP0
             FALSE -6 ALLOT EXIT
         THEN     
\ $  4444 @ U<
         OP1 @ C@   0A1 XOR      \ MOV EAX, # X
         OP2 @ W@  4589 XOR OR   \ MOV X1 [EBP], EAX
         OP2 @ 2+ C@
         OP0 @ 2+ C@    XOR OR 0= 
         IF  053B OP2 @ W!
             OP1 @ 1+ @ OP2 @ 2+ !
             OP2 ToOP0
             FALSE -5 ALLOT EXIT
         THEN     

    THEN

   OP3 @ :-SET U< IF TRUE EXIT THEN

    OP1 @ W@   453B   =
    IF OP0 @ @ FFFCFF AND C09C0F =  \ SETLE   AL 
      IF
\ $  4444  <
         OP2 @ C@   0B8 XOR      \ MOV EAX, # X
         OP3 @ W@  4589 XOR OR   \ MOV X1 [EBP], EAX
         OP3 @ 2+ C@
         OP1 @ 2+ C@    XOR OR 0= 
         IF  3D OP3 @ C!
             OP2 @ 1+ @ OP3 @ 1+ !
             2 OP2 +!
             OP0 @ @ 300 XOR  OP2 @ !     \  SETGE   AL 
             OP2 ToOP0
             FALSE -6 ALLOT EXIT
         THEN     
\ $  4444 @ <
         OP2 @ C@   0A1 XOR      \ MOV EAX, # X
         OP3 @ W@  4589 XOR OR   \ MOV X1 [EBP], EAX
         OP3 @ 2+ C@
         OP1 @ 2+ C@    XOR OR 0= 
         IF  053B OP3 @ W!
             OP2 @ 1+ @ OP3 @ 2+ !
             3 OP2 +!
             OP0 @ @ 300 XOR  OP2 @ !     \  SETGE   AL 
             OP2 ToOP0
             FALSE -5 ALLOT EXIT
         THEN     
       THEN
    THEN


   OP0 @ W@ 1889 XOR           \ MOV     [EAX] , EBX
   OP1 @ W@ 5D8B XOR OR 0=     \ MOV     EBX , X [EBP] \ !?
    IF
\ $  44444 !  
          OP3 @ W@  4589 XOR    \  MOV     X [EBP] , EAX
          OP3 @ 2+ C@
          OP1 @ 2+ C@    XOR OR
          OP2 @ C@ B8    XOR OR 0=
          IF  A3  OP3 @ C!
              OP2 @ 1+ @  OP3 @ 1+ !
              OP3 ToOP0
              FALSE -8 ALLOT EXIT   
          THEN

    THEN

   OP4 @ :-SET U< IF TRUE EXIT THEN

\ $ 10 LSHIFT
    OP4 @ W@ 4589     XOR      \ MOV X0 [EBP] , EAX
    OP3 @ C@ B8       XOR OR   \ MOV EAX, # 10
    OP2 @  @ 458BC88B XOR OR   \ MOV ECX, EAX \ !? MOV EAX, X2 [EBP]
    OP0 @ W@ F7FF AND E0D3  XOR OR  \  SHL|SHR    EAX , CL
    OP4 @ 2+ C@ OP1 @ 2+ C@ XOR OR  \  X0=X2
    0=
    IF  OP0 @ W@ 0012 - OP4 @ W!
        OP3 @ 1+ @ OP4 @ 2+ C!      
        OP4 ToOP0
        FALSE -C ALLOT EXIT   
    THEN

    TRUE

;

:  ?BR-OPT-STP

   OP0 @ :-SET U< IF TRUE EXIT THEN


   OP0 @ W@  408D =  \  LEA   EAX,  X [EAX]
   IF C083  OP0 @ W!     \  ADD  EAX, # X
      TRUE  EXIT
   THEN
   OP0 @ W@  808D =  \  LEA   EAX,  X [EAX]
   IF 05 OP0 @ C!
      OP0 @ 2+ @ OP0 @ 1+ !   \  ADD  EAX, # X
      TRUE  -1 ALLOT EXIT
   THEN

   OP1 @ :-SET U< IF TRUE EXIT THEN
\ $       0<> IF
        OP1 @ @  C01BD8F7 = \   NEG  EAX  \  SBB  EAX, EAX
        IF   OP2 ToOP0
\            084 TO J_COD
             FALSE  -4 ALLOT EXIT
        THEN
\ $       0= IF
        OP1 @  @  1B01E883 XOR
        OP0 @ W@      C01B XOR OR 0=
        IF  OP2 ToOP0
            J_COD 1 XOR TO J_COD
            FALSE  -5 ALLOT EXIT
        THEN

 \ $  U< IF
        OP1 @  C@  3D  <> 
        OP1 @  W@ 053B <> AND
        OP1 @   @ FFFD AND 
                  4539 XOR  AND
        OP0 @ W@  C01B XOR   OR 0=
        IF  OP1 ToOP0
            83 J_COD 1 AND XOR  TO J_COD
            TRUE  -2 ALLOT EXIT
        THEN
\   TRUE EXIT
   OP3 @ :-SET U< IF TRUE EXIT THEN

\ $  < IF
        OP2 @ @ FFFFFCFF AND  83C09C0F XOR
        OP1 @ @  4801E083 XOR OR 0=
        IF  OP2 @ 1+ C@ 10 - J_COD 1 AND XOR TO J_COD
            OP3 ToOP0
            TRUE  -7 ALLOT EXIT
        THEN

        TRUE

;
: ?BR-OPT
     OP1 ToOP0  -2 ALLOT   \ ликвидация OR EAX, EAX
     BEGIN ?BR-OPT-STP
     UNTIL

        OP0 @ C@  
        \ 00XX.X101
        DUP   C7 AND 05 <>  \  ADD|OR|ADC|SBB|AND|SUB|XOR|CMP EAX, # X
\       OVER  3D <> AND   \ ~ CMP EAX, # X
        OVER  40 <> AND   \ DEC     EAX
        OVER  48 <> AND   \ INC     EAX
        NIP
        OP0 @  W@
        DUP  4000  OR  ADD|XOR|OR|AND= INVERT
        OVER C01B  <> AND  \ SBB EAX, EAX
        OVER 4539  <> AND  \ CMP X [EBP], EAX
        OVER 453B  <> AND  \ CMP EAX , X [EBP]
        OVER 053B  <> AND  \ CMP EAX , X
        OVER C20B XOR AND  \  OR EAX , EDX
        NIP AND
        IF    SetOP 0xC00B W,    \ OR EAX, EAX
        THEN

;

: OPT_  ( -- )
  BEGIN OPT-STEP UNTIL  EVEN-EAX
 ;

: DO_OPT   ( ADDR -- ADDR' )
  OPT? IF OPT_ THEN ;

: MACRO?  ( CFA -- CFA FLAG )
  DUP         BEGIN
  2DUP
  MM_SIZE -   U< IF  DROP FALSE  EXIT THEN
  DUP C@      \  CFA CFA+OFF N'
  DUP   0C3    = IF 2DROP  TRUE  EXIT THEN  \ RET
  DUP5B?         M_WL DROP 5 + REPEAT
\ 0100.X0XX
  DUP   0F4
  AND    40    = M_WL DROP 1+  REPEAT \ INC|DEC  E(ACDB)X

  DUP   099    = M_WL DROP 1+  REPEAT  \ CDQ
\ 1110.11XX
\ DUP FC
\ AND    EC    = M_WL DROP 1+  REPEAT  \ IN|OUT  EAX AL, DX | DX, EAX EL
  DROP
  DUP W@      \  CFA CFA+OFF N'

  DUP3B?[EBP]    M_WL DROP 3 +  REPEAT
  DUP3B?         M_WL DROP 3 +  REPEAT
  DUP 06D8D    = M_WL DROP 3 +  REPEAT \ LEA  EBP, OFF-EBP [EBP]
  DUP 0C583    = M_WL DROP 3 +  REPEAT \ ADD  EBP, # OFF-EBP
  DUP 0ED83    = M_WL DROP 3 +  REPEAT \ SUB  EBP, # X
  DUP2B?         M_WL DROP 2 +  REPEAT
  DUP  C58B    = M_WL DROP 2 +  REPEAT \ MOV EAX,  EBP

\  DUP 0E3FF   = M_WL DROP 2 +  REPEAT   \ JMP  EBX
  DUP6B?         M_WL DROP 6 +  REPEAT
  DUP 45C7  =   M_WL  DROP 7 +  REPEAT  \ MOV     X [EBP] , # X

  DROP
  DUP @
  DUP 0424448B = M_WL DROP 4 + REPEAT
  FFFFFF AND
  DUP   C09D0F = M_WL DROP 3 + REPEAT \ SETGE  AL
  DUP   C09E0F = M_WL DROP 3 + REPEAT \ SETLE  AL

\ CMPXCHG [EAX] , AL| EAX
\ LSS     EAX , [EAX]
\ BTR     [EAX] , EAX
\ LFS     EAX , [EAX]
\ LGS     EAX , [EAX]
\ MOVZX   EAX , BYTE|WORD  PTR [EAX]
\ 0000.0000 1011.1XXX 0000.1111
  DUP FFF8FF 
  AND 00B00F = M_WL DROP 3 + REPEAT \ MOVZX  EAX, WORD PTR [EAX]

  DUP 85448B = M_WL DROP 4 + REPEAT \ MOV    EAX, X [EBP] [EAX*4]

\ XX00.0101 0000.0100 1000.1XX1
  DUP7B?       WHILE DROP 7 + REPEAT
 2DROP  FALSE
;

\  МАКРОПОДСТАНОВЩИК

: +EBP DUP C@ C>S OFF-EBP + C,    1+ ;

: 1_,_STEP SetOP DROP DUP C@ C,    1+ ;

: 2_,_STEP SetOP DROP DUP W@ W,    2+ ;

: 3_,_STEP  2_,_STEP DUP C@ C,    1+ ;

: 4_,_STEP_           DUP @  , CELL+ ;

: 4_,_STEP SetOP DROP 4_,_STEP_ ;

: 5_,_STEP  1_,_STEP 4_,_STEP_ ;

: 6_,_STEP  2_,_STEP 4_,_STEP_ ;

: 7_,_STEP  3_,_STEP 4_,_STEP_ ;

: 1A_,_STEP 1_,_STEP DUP @ + HERE - , CELL+ ;

: 2A_,_STEP 2_,_STEP DUP @ + HERE - , CELL+ ;

: _MACRO,  (  CFA  --  )
\  ." ^" DUP H.
              BEGIN
  DO_OPT

  DUP C@      \  CFA  N'
  DUP   0C3 = IF 2DROP     EXIT THEN  \ RET

  DUP5B?      M_WL  5_,_STEP  REPEAT \ ADD EAX, # X

\ 010X.XXXX
  DUP E0 AND 40 = M_WL 1_,_STEP REPEAT  \ INC|DEC|PUSH|POP  E_X

\ FS: GS: D16: A16: INSB INSD OUTSB OUTSD
\ 0110.X1XX
  DUP   F4 AND 64 = M_WL  1_,_STEP      REPEAT

  DUP   099 = M_WL  1_,_STEP      REPEAT  \ CDQ

\  DUP   0BB = M_WL  5_,_STEP     REPEAT  \ MOV EBX, # X
\  JO JNO JB JAE JE JNE JBE JA JS JNS JP JNP JL JGE JLE JG
\ 0111.XXXX
  DUP  F0 AND 70 = M_WL  2_,_STEP     REPEAT

  DUP   0E9 = M_WL 1A_,_STEP      REPEAT  \  JMP
  DROP
  DUP W@
  DUP3B?[EBP]  M_WL  2_,_STEP +EBP REPEAT
  DUP3B?       M_WL  3_,_STEP      REPEAT
  DUP2B?       M_WL  2_,_STEP      REPEAT
  DUP 0C48B =  M_WL  2_,_STEP   REPEAT  \ MOV EAX , ESP
  DUP  C58B =  M_WL EVEN-EBP 2_,_STEP   REPEAT  \ MOV EAX,  EBP

  DUP 06D8D = M_WL DROP DUP 2 + C@ +>OFF-EBP
                     3 + REPEAT  \ LEA  EBP, OFF-EBP [EBP]

  DUP 0C583 = M_WL DROP DUP 2 + C@ +>OFF-EBP
                     3 + REPEAT  \ ADD  EBP, # OFF-EBP

  DUP 0ED83 = M_WL DROP DUP 2 + C@ C>S NEGATE +>OFF-EBP
                     3 + REPEAT  \ SUB  EBP, # OFF-EBP

  DUP 0C483 = M_WL  3_,_STEP     REPEAT  \ ADD  ESP, # X
  DUP6B?      M_WL  6_,_STEP      REPEAT  \ MOV  EAX,  # X
  DUP 0E3FF = M_WL EVEN-EBP 2_,_STEP REPEAT  \ JMP  EBX
  DUP 0D3FF = M_WL EVEN-EBP 2_,_STEP REPEAT  \ CALL EBX
  DUP 810F  = M_WL 2A_,_STEP      REPEAT  \ JO [ESP]
  DUP 45C7  = M_WL 2_,_STEP +EBP 4_,_STEP_  REPEAT  \ MOV     X [EBP] , # X
  DROP
  DUP @
  DUP 0424448B = M_WL DROP   SetOP       \  MOV  EAX, 4 [ESP]
                    8B C, 04 C, 24 C,    \  MOV  EAX,   [ESP]
                    4 +
                 REPEAT

  FFFFFF AND
  DUP 240401 = M_WL 3_,_STEP      REPEAT \ ADD [ESP] , EAX
  DUP C09D0F = M_WL 3_,_STEP      REPEAT \ SETGE  AL
  DUP C09E0F = M_WL 3_,_STEP      REPEAT \ SETLE  AL

\ CMPXCHG [EAX] , AL| EAX
\ LSS     EAX , [EAX]
\ BTR     [EAX] , EAX
\ LFS     EAX , [EAX]
\ LGS     EAX , [EAX]
\ MOVZX   EAX , BYTE|WORD  PTR [EAX]
\ 0000.0000 1011.1XXX 0000.1111
  DUP FFF8FF
  AND 00B00F = M_WL 3_,_STEP      REPEAT
  DUP 24442B = M_WL 4_,_STEP      REPEAT \ SUB  EAX, X [ESP]
  DUP 85448B = M_WL 3_,_STEP +EBP REPEAT \ MOV  EAX, X [EBP] [EAX*4]
  DUP 24048B = M_WL 3_,_STEP      REPEAT \ MOV  EAX, 0 [ESP]
  DUP 85048D = M_WL 7_,_STEP      REPEAT \ LEA  EAX, X [EAX*4]
  DUP 45048D = M_WL 7_,_STEP      REPEAT \ LEA  EAX, X [EAX*2]
  DUP 2404FF = M_WL 3_,_STEP      REPEAT \ INC [ESP]
  DUP 18B60F = M_WL 3_,_STEP      REPEAT \ MOVZX EBX, BYTE PTR [EAX]
  DUP7B?      WHILE 7_,_STEP      REPEAT
 ." @COD, ERROR" ABORT
;

: -EVEN-EBP
     OP0 @ :-SET U< IF EXIT THEN
     OP0 @ W@ 06D8D =  \  LEA   ebp,  OFF-EBP [EBP]
     IF  OP0 @ 2+ C@ +>OFF-EBP
         OP1 ToOP0
        -3 ALLOT EXIT
     THEN ;


: OPT_CLOSE
   EVEN-EBP HERE TO LAST-HERE ;

:  OPT_INIT   ?SET -EVEN-EBP  ;

:  MACRO, ( CFA --  )   OPT_INIT  _MACRO, OPT_CLOSE ;

: OPT   ( -- )
  ['] NOOP DO_OPT DROP  ;

: FORLIT, ( N -- )
  'DUP _MACRO, SetOP 0B8 C, , OPT ;

: CON>LIT ( CFA -- CFA TRUE | FALSE )    

                 DUP C@ 0E8 <> IF TRUE EXIT THEN
                 
                 DUP 1+  REL@ CELL+ 
                 DUP   CREATE-CODE  = 
                 IF  DROP OPT_INIT 5 +  FORLIT, FALSE OPT_CLOSE EXIT
                 THEN
                 
                 DUP     USER-CODE  =
                 IF  DROP  OPT_INIT 'DUP _MACRO,
                   SetOP  878D W, 5 + @ , OPT   FALSE  OPT_CLOSE  EXIT
                 THEN

                 DUP     USER-VALUE-CODE  =
                 IF  DROP  OPT_INIT 'DUP _MACRO,
                   SetOP  878B W, 5 + @ , OPT   FALSE  OPT_CLOSE  EXIT
                 THEN

                 DUP  CONSTANT-CODE  =
                 IF  DROP  OPT_INIT 5 + DUP 5 +  REL@ 
                     TOVALUE-CODE CELL- =
                    IF      FORLIT, SetOP  008B ( @ ) W, OPT
                    ELSE    @  FORLIT, 
                    THEN   FALSE  OPT_CLOSE  EXIT
                 THEN
                 DUP 1+ REL@ CELL+ DOES-CODE =
                 IF  5 +         \ CFA
                     SWAP 5 + OPT_INIT FORLIT, 
                     TRUE     OPT_CLOSE EXIT
                 THEN
                 DUP  TOUSER-VALUE-CODE =
                 IF  DROP  OPT_INIT
                     SetOP  8789 W, CELL- @ , OPT 
                     'DROP _MACRO,
                     FALSE  OPT_CLOSE  EXIT
                 THEN
                  TOVALUE-CODE =
                 IF    OPT_INIT
                     SetOP  A3 C,  CELL-  ,   OPT
                     'DROP _MACRO,
                     FALSE  OPT_CLOSE  EXIT
                 THEN

  TRUE
;

BASE !

