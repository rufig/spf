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

: DIS-OPT FALSE TO OPT? ;

INLINEVAR
[IF]
0x20 VALUE MM_SIZE

0 VALUE OFF-EBP

0 VALUE OFF-EAX

0 VALUE :-SET

0 VALUE J-SET

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
 DP @ OP0 ! ;

: ToOP0 ( OPn -- )
     OP0 OpBuffSize CELL- QCMOVE ;

0x11 CELLS DUP CONSTANT JpBuffSize

CREATE JP0 HERE DUP , OVER ALLOT

DUP ROT ERASE 

CELL+ DUP CONSTANT JP1
CELL+ DUP CONSTANT JP2
CELL+ DUP CONSTANT JP3
CELL+ DUP CONSTANT JP4
DROP

: ClearJpBuff JP0 JpBuffSize ERASE ;

:  J@ 1+   REL@    CELL+ ;
: SJ@ 1+ DUP C@ C>S + 1+ ;

: J_@
        DUP C@ F0 
           AND 70 = IF   SJ@ ELSE
        DUP C@ EB = IF   SJ@ ELSE
        DUP C@ E9 = IF    J@ ELSE
        DUP W@ F0FF
         AND 800F = IF 1+ J@ ELSE
        HEX U. 1 ." J_@ ERR" ABORT
        THEN  THEN THEN THEN  
;

: SetJP ( -- )
 JP0 JpBuffSize + CELL- @ DUP  
 IF J_@
 THEN
 J-SET UMAX TO J-SET
 JP0 JP1 JpBuffSize CELL- CMOVE>
 DP @ JP0 ! ;

\ : ToJP0 ( OPn -- )
\     JP0 JpBuffSize CELL- QCMOVE
\ JP0 JpBuffSize + CELL- 0!  ;

: ?SET DP @ LAST-HERE <> IF DP @ DUP TO :-SET TO J-SET THEN ;

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
  DUP 4503 <> IF   \ ADD EAX, X2 [EBP]
  DUP 450B <> IF   \  OR
  DUP 4523 <> IF   \ AND
  DUP 4533 <> IF   \ XOR
   DROP FALSE EXIT
  THEN THEN THEN THEN
   DROP TRUE
;

: DUP3B?[EBP]  ( W -- W FLAG )

  DUP 0E7C4 AND 04500 <> IF      \ 010X.X101 00XX.X0XX
\ ADD|OR|ADC|SBB|AND|SUB|XOR|CMP  _L | E_X | X [EBP]  , _L | E_X | X [EBP]

  DUP  E7FD AND  4589 <> IF  \ 010X.X101 1000.10X1
\ MOV  X [EBP], E(ABCD)X | E(ABCD)X , X [EBP]
\   DUP           5503 <> IF \ ADD   EDX , 0 [EBP]

  DUP  EFFF AND  6DDB <> IF  \ FLD | FSTP     EXTENDED 0 [EBP]

  DUP            45DB <> IF  \ FILD DWORD FC [EBP]
  DUP            65F7 <> IF  \  MUL  X [EBP]
  DUP            6DF7 <> IF  \ IMUL  X [EBP]
  DUP           04587 <> IF  \ XCHG EAX , X [EBP]
  FALSE EXIT
  THEN THEN THEN  THEN THEN THEN THEN  
  TRUE
;

: DUP3B?      ( W -- W FLAG )
\  11XX.X000 1000.0011
   DUP C7FF AND  C083 <> IF \ ADD|OR|ADC|SBB|AND|SUB|XOR|CMP  EAX, # X
   DUP          0478B <> IF \ MOV  EAX, X [EDI]
   DUP          0588B <> IF \ MOV  EBX, X [EAX]
   DUP          0508B <> IF \ MOV  EDX, X [EAX]

   DUP          0588D <> IF \ LEA  EBX, X [EAX]
   DUP          0508D <> IF \ LEA  EDX, X [EAX]

   DUP          0F8C1 <> IF \ SAR  EAX, # X
   DUP          0E0C1 <> IF \ SHL  EAX, # X

   DUP          0E8C1 <> IF \ SHR  EAX, # X
   DUP          0408D <> IF \ LEA  EAX , X [EAX]
   DUP          0408B <> IF \ MOV  EAX , X [EAX]
  FALSE EXIT
  THEN THEN THEN  THEN THEN 
  THEN THEN
  THEN THEN THEN THEN 
  TRUE
;

: DUP2B?      ( W -- W FLAG )

  DUP 0E4C5 AND 0C001 <> IF
\ ADD|OR|ADC|SBB|AND|SUB|XOR|CMP  E_X , E_X

\  DUP           01801 <> IF  \ ADD  [EAX], EBX 
 
  DUP           01001 <> IF  \ ADD  [EAX], EDX 

  DUP 0C0FF AND  C085 <> IF \ TEST E__ , E__

\ 110X.X0XX  1000.10X1   
  DUP 0E4FC AND 0C088 <> IF \  MOV    E(ABCD)X , E(ABCD)X | (ABCD)L , (ABCD)L

\ 00XX.X0XX  1000.100X

  DUP 0C4FE AND 00088 <> IF \  MOV  [E(ABCD)X] , E(ABCD)X | (ABCD)(HL)
  DUP           0008B <> IF \ MOV EAX, [EAX]
  DUP           0C78B <> IF \ MOV EAX,  EDI
  DUP           0F88B <> IF \ MOV EDI,  EAX
\ 111X.X0XX  1101.00XX
  DUP 0E4FC AND 0E0D0 <> IF \  S(AH)(LR)  (ABCD)L | E(ABCD)X,  CL | 1
  DUP           0C0DD <> IF \ FFREE ST

  DUP  F0FF AND  C0D9 <> IF \  FLD     ST(X)  | FXCH    ST(X)
