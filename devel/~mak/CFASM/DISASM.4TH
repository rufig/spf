\ Disassembler Output                           Written by : Luke Lee
                                                \     Version : 1.5
                                                \      update : 09/19/'95
                                                \      update : 11/15/'96
                                                \      update : 01/24/'97 v1.5
                                                \ Last update : 01/27/'97 v1.5
        \  11\26\'99  Адаптировано под SPFOpt Максимовым М.О.
        \  email:mak@mail.rtc.neva.ru
        \  http://informer.rtc.neva.ru/fpauk.html

\ This program require CPU80486.4TH for disassembler

\ Output look :
\   CFASM-LOOK : Default value, the output is EXACTLY the same syntax
\                as you are writing CPU80486.4TH assembly.
\   MASM-LOOK  : Use this word and the outputs will looks like MASM
\                syntax.

~MAK\CFASM\CPU80486.4TH      \ 5/6/'94

DEFER DISASM1

VARIABLE SHOW-CODES     \ 1/15/'95 for SEE.4TH

DEFER ShowOperand

VARIABLE SPACEAPPEND
VARIABLE OperandCount   \ for MASM look

: COMP TUCK COMPARE ;

: ShowStr       ( adr -- )
        COUNT SWAP OVER TYPE 0> SPACEAPPEND @ AND IF SPACE THEN ;

: CurrMemonic   ( -- a )
        DisassembledInstruction .DisMemonic 1+ ;

: is-CALL?      ( -- T/F )
        CurrMemonic S" CALL" COMP 0= ;

: is-JMP?       ( -- T/F )
        CurrMemonic S" JMP" COMP 0= ;

: is-CALLF?     ( -- T/F )
        CurrMemonic S" CALLF" COMP 0= ;

: is-JMPF?      ( -- T/F )
        CurrMemonic S" JMPF" COMP 0= ;

: is-J(E)CXZ?   ( -- T/F )
        CurrMemonic S" J(E)CXZ" COMP 0= ;

: not-JMPF/CALLF?  ( -- T/F )
        is-CALLF?  is-JMPF?  OR  NOT ;

: CF-ShowOperand   ( .opr -- )
        DUP .OperandType C@ 
        CASE
           RegisterOperand  OF  .RegName1 ShowStr SPACE       ENDOF
           ImmediateOperand OF  .AssocImmediate @ . ." # "    ENDOF
           AddressOperand   OF  .AssocImmediate @
                    .
                ." # "                                           ENDOF
           MemoryOperand    OF
                DUP .OperandSize C@ CASE
                  0x08  OF  ." BYTE^ "                            ENDOF
                  0x10  OF  not-JMPF/CALLF? IF ." WORD^ " THEN   ENDOF
                  0x20  OF  not-JMPF/CALLF? IF ." DWORD^ " THEN  ENDOF
                  0x40  OF  ." QWORD^ "                           ENDOF
                ENDCASE
                >R ." { "
                R@ .RegName1 DUP ShowStr C@ 0<>
                R@ .RegName2 DUP ShowStr C@ 0<>
                DUP IF R@ .AssocScale C@
                    DUP 1 > IF  ." *" .  ELSE  DROP  THEN
                THEN
                2DUP AND IF ." + " THEN
                R> .AssocDisplacement @ DUP 0< IF
                     -ROT OR IF  ABS . ." - "  ELSE  ." -" ABS .  THEN
                ELSE DUP 0> IF
                     . OR IF ." + " THEN
                ELSE \ 0=                              \ 01/24/'97 modified
                     -ROT OR NOT IF  .  ELSE  DROP  THEN
                THEN THEN
                ." } "                                          ENDOF
          \ Otherwise :
                DROP
        ENDCASE  ;

: MASM-H.       ( val -- )
        [CHAR] 0 EMIT . 8 EMIT [CHAR] H EMIT ;

: OperandCount++  ( -- )
        1 OperandCount +!
        OperandCount @ 1 >  not-JMPF/CALLF? AND
        IF  [CHAR] , EMIT  THEN ;

: MASM-ShowOperand   ( .opr -- )
        DUP .OperandType C@
        CASE
           RegisterOperand  OF  OperandCount++ .RegName1 ShowStr  ENDOF
           ImmediateOperand OF
                is-CALL? is-JMP? OR is-CALLF? OR is-JMPF? OR 
                OR  OperandCount @ 1 >= AND  IF
                    [CHAR] : EMIT 1 OperandCount +!
                ELSE
                    OperandCount++
                THEN
                .AssocImmediate @ MASM-H.                      ENDOF
           AddressOperand   OF  OperandCount++
                .AssocImmediate @
