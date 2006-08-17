
REQUIRE Code ~mak\asm\ASM.FRT

Code ExBytes
    XCHG AL, AH
    RET
EndCode

Code ON
    MOV DWORD PTR [EAX], -1
    MOV EAX, [EBP]
    LEA EBP, [EBP+4]
    RET
EndCode

ALSO HIDDEN DEFINITIONS
0 VALUE *PtrX

: (?XPtr) ( --> n true | false )
   IN>R GetOp 3 = IF
    *PtrX IF
     C" QWORD" S= 8 ?S=
     C" TBYTE" S= 10 ?S=
    THEN
    C" DWORD" S= 4 ?S=
    C" BYTE"  S= 1 ?S=
    C" WORD"  S= 2 ?S=
   THEN
   DROP FALSE R>IN
;
' (?XPtr) TO (?Ptr)

: ?XMemReg ( --> flag )
   TRUE TO *PtrX ?MemReg FALSE TO *PtrX
;

: ?ST ( --> n true | FALSE )
   IN>R GetOp 3 = IF
    C" ST0" S= 0 ?S=
    C" ST1" S= 1 ?S=
    C" ST2" S= 2 ?S=
    C" ST3" S= 3 ?S=
    C" ST4" S= 4 ?S=
    C" ST5" S= 5 ?S=
    C" ST6" S= 6 ?S=
    C" ST7" S= 7 ?S=
    C" ST" S= IF
     IN>R GetOp 1 = SWAP [CHAR] ( =  AND IF
      GetOp 2 <> IF 0x59 THROW THEN
      DUP   7 U> IF 0x5E THROW THEN
      GetOp 1 = SWAP [CHAR] ) = AND 0= IF 0x59 THROW THEN
      RDROP
     ELSE R>IN 0 THEN
     TRUE RDROP EXIT
    THEN
   THEN
   DROP FALSE R>IN
;
: ?MM ( --> n true | false )
   IN>R GetOp 3 = IF
    C" MM0" S= 0 ?S=
    C" MM1" S= 1 ?S=
    C" MM2" S= 2 ?S=
    C" MM3" S= 3 ?S=
    C" MM4" S= 4 ?S=
    C" MM5" S= 5 ?S=
    C" MM6" S= 6 ?S=
    C" MM7" S= 7 ?S=
   THEN
   DROP FALSE R>IN
;
: ?CR ( --> n true | false )
   IN>R GetOp 3 = IF
    C" CR0" S= 0 ?S=
    C" CR2" S= 2 ?S=
    C" CR3" S= 3 ?S=
    C" CR4" S= 4 ?S=
   THEN
   DROP FALSE R>IN
;
: ?DR ( --> n TRUE | FALSE )
   IN>R GetOp 3 = IF
    C" DR0" S= 0 ?S=
    C" DR1" S= 1 ?S=
    C" DR2" S= 2 ?S=
    C" DR3" S= 3 ?S=
    C" DR4" S= 4 ?S=
    C" DR5" S= 5 ?S=
    C" DR6" S= 6 ?S=
    C" DR7" S= 7 ?S=
   THEN
   DROP FALSE R>IN