\     1100.XXXX.1101.1001

  DUP  FAFF AND  E0D9 <> IF \  FCHS|FABS|FTST|FXAM
\     1110.0X0X.1101.1001
  DUP  E8FF AND  E8D9 <> IF \ FLD1 FLDL2T FLDL2E FLDPI FLDLG2 FLDLN2 FLDZ ???
\     1110.1XXX.1101.1001

  DUP  F0FF AND  F0D9 <> IF   \ F2XM1 FYL2X FPTAN FPATAN
\     1111.XXXX.1101.1001    \ FXTRACT FPREM1  FDECSTP FINCSTP
                             \ FPREM   FYL2XP1 FSQRT   FSINCOS
                             \ FRNDINT FSCALE  FSIN    FCOS
  DUP  E8FF AND  20DB <> IF \  FLD     EXTENDED [E_X]  | FST  EXTENDED [E_X]
\   001X.0XXX.1101.1011

  DUP  E8FF AND  00DD <> IF \  FLD    DOUBLE [E_X]  | FST  DOUBLE [E_X]
\   000X.0XXX.1101.1101

  DUP  F0FF AND  C0DE <> IF \  FADDP   ST(X) | FMULP   ST(X)
  DUP  E0FF AND  E0DE <> IF \  FSUBRP  ST(X) | FSUBP   ST(X)
\     111X.XXXX.1101.1110  \  FDIVRP  ST(X) | FDIVP   ST(X)

  DUP            00FF <> IF \ INC [EAX]
\   DUP 0C0FF <> IF \ INC  EAX
\   DUP 0C3FF <> IF \ INC  EBX
\   DUP 0C8FF <> IF \ DEC  EAX
  DUP           0D0F7 <> IF \ NOT EAX
  DUP           0D8F7 <> IF \ NEG EAX
  DUP           0DAF7 <> IF \ NEG EDX
  DUP           0E9F7 <> IF \ IMUL ECX
  DUP           0F1F7 <> IF \  DIV ECX
  DUP           0F9F7 <> IF \ IDIV ECX
  FALSE EXIT
  THEN THEN THEN THEN THEN THEN
  THEN THEN THEN THEN THEN 

  THEN THEN THEN THEN THEN
  THEN THEN THEN THEN THEN 

  THEN THEN THEN THEN

  TRUE
;


: DUP6B?      ( W -- W FLAG )

\ X00X.X101 1000.10X1
  DUP   67FD AND 0589 <> IF  \ MOV X {[EBP]}, E(ACDB)X | E(ACDB)X , X {[EBP]}

  DUP   C3FF AND C081 <> IF \ ADD|OR|ADC|SBB|AND|SUB|XOR|CMP  EAX, # X

  DUP           00501 <> IF    \ ADD  X , EAX
  DUP            0503 <> IF \ ADD  EAX,  X 
  DUP            053B <> IF \ CMP  EAX,  X
  DUP            873B <> IF \ CMP  EAX,  X [EDI]
  DUP            F281 <> IF \ XOR  EDX , # 80000000
  DUP            928D <> IF \ LEA  EDX , [EDX+80000000H]

\  DUP   0589 <> IF \ MOV X , EAX
\  DUP   058B <> IF \ MOV EAX,  X
  DUP            808B <> IF \ MOV EAX, X [EAX]
  DUP            808D <> IF \ LEA EAX, X [EAX]
  DUP            8703 <> IF \ MOV EAX, X [EDI]

  DUP            878B <> IF \ MOV EAX, X [EDI]
  DUP            878D <> IF \ LEA EAX, X [EDI]
  DUP             0C7 <> IF \ MOV [EAX], # X
  DUP            05FF <> IF \ INC X

\  DUP  FCFF AND C0C7 <> IF \ MOV EAX|EBX|ECX|EDX, # X
  FALSE EXIT
  THEN THEN THEN THEN
  THEN THEN THEN
  THEN THEN THEN THEN THEN THEN
  THEN THEN
  TRUE
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
  :-SET + DP @  U>  ;

: ?EAX=  ( ADDR --  FALSE | TRUE )
   DUP C@
   DUP       B8 <> IF   \  MOV  EAX, # X 
   DUP       A1 <> IF   \  MOV  EAX,   X 
   DROP
   DUP W@
   DUP     C033 <> IF   \  XOR  EAX, EAX
   DUP     C031 <> IF   \  XOR  EAX, EAX
   DUP     C38B <> IF   \  MOV  EAX, EBX
   DUP     C28B <> IF   \  MOV  EAX, EDX
   DUP     D889 <> IF   \  MOV  EAX, EBX
   DUP     458B <> IF   \  MOV  EAX, X [EBP]
\   DUP     058B <>  IF   \  MOV  EAX, X 
   DUP     878B <> IF   \  MOV  EAX, X [EDI]
   DUP     878D <> IF   \  LEA  EAX, X [EDI]
   DROP
   DUP @ FFFFFF AND

   DUP   24048B <> IF   \  MOV  EAX,   [ESP]
   DUP   24448B <> IF   \  MOV  EAX, X [ESP]
   DUP   24878B <> IF   \  MOV  EAX, X [EDI]
   DUP   24448D <> IF   \  LEA  EAX, X [ESP]

   2DROP  TRUE EXIT
  THEN THEN THEN THEN
  THEN THEN 
  THEN THEN THEN THEN THEN THEN
  THEN THEN 
  2DROP FALSE
;

\   DUP   8B00 =     \  MOV  EAX, [EAX]
M\ VECT DTST

