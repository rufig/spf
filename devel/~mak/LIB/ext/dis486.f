\ $ID: DIS486.F,V 1.20 2007/05/14 16:01:00 ALEX_MCDONALD EXP $

\ 80386 DISASSEMBLER
\ ------------------------------------------------------------------------

\ COPYRIGHT [C] 2005 BY ALEX MCDONALD (ALEX AT RIVADPM DOT COM)
\                       DIRK BUSCH    (DIRK.YAHOO @ SCHNEIDER-BUSCH.DE)
\                       GEORGE HUBERT (GEORGEAHUBERT AT YAHOO.CO.UK)

\ BASED ON WORK BY TOM ZIMMER AND OTHERS

\
\ THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY IT
\ UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY THE
\ FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR <AT YOUR
\ OPTION> ANY LATER VERSION.
\
\ THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT
\ WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF
\ MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE.  SEE THE GNU
\ GENERAL PUBLIC LICENSE FOR MORE DETAILS.
\
\ YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE ALONG
\ WITH THIS PROGRAM; IF NOT, WRITE TO THE FREE SOFTWARE FOUNDATION, INC.,
\ 675 MASS AVE, CAMBRIDGE, MA 02139, USA.
\
\ <\dbg>

\ ------------------------------------------------------------------------
REQUIRE [IF] ~MAK\CompIF1.f
REQUIRE [IFNDEF] ~nn\lib\ifdef.f
REQUIRE CASE         ~MAK\case.f
REQUIRE { ~mak\locals4.f

[IFNDEF] NEAR_NFA
 : NEAR_NFA ( addr -- NFA addr | 0 addr ) DUP  WordByAddr DROP 1- SWAP
        2DUP 1000 - U< IF NIP 0 SWAP THEN ;
[THEN]

REQUIRE NextNFA lib\ext\vocs.f

[IFNDEF] >= : >= < 0= ; [THEN]

[IFNDEF] TAB : TAB 9 EMIT ; [THEN]

[IFNDEF] DEFER : DEFER VECT ; [THEN]
[IFNDEF] DUP>R : DUP>R POSTPONE DUP POSTPONE >R ; IMMEDIATE  [THEN]

[IFNDEF] 
: ARSHIFT
 0x80000000 OVER RSHIFT >R
 RSHIFT  R@ XOR R> - ;
[THEN]

[IFNDEF] Z"
 : Z" POSTPONE S" POSTPONE DROP ; IMMEDIATE
[THEN]

[IFNDEF] WCOUNT : WCOUNT DUP	2+ SWAP W@ ; [THEN]
[IFNDEF] LCOUNT : LCOUNT DUP CELL+ SWAP  @ ; [THEN]

[IFNDEF] H.
: H.           ( n1 n2 -- )    \ display n1 as a HEX number of n2 digits
                BASE @ >R U.  R> BASE ! ;
[THEN]

[IFNDEF] $. : $. ." 0x" H. ; [THEN]

[IFNDEF] D.R : D.R ( d w -- ) >R (D.) R> OVER - SPACES TYPE ; [THEN]
[IFNDEF] .R  : .R  ( n w -- ) >R S>D R> D.R ; [THEN]
[IFNDEF] H.R
: H.R           ( n1 n2 -- )    \ display n1 as a hex number right
                                \ justified in a field of n2 characters
                BASE @ >R HEX >R
                0 <# #S #> R> OVER - 0 MAX SPACES TYPE
                R> BASE ! ; [THEN]
[IFNDEF] H.N
: H.N           ( n1 n2 -- )    \ display n1 as a HEX number of n2 digits
                BASE @ >R HEX >R
                0 <# R> 0 ?DO # LOOP #> TYPE
                R> BASE ! ; [THEN]


[IFNDEF] PERFORM  : PERFORM  ( n w -- ) @ EXECUTE ; [THEN]

[IFNDEF] COLS 80 VALUE COLS [THEN]
[IFNDEF] @+ : @+  ( ADDR -- ADDR N )  DUP CELL+ SWAP @ ; [THEN]

CR .( LOADING 80486 DISASSEMBLER...)

ONLY FORTH ALSO DEFINITIONS

VOCABULARY DISASSEMBLER
DISASSEMBLER ALSO DEFINITIONS
DECIMAL

\ VAR/VALUES ARE ALL DIS.<NAME> SO IT'S EASIER TO SEE THAT THEY AREN'T
\ FUNCTIONS.  MOST DISPLAY FUNCTIONS ARE PRECEDED BY DOT (FOR PRINT).
\ DEMULTIPLIXING FUNCTIONS HAVE A PARAMETERLIST AS PART OF THEIR NAME,
\ OFTEN SIGNIFYING WHICH BITS ARE BEING USED.

\ PSEUDO OBJECT DIS FOR ALL THE VARS USED BY THE DISASSEMBLER
0 VALUE DIS.16BIT               \ START IN 32 BIT MODE
0 VALUE DIS.BASE-ADDR           \ NO OFFSET BY DEFAULT
0 VALUE DIS.SIZE                \ SIZE OF DATA IN OPCODE (FALSE=8BIT REG, TRUE=16/32BIT REG)
0 VALUE DIS.DATA16              \ 16 BIT DATA
0 VALUE DIS.ADDR16              \ 16 BIT ADDRESS
0 VALUE DIS.PREFIX-OP           \ PREFIX OPERATOR (LIKE CS: REP ETC)
0 VALUE DIS.MMX-REG?            \ DISPLAY AS MMX REG

\ -----------------------------------------------------------------------
\                     DISASSEMBLER UTILITIES
\ -----------------------------------------------------------------------

\ : DEFAULT-16BIT ( -- ) TRUE  TO 16BIT ;
\ : DEFAULT-32BIT ( -- ) FALSE TO 16BIT ;



C" NEAR_NFA" FIND NIP 0=
[IF] : NEAR_NFA ( addr -- NFA addr | 0 addr ) DUP  WordByAddr DROP 1- SWAP
        2DUP 1000 - U< IF NIP 0 SWAP THEN ;
[THEN]

: ?.NAME      ( CFA -- )
\ ELIMINATE " 0x"
                DUP   H.
                NEAR_NFA 
                >R DUP
                IF ."  ( " DUP COUNT TYPE
                     NAME> R> - DUP
                     IF   DUP ." +" NEGATE H.
                     THEN DROP        ."  ) "
                ELSE RDROP DROP
                THEN
                ;

  DEFER SHOW-NAME   ( CFA -- )      \ DISPLAY NEAREST SYMBOL

' ?.NAME TO SHOW-NAME


: DIS-LOC ( ADDR -- )                                \ DISPLAY DISASM LOCATION
        DUP ." ( 0x" SHOW-NAME ." ) " ;

\ -----------------------------------------------------------------------
\                           DISPLAY ROUTINES
\ -----------------------------------------------------------------------

: OPER-COL ( TAB ) ; \  32 COL ; \ SET TO OPERATOR FIELD
: OPND-COL ( TAB ) ; \  38 COL ; \ SET TO OPERAND FIELD
: CMNT-COL ( TAB ) ; \  60 COL ; \ SET TO COMMENT FIELD

: .SS     ( N ADR W )  OPER-COL
 DUP>R ROT
 *
 +
 R>
 TYPE
 OPND-COL
;

: (.SOP") ( A N -- )      OPER-COL TYPE TAB OPND-COL ;
: .SOP"   ( <-NAME-> -- ) POSTPONE S" POSTPONE (.SOP") ; IMMEDIATE

: .WORD       ." WORD " ;
: .DWORD      ." DWORD " ;
: .FLOAT      ." FLOAT " ;
: .DOUBLE     ." DOUBLE " ;
: .EXTENDED   ." EXTENDED " ;
: .QWORD      ." QWORD " ;
: .TBYTE      ." TBYTE " ;
: .FAR        ." FAR " ;

: .#      ( -- )          ." # " ;
: .,      ( -- )          ." , " ;

: .AL,        ." AL, " ;
: .AX,        ." AX, " ;
: .EAX,       ." EAX, " ;
: .DX         ." DX" ;
: .,CL        ." , CL"  ;

: ???     ( N1 -- )       .SOP" ???" DROP ;
: .SOP-FWAIT .SOP" FWAIT" ;
: .SOP-MOV   .SOP" MOV"   ;

\ ----------------------- UTILITY WORDS --------------------------

: SEXT  ( BYTE -- N )  24 LSHIFT 24 ARSHIFT ;  \ SIGN EXTEND A BYTE

: PARSE/SIB ( SS-III-BBB -- BBB III SS ) \ R INCLUDING GENERAL, SPECIAL, SEGMENT, MMX
   255 AND
 8 /MOD
 8 /MOD
 ;

\ ' PARSE/SIB ALIAS PARSE/MODR/M
: PARSE/MODR/M PARSE/SIB ;
    \ MOD-R-R/M -- 3BITS=R/M 3BITS=R/OP 2BITS=MOD
    \ R/OP INCLUDES GENERAL, SPECIAL, SEGMENT, MMX REGISTERS OR EXTENDED OPCODE

: BITS0-1       ( N -- N' ) 0x3 AND ;              \ ISOLATE BITS 0 THRU 1
: BITS0-2       ( N -- N' ) 0x7 AND ;              \ ISOLATE BITS 0 THRU 2
: BITS0-3       ( N -- N' ) 0xF AND ;              \ ISOLATE BITS 0 THRU 3
: BITS3-5       ( N -- N' ) 3 RSHIFT BITS0-2 ;       \ ISOLATE BITS 3 THRU 5
: BITS3-4       ( N -- N' ) 3 RSHIFT BITS0-1 ;       \ ISOLATE BITS 3 THRU 4
: BITS4-5       ( N -- N' ) 4 RSHIFT BITS0-1 ;       \ ISOLATE BITS 4 THRU 5
: BIT3          ( N -- F )  0x8 AND 0x8 = ;
: BIT2          ( N -- F )  0x4 AND 0x4 = ;
: BIT1          ( N -- F )  0x2 AND 0x2 = ;
: BIT0          ( N -- F )  0x1 AND 0x1 = ;

: .COND  ( CC -- )   BITS0-3 Z" O NOB AEE NEBEA S NSP NPL GELEG " 2 .SS ;  \ WAS TTTN
: .SREG  ( SR -- )   BITS3-5 Z" ESCSSSDSFSGS????"                 2 .SS ;
: .CREG  ( CR -- )   BITS3-5 Z" CR0???CR2CR3CR4?????????"         3 .SS ;
: .DREG  ( DR -- )   BITS3-5 Z" DR0DR1DR2DR3??????DR6DR7"         3 .SS ;
: .TREG  ( TR -- )   BITS3-5 Z" ?????????TR3TR4TR5TR6TR7"         3 .SS ; \ OBSOLETE
: .REGM  ( N -- )    BITS0-2 Z" MM0MM1MM2MM3MM4MM5MM6MM7"         3 .SS ;
: .REG8  ( N -- )    BITS0-2 Z" ALCLDLBLAHCHDHBH"                 2 .SS ;
: .REG16 ( N -- )    BITS0-2 Z" AXCXDXBXSPBPSIDI"                 2 .SS ;
: .REG32 ( N -- )  
  BITS0-2
 Z" EAXECXEDXEBXESPEBPESIEDI"
         3
 .SS
 ;
: .REG16/32 ( N -- ) DIS.DATA16 IF
 .REG16
 ELSE
 .REG32
 THEN ;

: .[IND16]  ( R/M -- ) BITS0-1 Z" [BX+SI][BX+DI][BP+SI][BP+DI]"    7 .SS ; \ R/M = 0, 1, 2, 3
: .[BASE16] ( R/M -- ) BITS0-1 Z" [SI][DI][BP][BX]"                4 .SS ; \ R/M = 4, 5, 6, 7
: .[REG16]  ( R/M -- ) BIT2 IF .[IND16] ELSE .[BASE16] THEN ;

: .REG      ( N -- )
        DIS.MMX-REG? IF .REGM
        ELSE DIS.SIZE IF .REG16/32
          ELSE .REG8
          THEN
        THEN ;

: .REL8      ( ADDR -- ADDR' )
        COUNT SEXT OVER + ." SHORT " SHOW-NAME ;

: .REL16/32  ( ADDR -- ADDR' )  
        DIS.ADDR16 IF
          WCOUNT ELSE LCOUNT
        THEN OVER + DIS.BASE-ADDR - SHOW-NAME ;

: .DISP8  ( ADR -- ADR' )     COUNT SEXT ." 0x" BASE @ >R HEX . R> BASE ! ;
: .DISP16 ( ADR -- ADR' )     WCOUNT SHOW-NAME ;
: .DISP32 ( ADR -- ADR' )     LCOUNT SHOW-NAME ;
: .DISP16/32 ( ADR -- ADR' )  DIS.ADDR16 IF .DISP16 ELSE .DISP32 THEN ;

: .IMM8   ( ADR -- ADR' )     .# .DISP8 ;
: .IMM16/32  ( ADR -- ADR' )  .# DIS.DATA16 IF .DISP16 ELSE .DISP32 THEN ;

: .[REG32   ( REG -- )
 ." ["
 .REG32
 ;
: .[REG32]  ( REG -- ) .[REG32 ." ]" ;
: .[REG*N]  ( SIB -- ) PARSE/SIB SWAP .[REG32 DUP 2* + Z" ]  *2]*4]*8]" + 3 -TRAILING TYPE DROP ;

\ -----------------------------------------------------------------------
\                       DEMULTIPLEXING MECHANISM
\ -----------------------------------------------------------------------

: .SIB=NN   ( ADR MOD -- ADR )
        >R COUNT TUCK BITS0-2 5 = R@ 0= AND
        IF    .DISP32 SWAP .[REG*N] RDROP       \ EBP BASE AND MOD = 00
        ELSE  R> CASE ( MOD )
                   1 OF .DISP8  ENDOF
                   2 OF .DISP32 ENDOF
                 ENDCASE
              SWAP DUP .[REG32] SPACE .[REG*N]
        THEN ;

: MOD-R/M32     ( ADR R/M MOD -- ADR' )
                DUP 3 =
                IF    DROP .REG             \ MOD = 3, REGISTER CASE
                ELSE  OVER 4 =
                      IF NIP .SIB=NN                    \ R/M = 4, SIB CASE
                      ELSE  2DUP 0= SWAP 5 = AND        \ MOD = 0, R/M = 5,
                            IF 2DROP .DISP32      \ DISP32 CASE
                            ELSE ROT SWAP
                                 CASE ( MOD )
                                   1 OF .DISP8  ENDOF
                                   2 OF .DISP32 ENDOF
                                 ENDCASE
                                 SWAP .[REG32]
                            THEN
                      THEN
                THEN ;

: MOD-R/M16     ( ADR R/M MOD -- ADR' )
    2DUP 0= SWAP 6 = AND
    IF   2DROP .DISP16            \ DISP16 CASE
    ELSE CASE ( MOD )
           0 OF .[REG16]                            ENDOF
           1 OF SWAP .DISP8  SWAP .[REG16]    ENDOF
           2 OF SWAP .DISP16 SWAP .[REG16]    ENDOF
           3 OF .REG                                ENDOF
         ENDCASE
    THEN ;

: MOD-R/M ( ADR MODR/M -- ADR' )
    PARSE/MODR/M NIP DIS.ADDR16
    IF    MOD-R/M16
    ELSE  MOD-R/M32
    THEN ;

: R/M8      0 TO DIS.SIZE MOD-R/M ;
: R/M16/32  1 TO DIS.SIZE MOD-R/M ;
: R/M16     TRUE TO DIS.DATA16 R/M16/32 ;

: R,R/M  ( ADR -- ADR' )
    COUNT DUP
 BITS3-5
 .REG
 .,
 MOD-R/M ;        ( OP/REG->REG/M )

: R/M,R  ( ADR -- ADR' )
    COUNT DUP
 >R
 MOD-R/M
 ., 
 R>
 BITS3-5
 .REG ;

: R/M  ( ADR OP -- ADR' )
    BIT1 IF R,R/M ELSE R/M,R THEN ;

\ -------------------- SIMPLE OPCODES --------------------

: OPSTR  ( -- "NAME" )
         CREATE PARSE-NAME S", ;

: INH   ( -<NAME>- )
        OPSTR DOES> COUNT (.SOP") DROP ;

INH CLC  CLC
INH STC  STC
INH CLI  CLI
INH STI  STI
INH CLD  CLD
INH STD  STD
INH CWDE CWDE
INH CDQ  CDQ
INH DAA  DAA
INH DAS  DAS
INH AAA  AAA
INH AAS  AAS
INH INB  INSB
INH OSB  OUTSB
INH SAH  SAHF
INH LAH  LAHF
INH HLT  HLT
INH CMC  CMC
INH XLT  XLAT
INH CLT  CLTS
INH INV  INVD
INH WIV  WBINVD
INH UD2  UD2
INH WMR  WRMSR
INH RTC  RDTSC
INH RMR  RDMSR
INH RPC  RDPMC
INH EMS  EMMS
INH RSM  RSM
INH CPU  CPUID
INH UD1  UD1
INH LEV  LEAVE
INH IRT  IRET
INH NTO  INTO


\ -------------------- STRING OPS --------------------

: STR   ( ADDR CODE -- ADDR' )
        OPSTR DOES> OPER-COL COUNT TYPE BIT0 IF ." D" ELSE ." B" THEN CMNT-COL ;

STR MVS MOVS
STR CPS CMPS
STR STS STOS
STR LDS LODS
STR SCS SCAS

\ -------------------- PREFIX OPS --------------------

: PRE   ( -<NAME>- )
        OPSTR DOES> OPER-COL COUNT TYPE SPACE DROP TRUE TO DIS.PREFIX-OP ;

PRE CS: CS:
PRE DS: DS:
PRE SS: SS:
PRE ES: ES:
PRE GS: GS:
PRE FS: FS:
PRE RPZ REPNZ
PRE REP REPZ 
PRE LOK LOCK
\ PRE D16A D16:
\ PRE A16A A16:

: D16   ( ADR CODE -- ADR' ) DROP TRUE TO DIS.PREFIX-OP TRUE TO DIS.DATA16 ;
: A16   ( ADR CODE -- ADR' ) DROP TRUE TO DIS.PREFIX-OP TRUE TO DIS.ADDR16 ;

: AAM   ( ADR CODE -- ADR' ) .SOP" AAM" DROP COUNT DROP ;
: AAD   ( ADR CODE -- ADR' ) .SOP" AAD" DROP COUNT DROP ;

: ISD   ( ADR CODE -- ADR' ) DROP DIS.DATA16 IF .SOP" INSW" ELSE .SOP" INSD" THEN ;
: OSD   ( ADR CODE -- ADR' ) DROP DIS.DATA16 IF .SOP" OUTSW" ELSE .SOP" OUTSD" THEN ;

: INP/IND ( ADR CODE -- ADR' ) .SOP" IN" OPND-COL BIT0 IF DIS.DATA16 IF .AX, ELSE .EAX, THEN ELSE .AL, THEN ;
: INP   ( ADR CODE -- ADR' ) INP/IND COUNT $. ;
: IND   ( ADR CODE -- ADR' ) INP/IND .DX ;

: .OUT  ( ADR CODE -- ADR' ) .SOP" OUT" OPND-COL ;
: OTP/OTD ( ADR CODE -- ADR' ) BIT0 IF DIS.DATA16 IF ." , AX" ELSE ." , EAX" THEN ELSE ." , AL" THEN ;
: OTP   ( ADR CODE -- ADR' ) .OUT SWAP COUNT $. SWAP OTP/OTD ;
: OTD   ( ADR CODE -- ADR' ) .OUT .DX OTP/OTD ;

\ -------------------- ALU OPCODES --------------------

: .ALU  ( N -- )    
        BITS3-5
 Z" ADDOR ADCSBBANDSUBXORCMP"
 3
 .SS TAB ;

: ALU   ( ADR OP -- ADR' )
  DUP .ALU R/M ;

: ALI   ( ADR OP -- ADR' )
        >R COUNT
        DUP .ALU
        MOD-R/M .,
        R> BITS0-1 ?DUP
        IF      1 =
                IF      .IMM16/32
                ELSE    .# .DISP8
                THEN
        ELSE    .IMM8
        THEN ;

: ALA   ( ADR OP -- ADR' )
        DUP .ALU BIT0 IF .EAX, .IMM16/32 ELSE .AL, .IMM8 THEN ;

\ -------------------- TEST/XCHG --------------------

: TXB   ( ADDR OP -- ADDR' )
        DUP BIT1 NEGATE Z" TESTXCHG" 4 .SS
        BIT0 TO DIS.SIZE R,R/M
        ;

: TST   ( ADDR OP -- ADDR' )
        .SOP" TEST" BIT0
        IF      DIS.DATA16
                IF   .AX,
                ELSE .EAX,
                THEN
                .IMM16/32
        ELSE    .AL, .IMM8
        THEN
        ;

\ -------------------- PUSH/POP INC/DEC --------------------

: PPP   ( ADDR OP -- ADDR' )
        OPSTR DOES> COUNT OPER-COL TYPE DROP
          DIS.DATA16 0= IF ." D" THEN OPND-COL ;

PPP PSA PUSHA
PPP PPA POPA
PPP PSF PUSHF
PPP PPF POPF

: IDP   ( ADDR OP -- ADDR' )
        OPSTR DOES>
 COUNT
 (.SOP")
 .REG16/32
 ;

IDP INC INC
IDP DEC DEC
IDP PSH PUSH
IDP POP POP

: PSS   ( ADDR OP -- ADDR' ) .SOP" PUSH" .SREG ;
: PPS   ( ADDR OP -- ADDR' ) .SOP" POP"  .SREG ;
: 8F.   ( ADDR OP -- ADDR' ) DROP COUNT .SOP" POP" R/M16/32 ;
: PSI   ( ADDR OP -- ADDR' ) .SOP" PUSH" BIT1 IF .IMM8 ELSE .IMM16/32 THEN ;

\ -------------------- MOVE --------------------

: .MOV  ( ADDR OP -- ADDR' N M )
        .SOP-MOV DROP COUNT DUP ;

: MOV   ( ADDR OP -- ADDR' ) .SOP-MOV R/M ;
: MRI   ( ADDR OP -- ADDR' )
        .SOP-MOV DUP BIT3
        IF      .REG16/32 .IMM16/32
        ELSE    .REG8 .IMM8
        THEN ;

: MVI  ( ADR OP -- ADR' )   ( MOV MEM, IMM )
        .SOP-MOV DROP COUNT MOD-R/M .,
        DIS.SIZE       \ \\\\
        IF      .IMM16/32
        ELSE    .IMM8
        THEN
        ;

: MRS   ( ADDR OP -- ADDR' )
        DIS.DATA16
        IF      .MOV R/M16/32 ., .SREG
        ELSE    ???
        THEN ;

: MSR   ( ADDR OP -- ADDR' )
        DIS.DATA16
        IF      .MOV .SREG ., R/M16/32
        ELSE    ???
        THEN ;

: MRC   ( ADDR OP -- ADDR' ) .MOV .REG32 ., .CREG ;
: MCR   ( ADDR OP -- ADDR' ) .MOV .CREG  ., .REG32 ;
: MRD   ( ADDR OP -- ADDR' ) .MOV .REG32 ., .DREG ;
: MDR   ( ADDR OP -- ADDR' ) .MOV .DREG  ., .REG32 ;
: MRT   ( ADDR OP -- ADDR' ) .MOV .REG32 ., .TREG ;   \ OBSOLETE
: MTR   ( ADDR OP -- ADDR' ) .MOV .TREG  ., .REG32 ;  \ OBSOLETE

: MV1   ( ADDR OP -- ADDR' )
        .SOP-MOV BIT0
        IF      DIS.DATA16
                IF      .AX,
                ELSE    .EAX,
                THEN
        ELSE    ." AL , "
        THEN
        .DISP16/32 ;

: MV2   ( ADDR OP -- ADDR' )
        .SOP-MOV SWAP .DISP16/32 SWAP ., BIT0
        IF      DIS.DATA16
                IF      ."  AX"
                ELSE    ."  EAX"
                THEN
        ELSE    ."  AL"
        THEN ;

: LEA   ( ADDR OP -- ADDR' ) .SOP" LEA" DROP  1 TO DIS.SIZE R,R/M ;
: LXS   ( ADDR OP -- ADDR' ) BIT0 IF .SOP" LDS" ELSE .SOP" LES" THEN R,R/M ;
: BND   ( ADDR OP -- ADDR' ) .SOP" BOUND" DROP  1 TO DIS.SIZE R,R/M ;
: ARP   ( ADDR OP -- ADDR' ) .SOP" ARPL"  DROP  TRUE TO DIS.DATA16 1 TO DIS.SIZE R,R/M ;
: MLI   ( ADDR OP -- ADDR' ) \ 3 ADDR FORM OF IMUL
        1 TO DIS.SIZE
        .SOP" IMUL" SWAP R,R/M ., SWAP BIT1 IF .IMM8 ELSE .IMM16/32 THEN ;

\ -------------------- JUMPS AND CALLS --------------------

: JSR  ( ADDR OP -- ADDR' ) .SOP" CALL" DROP .REL16/32 ;
: JMP  ( ADDR OP -- ADDR' ) .SOP" JMP" BIT1 IF .REL8 ELSE .REL16/32 THEN ;

: .JXX ( ADDR OP -- ADDR' ) OPER-COL ." J" .COND OPND-COL ;
: BRA  ( ADDR OP -- ADDR' ) .JXX .REL8 ;
: LBR  ( ADDR OP -- ADDR' ) .JXX .REL16/32 ;

: LUP  ( ADDR OP -- ADDR' ) BITS0-1 Z" LOOPNZLOOPZ LOOP  JECXZ " 6 .SS .REL8 ;
: RTN  ( ADDR OP -- ADDR' ) .SOP" RET"     ." NEAR " BIT0 0= IF WCOUNT $. THEN ;
: RTF  ( ADDR OP -- ADDR' ) .SOP" RET"     .FAR      BIT0 0= IF WCOUNT $. THEN ;
: ENT  ( ADDR OP -- ADDR' ) .SOP" ENTER" DROP WCOUNT $. ., COUNT $. ;


: CIS   ( ADDR OP -- ADDR' )
        0x9A =
        IF      .SOP" CALL"
        ELSE    .SOP" JMP"
        THEN
        DIS.DATA16
        IF      ." PTR16:16 "
        ELSE    ." PTR16:32 "
        THEN
        COUNT MOD-R/M ;

INH IRP "INT"

: NT3   ( ADDR OP -- ADDR' ) IRP 3 $. ;
: INT   ( ADDR OP -- ADDR' ) IRP COUNT $. ;

\ -------------------- EXCHANGE --------------------

: XGA  ( ADDR OP -- ADDR' )
    DUP 0x90 =
    IF
        DROP .SOP" NOP"
    ELSE
        .SOP" XCHG" .EAX, .REG16/32
    THEN ;

\ -------------------- SHIFTS & ROTATES --------------------

: .SHIFT ( N -- ) BITS3-5 Z" ROLRORRCLRCRSHLSHRXXXSAR" 3 .SS ;

: SHF  ( ADDR OP -- ADDR' )
        >R COUNT
        DUP .SHIFT
        MOD-R/M .,
        R> 0xD2 AND
        CASE
           0xC0 OF COUNT $.      ENDOF
           0xD0 OF 1 $.          ENDOF
           0xD2 OF 1 .REG8       ENDOF
        ENDCASE ;

\ -------------------- EXTENDED OPCODES --------------------

: WF1  ( ADDR -- ADDR' )
        1+ COUNT DUP
        0x0C0 <
        IF      DUP
                BITS3-5
                CASE 6 OF     .SOP" FSTENV"       MOD-R/M   ENDOF
                     7 OF     .SOP" FSTCW"  .WORD MOD-R/M   ENDOF
                     2DROP 2 - DUP .SOP-FWAIT
                ENDCASE
        ELSE    DROP 2 - .SOP-FWAIT
        THEN ;

: WF2  ( ADDR -- ADDR' )
        1+ COUNT
        CASE 0xE2 OF   .SOP" FCLEX"  ENDOF
             0xE3 OF   .SOP" FINIT"  ENDOF
             SWAP 2 - SWAP .SOP-FWAIT
        ENDCASE ;

: WF3  ( ADDR -- ADDR' )
        1+ COUNT DUP BITS3-5
        CASE 6 OF     .SOP" FSAVE"           MOD-R/M   ENDOF
             7 OF     .SOP" FSTSW" .WORD MOD-R/M   ENDOF
             2DROP 2 - DUP .SOP-FWAIT
        ENDCASE ;

: WF4  ( ADDR -- ADDR' )
        1+ COUNT 0xE0 =
        IF      .SOP" FSTSW" ." AX "
        ELSE    2 - .SOP-FWAIT
        THEN ;

: FWAITOPS   ( ADDR OP -- ADDR' )
        CASE 0xD9 OF    WF1     ENDOF
             0xDB OF    WF2     ENDOF
             0xDD OF    WF3     ENDOF
             0xDF OF    WF4     ENDOF
             .SOP-FWAIT
        ENDCASE ;

: W8F   ( ADDR OP -- ADDR' )
        DROP DUP C@ DUP 0xF8 AND 0xD8 =
        IF      FWAITOPS
        ELSE    DROP .SOP" WAIT"
        THEN ;

: FALU1   ( XOPCODE -- )   BITS3-5 Z" FADD FMUL FCOM FCOMPFSUB FSUBRFDIV FDIVR"         5 .SS ;
: FALU3   ( OP -- )        BITS3-5 Z" FIADD FIMUL FICOM FICOMPFISUB FISUBRFIDIV FIDIVR" 6 .SS ;
: FALU5   ( XOPCODE -- )   BITS3-5 Z" FADD FMUL ???? ???? FSUBRFSUB FDIVRFDIV "         5 .SS ;
: FALU6   ( OP -- )        BITS3-5 Z" FFREE ???   FST   FSTP  FUCOM FUCOMP???   ???   " 6 .SS ;
: FALU7   ( OP -- )        BITS3-5 Z" FADDP FMULP ???   ???   FSUBRPFSUBP FDIVRPFDIVP " 6 .SS ;

: .STI   ( OP -- )         BITS0-2 ." ST(" 1 .R ." )" ;

: FD8   ( ADDR OPCODE -- ADDR' )
        DROP COUNT DUP FALU1
        DUP 0xC0 <
        IF      .SOP" FLOAT" MOD-R/M
        ELSE    DUP 0xF0 AND 0xD0 =
                IF      .STI
                ELSE    ." ST, " .STI
                THEN
        THEN ;

: FDC   ( ADDR OPCODE -- ADDR' )
        DROP COUNT
        DUP DUP 0xC0 <
        IF      FALU1 .DOUBLE MOD-R/M
        ELSE    FALU5 .STI ." , ST"
        THEN ;

: FNULLARY-F   ( OP -- )
        0x0F AND DUP 8 <
        IF
           Z" F2XM1  FYL2X  FPTAN  FPATAN FXTRACTFPREM1 FDECSTPFINCSTP"
        ELSE  8 -
           Z" FPREM  FYL2XP1FSQRT  FSINCOSFRNDINTFSCALE FSIN   FCOS   "
        THEN
        7 .SS ;

: FNULLARY-E   ( OP -- )
        0x0F AND DUP 8 <
        IF
           Z" FCHS   FABS   ???    ???    FTST   FXAM   ???    ???    "
        ELSE  8 -
           Z" FLD1   FLDL2T FLDL2E FLDPI  FLDLG2 FLDLN2 FLDZ   ???    "
        THEN
        7 .SS ;

: FNULLARY   ( OP -- )
        DUP 0xEF >
        IF      FNULLARY-F EXIT
        THEN
        DUP 0xE0 <
        IF      0xD0 =
                IF      .SOP" FNOP"
                ELSE    DUP ???
                THEN
                EXIT
        THEN
        FNULLARY-E ;

: FD9   ( ADDR OP -- ADDR' )
        DROP COUNT DUP 0xC0 <
        IF      DUP 0x38 AND
                CASE
                        0x00 OF .SOP" FLD"     .FLOAT  ENDOF
                        0x10 OF .SOP" FST"     .FLOAT  ENDOF
                        0x18 OF .SOP" FSTP"    .FLOAT  ENDOF
                        0x20 OF .SOP" FLDENV"          ENDOF
                        0x28 OF .SOP" FLDCW"   .WORD   ENDOF
                        0x30 OF .SOP" FNSTENV"         ENDOF
                        0x38 OF .SOP" FNSTCW"  .WORD   ENDOF
                            DUP ???
                ENDCASE
                MOD-R/M
        ELSE
                DUP 0xD0 <
                IF      DUP 0xC8 <
                        IF      .SOP" FLD"
                        ELSE    .SOP" FXCH"
                        THEN
                        .STI
                ELSE    FNULLARY
                THEN
        THEN ;


: FCMOVA  ( OP -- )
        BITS3-5
        Z" FCMOVB FCMOVE FCMOVBEFCMOVU ???    ???    ???    ???    "
        7  .SS ;

: FDA   ( ADDR OP -- )
        DROP COUNT DUP 0xC0 <
        IF      DUP FALU3 .DWORD MOD-R/M
        ELSE    DUP 0xE9 =
                IF      .SOP" FUCOMPP" DROP
                ELSE    DUP FCMOVA .STI
                THEN
        THEN ;

: FDE   ( ADDR OP -- ADDR' )
        DROP COUNT DUP 0xC0 <
        IF      DUP FALU3 .WORD MOD-R/M
        ELSE    DUP 0xD9 =
                IF    .SOP" FCOMPP" DROP
                ELSE  DUP FALU7 .STI
                THEN
        THEN ;

: FCMOVB  ( OP -- )
        BITS3-5
        Z" FCMOVNB FCMOVNE FCMOVNBEFCMOVNU ???     FUCOMI  FCOMI   ???     " 8 .SS ;

: FDB   ( ADDR OP -- ADDR' )
        DROP COUNT DUP 0xC0 <
        IF      DUP 0x38 AND
                CASE    0x00 OF .SOP" FILD"   .DWORD     ENDOF
                        0x10 OF .SOP" FIST"   .DWORD     ENDOF
                        0x18 OF .SOP" FISTP"  .DWORD     ENDOF
                        0x28 OF .SOP" FLD"    .EXTENDED  ENDOF
                        0x38 OF .SOP" FSTP"   .EXTENDED  ENDOF
                            DUP ???
                ENDCASE
                MOD-R/M
        ELSE
                CASE    0xE2 OF .SOP" FNCLEX" ENDOF
                        0xE3 OF .SOP" FNINIT" ENDOF
                            DUP DUP FCMOVB .STI
                ENDCASE
        THEN ;

: FDD   ( ADDR OP -- ADDR' )
        DROP COUNT DUP 0xC0 <
        IF      DUP 0x38 AND
                CASE    0x00 OF .SOP" FLD"     .DOUBLE   ENDOF
                        0x10 OF .SOP" FST"     .DOUBLE   ENDOF
                        0x18 OF .SOP" FSTP"    .DOUBLE   ENDOF
                        0x20 OF .SOP" FRSTOR"            ENDOF
                        0x30 OF .SOP" FNSAVE"            ENDOF
                        0x38 OF .SOP" FNSTSW"  .WORD     ENDOF
                            DUP ???
                ENDCASE
                MOD-R/M
        ELSE    DUP FALU6 .STI
        THEN ;

: FDF   ( ADDR OP -- ADDR' )
        DROP COUNT DUP 0xC0 <
        IF      DUP 0x38 AND
                CASE    0x00 OF .SOP" FILD"    .WORD    ENDOF
                        0x10 OF .SOP" FIST"    .WORD    ENDOF
                        0x18 OF .SOP" FISTP"   .WORD    ENDOF
                        0x20 OF .SOP" FBLD"    .TBYTE   ENDOF
                        0x28 OF .SOP" FILD"    .QWORD   ENDOF
                        0x30 OF .SOP" FBSTP"   .TBYTE   ENDOF
                        0x38 OF .SOP" FISTP"   .QWORD   ENDOF
                            DUP ???
                ENDCASE
                MOD-R/M
        ELSE    DUP 0xE0 =
                IF      .SOP" FNSTSW" ." AX " DROP
                ELSE    DUP 0x38 AND
                        CASE    0x00 OF .SOP" FFREEP" .STI ENDOF
                                0x28 OF .SOP" FUCOMIP" .STI ENDOF
                                0x30 OF .SOP" FCOMIP" .STI ENDOF
                                        ???
                        ENDCASE
                THEN
        THEN ;

: GP6 ( ADDR OP -- ADDR' )
        DROP COUNT DUP BITS3-5 Z" SLDTSTR LLDTLTR VERRVERW??? ???" 4 .SS R/M16 ;

: GP7 ( ADDR OP -- ADDR' )
        DROP COUNT DUP BITS3-5 DUP Z" SGDT  SIDT  LGDT  LIDT  SMSW  ???   LMSW  INVLPG" 6 .SS
        BIT2
        IF   R/M16
        ELSE R/M16/32
        THEN ;

: .BTX  ( N -- )   BITS3-4 Z" BT BTSBTRBTC" 3 .SS ;

: GP8 ( ADDR OP -- ADDR' )
        DROP COUNT DUP .BTX
        R/M16/32 .IMM8 ;

: LXX              ( ADDR CODE -- ADDR' )
                   OPSTR DOES> COUNT (.SOP") DROP R,R/M ;

: SHFD             ( ADDR CODE -- ADDR' )
                   OPSTR DOES> COUNT (.SOP") DROP R/M,R ;

LXX LAR LAR
LXX LSL LSL
LXX LSS LSS
LXX LFS LFS
LXX LGS LGS
LXX BSF BSF
LXX BSR BSR
LXX IML IMUL

SHFD SLD SHLD
SHFD SRD SHRD

: SLI ( ADDR OP -- ADDR' ) SLD .IMM8 ;
: SRI ( ADDR OP -- ADDR' ) SRD .IMM8 ;
: SLC ( ADDR OP -- ADDR' ) SLD .,CL ;
: SRC ( ADDR OP -- ADDR' ) SRD .,CL ;

: BTX ( ADDR OP -- ADDR' ) .BTX R/M,R ;
: CXC ( ADDR OP -- ADDR' ) .SOP" CMPXCHG" BIT0 TO DIS.SIZE R/M,R ;
: XAD ( ADDR OP -- ADDR' ) .SOP" XADD" BIT0 TO DIS.SIZE R/M,R ;
: CX8 ( ADDR OP -- ADDR' ) .SOP" CMPXCHG8B" DROP COUNT R/M16/32 ;
: BSP ( ADDR OP -- ADDR' ) .SOP" BSWAP" .REG32 ;


: MVX { ADDR OP \ OP2 -- ADDR' }
        ADDR OP
        DUP BIT3
        IF      .SOP" MOVSX"
        ELSE    .SOP" MOVZX"
        THEN
        BIT0 >R
        COUNT DUP TO OP2 PARSE/SIB R>                    \ SIZE BIT
        IF    SWAP .REG32 .,                     \ WORD TO DWORD CASE
              3 =
              IF   .REG16
              ELSE DROP
                   .WORD OP2 MOD-R/M
              THEN
        ELSE  SWAP .REG16/32 .,                  \ BYTE CASE
              3 =
              IF    .REG8
              ELSE DROP
                   ." BYTE " OP2 MOD-R/M
              THEN
        THEN
        ;

: F6.  ( ADDR OP -- ADDR' )
\ ??
        >R COUNT
        DUP BITS3-5 DUP >R
        Z" TEST??? NOT NEG MUL IMULDIV IDIV" 4 .SS TAB
        MOD-R/M
        R> 0= IF .,
                R@ BIT0 IF .IMM16/32
                         ELSE .IMM8
                         THEN
              THEN
        RDROP ;

: FE.  ( ADDR OP -- ADDR' )
        DROP COUNT
        DUP BITS3-5
        CASE
                0 OF .SOP" INC"  ENDOF
                1 OF .SOP" DEC"  ENDOF
                     ???
        ENDCASE R/M8 ;

: FF.  ( ADDR OP -- ADDR' )
        DROP COUNT
        DUP BITS3-5
        CASE
                0 OF .SOP" INC"      ENDOF
                1 OF .SOP" DEC"      ENDOF
                2 OF .SOP" CALL"     ENDOF
                3 OF .SOP" CALL" .FAR  ENDOF
                4 OF .SOP" JMP"      ENDOF
                5 OF .SOP" JMP"  .FAR  ENDOF
                6 OF .SOP" PUSH"      ENDOF
                     ???
        ENDCASE R/M16/32 ;


: X".  ( ADDR -- ADDR' )
\       CR DUP  DIS.BASE-ADDR - 6 H.R SPACE
        DUP C@ 2DUP DUMP
        + 2+
\       ."  C, " 1+ OVER + SWAP
\       DO I C@ 2 H.R  ."  C, " LOOP
\       COUNT  + 1+
;


\ --------------------- CONDITIONAL MOVE ---------------

: SET   ( ADR OP -- )
        OPER-COL ." SET" .COND OPND-COL  COUNT R/M8 ;
       

: CMV   ( ADR OP -- )
        OPER-COL ." CMOV" .COND OPND-COL R,R/M ;


\ --------------------- MMX OPERATIONS -----------------

: MMX-SIZE ( OP -- ) BITS0-1 Z" BWDQ" 1 .SS ;


: UPL   ( ADR OP -- ADR' ) BITS0-1 Z" PUNPCKLBWPUNPCKLWDPUNPCKLDQ" 9 .SS R,R/M ;
: UPH   ( ADR OP -- ADR' ) BITS0-1 Z" PUNPCKHBWPUNPCKHWDPUNPCKHDQ" 9 .SS R,R/M ;

: .PSX  ( OP -- )
        0x30 AND
        CASE
             0x10 OF .SOP" PSRL" ENDOF
             0x20 OF .SOP" PSRA" ENDOF
             0x30 OF .SOP" PSLL" ENDOF
             .SOP" ???"
        ENDCASE ;

: SHX   ( ADR OP -- ADR' )  DUP .PSX MMX-SIZE R,R/M ;

: GPA   ( ADR OP -- ADR' )
        \ XX00-XXXX -> ???
        >R COUNT DUP .PSX R> MMX-SIZE .REGM ., .IMM8 ;

: MPD   ( ADR OP -- ADR' )
        .SOP" MOVD" DROP COUNT PARSE/MODR/M
        SWAP .REGM ., 3 =
        IF   .REG32
        ELSE MOD-R/M
        THEN ;

: MDP   ( ADR OP -- ADR' )
        .SOP" MOVD" DROP COUNT PARSE/MODR/M
        SWAP 3 =
        IF   .REG32
        ELSE MOD-R/M
        THEN ., .REGM ;

: PAR   ( ADR OP -- ADR' )
        OPSTR DOES> COUNT (.SOP") MMX-SIZE R,R/M ;


PAR CGT PCMPGT
PAR CEQ PCMPEQ
PAR SUS PSUBUS
PAR SBS PSUBS
PAR SUB PSUB
PAR AUS PADDUS
PAR ADS PADDS
PAR ADD PADD

LXX PUW PACKUSDW
LXX PSB PACKSSWB
LXX PSW PACKSSDW
LXX MPQ MOVQ
LXX MLL PMULLW
LXX MLH PMULHW
LXX MAD PMADDWD
LXX PAD PAND
LXX POR POR
LXX PAN PANDN
LXX PXR PXOR

SHFD MQP MOVQ

\ -------------------- OPCODE TABLE --------------------

: OPS 0x10 0 DO ' , LOOP ;

CREATE OP2-TABLE

\     0   1   2   3    4   5   6   7    8   9   A   B    C   D   E   F

OPS  GP6 GP7 LAR LSL  ??? ??? CLT ???  INV WIV ??? UD2  ??? ??? ??? ???  \ 0
OPS  ??? ??? ??? ???  ??? ??? ??? ???  ??? ??? ??? ???  ??? ??? ??? ???  \ 1
OPS  MRC MRD MCR MDR  MRT ??? MTR ???  ??? ??? ??? ???  ??? ??? ??? ???  \ 2
OPS  WMR RTC RMR RPC  ??? ??? ??? ???  ??? ??? ??? ???  ??? ??? ??? ???  \ 3

OPS  CMV CMV CMV CMV  CMV CMV CMV CMV  CMV CMV CMV CMV  CMV CMV CMV CMV  \ 4
OPS  ??? ??? ??? ???  ??? ??? ??? ???  ??? ??? ??? ???  ??? ??? ??? ???  \ 5
OPS  UPL UPL UPL PUW  CGT CGT CGT PSB  UPH UPH UPH PSW  ??? ??? MPD MPQ  \ 6
OPS  ??? GPA GPA GPA  CEQ CEQ CEQ EMS  ??? ??? ??? ???  ??? ??? MDP MQP  \ 7

OPS  LBR LBR LBR LBR  LBR LBR LBR LBR  LBR LBR LBR LBR  LBR LBR LBR LBR  \ 8
OPS  SET SET SET SET  SET SET SET SET  SET SET SET SET  SET SET SET SET  \ 9
OPS  PSS PPS CPU BTX  SLI SLC ??? ???  PSS PPS RSM BTX  SRI SRC ??? IML  \ A
OPS  CXC CXC LSS BTX  LFS LGS MVX MVX  ??? UD1 GP8 BTX  BSF BSR MVX MVX  \ B

OPS  XAD XAD ??? ???  ??? ??? ??? CX8  BSP BSP BSP BSP  BSP BSP BSP BSP  \ C
OPS  ??? SHX SHX SHX  ??? MLL ??? ???  SUS SUS ??? PAD  AUS AUS ??? PAN  \ D
OPS  ??? SHX SHX ???  ??? MLH ??? ???  SBS SBS ??? POR  ADS ADS ??? PXR  \ E
OPS  ??? ??? SHX SHX  ??? MAD ??? ???  SUB SUB SUB ???  ADD ADD ADD ???  \ F

\     0   1   2   3    4   5   6   7    8   9   A   B    C   D   E   F

: 0F.  ( ADR CODE -- )
        DROP COUNT DUP
        DUP 0x70 AND 0x50 0x80 WITHIN TO DIS.MMX-REG?
        CELLS OP2-TABLE + PERFORM
        0 TO DIS.MMX-REG? ;

CREATE OP1-TABLE

\     0   1   2   3    4   5   6   7    8   9   A   B    C   D   E   F

OPS  ALU ALU ALU ALU  ALA ALA PSS PPS  ALU ALU ALU ALU  ALA ALA PSS 0F.  \ 0
OPS  ALU ALU ALU ALU  ALA ALA PSS PPS  ALU ALU ALU ALU  ALA ALA PSS PPS  \ 1
OPS  ALU ALU ALU ALU  ALA ALA ES: DAA  ALU ALU ALU ALU  ALA ALA CS: DAS  \ 2
OPS  ALU ALU ALU ALU  ALA ALA SS: AAA  ALU ALU ALU ALU  ALA ALA DS: AAS  \ 3

OPS  INC INC INC INC  INC INC INC INC  DEC DEC DEC DEC  DEC DEC DEC DEC  \ 4
OPS  PSH PSH PSH PSH  PSH PSH PSH PSH  POP POP POP POP  POP POP POP POP  \ 5
OPS  PSA PPA BND ARP  FS: GS: D16 A16  PSI MLI PSI MLI  INB ISD OSB OSD  \ 6
OPS  BRA BRA BRA BRA  BRA BRA BRA BRA  BRA BRA BRA BRA  BRA BRA BRA BRA  \ 7

OPS  ALI ALI ??? ALI  TXB TXB TXB TXB  MOV MOV MOV MOV  MRS LEA MSR 8F.  \ 8
OPS  XGA XGA XGA XGA  XGA XGA XGA XGA CWDE CDQ CIS W8F  PSF PPF SAH LAH  \ 9
OPS  MV1 MV1 MV2 MV2  MVS MVS CPS CPS  TST TST STS STS  LDS LDS SCS SCS  \ A
OPS  MRI MRI MRI MRI  MRI MRI MRI MRI  MRI MRI MRI MRI  MRI MRI MRI MRI  \ B

OPS  SHF SHF RTN RTN  LXS LXS MVI MVI  ENT LEV RTF RTF  NT3 INT NTO IRT  \ C
OPS  SHF SHF SHF SHF  AAM AAD ??? XLT  FD8 FD9 FDA FDB  FDC FDD FDE FDF  \ D
OPS  LUP LUP LUP LUP  INP INP OTP OTP  JSR JMP CIS JMP  IND IND OTD OTD  \ E
OPS  LOK ??? RPZ REP  HLT CMC F6. F6.  CLC STC CLI STI  CLD STD FE. FF.  \ F

\     0   1   2   3    4   5   6   7    8   9   A   B    C   D   E   F



: VECT. ( ADDR -- ADDR' )
       CR DUP  DIS.BASE-ADDR - 6 H.R SPACE
       ."  A; " DUP @ 8 H.R DUP CELL+ SWAP @ ."  ,  \ " WordByAddr TYPE
;

: CONS. ( ADDR -- )
       CR DUP DIS.BASE-ADDR - 6 H.R SPACE
       ."  A; " @ 8 H.R ."  ,"
;

: USER. ( ADDR -- )
       CR DUP  DIS.BASE-ADDR - 6 H.R SPACE
       ."  A; " @ 8 H.R ."  , \ Relative in heap [hex]" \ CELL+
;

: UVAL. ( ADDR -- ADDR' )
       CR DUP  DIS.BASE-ADDR - 6 H.R SPACE
       ."  A; " DUP @ 8 H.R ."  , \ Relative in heap [hex]" CELL+
;

: CODE. ( ADDR -- )
        DUP NextNFA
        ?DUP
        IF OVER - 5 -
        ELSE
           DUP DP @ SWAP - ABS DUP 512 > IF DROP 40 THEN \ no applicable end found
        THEN
        ." Size of data: ~" DUP .
        DUMP
;

[DEFINED] G. [IF]

: FLIT8.  ( ADDR -- ADDR' )
       ." FLITERAL: "
       DUP DF@ G.  8 +
;

: FLIT10.  ( ADDR -- ADDR' )
       ." FLITERAL: "
       DUP F@ G.  10 +
;

[ELSE]

: FLIT8.
       CR DUP  DIS.BASE-ADDR - 6 H.R SPACE
       ."  A; " DUP 8 OVER + SWAP
       DO I C@ 3 H.R ."  C," LOOP
       8 +
;

: FLIT10. ( ADDR -- ADDR' )
       CR DUP  DIS.BASE-ADDR - 6 H.R SPACE
       ."  A; "  DUP 10 OVER + SWAP
       DO I C@ 3 H.R ."  C," LOOP
       10 +
;

[THEN]

\ -----------------------------------------------------------------------
\ USER INTERFACE
\ -----------------------------------------------------------------------

: DIS-OP  ( ADR -- ADR' )
        COUNT
        DUP BIT0 TO DIS.SIZE
        DUP CELLS OP1-TABLE + PERFORM
        DIS.PREFIX-OP 0= IF
          DIS.16BIT TO DIS.DATA16
          DIS.16BIT TO DIS.ADDR16
        THEN
        DIS.PREFIX-OP IF
          0 TO DIS.PREFIX-OP 
          RECURSE
        THEN ;

' NOOP VALUE NEXT-INST


: INST  ( ADR -- ADR' )
\        DUP DIS-LOC
        COLS 0x29 <
        IF      DIS-OP
        ELSE
		DUP	DIS.BASE-ADDR - 6 H.R TAB \ SPACE 
                DUP	DIS-OP
\		OVER	DIS.BASE-ADDR - 6 H.R SPACE
                DUP ROT
                2DUP - DUP>R 0x10 U> ABORT" DECOMPILER ERROR"
		TAB ." \ "
                DO I C@ 2 H.N LOOP
                R> 5 < IF 9 EMIT THEN
\                9 EMIT S-BUF COUNT TYPE
        THEN    NEXT-INST C@ 0xE8 =
                IF  NEXT-INST 1+ @+ SWAP +
                    CASE
                   ['] _CLITERAL-CODE OF  X".   ENDOF
                   ['] _SLITERAL-CODE OF  X".   ENDOF
                   ['] _VECT-CODE     OF  VECT. 2DROP RDROP ENDOF
                   ['] _CONSTANT-CODE OF  CONS. DROP RDROP ENDOF
                   ['] _USER-CODE     OF  USER. DROP RDROP ENDOF
                   ['] _CREATE-CODE   OF  CODE. DROP RDROP ENDOF
                   ['] _USER-VALUE-CODE OF UVAL. ENDOF
                   ['] _FLIT-CODE10   OF  FLIT10. ENDOF
                   ['] _FLIT-CODE8    OF  FLIT8. ENDOF
                    ENDCASE
                THEN  ;

: .DB   CR ." DB " COUNT $. ;
: .DW   CR ." DW " WCOUNT $. ;
: .DD   CR ." DD " LCOUNT $. ;
: .DS   CR ." STRING " 0x22 EMIT COUNT 2DUP TYPE + 0x22 EMIT ;

: FIND-REST-END ( xt -- addr | 0)
    DUP NextNFA DUP
    IF
      NIP
      NAME>C 1- \ Skip CFA field
    ELSE
      DROP
      DP @ - ABS 100 > IF 0 EXIT THEN \ no applicable end found
      DP @ 1-
    THEN

    BEGIN \ Skip alignment
      DUP C@ 0= WHILE 1-
    REPEAT ;


ALSO FORTH DEFINITIONS

: DIS  ( ADR -- )
        BEGIN
                DUP
                CR INST
                KEY  DUP 0x1B = OVER 0x20 OR [CHAR] q = OR 0=
        WHILE
                CASE
                  [CHAR] B OF DROP .DB ENDOF
                  [CHAR] W OF DROP .DW ENDOF
                  [CHAR] D OF DROP .DD ENDOF
                  [CHAR] S OF DROP .DS ENDOF
                         ROT DROP
                ENDCASE

        REPEAT DROP 2DROP ;


0 VALUE SHOW-NEXT?      \ DEFAULT TO NOT SHOWING NEXT INSTRUCTIONS


TRUE VALUE SEE-KET-FL

VARIABLE  COUNT-LINE

: REST-AREA ( addr1 addr2 -- )
\ if addr2 = 0 continue till RET instruction
                20    COUNT-LINE !
\                0 TO MAX_REFERENCE
                SWAP DUP TO NEXT-INST
                BEGIN
                        \ We do not look for JMP's because there may be
                         \ a jump in a forth word
                        CR
                        OVER 0= IF  NEXT-INST C@ 0xC3 <>
                                ELSE 2DUP < INVERT
                                THEN
                WHILE   INST
                        COUNT-LINE @ 1- DUP 0=  SEE-KET-FL AND
                           IF 9 EMIT ." \ Press <enter> | q | any" KEY
                            DUP   0xD = IF 2DROP 1  ELSE
                              DUP 0x20 OR [CHAR] q = SWAP 0x1B =
                              OR IF DROP 2DROP CR EXIT    THEN
                                DROP 20    THEN
                           THEN
                        COUNT-LINE !
                REPEAT  2DROP ." END-CODE  "
                ;

: III INST ;

: REST ( addr -- )
    0 REST-AREA
;

: SE       ( "name" -- )
    ' DUP FIND-REST-END ['] REST-AREA CATCH DROP
;

ONLY FORTH ALSO DEFINITIONS