\                is-CALL? is-JMP? OR  ANDTHEN  DUP CODE>HEAD 0<>  THEN-AND
\                IF
\                    DUP >HEAD .ID SPACE \ transform CFA to word name
\                    TAB ." ; "
\                THEN
                MASM-H.                                         ENDOF
           MemoryOperand    OF   OperandCount++
                DUP .OperandSize C@ CASE
                  0x08  OF  ." BYTE PTR "                            ENDOF
                  0x10  OF  not-JMPF/CALLF? IF  ." WORD PTR " 
                           ELSE ." FAR " THEN                      ENDOF
                  0x20  OF  not-JMPF/CALLF? IF ." DWORD PTR " 
                           ELSE ." FAR " THEN                      ENDOF
                  0x40  OF  ." QWORD PTR "                           ENDOF
                ENDCASE
                >R ." ["
                R@ .RegName1 DUP ShowStr C@ 0<>         ( R1? )
                R@ .RegName2 DUP C@ 0<> ROT             ( R2 R2? R1? )
                2DUP AND IF  [CHAR] + EMIT  THEN
                ROT ShowStr                             ( R2? R1? )
                OVER IF R@ .AssocScale C@
                    DUP 1 > IF  ." *" . 8 EMIT  ELSE  DROP  THEN
                THEN                                   ( R2? R1? )
                R> .AssocDisplacement @ DUP 0< IF
                     -ROT 2DROP [CHAR] - EMIT ABS MASM-H.
                ELSE DUP 0> IF
                     -ROT OR IF [CHAR] + EMIT THEN MASM-H.
                ELSE \ 0=                              \ 01/24/'97 modified
                     -ROT OR NOT IF  MASM-H.  ELSE  DROP  THEN
                THEN THEN
                ." ]"                                          ENDOF
          \ Otherwise :
                DROP
        ENDCASE  ;

: ShowOperands  ( DisassembledInstruction -- )
        DUP .DisOperand1  ShowOperand
        DUP .DisOperand2  ShowOperand
        .DisOperand3  ShowOperand  ;

: PerformDisAsm ( ^code -- ^next )
        DUP DISASSEMBLE SWAP ( ^next ^code )
        SHOW-CODES @ IF 
           BASE @ >R HEX
           DUP 6 U.R SPACE 
           BEGIN
              DUP C@ 0 <# # # #> TYPE  1+
           2DUP = UNTIL DROP
\           29 AT? DROP - DUP 0> IF  SPACES  ELSE  DROP  THEN SPACE \ 01/27/'97
           TAB
           R> BASE !
        ELSE 
           DROP
        THEN ;

: ShowPrefixes  ( DisassembledInstruction -- )
        DUP .DisPrefixName1 ShowStr
        DUP .DisPrefixName2 ShowStr
        DUP .DisPrefixName3 ShowStr
        .DisPrefixName4 ShowStr ;

: ShowMemonic   ( DisassembledInstruction -- )
        is-J(E)CXZ? IF
            DROP
            USE@ PrefixDisassembled @ 2 AND IF  0x30 XOR THEN
            ( 0x10 XOR 0x30 = 0x20; 0x20 XOR 0x30 = 0x10 )
            0x20 = IF
                ." JECXZ"
            ELSE
                ." JCXZ"
            THEN
        ELSE
            .DisMemonic ShowStr
        THEN ;
        
: CF-DISASM  ( ^code -- ^next )
        PerformDisAsm
        DisassembledInstruction 
        SYNTAX? PREFIX =  IF  DUP ShowMemonic TAB 8 EMIT THEN \ 09/19/'95
        DUP ShowPrefixes
        DUP ShowOperands
        SYNTAX? POSTFIX = IF  ShowMemonic  ELSE  DROP  THEN ;

: MASM-DISASM  ( ^code -- ^next )
        OperandCount OFF
        PerformDisAsm
        DisassembledInstruction
        2 SPACES  \ 01/27/'97 modified
        DUP ShowPrefixes
        is-CALLF? IF
           ." CALL"
        ELSE is-JMPF? IF
           ." JMP"
        ELSE
           DUP ShowMemonic
        THEN THEN TAB
        ShowOperands ;
        
FORTH DEFINITIONS

20 VALUE #INST

: CFASM-LOOK    ( -- ) \ default
      \ display output with CPU80486.4TH syntax
        SPACEAPPEND ON SHOW-CODES ON
        ['] CF-ShowOperand IS ShowOperand
        ['] CF-DISASM      IS DISASM1  ;

CFASM-LOOK

: MASM-LOOK     ( -- )
      \ display output with MASM syntax
        SPACEAPPEND OFF SHOW-CODES ON
        ['] MASM-ShowOperand IS ShowOperand
        ['] MASM-DISASM      IS  DISASM1 ;

: U     ( addr -- addr' )
        CR BASE @ >R HEX
        #INST 0 ?DO 
             DISASM1 CR 
        LOOP R> BASE ! ;

: U16   ( addr -- addr' )       
       \ disassemble with 16-bit addressing mode
        USE@ >R USE16 U R> USE! ;
: U32   ( addr -- addr' )
       \ disassemble with 32-bit addressing mode
        USE@ >R USE32 U R> USE! ;

ONLY FORTH ALSO DEFINITIONS

CR 
.( * 80486 Disassembler loaded * ) CR
.(    Example:  ' FLOAD U ) CR
.( Note : If you want the outputs looks like MASM syntax, use MASM-LOOK ; ) CR
.(        the default setting is CFASM-LOOK ,that is, CPU80486.4TH syntax.) CR