: ?2EAX ( -- )
        OP0 @ ?EAX=
        IF OP0 @ C@ 58 ( POP EAX ) <> IF EXIT THEN
        THEN
        OP1 @ ?EAX= IF EXIT THEN
        M\  0 DTST
        OP1 @ OP0 @ - ALLOT
        OP0 @ 2@ OP1 @ 2!
        OP1 ToOP0  M\ 1 DTST
;

: OP_SIZE ( OP - n )
  DUP IF THEN  DUP CELL- @ SWAP @ -
;

: OPexcise ( OPX -- )
      >R
      R@ CELL- @ R@ @  DP @ R@ CELL- @ - CMOVE

      R@ OP_SIZE NEGATE
      R@ OP0 DO DUP I +! CELL +LOOP 
      ALLOT
      
      R@ CELL+ R@ OpBuffSize CELL- R> - OP0 + QCMOVE
;

: XX_STEP ( OPX -- OPX+CELL FALSE | { OPX | FALSE } TRUE )
     DUP CELL+ OP0 OpBuffSize + U> IF DROP FALSE TRUE EXIT THEN
     DUP @
     DUP  :-SET U< IF 2DROP FALSE TRUE EXIT THEN
     C@ 
     DUP 3D = IF DROP CELL+ FALSE EXIT THEN   \ CMP EAX, # X
     DUP A3 = IF DROP CELL+ FALSE EXIT THEN   \ MOV X , EAX
     DROP
     DUP @ W@
     DUP 053B = IF DROP CELL+ FALSE EXIT THEN \ CMP EAX , X
     DUP 87C7 = IF DROP CELL+ FALSE EXIT THEN \ MOV X [EDI] , # 4444
     DUP 8289 = IF DROP CELL+ FALSE EXIT THEN \ MOV X [EDX], EAX
     DUP 05C7 = IF DROP CELL+ FALSE EXIT THEN \ MOV 4444 , # 5555
     DUP C00B = IF DROP CELL+ FALSE EXIT THEN \ OR EAX, EAX
     DUP 7D83 = IF DROP CELL+ FALSE EXIT THEN \ CMP X [EBP], # Z
     DUP 3D81 = IF DROP CELL+ FALSE EXIT THEN \ CMP  44444 , # 55555
     DUP 3D83 = IF DROP CELL+ FALSE EXIT THEN \ CMP 44444, # 0

     DUP 4589 = 
       IF   OVER @ 2+ C@ OP0 @  2+ C@ =
         IF  DROP TRUE  \ ." &"
             EXIT
         THEN
       THEN
     2DROP
     FALSE TRUE
;
\ 0 VALUE TTTT

\ : SSSSSS ;
\ TRUE VALUE ?C-JMP
 FALSE VALUE ?C-JMP