;
: F2Op ( name ( c1esc c1reg ... c4esc c4reg --> )
              ( --> )
   CREATE 4 0 DO SWAP 0xD8 + C, C, LOOP
DOES>
   TO *OpArray InitCommand 1 TO *OpcSize
   ?ST IF
    3 TO *Mod Comma ?DUP IF
     TO *R/M ?ST DUP IF DROP 0= THEN 0= IF 0x5E THROW THEN *OpArray
    ELSE
     ?ST 0= IF 0x5E THROW THEN TO *R/M *OpArray 2+
    THEN
   ELSE
    ?XMemReg DUP IF DROP *Mod 3 <> THEN 0= IF 0x5E THROW THEN
    *OpSize  CASE
     0 OF 0x5C THROW ENDOF
     4 OF *OpArray 6 + ENDOF
     8 OF *OpArray CELL+ ENDOF
     0x50 THROW
    ENDCASE
   THEN
   DUP C@ TO *OpCode 1+ C@ TO *Reg
   0 TO *OpSize CompileCommand
;
: F1Op ( name ( c1esc c1reg ... c4esc c4reg --> )
              ( --> )
   CREATE 4 0 DO SWAP 0xD8 + C, C, LOOP
DOES>
   TO *OpArray InitCommand 1 TO *OpcSize
   ?ST IF
    TO *R/M 3 TO *Mod *OpArray
   ELSE
    ?XMemReg DUP IF DROP *Mod 3 <> THEN 0= IF 0x5E THROW THEN
    *OpSize CASE
     0 OF 0x5C THROW ENDOF
     4 OF *OpArray 6 + ENDOF
     8 OF *OpArray CELL+ ENDOF
     10 OF *OpArray 2+ ENDOF
     0x50 THROW
    ENDCASE
   THEN
   DUP C@ DUP 0xD7 = IF 0x50 THROW THEN TO *OpCode 1+ C@ TO *Reg
   0 TO *OpSize CompileCommand
;
: FIxx ( name ( c1esc c1reg ... c3esc c3reg --> )
              ( --> )
   CREATE 3 0 DO SWAP 0xD8 + C, C, LOOP
DOES>
   TO *OpArray InitCommand 1 TO *OpcSize
   ?XMemReg DUP IF DROP *Mod 3 <> THEN 0= IF 0x5E THROW THEN
   *OpSize CASE
    0 OF 0x5C THROW ENDOF
    2 OF *OpArray CELL+ ENDOF
    4 OF *OpArray 2+ ENDOF
    8 OF *OpArray ENDOF
    0x50 THROW
   ENDCASE
   DUP C@ DUP 0xD7 = IF 0x50 THROW THEN TO *OpCode 1+ C@ TO *Reg
   0 TO *OpSize CompileCommand
;
: FNSTSW ( --> )
   InitCommand 1 TO *OpcSize
   ?Reg16 IF
    IF 0x5E THROW THEN 0xDF TO *OpCode 4 TO *Reg 3 TO *Mod 0 TO *R/M
   ELSE
    ?MemReg DUP IF DROP *Mod 3 <> THEN 0= IF 0x5E THROW THEN
    *OpSize CASE
       0 OF 0xDD TO *OpCode 7 TO *Reg ENDOF
       2 OF 0xDD TO *OpCode 7 TO *Reg ENDOF
     0x50 THROW
    ENDCASE
   THEN
  0 TO *OpSize CompileCommand
;
: FSTSW ( --> )
   0x9B C, FNSTSW
;
: F0Op ( name ( esc reg r/m --> )
              ( --> )
   CREATE ROT 0xD8 + C, SWAP C, C,
DOES>
   InitCommand 1 TO *OpcSize
   DUP C@ TO *OpCode 1+ DUP C@ TO *Reg 1+ C@ TO *R/M 3 TO *Mod
   CompileCommand
;
: FW0Op ( name ( esc reg r/m --> )
               ( --> )
   CREATE ROT 0xD8 + C, SWAP C, C,
DOES>
   InitCommand 1 TO *OpcSize
   DUP C@ TO *OpCode 1+ DUP C@ TO *Reg 1+ C@ TO *R/M 3 TO *Mod
   0x9B C, CompileCommand
;
: FCtl ( name ( wait size esc reg --> )
              ( --> )
   CREATE SWAP 0xD8 + C, C, C, C,
DOES>
   TO *OpArray InitCommand 1 TO *OpcSize
   ?MemReg DUP IF DROP *Mod 3 <> THEN 0= IF 0x5E THROW THEN
   *OpSize CASE
     0 OF *OpArray C@ TO *OpCode *OpArray 1+ C@ TO *Reg ENDOF
     2 OF *OpArray C@ TO *OpCode *OpArray 1+ C@ TO *Reg ENDOF
    0x50 THROW
   ENDCASE
   *OpArray 3 + C@ ?DUP IF C, THEN
   *OpArray 2+ C@ TO *OpSize CompileCommand
;
: FBxx ( name ( reg --> )
              ( --> )
   CREATE C,
DOES>
   InitCommand 1 TO *OpcSize
   ?XMemReg DUP IF DROP *Mod 3 <> THEN 0= IF 0x5E THROW THEN
   *OpSize 10 = IF C@ TO *Reg 0xDF TO *OpCode
   ELSE 0x50 THROW THEN
   0 TO *OpSize CompileCommand
;
: FRegOp ( name ( esc reg --> )
                ( --> )
   CREATE SWAP 0xD8 + C, C,
DOES>
   InitCommand 1 TO *OpcSize
   ?ST 0= IF 0x5E THROW THEN TO *R/M 3 TO *Mod
   DUP C@ TO *OpCode 1+ C@ TO *Reg
   CompileCommand
;
: FP6Op ( name ( esc reg --> )
               ( --> )
   CREATE SWAP 0xD8 + C, C,
DOES>
   InitCommand 1 TO *OpcSize
   ?ST 0= IF 0x5E THROW THEN IF 0x5E THROW THEN
   Comma ?ST 0= IF 0x5E THROW THEN TO *R/M 3 TO *Mod
   DUP C@ TO *OpCode 1+ C@ TO *Reg
   CompileCommand
;
: BOUND ( --> )
   InitCommand 1 TO *OpcSize
   ?Reg IF
    *OpSize DUP 1 = IF 0x50 THROW THEN >R 0 TO *OpSize
    Comma ?XMemReg IF
     *Mod 3 = IF 0x5E THROW THEN
     *OpSize ?DUP IF R@ 2* <> IF 0x50 THROW THEN THEN
     R> TO *OpSize 0x62 TO *OpCode
    ELSE 0x5E THROW THEN
   ELSE 0x5E THROW THEN
   CompileCommand
;
: ARPL ( --> )
   InitCommand 1 TO *OpcSize 0x63 TO *OpCode
   ?MemReg 0= IF 0x5E THROW THEN *OpSize 2 = *OpSize 0= OR 0= IF 0x50 THROW THEN
   Comma ?Reg16 0= IF 0x5E THROW THEN TO *Reg
   0 TO *OpSize CompileCommand
;
: RETx ( name ( opc1 opc2 --> )
              ( --> )
   CREATE SWAP C, C,
DOES>
   InitCommand 1 TO *OpcSize
   IN>R GetOp NIP 0= R>IN 0= IF
    1+ 2 TO *OpSize Imm *ImSize 4 = IF 0x5A THROW THEN 2 TO *ImSize
   THEN
   C@ TO *OpCode 0 TO *OpSize CompileCommand
;
: ENTER ( --> )
   2 TO *OpSize Imm *ImSize 4 = IF 0x5A THROW THEN *Imm >R
   Comma 1 TO *OpSize Imm *ImSize 1 > *Imm 31 U> OR IF 0x5A THROW THEN
   0xC8 C, R> W, *Imm C,
;
: AAx ( name ( opc --> )
             ( --> )
   CREATE C,
DOES>
   C@ InitCommand
   IN>R GetOp NIP 0= R>IN 0= IF
    1 TO *OpSize Imm *ImSize 1 > IF 0x5A THROW THEN *Imm
   ELSE 10 THEN
   InitCommand 2 TO *OpcSize 8 LSHIFT + TO *OpCode
   CompileCommand
;
: LxxCMOV ( name ( opc --> )
                 ( --> )
   CREATE ExBytes W,
DOES>
   InitCommand W@ TO *OpCode 2 TO *OpcSize
   ?Reg DUP IF DROP *OpSize 1 > THEN 0= IF 0x5E THROW THEN
   Comma ?MemReg 0= IF 0x5E THROW THEN
   CompileCommand
;
: P5Op ( name ( opc1 opc2 --> )
              ( --> )
   CREATE SWAP ExBytes W, ExBytes W,
DOES>
   InitCommand 2 TO *OpcSize
   ?MemReg 0= IF 0x5E THROW THEN
   Comma ?Reg 0= IF 0x5E THROW THEN
   *OpSize 1 <> IF 2+ THEN W@ TO *OpCode
   CompileCommand
;
: CMPXCHG8B ( --> )
   InitCommand 2 TO *OpcSize 0xC70F TO *OpCode
   ?XMemReg DUP IF DROP *Mod 3 <> THEN 0= IF 0x5E THROW THEN
   *OpSize 0= *OpSize 8 = OR 0= IF 0x50 THROW THEN
   1 TO *Reg 0 TO *OpSize CompileCommand
;
: BSWAP ( --> )
   InitCommand 2 TO *OpcSize
   ?Reg DUP IF DROP *OpSize 1 > THEN 0= IF 0x5E THROW THEN
   *Reg 8 LSHIFT 0xC80F + TO *OpCode
   CompileCommand
;
: SysOp16 ( name ( opc reg --> )
                 ( --> )
   CREATE SWAP ExBytes W, C,
DOES>
   InitCommand 2 TO *OpcSize
   ?MemReg 0= IF 0x5E THROW THEN
   *OpSize 0= *OpSize 2 = OR 0= IF 0x50 THROW THEN
   DUP W@ TO *OpCode 2+ C@ TO *Reg
   0 TO *OpSize CompileCommand
;
: SysOp64 ( name ( reg --> )
   CREATE C,
DOES>
   InitCommand 2 TO *OpcSize 0x010F TO *OpCode C@ TO *Reg
   ?XMemReg DUP IF DROP *Mod 3 <> THEN 0= IF 0x5E THROW THEN
   *Reg 7 <> IF
    *OpSize 0= *OpSize 8 = OR 0= IF 0x50 THROW THEN
   THEN
   0 TO *OpSize CompileCommand
;
: MOV ( --> )
   InitCommand 2 TO *OpcSize
   IN>R ?Reg32 IF
    TO *R/M Comma IN>R 0x200F TO *OpCode ?CR
    DUP 0= IF R>IN >R 0x210F TO *OpCode ?DR THEN
    RDROP IF
     RDROP TO *Reg 3 TO *Mod
     CompileCommand EXIT
    THEN
   ELSE
    R>IN IN>R 0x220F TO *OpCode ?CR
    DUP 0= IF DROP R>IN IN>R 0x230F TO *OpCode ?DR THEN
    IF
     RDROP Comma ?Reg32 0= IF 0x5E THROW THEN TO *R/M TO *Reg 3 TO *Mod
     CompileCommand EXIT
    THEN
   THEN
   R>IN [ ALSO S_ASSEM ] MOV [ PREVIOUS ]
;
: MMXOp ( name ( opc sz --> )
   CREATE SWAP ExBytes W, C,
DOES>
   InitCommand 2 TO *OpcSize DUP W@ TO *OpCode 2+ C@
   ?MM 0= IF 0x5E THROW THEN TO *Reg
   Comma IN>R ?MM IF
    TO *R/M 3 TO *Mod DROP RDROP
   ELSE
    R>IN ?XMemReg DUP IF DROP *Mod 3 <> THEN 0= IF 0x5E THROW THEN
    *OpSize = *OpSize 0= OR 0= IF 0x50 THROW THEN
   THEN
   0 TO *OpSize CompileCommand
;
: MOVx ( name ( opc1 opc2 sz --> )
              ( --> )
   CREATE C, SWAP ExBytes W, ExBytes W,
DOES>
   InitCommand 2 TO *OpcSize DUP 1+ SWAP C@
   IN>R ?MM IF
    RDROP TO *Reg
    Comma ?XMemReg 0= IF 0x5E THROW THEN
    *OpSize = *OpSize 0= OR 0= IF 0x50 THROW THEN
   ELSE
    R>IN ?XMemReg 0= IF 0x5E THROW THEN
    *OpSize = *OpSize 0= OR 0= IF 0x50 THROW THEN
    Comma ?MM 0= IF 0x5E THROW THEN TO *Reg 2+
   THEN
   W@ TO *OpCode
   0 TO *OpSize CompileCommand
;

: MMXShift ( name ( opc1 opc2 r2 --> )
                  ( --> )
   CREATE ROT ExBytes W, SWAP ExBytes W, C,
DOES>
   InitCommand 2 TO *OpcSize
   ?MM 0= IF 0x5E THROW THEN TO *Reg
   Comma IN>R ?MM IF
    RDROP TO *R/M 3 TO *Mod
   ELSE
    R>IN IN>R ?XMemReg IF
     RDROP *Mod 3 = IF 0x5E THROW THEN
     *OpSize 8 = *OpSize 0= OR 0= IF 0x50 THROW THEN
    ELSE
     R>IN 1 TO *OpSize Imm *ImSize 1 > IF 0x5A THROW THEN
     2+ DUP 2+ C@ *Reg TO *R/M TO *Reg 3 TO *Mod
    THEN
   THEN
   W@ TO *OpCode
   0 TO *OpSize CompileCommand
;

VARIABLE *DImm 0 ,

: (2OpD) ( c-addr --> d )
   BASE @ >R
   DUP C@ OVER + C@ CASE
   [CHAR] H OF 16 ENDOF
   [CHAR] B OF 2 ENDOF
   [CHAR] O OF 8 ENDOF
   [CHAR] D OF 10 ENDOF
    DROP DUP 1+! R@
   ENDCASE BASE !
   [CHAR] . OVER DUP C@ OVER + C!
   VAL 0= IF 0x61 THROW THEN R> BASE !
;
: ?DNumber ( --> d TRUE | FALSE )
   IN>R (GetOp) CASE
    2 OF (2OpD) TRUE RDROP ENDOF
    1 OF
      1+ C@ [CHAR] - = IF
       (GetOp) 2 = IF (2OpD) DNEGATE TRUE RDROP ELSE DROP FALSE R>IN THEN
      ELSE FALSE R>IN THEN
     ENDOF
    2DROP FALSE R>IN
   ENDCASE
;
: DImm ( --> )
   *Sign 0! 0. *DImm 2!
   BEGIN
    ?DNumber IF
     *Sign @ IF DNEGATE THEN *DImm 2@ D+ *DImm 2!
    ELSE
     GetOp IF 0x59 ELSE 0x66 THEN THROW
    THEN
    GetOp DUP 1 > IF 0x57 THROW THEN
    IF
     CASE
     [CHAR] + OF *Sign 0! FALSE ENDOF
     [CHAR] - OF *Sign ON FALSE ENDOF
     [CHAR] , OF TRUE >IN 1-! ENDOF
      DROP 0x59 THROW
     ENDCASE
    ELSE DROP TRUE THEN
   UNTIL
;
: DQ ( --> )
   BEGIN
    DImm *DImm 2@ SWAP 2,
    IN>R GetOp 1 = SWAP [CHAR] , = AND IF RDROP FALSE
    ELSE R>IN TRUE THEN
   UNTIL
;

ALSO S_ASSEM DEFINITIONS

0 0 4 0 0 0 4 0 F2Op FADD
0 1 4 1 0 1 4 1 F2Op FMUL
0 4 4 4 0 4 4 5 F2Op FSUB
0 5 4 5 0 5 4 4 F2Op FSUBR
0 6 4 6 0 6 4 7 F2Op FDIV
0 7 4 7 0 7 4 6 F2Op FDIVR
0 2 4 2 -1 0 0 2 F1Op FCOM
0 3 4 3 -1 0 0 3 F1Op FCOMP
1 2 5 2 -1 0 5 2 F1Op FST
1 0 5 0 3 5 1 0 F1Op FLD
1 3 5 3 3 7 5 3 F1Op FSTP
6 0 2 0 -1 0 FIxx FIADD
6 1 2 1 -1 0 FIxx FIMUL
6 2 2 2 -1 0 FIxx FICOM
6 3 2 3 -1 0 FIxx FICOMP
6 4 2 4 -1 0 FIxx FISUB
6 5 2 5 -1 0 FIxx FISUBR
6 6 2 6 -1 0 FIxx FIDIV
6 7 2 7 -1 0 FIxx FIDIVR
7 2 3 2 -1 0 FIxx FIST
7 0 3 0 7 5 FIxx FILD
7 3 3 3 7 7 FIxx FISTP
1 2 0 F0Op FNOP
1 4 0 F0Op FCHS
1 4 1 F0Op FABS
1 4 4 F0Op FTST
1 4 5 F0Op FXAM
1 5 0 F0Op FLD1
1 5 1 F0Op FLDL2T
1 5 2 F0Op FLDL2E
1 5 3 F0Op FLDPI
1 5 4 F0Op FLDLG2
1 5 5 F0Op FLDLN2
1 5 6 F0Op FLDZ
1 6 0 F0Op F2XM1
1 6 1 F0Op FYL2X
1 6 2 F0Op FPTAN
1 6 3 F0Op FPATAN
1 6 4 F0Op FXTRACT
1 6 5 F0Op FPREM1
1 6 6 F0Op FDECSTP
1 6 7 F0Op FINCSTP
1 7 0 F0Op FPREM
1 7 1 F0Op FYL2XP1
1 7 2 F0Op FSQRT
1 7 3 F0Op INCOS
1 7 4 F0Op FRNDINT
1 7 5 F0Op FSCALE
1 7 6 F0Op FSIN
1 7 7 F0Op FCOS
2 5 1 F0Op FUCOMPP
3 4 0 F0Op FNENI
3 4 1 F0Op FNDISI
3 4 2 F0Op FNCLEX
3 4 3 F0Op FNINIT
6 3 1 F0Op FCOMPP
3 4 0 FW0Op FENI
3 4 1 FW0Op FDISI
3 4 2 FW0Op FCLEX
3 4 3 FW0Op FINIT
3 4 4 FW0Op FSETPM
0x9B 0 1 4 FCtl FLDENV
0 0 1 5 FCtl FLDCW
0x9B 0 1 6 FCtl FSTENV
0x9B 0 1 7 FCtl FSTCW
0x9B 0 5 4 FCtl FRSTOR
0x9B 0 5 6 FCtl FSAVE
0 0 1 4 FCtl FNLDENV
0 0 1 6 FCtl FNSTENV
0 0 1 7 FCtl FNSTCW
0 0 5 4 FCtl FNRSTOR
0 0 5 6 FCtl FNSAVE
0x9B 2 1 4 FCtl FLDENVW
0x9B 2 1 6 FCtl FSTENVW
0x9B 2 5 4 FCtl FRSTORW
0x9B 2 5 6 FCtl FSAVEW
0x9B 4 1 4 FCtl FLDENVD
0x9B 4 1 6 FCtl FSTENVD
0x9B 4 5 4 FCtl FRSTORD
0x9B 4 5 6 FCtl FSAVED
0 2 1 4 FCtl FNLDENVW
0 2 1 6 FCtl FNSTENVW
0 2 5 4 FCtl FNRSTORW
0 2 5 6 FCtl FNSAVEW
0 4 1 4 FCtl FNLDENVD
0 4 1 6 FCtl FNSTENVD
0 4 5 4 FCtl FNRSTORD
0 4 5 6 FCtl FNSAVED
4 FBxx FBLD
6 FBxx FBSTP
1 1 FRegOp FXCH
5 0 FRegOp FFREE
5 4 FRegOp FUCOM
5 5 FRegOp FUCOMP
6 0 FRegOp FADDP
6 1 FRegOp FMULP
6 4 FRegOp FSUBRP
6 5 FRegOp FSUBP
6 6 FRegOp FDIVRP
6 7 FRegOp FDIVP
2 0 FP6Op FCMOVB
2 1 FP6Op FCMOVE
2 2 FP6Op FCMOVBE
2 3 FP6Op FCMOVU
3 0 FP6Op FCMOVNB
3 1 FP6Op FCMOVNE
3 2 FP6Op FCMOVNBE
3 3 FP6Op FCMOVNU
3 5 FP6Op FUCOMI
3 6 FP6Op FCOMI
7 5 FP6Op FUCOMIP
7 6 FP6Op FCOMIP
: FWAIT WAIT ;
0x66 1Op1 D32
0x67 1Op1 A32
0xD6 1Op1 SETALC
0xF1 1Op1 ICEBP
0x0F06 1Op2 CLTS
0x0F08 1Op2 INVD
0x0F09 1Op2 WBINVD
0x0F0B 1Op2 UD2
0x0F30 1Op2 WRMSR
0x0F31 1Op2 RDTSC
0x0F32 1Op2 RDMSR
0x0F33 1Op2 RDPMC
0x0F34 1Op2 SYSENTER
0x0F35 1Op2 SYSEXIT
0x0FA2 1Op2 CPUID
0x0FAA 1Op2 RSM
0xD9FB 1Op2 FSINCOS
0xC3 0xC2 RETx RETN
0xCB 0xCA RETx RETF
0xD4 AAx AAM
0xD5 AAx AAD
0x0F02 LxxCMOV LAR
0x0F03 LxxCMOV LSL
0x0F40 LxxCMOV CMOVO
0x0F41 LxxCMOV CMOVNO
0x0F42 LxxCMOV CMOVB
0x0F43 LxxCMOV CMOVNB
0x0F44 LxxCMOV CMOVE
0x0F45 LxxCMOV CMOVNE
0x0F46 LxxCMOV CMOVBE
0x0F47 LxxCMOV CMOVNBE
0x0F48 LxxCMOV CMOVS
0x0F49 LxxCMOV CMOVNS
0x0F4A LxxCMOV CMOVP
0x0F4B LxxCMOV CMOVNP
0x0F4C LxxCMOV CMOVL
0x0F4D LxxCMOV CMOVNL
0x0F4E LxxCMOV CMOVLE
0x0F4F LxxCMOV CMOVNLE
: CMOVNAE CMOVB ;
: CMOVAE CMOVNB ;
: CMOVZ CMOVE  ;
: CMOVNZ CMOVNE ;
: CMOVNA CMOVBE  ;
: CMOVA CMOVNBE ;
: CMOVPE CMOVP ;
: CMOVPO CMOVNP ;
: CMOVNGE CMOVL ;
: CMOVGE CMOVNL ;
: CMOVNG CMOVLE ;
: CMOVG CMOVNLE ;
0x0FB0 0x0FB1 P5Op CMPXCHG
0x0FC0 0x0FC1 P5Op XADD
0x0F00 0 SysOp16 SLDT
0x0F00 1 SysOp16 STR
0x0F00 2 SysOp16 LLDT
0x0F00 3 SysOp16 LTR
0x0F01 4 SysOp16 SMSW
0x0F01 6 SysOp16 LMSW
0x0F00 4 SysOp16 VERR
0x0F00 5 SysOp16 VERW
0 SysOp64 SGDT
1 SysOp64 SIDT
2 SysOp64 LGDT
3 SysOp64 LIDT
7 SysOp64 INVLPG
0x0F77 1Op2 EMMS
0x0F60 4 MMXOp PUNPCKLBW
0x0F61 4 MMXOp PUNPCKLWD
0x0F62 4 MMXOp PUNPCKLDQ
0x0F63 8 MMXOp PACKSSWB
0x0F64 8 MMXOp PCMPGTB
0x0F65 8 MMXOp PCMPGTW
0x0F66 8 MMXOp PCMPGTD
0x0F67 8 MMXOp PACKUSWB
0x0F68 8 MMXOp PUNPCKHBW
0x0F69 8 MMXOp PUNPCKHWD
0x0F6A 8 MMXOp PUNPCKHDQ
0x0F6B 8 MMXOp PACKSSDW
0x0F74 8 MMXOp PCMPEQB
0x0F75 8 MMXOp PCMPEQW
0x0F76 8 MMXOp PCMPEQD
0x0FD5 8 MMXOp PMULLW
0x0FD8 8 MMXOp PSUBUSB
0x0FD9 8 MMXOp PSUBUSW
0x0FDB 8 MMXOp PAND
0x0FDC 8 MMXOp PADDUSB
0x0FDD 8 MMXOp PADDUSW
0x0FDF 8 MMXOp PANDN
0x0FE5 8 MMXOp PMULHW
0x0FE8 8 MMXOp PSUBSB
0x0FE9 8 MMXOp PSUBSW
0x0FEB 8 MMXOp POR
0x0FEC 8 MMXOp PADDSB
0x0FED 8 MMXOp PADDSW
0x0FEF 8 MMXOp PXOR
0x0FF5 8 MMXOp PMADDWD
0x0FF8 8 MMXOp PSUBB
0x0FF9 8 MMXOp PSUBW
0x0FFA 8 MMXOp PSUBD
0x0FFC 8 MMXOp PADDB
0x0FFD 8 MMXOp PADDW
0x0FFE 8 MMXOp PADDD
0x0F6E 0x0F7E 4 MOVx MOVD
0x0F6F 0x0F7F 8 MOVx MOVQ
0x0FD1 0x0F71 2 MMXShift PSRLW
0x0FD2 0x0F72 2 MMXShift PSRLD
0x0FD3 0x0F73 2 MMXShift PSRLQ
0x0FE1 0x0F71 4 MMXShift PSRAW
0x0FE2 0x0F72 4 MMXShift PSRAD
0x0FF1 0x0F71 6 MMXShift PSLLW
0x0FF2 0x0F72 6 MMXShift PSLLD
0x0FF3 0x0F73 6 MMXShift PSLLQ

PREVIOUS
PREVIOUS DEFINITIONS