\ $ - указывает на фрагмент исходного текста, оптимизируемый
\ данным методом
: OPT-STEP  ( ADDR  -- ADDR' FLAG )

   OP0 @ :-SET U< IF TRUE EXIT THEN

   OP0 @  W@  408D =  \  LEA   EAX,  X [EAX]
   IF  M\ 2 DTST
       OP0 @ 2+ C@ C>S OFF-EAX + TO OFF-EAX
       OP1 ToOP0
       FALSE  -3 ALLOT M\ 3 DTST
       EXIT
   THEN

   OP0 @ C@ 05 =    \ ADD  EAX, # X
   IF  M\ 4 DTST
       OP0 @ 1+ @ OFF-EAX + TO OFF-EAX
       OP1 ToOP0
       FALSE  -5 ALLOT M\ 5 DTST
       EXIT
   THEN

   OP0 @  W@ 408D =  \  LEA   EAX,  X [EAX]
   IF  M\ 6 DTST
       OP0 @ 2+ @ OFF-EAX + TO OFF-EAX
       OP1 ToOP0
       FALSE  -6 ALLOT M\ 7 DTST
       EXIT
   THEN

   OP0 @ @ 3FFFFF AND
   05048D =      \ LEA  EAX, X [EAX*_]
   IF

\ $ 4444 CELLS

      OP1 @ :-SET U< 0=
      IF
           OP1 @ C@ B8 XOR     \ MOV EAX, # X1
           OP0 @ 3 + @         \ X=0
           OR 0=
           IF  M\ 8 DTST
               OP1 @ 1+ @   OP0 @ @ C00000 AND 16 RSHIFT
               LSHIFT
               OP1 @ 1+ !
               OP1 ToOP0       \ FIX 
               FALSE  -7 ALLOT M\ 9 DTST
               EXIT
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
       IF   M\ 0A DTST
            C033 OP0 @  W!    \ XOR EAX, EAX
           -3 ALLOT
\           FALSE   EXIT
           M\ 0B DTST
       THEN
       OP1 @ :-SET U< IF TRUE EXIT THEN
       DUP C@  0C3   XOR
       OP1 @  W@ 45C7 XOR OR 0=   \ MOV     F8 [EBP] , # 5 
       IF  OP1 @ 2+ C@ C>S OFF-EBP U<
         IF
           M\ 10A DTST
             OP1 OPexcise
\            FALSE   EXIT 
            M\ 10B DTST
         THEN
       THEN
   THEN

   OP1 @ :-SET U< IF TRUE EXIT THEN

     ?2EAX

   ?C-JMP
   IF     OP0 @  C@ C3 XOR  
          OP1 @  C@ E8 XOR OR 0=    \ CALL X   RET
          IF M\ 0C DTST
             OP1 @ 1+!
             OP1 ToOP0
             FALSE  -6 ALLOT 
             SetJP   5 ALLOT  M\ 0D DTST
             EXIT 
          THEN
   THEN
 \ $ 4444 TO VVVV
   OP1 @  C@ B8 XOR       \ MOV  EAX, # X
   OP0 @  C@ A3 XOR OR 0= \ MOV ' VVVV >BODY ,  EAX
   IF M\ 20E DTST
       OP1 @ 1+ @    OP0 @ 1+ @
       OP1 @ 2+ !    OP0 @ 1+ ! 
        05C7 OP1 @ W!
        FALSE
       OP1  ToOP0  M\ 20F DTST
       EXIT  
   THEN


   OP0 @ 2+ C@ C>S  OFF-EBP <  \ !!
   OP0 @  W@  458B =  AND
   IF  OP1  \ ." $"
       BEGIN XX_STEP
       UNTIL DUP
             IF  OPexcise 
             OP1 ToOP0 -3 ALLOT FALSE EXIT 
             THEN DROP
   THEN 

 \ $ CELLS 444 + @
   OP1 @  W@ 38FF AND 008D = \ LEA EAX , ____
   IF  OP0 @  W@ 008B   =   \ MOV EAX , [EAX]
      IF
        M\ 0E DTST
        8B OP1 @ C!
        OP1 ToOP0
        FALSE  -2 ALLOT M\ 0F DTST
        EXIT  
      THEN
      OP0 @ @ FFFEFF AND 00B60F = \ MOVZX   EAX , BYTE|WORD PTR [EAX] 
      IF
       M\ 10E DTST
        OP0 @ W@   OP1 @ 2@  OP1 @ 1+ 2!
        OP1 @ W!
        OP1 ToOP0
        FALSE  -2 ALLOT M\ 10F DTST
        EXIT  
      THEN 
   THEN
   OP0 @  W@ 4589  XOR  \  MOV  X [EBP], EAX
   OP0 @ 2+ C@
   OP1 @ 2+ C@     XOR OR 0=   \  (FALG &( X1=X ))
    IF
          OP1 @    W@ 458B =   \  MOV  EAX, 1X [EBP] \ $ DROP DUP
          IF   M\ 10 DTST
               OP1 ToOP0
               FALSE  -3 ALLOT M\ 11 DTST
               EXIT
          THEN
          OP1 @     W@ ADD|XOR|OR|AND=  \ переворот для дальнейшего
                                        \ удобства оптимизировать
          IF   M\ 12 DTST
               OP1 @ C@ 2 XOR 
               OP1 @ C!       \ ADD  X [EBP], EAX
            8B OP0 @ C!       \ MOV  EAX, X [EBP]
               FALSE  M\ 13 DTST
               EXIT
          THEN
    THEN

    OP1 @  C@ B8 =              \ MOV  EAX, # X
    IF  OP0 @  W@
          DUP   D8F7   =   \ NEG EAX
       IF DROP M\ 14 DTST
          OP1 @ 1+ @ NEGATE OP1 @ 1+ !   \  MOV EAX, # -X
          OP1 ToOP0
          FALSE -2 ALLOT M\ 15 DTST
          EXIT
       THEN
          DUP   D0F7   =   \ NOT EAX
       IF DROP M\ 16 DTST
          OP1 @ 1+ @ INVERT OP1 @ 1+ !   \  MOV EAX, # ~X
          OP1 ToOP0
          FALSE -2 ALLOT M\ 17  DTST
          EXIT
       THEN
          DUP    008B   =   \ MOV EAX, [EAX]
       IF DROP M\ 18 DTST
          A1 OP1 @ C!   \  MOV EAX, X
          OP1 ToOP0
          FALSE -2 ALLOT M\ 19  DTST
          EXIT
       THEN
         DROP

    THEN


   OP2 @ :-SET U< IF TRUE EXIT THEN

    OP2 @ C@ A1 XOR     \ MOV     EAX , 44444
    OP1 @ C@ 3D XOR OR  \ CMP     EAX , # 55555 
    OP0 @ ?EAX=     OR  0=
    IF M\ 218 DTST
       OP2 @ 1+ @ OP2 @ 2+ !
       3D81 OP2 @ W!         \ CMP  44444 , # 55555
       OP0 @ OP1 !
       OP1 ToOP0
       FALSE
       EXIT M\ 219 DTST
    THEN
 
\ $ - DUP
    OP2 @ W@ D8F7 XOR
    OP1 @ W@ 4501 XOR OR 0=
    IF M\ 118 DTST
       OP2 OPexcise
       29 OP1 @ C!
       FALSE
       EXIT M\ 119 DTST
    THEN

   OP0 @ C@ 58 XOR
   OP0 @ ?EAX= AND 0=
   IF  OP1 @  C@ 50 =   \ PUSH EAX
     IF
     \  444 >R 
       OP2 @  C@ B8 = \ MOV EAX , # 5
       IF    M\ 1A DTST
             68 OP2 @ C!
             OP0 @ 2@ OP1 @ 2!
             OP1 ToOP0
           FALSE  -1 ALLOT M\ 1B DTST
           EXIT  
       THEN
     THEN
     OP1 @  W@ 4589 =   \ MOV X [EBP], EAX
     IF
     \    444 555
       OP2 @  C@ B8 =  \ MOV EAX ,  5
       IF    M\ 1C DTST
             OP2 @ 1+ @
                   45C7   OP2 @    W!
              OP1 @ 2+ C@ OP2 @ 2+ C!
                          OP2 @ 3 + !
             2 OP1  +!
             OP0 @ 2@ OP1 @ 2!
             OP1 ToOP0
           FALSE  -1 ALLOT M\ 1D DTST
           EXIT  
       THEN
     THEN
   THEN

\ $ DUP >R
   OP2 @  W@ 4589 XOR           \  MOV     X2 [EBP] , EAX
   OP1 @  C@ 50   XOR       OR  \  PUSH    EAX
   OP0 @  W@ 458B XOR       OR  \  MOV     EAX , X0 [EBP]
   OP2 @  2+ C@ OP0 @  2+  C@ XOR OR 0=  \   X2=X0
     IF M\ 1E DTST
        50 OP2 @ C!
        OP2 ToOP0
        -6 ALLOT 
        FALSE M\ 1F DTST
        EXIT
     THEN
\ $ - -
   OP2 @  @  4503D8F7 XOR           \  NEG EAX  ADD EAX, X [EBP] 
   OP0 @  W@ D8F7     XOR    OR 0=  \ NEG EAX 
     IF  M\ 20 DTST
         OP1 @ @ 452B OR OP2 @ ! \  SUB EAX, X [EBP] 
         OP2 ToOP0
         -4 ALLOT 
         FALSE M\ 21 DTST
         EXIT
     THEN

 OP0 @ W@  ADD|XOR|OR|AND= INVERT      \ $  4444  OR
 OP2 @ 2+ C@
 OP0 @ 2+ C@      XOR OR 0= \ 0 NIP
    IF
      OP2 @ W@    4589 =  \ MOV X1 [EBP], EAX
      IF
          OP1 @ W@ 
          DUP  0878B =     \ MOV EAX, X [EDI] 
               IF  DROP M\ 22 DTST
                   OP0 @ C@ 8700 + OP2 @ W!
                   OP1 @ 2+ @ OP2 @ 2+ !
                   OP2 ToOP0
                   FALSE -6 ALLOT M\ 23 DTST
                  EXIT   
               THEN
          DUP  0458B =     \  MOV     EAX , X [EBP]
               IF  DROP  M\ 122 DTST
                   OP0 @ C@  OP2 @ C!
                   OP1 @ 2+ @ OP2 @ 2+ C!
                   OP2 ToOP0
                   FALSE -6 ALLOT M\ 123 DTST
                   EXIT   
               THEN
          FF AND
          DUP  0B8 =       \ MOV EAX, # X
               IF  DROP M\ 24 DTST
                   OP0 @ C@ 2+ OP2 @ C!
                   OP1 @ 1+ @ OP2 @ 1+ !
                   OP2 ToOP0
                   FALSE -6 ALLOT M\ 25 DTST
                   EXIT   
               THEN
          DUP  0A1 =       \ MOV EAX,  X
               IF  DROP  M\ 26 DTST
                   OP0 @ C@ 500 +
                   OP1 @ 1+ @ OP1 @ 2+ !
                    OP1 @ W!
                   OP1 ToOP0
                   FALSE -2 ALLOT M\ 27 DTST
                   EXIT   
               THEN
          DROP
      THEN
      OP2 @ W@    45C7 XOR  \ MOV X1 [EBP], # 4444 \ $ 4444 5555 OR
      OP1 @ C@      B8 XOR OR 0= \ TTTT AND
      IF  M\ 124 DTST
          OP2 @ 3 + @ OP1 @ 1+ @ 
          C300  OP0 @ 2+ ! OP0 @ EXECUTE
          OP1 @ 1+ ! DROP
\          OP2 OPexcise
          OP1 ToOP0
          FALSE -3 ALLOT M\ 125 DTST
          EXIT
      THEN
    THEN

    OP0 @ W@   4539   =
    IF 
         OP1 @ C@   0B8 XOR      \ MOV EAX, # X
         OP2 @ W@  4589 XOR OR   \ MOV X1 [EBP], EAX
         OP2 @ 2+ C@
         OP0 @ 2+ C@    XOR OR 0= 
         IF  M\ 28 DTST
             3D OP2 @ C!
             OP1 @ 1+ @ OP2 @ 1+ !
             OP2 ToOP0
             FALSE -6 ALLOT M\ 29 DTST
             EXIT
         THEN     
\ $  4444 @ U<
         OP1 @ C@   0A1 XOR      \ MOV EAX, # X
         OP2 @ W@  4589 XOR OR   \ MOV X1 [EBP], EAX
         OP2 @ 2+ C@
         OP0 @ 2+ C@    XOR OR 0= 
         IF  M\ 2A DTST
             053B OP2 @ W!
             OP1 @ 1+ @ OP2 @ 2+ !
             OP2 ToOP0
             FALSE -5 ALLOT M\ 2B DTST
             EXIT
         THEN     

    THEN

   OP0 @ W@ 1089 XOR           \ MOV     [EAX] , EDX
   OP1 @ W@ 558B XOR OR 0=     \ MOV     EDX , X [EBP] \ !?
    IF
          OP2 @ W@ 408D =    \ LEA     EAX , 4 [EAX]  \ $ CELL+ !
          IF  M\ 430 DTST  
              OP2 @ 2+ C@
              OP1 @ @ OP2 @ !
              5089 OP1 @ W!
              OP1 @ 2+ C!
              OP1 ToOP0
              FALSE -2 ALLOT M\ 431 DTST
              EXIT
          THEN
          OP3 @ :-SET U< IF TRUE EXIT THEN
\ $  44444 !  
          OP3 @ 2+ C@
          OP1 @ 2+ C@    =
          IF   OP3 @ W@ 4589 =   \  MOV     X [EBP] , EAX
            IF OP2 @ C@ B8   =  \  MOV     EAX, X 
               IF M\ 30 DTST  
                  A3  OP3 @ C!
                  OP2 @ 1+ @  OP3 @ 1+ !
                  OP3 ToOP0
                  FALSE -8 ALLOT M\ 31 DTST
                  EXIT   
               THEN
               OP2 @ W@ 878D =     \ LEA      EAX,  X [EDI]
               IF M\ 230 DTST  
                  OP3 OPexcise 
                  8789 OP2 @ W!    \ MOV     X [EDI] , EAX 
                  OP2 ToOP0
                  FALSE  -5 ALLOT M\ 231 DTST
                  EXIT   
               THEN
            THEN  
            OP3 @ W@  45C7 =   \  MOV     X [EBP] , # 44444
            IF OP2 @ C@ B8   =   \  MOV     EAX, X 
               IF  M\ 130 DTST 
                   -4000 OP3 @ +!
                   OP3 @ 3 + @   OP2 @ 1+ @ OP3 @ 2+  !
                   OP3 @ 6 + !
                           
                   OP3 ToOP0
                   FALSE -7 ALLOT M\ 131 DTST
                   EXIT   
               THEN

               OP2 @ W@  878D =  \ LEA      EAX,  X [EDI]
               IF  M\ 330 DTST 
                    87C7 OP3 @ W!
                    OP3 @ 3 + @   OP2 @ 2+ @ OP3 @ 2+  !
                    OP3 @ 6 + !
                           
                    OP3 ToOP0
                    FALSE -8 ALLOT M\ 331 DTST
                    EXIT   
               THEN
            THEN
          THEN
    THEN

    OP2 @ C@ 0A1 XOR        \ MOV     EAX , XX
    OP1 @ C@ 025 XOR OR     \ AND     EAX , # ZZ 
    OP0 @ C@ 0A3 XOR OR     \ MOV      XX ,  EAX
    OP2 @ 1+ @  OP0 @ 1+ @  XOR OR 0=
    IF   M\ 530 DTST
       OP2 @ 1+ @
       OP1 @ 1+ @        8125  OP2 @ !
       OP2 @ 6 + !  OP2 @ 2+ !
       OP2 ToOP0
       FALSE -2 ALLOT  M\ 531 DTST
       EXIT   
    THEN

   OP3 @ :-SET U< IF TRUE EXIT THEN

\ $ SWAP 4444   
   OP2 @ W@ C28B =    \ MOV     EAX , EDX 
   IF 
        OP0 @ ?EAX=
        OP1 @ W@ 4589 XOR OR 0= \ MOV   X [EBP] , EAX 
     IF 1000  OP1 @ +!		\  MOV    X [EBP] , EDX 
        FALSE  OP2 OPexcise  EXIT
     THEN
   THEN

    OP1 @ W@   453B   =      \ CMP   EAX , X [EBP]
    IF OP0 @ @ FFFCFF AND C09C0F =  \ SETLE   AL 
      IF
\ $  4444  <
         OP2 @ C@   0B8 XOR      \ MOV EAX, # X
         OP3 @ W@  4589 XOR OR   \ MOV X1 [EBP], EAX
         OP3 @ 2+ C@
         OP1 @ 2+ C@    XOR OR 0= 
         IF  M\ 2C DTST
             3D OP3 @ C!
             OP2 @ 1+ @ OP3 @ 1+ !
             2 OP2 +!
             OP0 @ @ 300 XOR  OP2 @ !     \  SETGE   AL 
             OP2 ToOP0
             FALSE -6 ALLOT M\ 2D DTST
             EXIT
         THEN     
\ $  4444 @ <
         OP2 @ C@   0A1 XOR      \ MOV EAX, # X
         OP3 @ 2+ C@
         OP1 @ 2+ C@    XOR OR 0= 
         IF
         OP3 @ W@  4589 =   \ MOV X1 [EBP], EAX
           IF M\ 2E DTST
              053B OP3 @ W!
              OP2 @ 1+ @ OP3 @ 2+ !
              3 OP2 +!
              OP0 @ @ 300 XOR  OP2 @ !     \  SETGE   AL 
              OP2 ToOP0
              FALSE -5 ALLOT M\ 2F DTST
              EXIT
            THEN

         OP3 @ W@  45C7 =   \ 
           IF M\ 12E DTST
              3D81 OP3 @ W!
              OP3 @ 3 + @ 
              OP2 @ 1+ @ OP3 @ 2+ !  OP3 @ 6 + !
              3 OP2 +!
              OP0 @ @   OP2 @ !
              OP2 ToOP0
              FALSE -5 ALLOT M\ 12F DTST
              EXIT
            THEN

         THEN     
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
    IF  M\ 32 DTST
        OP0 @ W@ 0012 - OP4 @ W!
        OP3 @ 1+ @ OP4 @ 2+ C!      
        OP4 ToOP0
        FALSE -C ALLOT M\ 33 DTST
        EXIT   
    THEN

    TRUE

;

: -EVEN-EBP
     OP0 @ :-SET U< IF EXIT THEN
     OP0 @ W@ 06D8D =  \  LEA   ebp,  OFF-EBP [EBP]
     IF  OP0 @ 2+ C@ +>OFF-EBP
         OP1 ToOP0
        -3 ALLOT EXIT
     THEN ;


: OPT_  ( -- )
  BEGIN OPT-STEP UNTIL  EVEN-EAX
 ;

: DO_OPT   ( ADDR -- ADDR' )
  OPT? IF OPT_ THEN ;

: INLINE?  ( CFA -- CFA FLAG )
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
  DUP2B?         M_WL DROP 2+   REPEAT
  DUP  C58B    = M_WL DROP 2+   REPEAT \ MOV EAX,  EBP

\  DUP 0E3FF   = M_WL DROP 2+   REPEAT   \ JMP  EBX
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

: MACRO? INLINE? ;

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

: 1A_,_STEP 1_,_STEP DUP @ + DP @ - , CELL+ ;

: 2A_,_STEP 2_,_STEP DUP @ + DP @ - , CELL+ ;

: _INLINE,  (  CFA  --  )
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
\  DUP 0D3FF = M_WL EVEN-EBP 2_,_STEP REPEAT  \ CALL EBX

\ DUP 0E2FF = M_WL EVEN-EBP 2_,_STEP REPEAT  \ JMP  EDX
  DUP 0D2FF = M_WL EVEN-EBP 2_,_STEP REPEAT  \ CALL EDX
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
  DUP 244403 = M_WL 4_,_STEP      REPEAT \ ADD  EAX, X [ESP]
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

: OPT_CLOSE
   EVEN-EBP DP @ TO LAST-HERE ;

:  OPT_INIT   ?SET -EVEN-EBP  ;

: INLINE, ( CFA --  )   OPT_INIT  _INLINE, OPT_CLOSE ;

: MACRO, INLINE, ;

:  ?BR-OPT-STP ( cfa -- cfa' flag )
   OP0 @ :-SET U< IF TRUE EXIT THEN

   DUP 'DROP XOR
   OP0 @  W@  4589 XOR OR 0= \ MOV X [EBP] , EAX
   IF DP @ TO LAST-HERE INLINE, ['] NOOP FALSE EXIT
   THEN  

   OP0 @ C@  A1 =   \  MOV     EAX , 44444
   IF M\ 434 DTST
      0 W,
      OP0 @ 1+ @ OP0 @ 2+ !
      3D83  OP0 @ W!     \  CMP 44444, # 0
      TRUE  M\ 435 DTST
      EXIT
   THEN

   DUP 'DROP XOR
   OP0 @ W@  458B XOR OR 0= \  MOV     EAX , 0 [EBP]  
   IF M\ 334 DTST
      7D83  OP0 @ W!     \  CMP X [EBP], # Z
      TRUE 0 C, M\ 335 DTST
      EXIT
   THEN

   OP0 @ W@  408D =  \  LEA   EAX,  X [EAX]
   IF M\ 234 DTST
      C083  OP0 @ W!     \  ADD  EAX, # X
      TRUE M\ 235 DTST
      EXIT 
   THEN
   OP0 @ W@  808D =  \  LEA   EAX,  X [EAX]
   IF M\ 34 DTST
      05 OP0 @ C!
      OP0 @ 2+ @ OP0 @ 1+ !   \  ADD  EAX, # X
      TRUE  -1 ALLOT M\ 35 DTST
      EXIT
   THEN

   DUP 'DROP XOR
   OP0 @ @ FFFFFF AND 1FF8C1 XOR OR 0= \  SAR  EAX , 1F 
   IF  M\ 13A DTST
            OP1 ToOP0
            8D J_COD 1 AND XOR  TO J_COD
            TRUE  -3 ALLOT M\ 13B DTST
            EXIT
   THEN
   DUP 'DROP XOR
   OP0 @ C@  35  XOR OR 0= \   XOR  EAX, # X
   IF M\ 134 DTST
      3D OP0 @ C!   \  CMP  EAX, # X
      TRUE  M\ 135 DTST
      EXIT
   THEN

   OP1 @ :-SET U< IF TRUE EXIT THEN
\ $       0<> IF
   DUP 'DROP XOR
   OP1 @ @  C01BD8F7  XOR OR 0= \   NEG  EAX  \  SBB  EAX, EAX
        IF   M\ 36 DTST
             OP2 ToOP0
\            084 TO J_COD
             FALSE  -4 ALLOT M\ 37 DTST
             EXIT
        THEN
\ $       0= IF
        DUP 'DROP XOR
        OP1 @  @  1B01E883 XOR OR     \ SUB EAX , # 1
        OP0 @ W@      C01B XOR OR 0=  \ SBB EAX , EAX
        IF  M\ 38 DTST
\            OP2 @ W@ U.
            OP2 ToOP0  
            J_COD 1 XOR TO J_COD
            FALSE  -5 ALLOT M\ 39 DTST
            EXIT
        THEN


 \ $  U< IF
        DUP 'DROP XOR
        OP1 @  C@  3D  <> 
        OP1 @  W@ 053B <> AND
        OP1 @   @ FFFD AND 
                  4539 XOR  AND      \ CMP    X [EBP] , EAX
        OP0 @ W@  C01B XOR OR OR 0=   \ SBB    EAX , EAX
        IF  M\ 3A DTST
            OP1 ToOP0
            83 J_COD 1 AND XOR  TO J_COD
            FALSE -2 ALLOT M\ 3B DTST
            EXIT
        THEN

   OP3 @ :-SET U< IF TRUE EXIT THEN

\ $  < IF
     DUP 'DROP XOR
     OP2 @ @ FFFFFCFF AND  83C09C0F XOR OR
     OP1 @ @  4801E083 XOR OR 0=
     IF  M\ 3C DTST
             OP2 @ 1+ C@ 10 - J_COD 1 AND XOR TO J_COD
             OP3 ToOP0
             TRUE  -7 ALLOT M\ 3D DTST
             EXIT
     THEN

\ 5 OVER = IF
     OP0 @ W@ 4533 =  \ XOR   EAX , F8 [EBP] 
     IF
         DUP 'DROP XOR
         OP3 @ W@ 4589 XOR OR  \ MOV    FC [EBP] , EAX 
         OP2 @ W@ 45C7 XOR OR  \ MOV    F8 [EBP] , # 5 
         OP1 @ W@ 458B XOR OR  \ MOV    EAX , FC [EBP] 
         OP3 @ 2+ C@ OP1 @ 2+ C@ XOR OR
         OP2 @ 2+ C@ OP0 @ 2+ C@ XOR OR 0=
         IF M\ 234 DTST
            3D OP2 @ C!
            OP2 @ 3 + @ OP2 @ 1+ !
            OP2 ToOP0
            TRUE -8 ALLOT  M\ 235 DTST
            EXIT
         THEN
     THEN

     TRUE  ;

: ?BR-OPT
     BEGIN ?BR-OPT-STP
     UNTIL
        OP0 @ :-SET U<
        IF    SetOP 0xC00B W,    \ OR EAX, EAX
              EXIT
        THEN
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
        OVER C083  <> AND  \ ADD EAX , # X
        OVER F8C1  <> AND  \ SAR EAX ,   X
        OVER 7D83  <> AND  \ CMP X [EBP], # Z
        OVER 3D81  <> AND  \ CMP 44444, # 55555
        OVER 3D83  <> AND  \ CMP 44444, # 0

        OVER C20B XOR AND  \  OR EAX , EDX
        NIP AND
        IF    SetOP 0xC00B W,    \ OR EAX, EAX
        THEN

;


: OPT   ( -- )
  ['] NOOP DO_OPT DROP  ;

: FORLIT, ( N -- )
  'DUP _INLINE, SetOP 0B8 C, , OPT ;

: CON>LIT ( CFA -- CFA TRUE | FALSE )    
                  OPT? 0= IF TRUE EXIT THEN
               MM_SIZE 0= IF TRUE EXIT THEN
                 DUP C@ 0E8 <> IF TRUE EXIT THEN
                 
                 DUP 1+  REL@ CELL+ 
                 DUP   CREATE-CODE  = 
                 IF  DROP OPT_INIT 5 +  FORLIT, FALSE OPT_CLOSE EXIT
                 THEN
                 
                 DUP     USER-CODE  =
                 IF  DROP  OPT_INIT 'DUP _INLINE,
                   SetOP  878D W, 5 + @ , OPT   FALSE  OPT_CLOSE  EXIT
                 THEN

                 DUP     USER-VALUE-CODE  =
                 IF  DROP  OPT_INIT 'DUP _INLINE,
                   SetOP  878B W, 5 + @ , OPT   FALSE  OPT_CLOSE  EXIT
                 THEN

                 DUP  CONSTANT-CODE  =
                 IF  DROP  OPT_INIT 5 + DUP 5 +  REL@ 
                     TOVALUE-CODE CELL- =
                    IF    'DUP _INLINE, SetOP 0A1 C, , OPT
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
                     'DROP _INLINE,
                     FALSE  OPT_CLOSE  EXIT
                 THEN
                  TOVALUE-CODE =
                 IF    OPT_INIT
                     SetOP  A3 C,  CELL-  ,   OPT
                     'DROP _INLINE,
                     FALSE  OPT_CLOSE  EXIT
                 THEN

  TRUE
;

: J?_STEP  ( ADR OPX -- ADR OPX+4 FALSE | OPX TRUE TRUE | ADR FALSE TRUE )
     OVER J-SET U> 0= IF   DROP FALSE TRUE EXIT THEN
     OVER DP @ =   IF   NIP  TRUE TRUE EXIT THEN
     DUP @ @ FFF2840F =  IF  DROP  FALSE TRUE EXIT THEN
     DUP @ @ FFFFFBE9 =  IF  DROP  FALSE TRUE EXIT THEN
     DUP CELL+ OP0 OpBuffSize + U> 
                   IF   DROP FALSE TRUE EXIT THEN
     2DUP @ =      IF  NIP CELL+ TRUE TRUE EXIT THEN
     CELL+ FALSE
;


: J_+!
        DUP C@ F0 
           AND 70 = IF 1+ ELSE
        DUP C@ EB = IF 1+ ELSE
        DUP C@ E9 = IF 1+ ELSE
        DUP W@ F0FF
         AND 800F = IF 2+  ELSE
          ." J_+! ERR" ABORT
        THEN  THEN THEN THEN  +!
;

: J_MOVE ( OPX n -- )
  OVER OP0 <>
  IF
      OVER CELL- @
      2DUP - NEGATE
      OVER DP @  - NEGATE ( U. U. U.  ABORT )  CMOVE      
      OVER OP0 
      ?DO  DUP NEGATE I +!
           I @ C@ E8 = IF DUP I @ 1+ +! THEN
           CELL
      +LOOP
  THEN
      OVER @    
      JP0 JpBuffSize + JP0
      ?DO I @ 
           IF   DUP  I @ U<
                IF
                   OVER NEGATE I +!
                    DUP I @ J_@ U> 
                    IF OVER I @ J_+!
                    THEN
                ELSE 
                   DUP  I @ <> 
                   IF
                     DUP I @ J_@ U<
                     IF OVER NEGATE  I @ J_+!
                     THEN
                   THEN
                THEN
           THEN  CELL
      +LOOP DROP
 \ THEN

  NIP NEGATE DUP ALLOT  :-SET + TO :-SET EXIT
   ;

TRUE VALUE J_OPT?

: RESOLVE_OPT ( ADR -- )
  DUP CELL- JP0 JpBuffSize + CELL- @ U< 
    IF DUP CELL- REL@ CELL+ J-SET UMAX TO J-SET THEN

  J_OPT?  0= IF DROP EXIT THEN
 \ ." J_S"  \ BASE @ HEX  J-SET U. DP @ U. BASE !
  DP @ OVER - 7E >  IF ( ." S" )    DROP EXIT THEN
  DP @ LAST-HERE <> IF ( ." L" ) ?SET DROP EXIT THEN
  OPT? 0= IF DROP EXIT THEN
  CELL+  OP0 
    BEGIN J?_STEP
    UNTIL
    IF DUP  @ 
       DUP C@ E9 =
       IF  EB SWAP C! 3
       ELSE
             DUP 1+ W@ 10 - \ 400 +
            SWAP W!  4
       THEN
\       OVER CELL- @ REST
      J_MOVE DP @ TO LAST-HERE EXIT
    THEN  \ OPX
  DROP

; 
\  0 TO J_OPT? 

BASE !

