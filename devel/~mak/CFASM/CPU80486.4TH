\ ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
\ ³  80486 CPU Assembler/Disassembler for Common Forth Experiment Versions  ³
\ ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

                        \ Copyright (C) Luke Lee, since 1993
                        \               All rights reserved.

                        \ Author       : Luke Lee
                        \ Version      : 1.65
                        \ System       : Common Forth Experiment version 1.600
                        \                on 80486-50 AT compatiable.
                        \ Starting date: 02/21/'93
                        \ Finish   date: 04/03/'93
                        \ Last update  : 03/28/'95

( +-----------------   80486 Assembler/Disassembler   -----------------+ )
( |                           Version 1.66                             | )
( |           [ For Common Forth Experiment Version 1.6xx ]            | )
( |                      Written by : Luke Lee                         | )
\ ( |       Copyright (C) CHAR )  EMIT
\                        .(  Luke Lee, since 1993, All rights reserved      | )
( |                     Last update : 03/28/'96                        | )
( +--------------------------------------------------------------------+ )

        \ Update history :
        \   05/30/'93 : Add global label words for USE32 mode
        \   05/31/'93 : Target memory operation words for labels. USE16 mode
        \               now supported.
        \   06/16/'93 : modify 16/ to 2/ 2/ 2/ 2/ to speed up, and other
        \               similar words. ( like 256/ 64/ ... )
        \   06/19/'93 : modify instruction JMP and CALL to allow instructions
        \               such as  EAX JMP   EDX CALL ... etc.
        \   07/29/'93 ... 08/17/'93 : Disassembler included.
        \               ( 08/17/'93  23:23 Disassembler successfully work ).
        \   08/20/'93 : Found a bug which is very difficult to know from
        \               any books ... there is a 'signed immediate value'
        \               type in 80x86 . ( Only in 8bit immediate patterns.)
        \   08/21/'93 : Documents.
        \   08/22/'93 : Modify CODE: and ;CODE, use 'ALSO' and 'PREVIOUS'
        \               to prevent changing original CONTEXT, and better
        \               error handling .
        \   08/14/'94 : Fix disassembler bug in 'DisassembleSIB'.
        \   09/04/'94 : Modify 'Max#DisassemblerLink' to 800 and allow
        \               'FreeDisLinkSpaceIndex++' to perform error checking.
        \   09/06/'94 : Add 'INLINE[' and ']INLINE'
        \   09/11/'94 : Modify a long existing bug in 'Prefix:', prefixes
        \               behaves just like any other instructions while
        \               disassembling, so they MUST have their own
        \               'NewEntry' for 'InstructionDescriptor' .
        \   11/03/'94 : Rename all '(...)' comment pair into '((...))'
        \   07/31/'95 : Rename all RECURSE to RECURSIVE .
        \   08/16/'95 : FIELD-LABEL: is deleted, so use '0 FIELD:' instead.
        \   09/18/'95 : Add PREFIX / POSTFIX syntax facility.
        \   10/04/'95 : Fix bug in 'PrefixSyntaxPreProc' for 'PreProcessing'
        \   10/06/'95 : Add 'ClearCurrentInstructionButPrefixes' for fixing
        \               a long existing bug : each time a shorter instruction
        \               pattern is found, the original prefixes like 'CS:' 
        \               will be erased by 'ClearCurrentInstruction' .
        \   10/22/'95 : Modify ;CODE, in PREFIX syntax, it cannot be used
        \               after any instruction, it must be put standalone.
        \   10/23/'95 : Another long existing bug is found ! See JU< and JU<=,
        \               it's a logical error ! Fixed now. Rename CLEAR-LABEL
        \               to BLIND-LABEL: which is better clear.
        \   10/25/'95 : Treat '0>' and '0<=' as error, there is no '0>' and
        \                its revese condition '0<=' in 80x86 assembly.
        \   11/13/'95 : Add FOR ... NEXT structure for counted loop.    
        \   03/28/'96 : Modify for TRACER.4TH, set TRACER OFF in CODE:,
        \                or it will sure to crash . 
        \  11\26\'99  €¤ ¯â¨à®¢ ­® ¯®¤ SPFOpt Œ ªá¨¬®¢ë¬ Œ.Ž.
        \  email:mak@mail.rtc.neva.ru
        \  http://informer.rtc.neva.ru/fpauk.html

 \     -- The following words are designed for activate the disassembler --
 \         USE@
 \         USE!
 \         DISASSEMBLE ( instruction_address -- next_instruction_address )
 \         DisassembledInstruction ( a data structure to place the result
 \                                   produce by DISASSEMBLE )
 \             Note : For detail of DisassembledInstruction, reference to
 \                    the following data structures :
 \                        "DisassembledOperand:" and "DisassembleBuffer:"

\ References :
\
\    1. Penn Brumm, Don Brumm and Leo J. Scanlon, "80486 Programming",
\        McGraw-Hill, 1991,
\        Chapter 10, "80486 instruction set".
\      ( Note that there are a few mistakes in this book, especially in
\        the opcode of instructions. )
\
\    2. Ross P. Nelson, "Microsoft's 80386/80486 Programming Guide",
\        Microsoft, 1991.

\ -----------------------------------------
\  General instruction pattern for 80486 :
\ -----------------------------------------

\  1. Prefix : ( Prefixes may not follow the following order .)
\   ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿
\   ³ Address Size ³ Operand Size ³ Instruction ³ Segment    ³ prefix
\   ³ Prefix       ³ Prefix       ³ Prefix      ³  Override  ³ name
\   ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄ´
\   ³    0 or 1    ³    0 or 1    ³   0 or 1    ³   0 or 1   ³ bytes
\   ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÙ

\  2. Instruction body :
\   ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
\   ³  Opcode  ³ MOD|REG|R/M ³  SIB  ³  Displacement  ³   Immediate   ³
\   ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
\   ³  1 or 2  ³   0 or 1    ³ 0 or 1³   0,1,2 or 4   ³  0,1,2 or 4   ³ bytes
\   ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
\  ( Maximum length of instruction = 16 bytes )
WARNING @
WARNING OFF

FORTH DEFINITIONS

 \ Constants for  DisassembledOperand .OperandType

  1     CONSTANT        RegisterOperand
  2     CONSTANT        MemoryOperand
  3     CONSTANT        ImmediateOperand
  4     CONSTANT        AddressOperand

CR .( 1. Defining Data Structures ...)

0
        1 FIELD .OperandType   \ Register/Memory/Immediate/Address Operand
        1 FIELD .OperandSize   \ only for Memory Operand ( $FF for any size )
        6 FIELD .RegName1      \ longest register name is "ST(?)", 6 bytes.
        6 FIELD .RegName2      \ only for Memory Operand
        1 FIELD .AssocScale    \ 1 means no scale
        4 FIELD .AssocDisplacement
        4 FIELD .AssocImmediate
CONSTANT DisassembledOperand

VARIABLE  PrefixDisassembled

0
        10 FIELD .DisPrefixName1 \ Address prefix have no name, they are
        10 FIELD .DisPrefixName2 \ stored in 'PrefixDisassembled'
        10 FIELD .DisPrefixName3
        10 FIELD .DisPrefixName4
        10 FIELD .DisMemonic
        DisassembledOperand FIELD .DisOperand1
        DisassembledOperand FIELD .DisOperand2
        DisassembledOperand FIELD .DisOperand3
CONSTANT DisassembleBuffer:
CREATE DisassembledInstruction \ <-- Disassembler place its result here
DisassembleBuffer: ALLOT

\ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\ %                80486        Assembler / Disassembler                   %
\ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

VOCABULARY ASSEMBLER

ALSO ASSEMBLER ALSO DEFINITIONS

\ Data structures
0
        CELL FIELD .^InstructionDisassembler
           1 FIELD .EntryIndex
CONSTANT DisassembleTableEntry:

0       1 FIELD   .#Patterns
        0 FIELD   .FirstPatternEntry
CONSTANT InstructionPatterns:

\  Operand pattern :
\                 ÚÄÄ Sub-type
\         ÚÄ Size ³        ÚÄÄ Type
\        ÚÁÄ¿  ÚÄÄÁÄÄ¿  ÚÄÄÁÄÄ¿
\        7  6  5  4  3  2  1  0
\      ÚÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ¿
\      ³  ³  ³  ³  ³  ³  ³  ³  ³
\      ÀÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÙ
\        ³  ³  ³  ³  ³  ÀÄÄÁÄÄÁÄ 000 : Not a special pattern (gerneal pattern)
\        ³  ³  ³  ³  ³           001 : Integer  register
\        ³  ³  ³  ³  ³           010 : Segment  register
\        ³  ³  ³  ³  ³           011 : Floating register
\        ³  ³  ³  ³  ³           100 : Control  register
\        ³  ³  ³  ³  ³           101 : Test     register
\        ³  ³  ³  ³  ³           110 : Debug    register
\        ³  ³  ³  ³  ³           111 : **  Extreme cases  **
\        ³  ³  ÀÄÄÁÄÄÁÄ if special pattern :
\        ³  ³             ù Register type : Register value
\        ³  ³             ù Extreme cases : 000 : Offset in segment (unsigned)
\        ³  ³                               001 : Relative to (E)IP (signed)
\        ³  ³                               010 : immediate displacement
\        ³  ³                               011 : Memory only
\        ³  ³                               100 : Memory >= 80 ( for floating )
\        ³  ³                               101 : ( not used )
\        ³  ³                               110 : Signed immediate value
\        ³  ³                               111 : Immediate value
\        ³  ³           if general pattern :
\        ³  ³                               000 : memory/integer registers
\        ³  ³                               001 : Integer registers only
\        ³  ³                               010 : Segment registers only
\        ³  ³                               011 : Floating registers only
\        ³  ³                               100 : Control registers only
\        ³  ³                               101 : Test registers only
\        ³  ³                               110 : Debug registers only
\        ÀÄÄÁÄ Opreand size : 00 8-bits
\                             01 16-bits
\                             10 32-bits
\                             11 80-bits
\ Foot note of operand pattern :
\   Immediate pattern is a very special case since 8-bit immediate value can
\   be treated as 16-bit or 32-bit values also, so it must be explicitly
\   processed in pattern matching routines : operand size not equal doesn't
\   necessarily means that immediate value pattern mismatch.

\   InstructionDescriptor.OverallDescription
\        7  6  5  4  3  2  1  0
\      ÚÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ¿
\      ³  ³  ³  ³  ³  ³  ³  ³  ³
\      ÀÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÙ
\        ³  ³  ³  ³  ³  ³  ÀÄÄÁÄ Number of opcode(s)
\        ³  ³  ³  ³  ÀÄÄÁÄ Number of operand(s)
\        ³  ³  ³  ÀÄÄ 1 : No operand prefix check for operand 1
\        ³  ³  ÀÄÄ 1 : No operand prefix check for operand 2
\        ³  ÀÄÄ 1 : Both operands are general register patterns ( MOV )
\        ÀÄÄ 1 : Force operand size check for immediate values ( PUSH immed )
\
\    InstructionDescriptor.DetailDescription
\        7  6  5  4  3  2  1  0
\      ÚÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ¿
\      ³  ³  ³  ³  ³  ³  ³  ³  ³
\      ÀÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÙ
\              ³  ³  ³     ³  ÀÄ 1 : Opcode modifier exist
\              ³  ³  ³     ÀÄ 1 : MOD|REG|R/M modifier exist( extended opcode )
\              ÀÄÄÁÄÄÁÄ MOD|REG|R/M modify value ( only if modifier exists )

0
        1 FIELD .OverallDescription
        1 FIELD .DetailDescription
        1 FIELD .Opcode1
        1 FIELD .Opcode2
        1 FIELD .Opcode3  ( for compound instructions, eg. FINIT = FWAIT FNINIT )
        1 FIELD .Operand1Pattern
        1 FIELD .Operand2Pattern
        1 FIELD .Operand3Pattern
        2 FIELD .DisassemblerLinkIndex         \ for 2-opcode disassembler
CONSTANT InstructionDescriptor:

\ OperandDescriptor.Scale
\        7  6  5  4  3  2  1  0
\      ÚÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ¿
\      ³  ³  ³  ³  ³  ³  ³  ³  ³
\      ÀÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÙ
\        ³                 ÀÄÄÁÄÄ  Scale value : 0, 1, 2 or 3
\        ³                         ( where 0 is default value )
\        ÀÄÄ  0 Scale on .Register1Pattern ( default )
\             1 Scale on .Register2Pattern

0
        1 FIELD .OperandPattern   \ Overall description of this operand.
        1 FIELD .Register1Pattern         \ if SIB present : Base     Index
        1 FIELD .Register2Pattern         \                  Index    Base
        1 FIELD .Scale                    \                  Scale    Scale
CONSTANT OperandDescriptor:

\  InstructionBuffer.Description byte :
\     7  6  5  4  3  2  1  0
\   ÚÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ¿
\   ³  ³  ³  ³  ³  ³  ³  ³  ³
\   ÀÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÙ
\    ³  ³   ³  ³  ³  ³  ÀÄÄÁÄÄ  Opcode length \ at least 1, 0 is invalid
\    ³  ³   ³  ³  ³  ÀÄÄ 1: Addressing mode byte ( MOD|Reg|R/M ) present
\    ³  ³   ³  ³  ÀÄÄ 1: Scale Index byte present
\    ³  ³   ÀÄÄÁÄÄ  00 : No displacement
\    ³  ³           01 : 1-byte displacement
\    ³  ³           10 : 2-byte displacement
\    ³  ³           11 : 4-byte displacement
\    ÀÄÄÁÄÄ 00 : No immediate value
\           01 : 1 byte immediate value
\           10 : 2-byte immediate value
\           11 : 4-byte immediate value

0
        1 FIELD .#Prefix
        1 FIELD .Prefix1  1 FIELD .Prefix2  1 FIELD .Prefix3 1 FIELD .Prefix4
        1 FIELD .Description
        1 FIELD .Op1      1 FIELD .Op2      1 FIELD .Op3
        1 FIELD .AddressingMode           \    MM RRR R/M
        1 FIELD .ScaleIndexByte           \    SS III BBB
        4 FIELD .Displacement
        4 FIELD .ImmediateValue
CONSTANT InstructionBuffer:

\ CR .( 2. Defining Constants and Variables ...)

\ Constants

3     CONSTANT  #MaxOperands  \ 80486 instruction set has at most 3 operands
4     CONSTANT  #MaxPrefixes

0     CONSTANT  DefiningPhase
1     CONSTANT  AssemblingPhase
2     CONSTANT  DisassemblingPhase

 \ For Operand Pattern, size bits

 2 BASE !

      00        CONSTANT         8Bits
      01        CONSTANT        16Bits
      10        CONSTANT        32Bits
      11        CONSTANT        64Bits
      11        CONSTANT        80Bits

 \ For Operand Pattern, type bits

     000    CONSTANT    GeneralTypes
     001    CONSTANT    IntegerRegisterType
     010    CONSTANT    SegmentRegisterType
     011    CONSTANT    FloatingRegisterType
     100    CONSTANT    ControlRegisterType
     101    CONSTANT    TestRegisterType
     110    CONSTANT    DebugRegisterType
     111    CONSTANT    ExtremeCases

  000000    CONSTANT    MemoryType          \ default value = 0 = This type
  000111    CONSTANT    OffsetType          \ (segment:) offset
  001111    CONSTANT    RelativeType        \ (E)IP + relative address
  010111    CONSTANT    DisplacementType    \ immediate displacement
  011111    CONSTANT    MemoryOnlyType      \ For memory only operands
  100111    CONSTANT    Memory>=80Type      \ For special floating operands
  110111    CONSTANT    SignedImmediateType \ For signed immediate data
  111111    CONSTANT    ImmediateType       \ immediate data

DECIMAL

 \ Error codes :

-1  CONSTANT  NotImplemented
 1  CONSTANT  InvalidAddressingMode
 2  CONSTANT  InvalidOperands
 3  CONSTANT  TooManyPrefixes
 4  CONSTANT  IndexNotDefined
 5  CONSTANT  OffsetOutOfRange
 6  CONSTANT  ESPcan'tBeIndex
 7  CONSTANT  NotAddressingNow
 8  CONSTANT  StillAddressingNow
 9  CONSTANT  NotInterpretingMode
10  CONSTANT  PrefixSyntaxMultiInstr
11  CONSTANT  CompWithZeroCondition

\ Disassembler link space size
 \ ( This value was optained from experiment, use 1024 at first, and then
 \   load CPU80486.4TH ; then "FreeDisLinkSpaceIndex @ ." = 745, so use
 \   745 for Max#DisassemblerLink to fit the requirement.

 \ [ 09/04/'94 ] While I'm porting this version into GO32 I found 745
 \  does not meet the requirements ( the requirements becames 756 ), so I
 \  modify it to 800 in case some day it happens again.

 \ [ 09/11/'94 ] While working on GO32 version, I found a serious bug in
 \  disassembler which long existed in this system but never beem found. The
 \  word 'Prefix:' make the prefixes behaves just like any other instruction
 \  while disassembling instructions. But no prefix have its own
 \  'InstructionDescriptor', so how could it be linked into the disassembler
 \  list ? There are 11 prefixes in this assembler, that's why 756-745 = 11.

 756 CONSTANT Max#DisassemblerLink

\ Variables, data objects and Tables

CREATE DefaultOperand OperandDescriptor:      ALLOT
CREATE TargetInstruction InstructionBuffer:   ALLOT
CREATE CurrentInstruction InstructionBuffer:  ALLOT    

VARIABLE  Assembler-Phase        \ Defining/Assembling/Disassembling Phase
VARIABLE  DefiningMemoryLocation \ True while in { ... } and False outside
VARIABLE  DefiningCode   \ for error handling
VARIABLE  Operand^       \ current operand of current instruction
VARIABLE  #Operands
VARIABLE  CurrInstDescIndex
VARIABLE  CurrInstDesc^  \ current instruction descriptor pointer
VARIABLE  UseXX          \ USE16 or USE32
VARIABLE  ChooseLongest  \ TRUE/FALSE (select longest pattern as target inst.)
VARIABLE  #PrefixDisassembled
VARIABLE  DisOperandIndex       \ for disassembler
VARIABLE  FreeDisLinkSpaceIndex \ for DisassemblerLinkSpace
 \ The following 2 variables are used only in disassembling time. It is
 \ used by few routines, so pass them through variables instead of stack
 \ ( local variable ) in order to reduce stack operations. Fetch or store
 \ them only when necessary; no need to SWAP or ROT them
VARIABLE CurrInstructionBody^
VARIABLE CurrTargetOpcode1^

CREATE    OperandDescriptors     \ each operand has its own descriptor
          OperandDescriptor: #MaxOperands *        ALLOT

CREATE    DisassembleTable
                256  DisassembleTableEntry:  *  ALLOT
CREATE    2opcodeDisassembleTable
                256  DisassembleTableEntry:  *  ALLOT
CREATE    DisassemblerLinkSpace  \ for collision of 2 opcode instructions
                Max#DisassemblerLink  DisassembleTableEntry:  *  ALLOT
                \ The first entry is reserved for (DB).

CREATE    RegisterTable
                8  8 CELLS  *  DUP ALLOT   RegisterTable SWAP 0 FILL
                \ RegisterTable : 2-d Array
                \   column = register value
                \   row : 0 =  8-bit integer register
                \         1 = 16-bit integer register
                \         2 = 32-bit integer register
                \         3 = Segment register
                \         :
                \         :
                \         7 = Debug register

\ Variable initiation

 DefiningPhase        Assembler-Phase           !
 OperandDescriptors   Operand^                  !
 32Bits               UseXX                     !
 FALSE                DefiningMemoryLocation    !
 FALSE                DefiningCode              !
 FALSE                ChooseLongest             !
                           \ defaultly choose shortest instruction pattern
 1                    FreeDisLinkSpaceIndex     !       \ entry 0 is reserved

\ CR .( 3. Miscellaneous Words for Assembling/Disassembling ...)

\ ---------------------   System dependent routines   ---------------------

: LAST-WORD-CFA ( -- CFA )
        \ return the CFA of the LAST word
        LAST @ NAME> ;

\ : LAST-WORD|SIZE+!      ( adjust-size -- )
\        LAST @ |SIZE +!  ;  \ for most systems, just DROP the 'adjust-size'

: BODY>CFA  BODY> ;

: CFA>BODY  >BODY ;

: BODY>NAME     ( PFA -- NFA ) \ NFA is the address of an counted-string
        BODY> >NAME ;

\ -----     Global Routines      -----

: 4/            CELL/ ;
: 8/            CELL/ 2/ ;
: 8*            CELLS 2* ;
: 16/           CELL/ CELL/ ;
: 16*           CELLS CELLS ;
: 64/           CELL/ CELL/ CELL/ ;
: 64*           CELLS CELLS CELLS ;
: 256/          CELL/ CELL/ CELL/ CELL/ ;
: MASK$01       0x01 AND ;
: MASK$02       0x02 AND ;
: MASK$03       0x03 AND ;
: MASK$07       0x07 AND ;
: MASK$3F       0x3F AND ; \ 00111111
: MASK$38       0x38 AND ; \ 00111000
: MASK$C7       0xC7 AND ; \ 11000111
: MASK$FF       0xFF AND ;

: OR-C! ( v addr -- ) \ similar to '+!' but operator is 'OR' and operand is byte
        SWAP OVER C@ OR SWAP C! ;

: Operand^@     Operand^ @ ;

: Operand^++ ( -- )
        Operand^@   OperandDescriptor:  +   Operand^ !
        1 #Operands +! ;

: CurrInstDesc^@        CurrInstDesc^ @ ;

: CurrOperandPattern ( -- addr )
        CurrInstDesc^@ .Operand1Pattern #Operands @ +    ;

: UnsignedValueSize     ( value32 -- size )
        256/ DUP IF
           256/ IF
                32Bits
           ELSE
                16Bits
           THEN
        ELSE
           DROP  8Bits
        THEN   ;

: SignedValueSize   ( value32 -- size )
        DUP 0x80 + 256/ IF
           0x8000 + 256/ 256/ IF
                32Bits
           ELSE
                16Bits
           THEN
        ELSE
           DROP  8Bits
        THEN   ;

: FormPatternByte ( Size Type Value/Sub-type -- OperandPattern )
        8* ( shift Value/Sub-type leftward 3 bits ) OR ( with Type )
        SWAP 64* ( shift Size leftward 6 bits )     OR   ;

: ClearCurrentInstruction ( -- )
        CurrentInstruction  InstructionBuffer: 0 FILL ;

: ClearCurrentInstructionButPrefixes  ( -- ) \ keep prefixes   10/06/'95
        CurrentInstruction .Description
        [ InstructionBuffer: 0 .Description - ] LITERAL
        0 FILL  ;

: ClearInstructionBuffers ( -- )
        TargetInstruction  InstructionBuffer: 0 FILL
        ClearCurrentInstruction ;

: ResetDefaultOperand   \ Initialize default operand
        UseXX @  MemoryType  0  \ default type is MemoryType
        FormPatternByte DefaultOperand .OperandPattern          C!
        0               DefaultOperand .Register1Pattern        C!
        0               DefaultOperand .Register2Pattern        C!
        0               DefaultOperand .Scale                   C!      ;

: ResetOperandDescriptors ( -- )
        0 #Operands !   OperandDescriptors Operand^ !
        ResetDefaultOperand
        OperandDescriptors
        #MaxOperands 0 DO
           DefaultOperand OVER OperandDescriptor: CMOVE
           OperandDescriptor: +
        LOOP DROP ;

: InstructionLength ( InstructionBuffer -- length )
        DUP .#Prefix C@ \ number of prefix(es)
        SWAP .Description C@ SWAP \ desb len
        OVER MASK$03 + \ opcode length
        OVER  4/ MASK$01 + \ addressing mode byte
        OVER  8/ MASK$01 + \ SIB byte
        OVER 16/ MASK$03 DUP 0x03 = IF 1+ THEN + \ displacement
        SWAP 64/         DUP 0x03 = IF 1+ THEN + ;

: #C@-TC,   ( addr length-description -- )
        DUP 3 = IF 1+ THEN  \ length description = 3   means   4 bytes
        0 ?DO
            DUP C@   C,  1+
        LOOP DROP ;

: Instruction>>TargetMemory ( -- )
        TargetInstruction .Prefix1
        TargetInstruction .#Prefix C@  0  ?DO        \ prefix
            DUP C@ C, 1+
        LOOP DROP  
        TargetInstruction .Description C@  ." III1" DUP . >R  
        TargetInstruction .Op1   R@ MASK$03     0  DO  \ opcodes
            DUP C@ C, 1+
        LOOP DROP      ." III2"
        R@ 4/ MASK$01  \ addressing mode byte exist?
        IF       TargetInstruction .AddressingMode C@   C,  THEN
        R@ 8/ MASK$01  \ scale index byte exist?
        IF       TargetInstruction .ScaleIndexByte C@   C,  THEN
        TargetInstruction .Displacement  R@ 16/ MASK$03  #C@-TC,
        TargetInstruction .ImmediateValue   R> 64/   #C@-TC,    ;

 \ Routines for disassembler :

: FreeDisLinkSpaceIndex++       ( -- )
        1 FreeDisLinkSpaceIndex +!
        FreeDisLinkSpaceIndex @ Max#DisassemblerLink
        > IF
           CR ." * Out of DisassemblerLinkSpace, please modify the constant : "
           CR ."  'Max#DisassemblerLink' to a larger value."
        THEN ;

: CurrOverallDescription        CurrInstDesc^@ .OverallDescription  C@ ;
: CurrDetailDescription         CurrInstDesc^@ .DetailDescription   C@ ;

: DisOperandIndex@      DisOperandIndex   @ ;
: 1DisOperandIndex!     1 DisOperandIndex ! ;
: 2DisOperandIndex!     2 DisOperandIndex ! ;
: 3DisOperandIndex!     3 DisOperandIndex ! ;

: ClearDisassembledInstruction ( -- )
        0 DUP PrefixDisassembled !  #PrefixDisassembled !
        DisassembledInstruction DisassembleBuffer: 0 FILL ;

: ClearDisassembledOperands  ( -- )
        DisassembledInstruction .DisOperand1
        [ DisassembledOperand 3 * ] LITERAL 0 FILL ;

: SizeDesc>NumbericSize  ( size -- n )
      \ Transform 00B to 8, 01B to 16, 10B to 32, 11B to 64
        DUP 0 3 BETWEEN IF      \ transform only when 0 <= size <= 3
           8 SWAP 0 ?DO  2*  LOOP
        THEN  ;

: U8>S8  ( unsigned-char -- signed-char )    \ 8 bit
        DUP 0x80 >= IF 0xFFFFFF00 OR THEN ;

: U16>S16  ( unsigned-16bit -- signed-16bit )
        DUP 0x8000 >= IF 0xFFFF0000 OR THEN ;

: SetDisassembleTableEntry      ( index ^disassembler-word ^entry -- )
        SWAP OVER .^InstructionDisassembler  !
        .EntryIndex  C!  ;

: CopyNameString        ( NFA addr -- )
        OVER C@ 1+ CMOVE ;

: DisassembleTable[]    ( opcode -- ^entry )
      \ DUP 0xFF > ABORT" Out of range : DisassembleTable"
        DisassembleTableEntry: * DisassembleTable + ;

: 2opcodeDisassembleTable[]     ( opcode2 -- ^entry )
      \ DUP 0xFF > ABORT" Out of range : 2opcodeDisassembleTable"
        DisassembleTableEntry:  * 2opcodeDisassembleTable + ;

: DisassemblerLinkSpace[]       ( index -- ^entry )
      \ DUP Max#DisassemblerLink > ABORT" Out of range : DisassemblerLinkSpace"
        DisassembleTableEntry: * DisassemblerLinkSpace + ;

: RegisterSize/Type>Row ( size type -- row )
        DUP IntegerRegisterType <= IF
           DROP  \ size = row index
        ELSE \ type > integer register type
           NIP 1+
        THEN  ;

: RegisterTable[][]     ( row register-value -- ^entry )
        CELLS    SWAP  [ 8 CELLS ] LITERAL  *    +
        RegisterTable  +   ;

: DisassembledMemonic   ( PFA -- )
        BODY>NAME  DisassembledInstruction .DisMemonic  CopyNameString  ;

: DisassemblingOperand  ( oprindex -- DisassembledInstruction.DisOperandX )
        1-  DisassembledOperand  *
        DisassembledInstruction .DisOperand1 +  ;

: Set.RegNameX  ( reg-value reg-size reg-type Reg-Index -- )
        -ROT RegisterSize/Type>Row ROT
        RegisterTable[][]  @EXECUTE  ;

: Set.OperandType  ( type -- )
        DisOperandIndex@ DisassemblingOperand .OperandType C! ;

: Set.OperandSize  ( size-description -- )
        SizeDesc>NumbericSize
        DisOperandIndex@ DisassemblingOperand .OperandSize  C! ;

: Set.AssocScale  ( scale -- )
      \ 00B = 1, 01B = 2, 10B = 4, 11B = 8
        SizeDesc>NumbericSize 8/
        DisOperandIndex@ DisassemblingOperand .AssocScale       C! ;

: Set.AssocDisplacement  ( value -- )
        MemoryOperand Set.OperandType
        DisOperandIndex@ DisassemblingOperand .AssocDisplacement !  ;

: Set.AssocImmediate  ( value -- )
        ImmediateOperand Set.OperandType
        DisOperandIndex@ DisassemblingOperand .AssocImmediate  !  ;

: (DB) ( Tcurr-adr entryindex -- Tnext-adr ) \ Default disassembler
        ClearDisassembledOperands   \ There might be some prefix disassembled
        DROP                        \ ,so do not ClearDisassembledInstruction
        [ LAST @ NAME> CFA>BODY ] LITERAL DUP DisassembledMemonic CurrInstructionBody^ !
        DUP C@  1DisOperandIndex! Set.AssocImmediate
        1+  ;

: InitDisassembleTable ( table-addr limit -- )
        0 DO
           DUP 0  ['] (DB)  ROT  SetDisassembleTableEntry
           DisassembleTableEntry: +
        LOOP DROP ;

DisassembleTable         256                    InitDisassembleTable
2opcodeDisassembleTable  256                    InitDisassembleTable
DisassemblerLinkSpace    Max#DisassemblerLink   InitDisassembleTable

\ FORGET InitDisassembleTable

: (Disassemble) ( target-curr-adr -- target-next-adr )
     \ Dispatch DisassembleTable
        DUP C@ DisassembleTable[] DUP .EntryIndex C@
        SWAP .^InstructionDisassembler  @EXECUTE  ;

VARIABLE CURR-SYNTAX        \ default PREFIX               09/18/'95

FORTH DEFINITIONS \ ---------------------------------------------------------

\ Syntax definition

: SYNTAX?       ( -- N )      CURR-SYNTAX @   ;       \ 09/19/'95
: SYNTAX        ( N -- )      CURR-SYNTAX !   ;       \ 09/18/'95
0       CONSTANT        PREFIX                          \ 09/18/'95
1       CONSTANT        POSTFIX                         \ 09/18/'95

\ Disassembler interface, it place its result in 'DisassembledInstruction'

: DISASSEMBLE ( target-curr-adr -- target-next-adr )
        DisassemblingPhase  Assembler-Phase  !
        ClearDisassembledInstruction  (Disassemble)  ;

ASSEMBLER DEFINITIONS \ -----------------------------------------------------

 \ 1. Two 1-opcode instructions could have the same opcode, since there
 \    may be some MM|REG|R/M modifier as extended opcode.
 \ 2. The first opcode of 2-opcode instructions could not possibly have
 \    the same value with any 1-opcode instruction, otherwise there is no
 \    way for hardware to tell the difference between 1-opcode and 2-opcode
 \    instructions.
 \    So, the first opcode can determines whether this instruction is
 \    1-opcoded or 2-opcoded .
 \ 3. Each 2-opcode disassembler should check whether the second opcode is
 \    the same as the one of itself, otherwise pass the control to its
 \    assembler link, until there is one be able to decode this; at last,
 \    if there is no one could decode this 2-opcode instruction, pass it
 \    to '(DB)' ( define byte ) .

: Dispatch-2opcodeDisassembler  ( Tcurr-adr entry-index -- Tnext-adr )
      \ There is no possibility that 1-opcode instructions occupy the same
      \ table entry, so there is no .DisassemblerLinkIndex field for itself.
        DROP   DUP 1+ C@
        2opcodeDisassembleTable[]
        DUP .EntryIndex C@ SWAP .^InstructionDisassembler @EXECUTE  ;

 \ There might be several instruction patterns for the same opcode, so
 \ any opcode might call the following routines several times.

: Index/PFA>InstDesc    ( index PFA -- ^InstructionDescriptor )
        .FirstPatternEntry  SWAP InstructionDescriptor: *  +  ;

: link-disassembler ( inst-patterm-idx ^disasm-word table-entry -- )
        DUP .^InstructionDisassembler @   ['] (DB)  <>
        CurrDetailDescription MASK$01 0<>  OR
        IF \ collision
           >R 2DUP CFA>BODY Index/PFA>InstDesc  .DisassemblerLinkIndex
           FreeDisLinkSpaceIndex @ DUP ROT W!
           DisassemblerLinkSpace[] R@ SWAP
           DisassembleTableEntry:  CMOVE
           FreeDisLinkSpaceIndex++
           R>
        THEN
        SetDisassembleTableEntry 
 ;

: 1-opcodeDisassembler>>TableEntry
      ( instruction-pattern-index ^disassembler-word opcode -- )
        DisassembleTable[] link-disassembler  ;

: Set-2opcodeDispatcher ( opcode1 -- )
        0 ['] Dispatch-2opcodeDisassembler ROT DisassembleTable[]
        DUP .^InstructionDisassembler @ ['] (DB) <> IF
           BEGIN
              DUP .EntryIndex C@ SWAP .^InstructionDisassembler @
              ( 0 dispatcher ei cfa )
              DUP ['] Dispatch-2opcodeDisassembler = IF
                 2DROP 2DROP EXIT \ dispatcher already exist.
              THEN
              CFA>BODY Index/PFA>InstDesc .DisassemblerLinkIndex
           DUP W@ 0<> WHILE
              W@ DisassemblerLinkSpace[]
           REPEAT
           FreeDisLinkSpaceIndex @ DUP ROT W! DisassemblerLinkSpace[]
           FreeDisLinkSpaceIndex++
        THEN
        SetDisassembleTableEntry  ;

: 2-opcodeDisassembler>>TableEntry
      ( instruction-pattern-index ^disassembler-word opcode<16bits> -- )
        DUP MASK$FF Set-2opcodeDispatcher
        256/ MASK$FF 2opcodeDisassembleTable[]
        link-disassembler 
 ;

\ Error Messages :

VARIABLE LAST#ERROR

: Error ( #err -- )
        DUP LAST#ERROR ! CR ."  * Error : "
        CASE
           NotImplemented        OF ." Not Implemented yet"              ENDOF
           InvalidAddressingMode OF ." Invalid addressing mode"          ENDOF
           InvalidOperands       OF ." Invalid operands"                 ENDOF
           TooManyPrefixes       OF ." Too many prefixes"                ENDOF
           IndexNotDefined       OF ." Index register not defined yet"   ENDOF
           OffsetOutOfRange      OF ." Offset out of range" ENDOF
           ESPcan'tBeIndex       OF ." Cannot use ESP as index register" ENDOF
           NotAddressingNow      OF
                   ." Not addressing memory location, '{' expected"      ENDOF
           StillAddressingNow    OF
                   ." Still addressing memory location, '}' expected"    ENDOF
           NotInterpretingMode   OF                             \ 09/18/'95
                   ." Cannot used in compiling state"                    ENDOF
           PrefixSyntaxMultiInstr OF                            \ 09/19/'95
                   ." Cannot put more than one instruction in one line while" 
                   ."  using " CR TAB ."    PREFIX SYNTAX "              ENDOF
           CompWithZeroCondition  OF                            \ 10/25/'95
                   ." There is no '0>' or '0<=' condition test "         ENDOF
        ENDCASE
        ." ." CR ABORT ;


\  %%%%%%%%%%%%%%%%%%%%%%
\  %   Operand  Words   %
\  %%%%%%%%%%%%%%%%%%%%%%

\ CR .( 4. Words for Processing Registers ... )

: RegisterInAssemblingPhase ( PatternByte -- 0 )
    \ Routine for 'Register:' in AssemblingPhase
        DefiningMemoryLocation @  IF
           Operand^@ .Register1Pattern C@  0= IF  \ not initialized
                Operand^@ .Register1Pattern   C!
           ELSE
                Operand^@ .Register2Pattern
                DUP C@   \ More than 2 registers used in addressing
                IF   InvalidAddressingMode  Error   THEN
                C!
           THEN
        ELSE
           Operand^@ .OperandPattern  C!        Operand^++
        THEN   0       ( Put a zero on stack )         ;

: RegisterInDisassemblingPhase ( registerIndex PFA -- )
        BODY>NAME SWAP
        1- 0 .RegName1   *
        DisOperandIndex@ DisassemblingOperand .RegName1  +
        CopyNameString  ;

: ???   ( registerIndex -- ) \ invalid register type
        [ LAST @ NAME> CFA>BODY ] LITERAL RegisterInDisassemblingPhase  ;

: InitRegisterTable ( -- )
        RegisterTable
        8 8 *  0  DO
           ['] ???  OVER  !     CELL+
        LOOP DROP  ;

InitRegisterTable
\ FORGET InitRegisterTable

: Register: ( register-size register-type register-value -- )
        CREATE \ create a state smart word in assembling phase
           >R 2DUP RegisterSize/Type>Row R@ RegisterTable[][]
           LAST-WORD-CFA  SWAP  !  R>
           FormPatternByte C,
        DOES> Assembler-Phase @
              CASE
                DefiningPhase      OF   C@  CurrOperandPattern C!     ENDOF
                AssemblingPhase    OF   C@ RegisterInAssemblingPhase   ENDOF
                DisassemblingPhase OF   RegisterInDisassemblingPhase   ENDOF
              ENDCASE   ;

: `     ( <register-name> -- register-value )
        ' CFA>BODY C@ 8/ MASK$07 ;

: Registers: ( RegisterType Size #Registers -- )
        0 DO
            2DUP    I    Register:
        LOOP 2DROP ;

8Bits  IntegerRegisterType    8  Registers:    AL  CL  DL  BL  AH  CH  DH  BH
16Bits IntegerRegisterType    8  Registers:    AX  CX  DX  BX  SP  BP  SI  DI
32Bits IntegerRegisterType    8  Registers:   EAX ECX EDX EBX ESP EBP ESI EDI

\  %%%%%%%%%%%%%%%%%%%%%
\  %   Prefix  Words   %
\  %%%%%%%%%%%%%%%%%%%%%

\ CR .( 5. Words for Processing Prefixes ...)

: PrefixNotExist? ( prefix-value #prefixs -- T/F )
        TRUE -ROT CurrentInstruction .Prefix1 -ROT
        0 ?DO ( flag prefixN prefixvalue )
            OVER C@  OVER  =  IF
                DROP FALSE -ROT LEAVE
            THEN
            SWAP 1+ SWAP
        LOOP 2DROP ;

: PrefixInAssemblingPhase ( PrefixValue -- )
        CurrentInstruction .#Prefix C@
        DUP  #MaxPrefixes  <  IF
            2DUP PrefixNotExist? IF \ existed prefix needs no copy
                CurrentInstruction .Prefix1 +   C!
                1   CurrentInstruction .#Prefix   +!
            ELSE \ same prefix already existed ignores it.
                2DROP
            THEN
        ELSE
            TooManyPrefixes Error
        THEN   ;

 \ Prefix never exist alone, it always appears before some instruction.
 \   PrefixDisassembled :
 \                                    1 0
 \      ÚÄÄÄÄÄÄÄÄÄÄÄùùùùùùÄÄÄÄÄÄÄÄÄÄÄÂÄÂÄ¿
 \      ³          Not  Used         ³ ³ ³
 \      ÀÄÄÄÄÄÄÄÄÄÄÄùùùùùùÄÄÄÄÄÄÄÄÄÄÄÁÄÁÄÙ
 \                                    ³ ÀÄ Operand size prefix (OS:)
 \                                    ÀÄ Address size Prefix (AS:)

: Address/Operand-Prefix ( Tcurr-addr flag-value -- Tnext-addr )
        \ set flag and execute next disassembler
        PrefixDisassembled OR-C!  (Disassemble)  ;

: PrefixInDisassemblingPhase ( curr-addr entry-index PFA -- next-addr )
        #PrefixDisassembled @ 4 >= IF \ no more than 4 prefix
           DROP (DB)
        ELSE
           1 #PrefixDisassembled +!
           NIP SWAP 1+ SWAP
           DUP .Opcode1 C@ \ check itself, not target address
           CASE
              0x66  OF  DROP 1 Address/Operand-Prefix  ENDOF
              0x67  OF  DROP 2 Address/Operand-Prefix  ENDOF
           \ OTHERWISE:
              SWAP BODY>NAME     DisassembledInstruction .DisPrefixName1
                #PrefixDisassembled @ 1- .DisPrefixName1 *   +
              CopyNameString
           ENDCASE
        THEN  ;

: NewEntry ( -- ) \ allocate a new entry in Instruction Pattern Table
        HERE CurrInstDesc^ !
        HERE InstructionDescriptor: DUP ALLOT   0 FILL ;

: Prefix:       ( value -- )
      \ It is a 1-opcode disassembler and no .DisassemblerLinkIndex field is
      \ needed since it disassembles only 1 byte of memory, no any other
      \ instruction could couflict with it, otherwise the CPU won't be able
      \ to tell the difference between them.
        CREATE
              NewEntry  \ build a dummy entry for disassembler linkage
              DUP CurrInstDesc^@ .Opcode1 C!
              0 LAST-WORD-CFA ROT 1-opcodeDisassembler>>TableEntry
        DOES> Assembler-Phase @
              CASE      \ No defining phase actions
                AssemblingPhase    OF  .Opcode1 C@ PrefixInAssemblingPhase
                                                                        ENDOF
                DisassemblingPhase OF  PrefixInDisassemblingPhase       ENDOF
              ENDCASE   ;

0x66 Prefix:     OS:     \ operand size prefix
0x67 Prefix:     AS:     \ address size prefix

\  %%%%%%%%%%%%%%%%%%%%%%%%%%
\  %   Instruction  Words   %
\  %%%%%%%%%%%%%%%%%%%%%%%%%%

\ CR .( 6. Words for Processing Instructions ...)

\ ------------------------
\  Defining Phase words :
\ ------------------------

\ CR .(  6.1  Instruction Description ...)


: AddInstructionTableEntry
     ( #opcodes opcodes #operands PFA | <opr1> <opr2> <opr3> -- )
        DUP .#Patterns DUP C@ 1+ SWAP  C!                \ increase entry number
        HERE >R  NewEntry  0 #Operands !              \ allocate new entry
        >R DUP 0  ?DO   ' EXECUTE  1 #Operands +!    LOOP  \ operands
        -ROT OVER                       ( #opr #opc opcs #opc )
        2DUP CurrInstDescIndex @
        R> BODY>CFA 2SWAP            ( #opr #opc opcs #opc ci cfa opcs #opc )
        CASE
           1  OF   1-opcodeDisassembler>>TableEntry        ENDOF
           2  OF   2-opcodeDisassembler>>TableEntry        ENDOF
           3  OF   2DROP DROP ( compound instructions )  ENDOF
        ENDCASE                         ( #opr #opc opcs #opc )
        R@ .Opcode1  SWAP 0  DO         ( #opr #opc opcs ^opc )
            OVER MASK$FF   OVER  C!
            1+ SWAP 256/ SWAP
        LOOP 2DROP                      ( #opr #opc )
        SWAP 4 * OR   R> .OverallDescription C!
        1  CurrInstDescIndex +!   
 ;

\ --------------------------
\  Assembling Phase words :
\ --------------------------

: ChooseInstruction ( -- )
        TargetInstruction .Description C@ 0=  \ initial status ?
        CurrentInstruction  InstructionLength
        TargetInstruction InstructionLength  <  \ shorter ?
        ChooseLongest @ IF   NOT   THEN  \ longer ?
        OR IF
             CurrentInstruction  TargetInstruction
             InstructionBuffer: CMOVE
        THEN ;

 \  Instruction pattern match routines :

\ CR .(  6.2  Instruction Pattern Match ...)

: Valid-Offset?    ( OprNDesc^ OprNDesc^.Pat Inst.OprNPat -- T/F )
        OVER MASK$3F  MemoryType    =          \ memory type
        -ROT 64/ SWAP 64/           =  AND     \ same size
        SWAP .Register1Pattern C@  0=  AND  ;  \ only displacement present.

: Valid-Relative?    ( OprNDesc^ OprNDesc^.Pat Inst.OprNPat -- T/F )
      \ Operand size will be checked later
        64/  DUP  UseXX @  =  SWAP 8Bits = OR
        SWAP MASK$3F ImmediateType =  AND   NIP ;

: Valid-Displacement? ( OprNDesc^ OprNDesc^.Pat Inst.OprNPat -- T/F )
      \ Same as valid-relative, but different when applying operands.
        Valid-Relative?  ;

: Valid-MemoryOnly?   ( OprNDesc^ OprNDesc^.Pat Inst.OprNPat -- T/F )
        64/ OVER 64/  =  SWAP     \ same size
        MASK$3F MemoryType = AND NIP ;

: Valid-Memory>=80?   ( OprNDesc^ OprNDesc^.Pat Inst.OprNPat -- T/F )
        = NIP ;

: Valid-SignedImmediate?    ( OprNDesc^ OprNDesc^.Pat Inst.OprNPat -- T/F )
      \ .Scale is a piggyback for signed immediate value size
        SWAP MASK$3F ImmediateType =  -ROT
        64/ SWAP .Scale C@ >=  AND  ;  \ valid signed size

: Valid-Immediate?    ( OprNDesc^ OprNDesc^.Pat Inst.OprNPat -- T/F )
        64/ OVER 64/ >=   SWAP    \ valid size
        MASK$3F ImmediateType = AND   NIP   ;

: Valid-ExtremeCases?  ( OprNDesc^ OprNDesc^.Pat Inst.OprNPat -- T/F )
        DUP MASK$3F
        CASE
           OffsetType           OF    Valid-Offset?             ENDOF
           RelativeType         OF    Valid-Relative?           ENDOF
           DisplacementType     OF    Valid-Displacement?       ENDOF
           MemoryOnlyType       OF    Valid-MemoryOnly?         ENDOF
           Memory>=80Type       OF    Valid-Memory>=80?         ENDOF
           SignedImmediateType  OF    Valid-SignedImmediate?    ENDOF
           ImmediateType        OF    Valid-Immediate?          ENDOF
        ENDCASE ;

: MatchSpecialPattern?  ( OprNDesc^ OprNDesc^.Pat Inst.OprNPat -- T/F )
        DUP MASK$07  ExtremeCases  =  IF
             Valid-ExtremeCases?
        ELSE \ special register
             =  NIP     \ must be exactly the same type, value and size.
        THEN ;

: MatchGeneralPattern?  ( OprNDesc^ OprNDesc^.Pat Inst.OprNPat -- T/F )
        DUP 8/ MASK$07  MemoryType  =  IF   \ integer register type or memory
            OVER MASK$07  IntegerRegisterType  <=
        ELSE \ Other register types
            OVER MASK$07  OVER 8/ MASK$07  =    \ same type
        THEN
        -ROT 64/ SWAP 64/  =   AND   NIP ;      \ size match

: OneOperandPatternMatch?  ( Inst.OprNPat^ OprNDesc^ -- T/F )
        DUP .OperandPattern C@ ROT C@ \ OprNDesc^ OprNDesc^.Pat Inst.OprNPat
        DUP MASK$07 IF
             MatchSpecialPattern?
        ELSE
             MatchGeneralPattern?
        THEN ;

: OperandsPatternMatch? ( Table-Entry -- True/False )
        .Operand1Pattern    OperandDescriptors    TRUE
        #Operands @  0  ?DO ( OprNpattern OprNdesc Flag )
           >R
           2DUP OneOperandPatternMatch? IF
              OperandDescriptor: + SWAP   1+   SWAP
           ELSE \ exit loop as soon as any operand pattern mismatch
              RDROP FALSE LEAVE
           THEN
           R>
        LOOP -ROT 2DROP ;

: InstructionPatternMatch? ( Table-Entry -- True/False )
        #Operands @   OVER .OverallDescription C@ 4/ MASK$03   =   IF
             OperandsPatternMatch?
        ELSE    \ number of operands not match
             DROP FALSE
        THEN ;

 \  Instruction layout routines :

\ CR .(  6.3  Instruction Layout ...)

: CopyOpcodes   ( Table-Entry -- )
        DUP .OverallDescription C@ MASK$03
        DUP  CurrentInstruction .Description  OR-C!  \ opcode len.
        SWAP .Opcode1   CurrentInstruction .Op1   ROT    CMOVE  ;

VARIABLE NoOperandPrefix \ read by OperandPrefixCheck
                         \ modify by ApplyToCurrentInstruction
: OperandPrefixCheck    ( operandPattern -- )
        NoOperandPrefix @ MASK$01 IF
           DROP
        ELSE
           DUP MASK$07 IntegerRegisterType <=  IF  \ integer regs or memory
               64/ DUP 16Bits = OVER 32Bits = OR
               SWAP UseXX @ <>   AND    IF
                   OS:  \ lay down operand prefix
               THEN
           ELSE
               DROP
           THEN
        THEN ;

   \ General patterns : r/mXX regXX segXX ctlXX dbgXX tstXX
   \
   \  Addressing Mode Byte Format :    7  6  5  4  3  2  1  0
   \                                 ÚÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ¿
   \               MM|REG|R/M        ³ MOD ³ R  E  G³ R /  M ³
   \                                 ÀÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÙ

: AddrModeBytePresent   ( -- )
        0x04  CurrentInstruction .Description   OR-C!    ;

: ScaleIndexBytePresent   ( -- )
      \ Both addressing-mode-byte and scale-index-byte are present now.
        0x0C  CurrentInstruction .Description   OR-C!    ;

: 16BitDS:[Offset]   ( oprVal -- ) \ MM|REG|R/M = 00|xxx|110
        AddrModeBytePresent
        0x06  CurrentInstruction .AddressingMode  OR-C!
        DUP SignedValueSize 16Bits > IF
                OffsetOutOfRange Error
        ELSE
                CurrentInstruction .Displacement !
        THEN   ;

: 32BitDS:[Offset]   ( oprVal -- ) \ MM|REG|R/M = 00|xxx|101
        AddrModeBytePresent
        0x05  CurrentInstruction .AddressingMode  OR-C!
        CurrentInstruction .Displacement !  ;

: OffsetOnly    ( oprVal -- )
        UseXX @ 16Bits = IF \ USE16
           16BitDS:[Offset]
           [ 2 16* ] LITERAL  CurrentInstruction .Description   OR-C!
        ELSE \ USE32
\          DUP SignedValueSize 32Bits <  IF \ save 1 byte of memory
\               AS:  16BitDS:[Offset]   2 ( length = 2 bytes )
\          ELSE
                32BitDS:[Offset]        3 ( length = 4 bytes )
\          THEN
           16*  CurrentInstruction .Description  OR-C!
        THEN ;

   \ 16-bit addressing modes :
   \
   \     \ MODº     00     ³      01      ³      10       ³      11
   \    R/M \ º            ³              ³               ³  w=0  ³   w=1
   \   ÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍ
   \     000  º  [BX+SI]   ³  [BX+SI]+d8  ³  [BX+SI]+d16  ³   AL  ³   AX
   \     001  º  [BX+DI]   ³  [BX+DI]+d8  ³  [BX+DI]+d16  ³   CL  ³   CX
   \     010  º  [BP+SI]   ³  [BP+SI]+d8  ³  [BP+SI]+d16  ³   DL  ³   DX
   \     011  º  [BP+DI]   ³  [BP+DI]+d8  ³  [BP+DI]+d16  ³   BL  ³   BX
   \     100  º   [SI]     ³   [SI]  +d8  ³   [SI]  +d16  ³   AH  ³   SP
   \     101  º   [DI]     ³   [DI]  +d8  ³   [DI]  +d16  ³   CH  ³   BP
   \     110  º [offset16] ³   [BP]  +d8  ³   [BP]  +d16  ³   DH  ³   SI
   \     111  º   [BX]     ³   [BX]  +d8  ³   [BX]  +d16  ³   BH  ³   DI

\ MOD = 00 01 10

: R/M-value(2Regs)   ( reg1-val reg2-val -- R/M T/F )
    \ R/M = 000 ... 011
        CASE
           [ ` SI ] LITERAL  OF   0  TRUE  ENDOF
           [ ` DI ] LITERAL  OF   1  TRUE  ENDOF
           ( otherwise ) FALSE DUP ROT   \ no such addressing mode
        ENDCASE
        IF SWAP CASE
              [ ` BX ] LITERAL  OF       ( 000 or 001 ) TRUE  ENDOF
              [ ` BP ] LITERAL  OF   2 + ( 010 or 011 ) TRUE  ENDOF
              ( otherwise ) FALSE SWAP    \ no such addressing mode
           ENDCASE
        THEN ;

: SetDisplacement8/16   ( disp R/M -- MM|000|R/M )
        SWAP DUP IF \ displacement <> 0
           DUP  CurrentInstruction .Displacement  !
           SignedValueSize \ R/M size disp
           CASE
               8Bits OF   01 ( MOD = 01 )  0x10 ( 00 01 0000 )   ENDOF
              16Bits OF   02 ( MOD = 10 )  0x20 ( 00 10 0000 )   ENDOF
              ( otherwise ) InvalidAddressingMode Error
           ENDCASE
           CurrentInstruction .Description   OR-C!   \ set displacement length
           64* ( shift left 6 bits ) OR
        ELSE \ displacement = 0, MOD = 00, return 00|000|R/M
           DROP
        THEN ;

: 2RegisterAddressing16  ( displacement reg1-val reg2-val -- MM|000|R/M )
        2DUP R/M-value(2Regs) IF
           -ROT 2DROP
        ELSE
           DROP SWAP \ exchange the order of the two registers
           R/M-value(2Regs) NOT IF  InvalidAddressingMode Error  THEN
        THEN \ disp R/M
        SetDisplacement8/16     ;

: CheckMode...(E)BP=Base   ( displacement regvalue -- )
     \ Base = (E)BP and displacement = 0, change MM=01 since MM=00 is
     \ used as DS:[OFFSET] only. This is always a special case no matter
     \ USE16 or USE32, and no matter SIB present or not when USE32.
        [ ` BP ] LITERAL =  SWAP 0=  AND  IF
          \ modify MM = 01
            0x40 ( 0100000 )  CurrentInstruction .AddressingMode  OR-C!
          \ set displacement length = 1 bytes
            0x10 ( 0001000 )  CurrentInstruction .Description     OR-C!
        THEN  ;

: 1RegisterAddressing16  ( displacement reg -- MM|000|R/M )
   \ R/M = 100 ... 111
        2DUP CASE
             [ ` SI ] LITERAL OF   0x04 ( R/M = 100 )   ENDOF
             [ ` DI ] LITERAL OF   0x05 ( R/M = 101 )   ENDOF
             [ ` BP ] LITERAL OF   0x06 ( R/M = 110 )   ENDOF
             [ ` BX ] LITERAL OF   0x07 ( R/M = 111 )   ENDOF
             ( otherwise ) InvalidAddressingMode Error
        ENDCASE
        SetDisplacement8/16
        -ROT  CheckMode...(E)BP=Base  ;

: 16BitsAddressingModes ( displacement oprNdesc^ -- )
        DUP .Register1Pattern C@ 8/ MASK$07
        SWAP .Register2Pattern C@
        DUP IF
            8/ MASK$07 2RegisterAddressing16
        ELSE
            DROP 1RegisterAddressing16
        THEN
        CurrentInstruction .AddressingMode  OR-C!
        AddrModeBytePresent   ;

   \ 32-bit addressing modes :
   \
   \     \ MODº     00     ³     01     ³     10      ³      11
   \    R/M \ º            ³            ³             ³  w=0  ³  w=1
   \   ÍÍÍÍÍÍÍÎÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍØÍÍÍÍÍÍÍ
   \     000  º   [EAX]    ³  [EAX]+d8  ³  [EAX]+d32  ³   AL  ³  EAX
   \     001  º   [ECX]    ³  [ECX]+d8  ³  [ECX]+d32  ³   CL  ³  ECX
   \     010  º   [EDX]    ³  [EDX]+d8  ³  [EDX]+d32  ³   DL  ³  EDX
   \     011  º   [EBX]    ³  [EBX]+d8  ³  [EBX]+d32  ³   BL  ³  EBX
   \     100  º    SIB     ³   SIB +d8  ³   SIB +d32  ³   AH  ³  ESP
   \     101  º [offset32] ³  [EBP]+d8  ³  [EBP]+d32  ³   CH  ³  EBP
   \     110  º   [ESI]    ³  [ESI]+d8  ³  [ESI]+d32  ³   DH  ³  ESI
   \     111  º   [EDI]    ³  [EDI]+d8  ³  [EDI]+d32  ³   BH  ³  EDI

: SetDisplacement8/32   ( disp R/M -- MM|000|R/M )
        SWAP DUP IF \ displacement <> 0
           DUP SignedValueSize \ R/M disp size
           SWAP   CurrentInstruction .Displacement   !
           8Bits = IF
                01  DUP ( length description = 1 also )
           ELSE \ use 32bit displacement
                02  3 ( length description = 3 )
           THEN
           16*   CurrentInstruction .Description   OR-C!
           64* ( shift left 6 bits ) OR
        ELSE \ displacement = 0
           DROP
        THEN ;

   \  Scale Index Byte Format :    7  6  5  4  3  2  1  0
   \                             ÚÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ¿
   \           SS | III | BBB    ³ S  S³ I  I  I³ B  B  B³
   \                             ÀÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÙ
   \  Scale = 00 ... *1
   \          01 ... *2
   \          10 ... *4
   \          11 ... *8
   \
   \  Base = 000 ...... EAX
   \         001 ...... ECX
   \         010 ...... EDX
   \         011 ...... EBX
   \         100 ...... ESP
   \         101 ...... EBP ( except MOD=00 for 32-bit displacement, no base )
   \         110 ...... ESI
   \         111 ...... EDI
   \
   \ Index = 000 ...... EAX
   \         001 ...... ECX
   \         010 ...... EDX
   \         011 ...... EBX
   \         100 ...... ( None, scale MUST be 0 )
   \         101 ...... EBP
   \         110 ...... ESI
   \         111 ...... EDI

: <Scale&Index&Base+disp>   ( displacement index base scale -- )
    \ Full ScaleIndexByte :  [ Base Index *Scale + displacement + ]
    \                     or [ Index *scale Base + displacement + ]
        64* OVER OR ROT \ disp base SS000BBB index
        DUP [ ` ESP ] LITERAL = IF   ESPcan'tBeIndex Error   THEN
        8* OR   CurrentInstruction .ScaleIndexByte   C!
        OVER 0x04 ( R/M=100=SIB present )  SetDisplacement8/32
        CurrentInstruction .AddressingMode  OR-C!
        CheckMode...(E)BP=Base
        ScaleIndexBytePresent  ;

: <Scale&Index+disp>   ( displacement index scale -- )
        OVER  [ ` ESP ] LITERAL  =  IF   ESPcan'tBeIndex Error   THEN
        0 ( a fake displacement to make MOD=?? ) -ROT
        0x05 ( base=101=EBP except MOD=00 ) SWAP   <Scale&Index&Base+disp>
     \ Now, mask off the MOD=XX into MOD=00 ( XX|REG|R/M => 00|REG|R/M )
        CurrentInstruction .AddressingMode
        DUP C@ MASK$3F ( 00 111 111 ) SWAP C!
     \ Always a 32-bit displacement
        CurrentInstruction .Displacement !
        0x30 ( 00 11 0 0 00 )   CurrentInstruction .Description   OR-C!  ;

: <Base+disp>   ( displacement baseReg -- )
    \ Only when ESP is base register could assembler reach this routine,
    \ since [ Base disp + ] can be enconded in MM|REG|R/M byte,SIB never needed.
        0x00 ( index=000=EAX, temporary )  SWAP  0  <Scale&Index&Base+disp>
        [ 0x04 ( index=100=None ) 8* ] LITERAL \ modify index into None
        CurrentInstruction .ScaleIndexByte  OR-C! ;

: 2RegistersInSIB       ( disp desc^ reg1 reg2 -- )
    \ If the scale is 0, the order of reg1 and reg2 can be exchanged.
    \ If scale <> 0, explicit order is required.
        ROT .Scale C@ DUP MASK$03  \ disp  reg1  reg2  desc^.scale  scale
        DUP IF \ Scale <> 0
           SWAP 0x80 AND IF \ scale on reg2
                >R SWAP R> \ change the order of reg1 and reg2
           THEN \ disp index base scale
        ELSE       \ scale = 0       disp  reg1  reg2
           2DROP \ Use EBP as base might waste 1 byte,
                 \ refer to  CheckMode...(E)BP=Base
           OVER [ ` ESP ] LITERAL =       \ index is ESP ? ( illegal )
           OVER [ ` EBP ] LITERAL =  OR   \ base is EBP ? ( save space )
           IF  SWAP  THEN   0
        THEN
        <Scale&Index&Base+disp>  ;

: SetScaleIndexByte     ( displacement oprNdesc^ -- )
    \ Encode SIB byte   SS | III | BBB
        DUP .Register1Pattern C@ 8/ MASK$07
        OVER .Register2Pattern C@  \ disp desc^ reg1 reg2pat
        DUP IF  \ 2 registers used in addressing, full scale index byte
           8/ MASK$07  \ disp desc^ reg1 reg2
           2RegistersInSIB
        ELSE        \ 1 register used in addressing, partial scale index byte
           DROP SWAP .Scale C@ DUP IF \ index and scale
               <Scale&Index+disp>
           ELSE \ no scale, only base and disp
               DROP   <Base+disp>
           THEN
        THEN  ;

: 1RegisterAddressing32 ( displacement oprNdesc^ -- )
     \ 1 register used in addressing and no scaling.
        DUP .Register1Pattern C@ 8/ MASK$07     \ register value
        [ ` ESP ] LITERAL  OVER  =  IF
           DROP SetScaleIndexByte
        ELSE \ encode  MM|REG|R/M   byte
           NIP 2DUP  \ disp reg-value  disp reg-value
           SetDisplacement8/32  CurrentInstruction .AddressingMode   OR-C!
           CheckMode...(E)BP=Base  AddrModeBytePresent
        THEN ;

: 32BitsAddressingModes ( displacement oprNdesc^ -- )
        DUP .Register2Pattern C@  0<>    \ 2 registers used in addressing
        OVER .Scale C@  0<>  OR   IF     \ scale value applied.
           SetScaleIndexByte
        ELSE \ 1 register and no scale used in addressing
           1RegisterAddressing32
        THEN ;

: ApplyOpcodeModifier   ( register-value -- )
    \ Opcode modifier exists only when there is only one register operand
    \  needs to be identified in opcodes, so the other operand ( if there is
    \  one ) must be a special pattern .
    \ See BSWAP DEC ESC INC MOV POP PUSH XCHG    and
    \     FADD FCOM FDIV FDIVR FFREE FLD FMUL FSTP FSUB FSUBR FUCOM FXCH .
        CurrentInstruction .Op1         \ modify the last opcode
        CurrentInstruction .Description C@ MASK$03 1-    +   OR-C!  ;

: ApplyRegister>>MOD|REG|R/M  ( entry^ entry^.oprNpat^ register-value -- )
    \ This is the same for both 16-bit and 32-bit segment.
        SWAP C@ DUP MASK$3F MemoryType >
        IF \ any general register type
           ROT .OverallDescription C@ 64/ MASK$01 0<>  \ 2 register patterns
           SWAP 8/ MASK$07 IntegerRegisterType = AND IF
                [ 3 64* ] LITERAL OR \ 11|reg|R/M ( for MOV instruction )
           ELSE
                8*      \ mm|REG|r/m
           THEN
        ELSE   \ 11|reg|R/M    ( entry^ register-value entry^.oprNpat )
           ROT 2DROP [ 3 64* ] LITERAL OR \ 11|reg|R/M
        THEN
        CurrentInstruction .AddressingMode   OR-C!
        AddrModeBytePresent ;

: ApplyGeneralRegisters   ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
        .OperandPattern C@    DUP OperandPrefixCheck
        8/ MASK$07 \ oprVal entry^ entry^.oprNpat^ register-value
        ROT DUP .DetailDescription
        C@ MASK$01 IF   \ opcode modifier exist
            DROP ApplyOpcodeModifier DROP
        ELSE \ no opcode modifier, MOD|REG|R/M byte should present
            -ROT ApplyRegister>>MOD|REG|R/M
        THEN DROP ;

: ApplyMemoryAddressingModes  ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
    \ Either memory or integer registers
        DUP .OperandPattern C@ MASK$07   IntegerRegisterType  =  IF
            ApplyGeneralRegisters
        ELSE
            -ROT 2DROP DUP .OperandPattern C@  OperandPrefixCheck
            DUP .Register1Pattern C@ DUP 0= IF  \ only offset present
                2DROP OffsetOnly        \ choose shortest representation
            ELSE
                64/  DUP UseXX @ <> IF  AS:  THEN  \ check addressing prefix
                16Bits = IF     \ 16bit addressing
                   16BitsAddressingModes
                ELSE            \ 32Bit addressing
                   32BitsAddressingModes
                THEN
            THEN
        THEN ;

: ApplyGeneralPattern   ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
        OVER C@ 8/ MASK$07  MemoryType  =  IF  \ Memory / integer registers
            ApplyMemoryAddressingModes
        ELSE \ general register type
            ApplyGeneralRegisters
        THEN  ;

\ Special patterns :

VARIABLE RelativeFlag \ bit 0 : 1 = relative value
                      \ bit 6,7 : relative size limit

: LayDownOffset  ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
        ApplyMemoryAddressingModes
        CurrentInstruction .Description DUP  C@ [ 0x04 NOT ] LITERAL AND
        SWAP C! ; \ mask off the 'addressing mode byte present' flag

: LayDownRelativeAddress  ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
        DROP NIP C@
        0xC0 AND DUP 1 OR  RelativeFlag  !  \ it will be processed later
        64/ 1+ 16* CurrentInstruction .Description OR-C!
        CurrentInstruction .Displacement ! ;

: LayDownDisplacement  ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
        DROP NIP C@
        64/ 1+  \ add 1 just met length description
        16*   CurrentInstruction .Description   OR-C!
        CurrentInstruction .Displacement ! ;

: MoveImmed>Disp ( -- )
        CurrentInstruction .Description C@ DUP 0xC0 AND 4/
        SWAP MASK$3F OR  CurrentInstruction .Description  C!
        CurrentInstruction DUP .ImmediateValue @ SWAP .Displacement ! ;

: LayDownImmediateValue  ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
      \ There are two immediate operands for ENTER. Put the first one into
      \ displacement.
        DROP SWAP .OverallDescription C@ 0x80 AND IF \ force size check flag?
           DROP UseXX @
        ELSE
           C@ 64/
        THEN
        CurrentInstruction .Description C@ 64/ IF \ immediate present
           MoveImmed>Disp
        THEN
        1+  \ add 1 just met length description
        64*   CurrentInstruction .Description    OR-C!
        CurrentInstruction .ImmediateValue !  ;

: ApplyExtremeCases ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
        OVER C@ MASK$3F
        CASE
           OffsetType           OF   LayDownOffset                 ENDOF
           RelativeType         OF   LayDownRelativeAddress        ENDOF
           DisplacementType     OF   LayDownDisplacement           ENDOF
           MemoryOnlyType       OF   ApplyMemoryAddressingModes    ENDOF
           Memory>=80Type       OF   ApplyMemoryAddressingModes    ENDOF
           SignedImmediateType  OF   LayDownImmediateValue         ENDOF
           ImmediateType        OF   LayDownImmediateValue         ENDOF
        ENDCASE ;

: ApplySpecialRegisters ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
        \ Special register information has already been encoded in opcode,
        \ so just check operand size.
        DROP C@ OperandPrefixCheck 2DROP ;

: ApplySpecialPattern ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
        OVER C@ MASK$07 ExtremeCases = IF
            ApplyExtremeCases
        ELSE
            ApplySpecialRegisters
        THEN ;

: ApplyOneOperand ( oprVal entry^ entry^.oprNpat^ oprNdesc^ -- )
        OVER C@ MASK$07 GeneralTypes = IF
            ApplyGeneralPattern
        ELSE
            ApplySpecialPattern
        THEN ;

: ExtendedOpcode  ( 00opc000 -- )
        MASK$38  CurrentInstruction .AddressingMode
        DUP C@   DUP MASK$38  IF
           8/ 0xC0 ( 11000000 ) OR
        THEN
        ROT OR SWAP C! ;

: ApplyOperands  \ ( dest entry^ -- dest entry^ ) or
                 \ ( dest source entry^ -- . . . ) or
                 \ ( dest source1 source2 entry^ -- . . . . )

     \ * Check operand prefix and addressing mode prefix .
     \ * Operands associate with special pattern for registers never have
     \   to be dealed with since it has already encoded in opcodes.
     \ * Relative values should be take cared . (size should be checked)

        >R #Operands @ 0 ?DO   I 2 * PICK   LOOP
        R>         \ (d d e^) or (s d d s e^) or (s1 s2 d d s2 s1 e^)
        #Operands @ 0 ?DO              ( s1 d d e^ s1 e^ e^.oprNpat^ descN^ )
            SWAP OVER DUP .Operand1Pattern  I +     ( ... x e^ e^.oprNpat^ )
            OperandDescriptors  OperandDescriptor: I *  +
            ApplyOneOperand                                        ( ... e^ )
            NoOperandPrefix @ 2/  NoOperandPrefix  !
        LOOP
        DUP .DetailDescription C@ DUP 0x02 AND IF \ extended opcode exist
            ExtendedOpcode
        ELSE
            DROP
        THEN ;

: AdjustToRelativeValue ( -- T/F )
        CurrentInstruction .Displacement @
        CurrentInstruction InstructionLength   HERE   +
        -  DUP
        SignedValueSize   RelativeFlag @ 64/   <=    IF
            CurrentInstruction .Displacement !    TRUE
        ELSE
            DROP FALSE  \ relative value out of range
        THEN ;

: ApplyToCurrentInstruction  ( ? ? ? Table-Entry -- ? ? ? Table-Entry T/F )
        0   RelativeFlag   !
        DUP .OverallDescription C@ 16/  NoOperandPrefix  !
        DUP CopyOpcodes
        #Operands @ IF \ more than 1 operand
           ApplyOperands
        ELSE \ zero-operand instruction, check whether it needs a prefix
             \ for IRET, IRETD, SCASW, SCASD ...
           DUP .Operand1Pattern C@ OperandPrefixCheck
        THEN
        TRUE
        RelativeFlag @ IF
           DROP AdjustToRelativeValue \ Instruction pointer relative value
        THEN  ;

: CheckStillAddressing   ( -- )
        DefiningMemoryLocation @ IF StillAddressingNow Error THEN ;

VARIABLE PreProcessing  \ a flag used only by PrefixSyntaxPreProc 09/19/'95
         PreProcessing OFF
: PrefixSyntaxPreProc   ( PFA -- PFA )  \ 09/18/'95 \ 10/04/'95 bug fixed
        \ Prefix syntax preprocessor
        SYNTAX? PREFIX = IF
            STATE @         IF  NotInterpretingMode    Error  THEN
            PreProcessing @ IF  PreProcessing OFF  \ 10/04/'95
                                PrefixSyntaxMultiInstr Error  THEN
           PreProcessing ON  \ reentrant prevention
           >R
          ['] INTERPRET CATCH THROW \ this might cause recursion to PrefixSyntaxPreProc
           PreProcessing OFF
           R>
        THEN ;

: LayoutCurrentInstruction \ ( PFA -- ) or
                           \ ( dest PFA -- ) or
                           \ ( dest source PFA -- ) or
                           \ ( dest source1 source2 PFA -- )
        PrefixSyntaxPreProc                     \ 09/18/'95
        CheckStillAddressing
        DUP .FirstPatternEntry FALSE ROT          ( ? ? ? entries^ FALSE PFA )
        .#Patterns C@
  0  DO                            ( ? ? ? ^entry flag )
           >R
           DUP InstructionPatternMatch? IF
                ApplyToCurrentInstruction ( ? ? ? entry^ -- ? ? ? entry^ T/F )
                RDROP >R R@  IF   ChooseInstruction   THEN
                ClearCurrentInstructionButPrefixes      \ 10/06/'95
           THEN
           InstructionDescriptor: + \ next entry^
           R>
        LOOP                                   ( ? ? ? ^entry flag )
        NIP  NOT IF   InvalidOperands Error   THEN     \ No one matched ?
        #Operands @ 0 ?DO   DROP   LOOP 
        Instruction>>TargetMemory 
        FALSE ChooseLongest !
        ClearInstructionBuffers  
       ResetOperandDescriptors   ;

\ -----------------------------
\  Disassembling Phase words :
\ -----------------------------

\ CR .(  6.4  Instruction Disassemble ...)

 \ All instruction descriptor modifier are exclusive, ( except for ~prechkN
 \ modifier ). All the rules are commented inside the associated routines.
 \   Note:  "+reg" modifier never appears with any other modifier.

 \ 1. General routines :

: OperandPattern1       CurrInstDesc^@ .Operand1Pattern     C@ ;
: OperandPattern2       CurrInstDesc^@ .Operand2Pattern     C@ ;
: OperandPattern3       CurrInstDesc^@ .Operand3Pattern     C@ ;

: is-MEMONLY? ( pattern -- T/F )
        MASK$3F DUP MemoryOnlyType =  SWAP Memory>=80Type =  OR ;

: is-R/M? ( pattern -- T/F )
        MASK$3F DUP MemoryType =  SWAP is-MEMONLY?  OR  ;

: is-REG? ( pattern -- T/F )
        MASK$3F DUP MASK$07 0=   SWAP MemoryType >   AND  ;

: UsingAdjust  ( size flag -- size' )
      \ 8Bits = 00, 16Bits = 01, 32Bits = 10, 64Bits = 11
        OVER DUP 16Bits = SWAP 32Bits = OR IF
           NIP UseXX @ SWAP IF  0x03 XOR  THEN
        ELSE
           DROP
        THEN ;

: OperandPrefixOFF   ( -- )
        PrefixDisassembled DUP @ MASK$02 SWAP ! ;

: AdjustToSizeUsing ( PatternSize -- SizeUsing )       \ operand prefix
        CurrOverallDescription 16/
        DisOperandIndex@ CASE
         \ 1  OF  ( already done )   ENDOF
           2  OF  2/                 ENDOF
           3  OF  DROP 0             ENDOF
        ENDCASE
        MASK$01 0=  IF
           PrefixDisassembled @ MASK$01 0<>  UsingAdjust
        THEN  ;

: AdjustToAddressUsing ( AddressSize -- AddressUsing ) \ address prefix
        PrefixDisassembled @ MASK$02 UsingAdjust ;

: RegisterForOpcodeModifier     ( Toperand_adr -- register_value )
        1- C@                                           ( Topc )
        CurrOverallDescription MASK$03 1-  CurrInstDesc^@ .Opcode1  +  C@
        -  ;  \  curr-op - opcode0 = register_value

: NextDisassembler ( Toperand_adr -- Tnext_adr )
        ClearDisassembledOperands
        CurrInstDesc^@ .DisassemblerLinkIndex W@ SWAP
        CurrDetailDescription MASK$01 IF \ opcode modifier exists
            RegisterForOpcodeModifier  +
        ELSE  \ opcode modifier does not exist
            DROP
        THEN
        DisassemblerLinkSpace[]  CurrTargetOpcode1^ @ SWAP
        DUP .EntryIndex C@ SWAP .^InstructionDisassembler @EXECUTE ;

: FollowingT@  ( ^Taddr size -- ^Tnext value )
        OVER SWAP ( ^Taddr ^Taddr size )
        CASE
            8Bits  OF   1+  SWAP C@   ENDOF
           16Bits  OF   2 + SWAP W@   ENDOF
           32Bits  OF   4 + SWAP @    ENDOF
        ENDCASE  ;

: SignedFollowingT@ ( ^Taddr size -- ^Tnext value )
        DUP >R FollowingT@ R>
        CASE
           8Bits OF  U8>S8    ENDOF
          16Bits OF  U16>S16  ENDOF
        ENDCASE  ;

 \ 2. 16-bit addressing modes ( USE16 )

: Set1Reg16 ( 'reg1 -- )
        1 SWAP EXECUTE ;
: Set2Reg16 ( 'reg1 'reg2 -- )
        2 SWAP EXECUTE Set1Reg16 ;

: <BX+SI>  ( -- )   ['] BX ['] SI  Set2Reg16 ;
: <BX+DI>  ( -- )   ['] BX ['] DI  Set2Reg16 ;
: <BP+SI>  ( -- )   ['] BP ['] SI  Set2Reg16 ;
: <BP+DI>  ( -- )   ['] BP ['] DI  Set2Reg16 ;
: <SI>     ( -- )   ['] SI         Set1Reg16 ;
: <DI>     ( -- )   ['] DI         Set1Reg16 ;
: <BP>     ( -- )   ['] BP         Set1Reg16 ;
: <BX>     ( -- )   ['] BX         Set1Reg16 ;

CREATE Addressing16Table
        ' <BX+SI> ,   ' <BX+DI> ,   ' <BP+SI> ,   ' <BP+DI> ,
        ' <SI> ,      ' <DI> ,      ' <BP> ,      ' <BX> ,

: DisassembleAddressing16  ( Toperand_adr R/M MM -- Tnext_adr )
        2DUP 0=   SWAP 0x06 ( 110B ) =   AND  IF  \ [disp16] mode
            2DROP 1+ 0x02                                      ( T^disp MM=$02 )
        ELSE
            SWAP  CELLS Addressing16Table  +  @EXECUTE
            SWAP 1+ SWAP                                          ( T^next MM )
        THEN
        CASE ( MM bits )
           0x00  OF  ( no disp ) 0                         ENDOF
           0x01  OF  ( disp8  )  8Bits SignedFollowingT@   ENDOF
           0x02  OF  ( disp16 ) 16Bits SignedFollowingT@   ENDOF
        ENDCASE
        Set.AssocDisplacement  ;

 \ 3. 32-bit addressing mode ( USE32 )

: Set1Reg32 ( regvalue reg-index -- )
        32Bits IntegerRegisterType ROT Set.RegNameX  ;

: DisassembleSIB  ( TSIB_adr MM -- Tnext_adr )
        SWAP DUP C@            \ MM TSIB_adr SIB
       \ 1. process Index (ssIIIbbb)
        DUP 8/ MASK$07
        DUP  [ ` ESP ] LITERAL <>   IF  \ ESP cannot be an index
            2 Set1Reg32 ( index )
        ELSE
            DROP  \ ESP = 100B, it means "No index register, scale must be 0"
        THEN                                                 ( MM ^TSIB SIB )
       \ 2. process Scale (SSiiibbb)
        DUP 64/ Set.AssocScale                                ( MM ^TSIB SIB )
       \ 3. process Base (ssiiiBBB)
        MASK$07         \ MM ^TSIB BBB
        ROT 0<>   OVER  [ ` EBP ] LITERAL  <>   OR  IF  \ ^TSIB BBB
          \ MM=00 and BBB=101(EBP) means 'No base register but 32 bit offset.'
            1 Set1Reg32 ( base )
            1+ ( skip SIB byte )
        ELSE
            DROP 1+ ( skip SIB byte )
            32Bits SignedFollowingT@ Set.AssocDisplacement
        THEN ;

: DisassembleAddressing32  ( Toperand_adr R/M MM -- Tnext_adr )
        OVER 0x04 ( 100B = SIB present )  =  IF                  ( ^opr R/M MM )
           NIP SWAP 1+ OVER DisassembleSIB  SWAP                ( Tnext_adr MM )
        ELSE \ SIB not present
           2DUP 0=   SWAP 0x05 ( 101B )  =  AND  IF  \ [disp32] mode
               2DROP 0x02                                       ( T^opr MM=$02 )
           ELSE
               SWAP 1 Set1Reg32                                    ( T^opr MM )
           THEN
           SWAP 1+ SWAP
        THEN
        CASE ( MM bits )
           0x00  OF  ( no disp ) 0                  ENDOF
           0x01  OF  ( disp8  )  8Bits SignedFollowingT@  ENDOF
           0x02  OF  ( disp32 ) 32Bits SignedFollowingT@  ENDOF
        ENDCASE
        Set.AssocDisplacement  ;

: Disassemble-R/M-bits   ( Toperand_adr OperandPattern -- Tnext_addr )
        DUP >R 64/ AdjustToSizeUsing DUP Set.OperandSize
        SWAP DUP C@ DUP MASK$07 SWAP 64/               ( oprsiz ^opr R/M MM )
        DUP 0x03 = IF  ( MM = 11B )
           R> is-MEMONLY? IF
              2DROP NIP NextDisassembler EXIT
           ELSE
              DROP ROT IntegerRegisterType 1 Set.RegNameX  1+
              RegisterOperand
           THEN
        ELSE          ( MM = 00B, 01B or 10B )
           R> MASK$3F Memory>=80Type =  IF  0xFF Set.OperandSize  THEN
           32Bits  DUP AdjustToAddressUsing  =  IF
               DisassembleAddressing32
           ELSE
               DisassembleAddressing16
           THEN
           NIP MemoryOperand
        THEN
        Set.OperandType  ;

: Disassemble-REG-bits  ( Toperand_adr OperandPattern -- Tnext_addr )
        OVER C@ 8/ MASK$07 SWAP DUP 64/ AdjustToSizeUsing
        SWAP 8/ MASK$07 1  Set.RegNameX
        RegisterOperand  Set.OperandType  1+  ;

: Disassemble-MOD|REG|R/M  ( Toperand_adr OperandPattern -- Tnext_addr )
      \ Any instruction with the pattern "XXX r/mxx regxx" or "XXX r/mxx segreg"
      \ should disassemble the "regxx" or "segreg" first, otherwise you will
      \ lost the original "operand-adr" since disassembling "r/mxx" might
      \ return "next-addr" with some bytes of distance from "operand-adr".
        DUP is-R/M? IF \ disassemble R/M bits
           Disassemble-R/M-bits
        ELSE \ disassemble REG bits
           DUP 8/ MASK$07 IntegerRegisterType = IF
              CurrOverallDescription 0x40 AND IF \ MOV, 2 general patterns
                \ Integer register of this pattern is always 32 bit.
                 32Bits  UseXX DUP @ >R  !  OperandPrefixOFF
                 Disassemble-R/M-bits R> UseXX ! EXIT
              THEN
           THEN
           Disassemble-REG-bits
        THEN  ;

 \ 4. Special operand patterns :

: DisassembleOffset  ( Toperand_adr OperandPattern -- Tnext_addr )
        64/ AdjustToSizeUsing Set.OperandSize
        UseXX @ AdjustToAddressUsing  ( addressing memory, use Address prefix )
        SignedFollowingT@  Set.AssocDisplacement  ;

: DisassembleRelative \ relative value to (E)IP register
                ( Toperand_adr OperandPattern -- Tnext_addr )
      \ Only CALL and JXX instructions have relative value, 1 operand only.
        64/ 0 UsingAdjust   \ Ignore Operand/Address prefix, always apply UseXX
        SignedFollowingT@
        OVER +   Set.AssocImmediate   ( .OperandType becames ImmediateOperand )
        AddressOperand  Set.OperandType   ;

: DisassembleDisplacement  ( Toperand_adr OperandPattern -- Tnext_addr )
      \ Only CALL and JMP have this operand pattern, besides, they
      \ are always the second operand. ( CALL imm16:disp16/32 )
        64/ AdjustToSizeUsing          ( \ Note: Not Address Prefix !!! \ )
        FollowingT@  Set.AssocImmediate  ;

: DisassembleImmediate  ( Toperand_adr OperandPattern -- Tnext_adr )
      \ 1) for 1-operand instructions, imm16 or imm32 will be applied directly
      \    except for the 'force immediate operand size check' flag is set.
      \ 2) for instructions which has more than 1 operand, imm16 and imm32
      \    are used according to UseXX and the operand prefix, except when
      \    imm16 is used as the first operand ( for ENTER, CALL and JMP ).
        64/  \ operand size
        CurrOverallDescription 4/ MASK$03  1 =  IF \ 1 operand
           CurrOverallDescription 0x80 AND \ force immediate size check ?
        ELSE \ more than 1 operand
           DisOperandIndex@ 1 <>        \ immXX is not the first operand
        THEN
        IF   AdjustToSizeUsing  THEN
        FollowingT@  Set.AssocImmediate  ;

: DisassembleSignedImmediate  ( Toperand_adr OperandPattern -- Tnext_adr )
      \ Only signed 8 bit immediate exists.
        64/ SignedFollowingT@  Set.AssocImmediate  ;

: DisassembleExtremeCases  ( Toperand_adr OperandPattern -- Tnext_addr )
      \ For all extreme cases, there is no possibility that the operand-adr
      \ is a MOD|REG|R/M or SIB byte, since all general patterns appears
      \ first. So, fetch their values from operand-adr directly.
        DUP MASK$3F CASE
            OffsetType           OF    DisassembleOffset             ENDOF
            RelativeType         OF    DisassembleRelative           ENDOF
            DisplacementType     OF    DisassembleDisplacement       ENDOF
            MemoryOnlyType       OF    Disassemble-MOD|REG|R/M       ENDOF
            Memory>=80Type       OF    Disassemble-MOD|REG|R/M       ENDOF
            SignedImmediateType  OF    DisassembleSignedImmediate    ENDOF
            ImmediateType        OF    DisassembleImmediate          ENDOF
        ENDCASE  ;

: DisassembleSpecialPatterns  ( Toperand_adr OperandPattern -- Tnext_adr )
        DUP MASK$07 ExtremeCases <> IF
          \ Special register pattern, operand info. is embeded in opcode,
          \ so there is no need to decode the MOD|REG|R/M byte.
           DUP 8/ MASK$07 OVER 64/ ROT MASK$07            ( ^opr rval siz typ )
           DUP IntegerRegisterType = IF   SWAP AdjustToSizeUsing SWAP   THEN
           1 Set.RegNameX   RegisterOperand Set.OperandType
        ELSE
           DisassembleExtremeCases
        THEN  ;

 \ 5. Routines for disassembling operands :

: DisassembleOneOperand  ( ^Toperand OperandPattern -- Tnext_addr )
        DUP MASK$07 GeneralTypes = IF
            Disassemble-MOD|REG|R/M     \ general patterns
        ELSE
            DisassembleSpecialPatterns
        THEN  ;

: DisassembleWithoutModifiers  ( Toperand_adr -- Tnext_addr )
      \ Things are a little complicate if the instruction has more than
      \ one operand ( without opcode/extended-opcode modifier ) :
      \    1. if the first operand pattern is "r/mXX", the second operand
      \       is always a "regXX" or "segreg" pattern.
      \    2. if the first operand pattern is "regXX", then the second operand
      \       must be disassembled from the MM|REG|R/M byte.
      \    3. otherwise, all operands are of special pattern.
        CurrOverallDescription 4/ MASK$03 ( #operand )
        1 = IF  \ 1 operand
           OperandPattern1 1DisOperandIndex!
        ELSE    \ more than 1 operand
           OperandPattern2 OperandPattern1           ( Toperand_adr pat2 pat1 )
           DUP is-R/M? IF
             \ Pattern 1 is R/Mxx, so pattern 2 is REGxx, disassembled it first
              -ROT OVER SWAP 2DisOperandIndex!  DisassembleOneOperand  DROP
              SWAP 1DisOperandIndex!                  ( Toperand_adr pattern1 )
           ELSE
              ROT                                    ( pat2 pat1 Toperand_adr )
              OVER is-REG? IF
                \ Pattern 1 is REGxx, so pattern 2 is R/Mxx or MEMxx
                 DUP ROT 1DisOperandIndex!  DisassembleOneOperand       DROP
              ELSE
                \ Pattern 1 is a special pattern, so does pattern 2
                 SWAP 1DisOperandIndex! DisassembleOneOperand ( pat2 Tnext_adr )
              THEN
              SWAP 2DisOperandIndex!                  ( Toperand_adr pattern2 )
           THEN
        THEN
        DisassembleOneOperand  ;

: Disassemble-Opcode-Modifier  ( Toperand_adr -- Tnext_addr )
      \ Opcode-modifer always applied on the last opcode.
        DUP RegisterForOpcodeModifier                          ( ^Topr regval )
        DisOperandIndex@ 1 = IF  OperandPattern1  ELSE  OperandPattern2  THEN
        DUP 64/ ( reg-size )  AdjustToSizeUsing
        SWAP 8/ MASK$07 ( reg-type ) 1  Set.RegNameX
        RegisterOperand  Set.OperandType  ;

: Disassemble-MOD|REG|R/M-Modifier  ( Toperand_adr -- Tnext_addr T/F )
        DUP C@ MASK$38   CurrDetailDescription MASK$38   =
        IF   \ MOD|REG|R/M modifier match
           OperandPattern1  1DisOperandIndex!
           Disassemble-MOD|REG|R/M    TRUE ( continue on next operand )
        ELSE \ MOD|REG|R/M modifier not match, next disassembler
           NextDisassembler          FALSE ( done, no continue )
        THEN  ;

: NoOperandInstruction  ( Toperand_adr -- Tnext_addr )
      \ Check for instruction size ( like CWDE, CBW, MOVSW, MOVSD ... )
        OperandPattern1 64/   DUP AdjustToSizeUsing   <>  IF
            NextDisassembler
        THEN  ;

: OneOperandInstruction  ( Toperand_adr -- Tnext_addr )
        CurrDetailDescription
        DUP MASK$01 IF   \ opcode modifier exists
           DROP 1DisOperandIndex!       Disassemble-Opcode-Modifier
        ELSE MASK$02 IF  \ MOD|REG|R/M modifier exist
           Disassemble-MOD|REG|R/M-Modifier DROP
        ELSE             \ all other patterns without modifiers
           DisassembleWithoutModifiers
        THEN THEN ;

: TwoOperandInstruction  ( Toperand_adr -- Tnext_addr )
      \ For 2-operand instructions with
      \  1. MOD|REG|R/M modifier :
      \       the second operand could only be immediate or special register.
      \  2. Opcode modifier :
      \       it might be applied on the first operand or the second one.
      \       But the other operand is either immediate or special register.
        CurrDetailDescription
        DUP MASK$02 IF   \ MOD|REG|R/M modifier exist
            DROP Disassemble-MOD|REG|R/M-Modifier   IF
                OperandPattern2 2DisOperandIndex!   DisassembleSpecialPatterns
            THEN
        ELSE MASK$01 IF  \ opcode modifier exist
            OperandPattern1  MASK$07  GeneralTypes  =  IF
               1DisOperandIndex!  Disassemble-Opcode-Modifier     ( next_addr )
               OperandPattern2  2DisOperandIndex!   DisassembleSpecialPatterns
            ELSE         \ Operand 1 is an special register pattern
               OperandPattern1  1DisOperandIndex!   DisassembleSpecialPatterns
               2DisOperandIndex!  Disassemble-Opcode-Modifier
            THEN
        ELSE             \ without modifiers
            DisassembleWithoutModifiers
        THEN THEN  ;

: ThreeOperandInstruction  ( Toperand_adr -- Tnext_addr )
      \ only IMUL, SHLD and SHRD has three operands, besides, the third operand
      \ is an immediate pattern or a special register pattern.
        TwoOperandInstruction
        OperandPattern3   3DisOperandIndex!   DisassembleSpecialPatterns  ;

CREATE #OperandsDisassembler
        ' NoOperandInstruction ,
        ' OneOperandInstruction ,
        ' TwoOperandInstruction  ,
        ' ThreeOperandInstruction ,

: DisassembleOperands  ( Toperand_adr -- Tnext_adr )
        CurrOverallDescription 4/ MASK$03    \ Number of operands
        CELLS #OperandsDisassembler +  @EXECUTE  ;

: DisassembleInstruction ( opcode_addr EntryIndex PFA -- next_instruction_addr )
        DUP CurrInstructionBody^ !
        Index/PFA>InstDesc  CurrInstDesc^  !                        ( opc_adr )
        DUP CurrTargetOpcode1^ !
        CurrOverallDescription MASK$03 1 = IF \ 1 opcode
           1+ DisassembleOperands
        ELSE \ 2 opcodes at most, 3 opcodes are compound instructions
         \ For instructions with opcode modifier, the second opcode is
         \ not always the same ( must +reg, opc2 <= Topc <= opc2+7 )
           DUP C@  CurrInstDesc^@ .Opcode1 C@  =                  ( ^opc T/F )
           OVER 1+ C@ CurrInstDesc^@ .Opcode2 C@       ( ^opc T/F topc2 opc2 )
           CurrDetailDescription MASK$01  IF  \ opcode modifier exist.
                DUP 7 +  BETWEEN
           ELSE
                =
           THEN
           AND  IF
              2 + DisassembleOperands
           ELSE
              2 + NextDisassembler
           THEN
        THEN
        CurrInstructionBody^ @ DisassembledMemonic  ;

: Instruction: ( -- )
        0  CurrInstDescIndex  !
        CREATE HERE InstructionPatterns: ALLOT \ it will perform a CREATE
              .#Patterns 0 SWAP C!
        DOES> \ ( PFA -- ) or ( dest PFA -- ) or ( dest source PFA -- ) or
              \ ( dest source1 source2 PFA -- ), according to the number
              \ of operands of this instruction ( AssemblingPhase )
               Assembler-Phase @
              CASE
                DefiningPhase      OF  AddInstructionTableEntry  ENDOF
                AssemblingPhase    OF  LayoutCurrentInstruction  ENDOF
                DisassemblingPhase OF  DisassembleInstruction    ENDOF
              ENDCASE
;

\ Special operand patterns for defining instruction descriptor :

\ CR .( 7. Operand/Modifier Defining Words ...)

: SetOperandPattern ( size type sub-type -- )
        FormPatternByte  CurrOperandPattern  C!  ;

: immXX ( XX -- )  ExtremeCases  ImmediateType 8/  SetOperandPattern ;
: imm8  ( -- )  8Bits immXX ;
: imm16 ( -- ) 16Bits immXX ;
: imm32 ( -- ) 32Bits immXX ;

: sgnimm8   8Bits ExtremeCases  SignedImmediateType 8/  SetOperandPattern ;

: offXX ( XX -- )  ExtremeCases  0   SetOperandPattern ;
: off8  ( -- )  8Bits offXX ;   \ BYTE^  [ OFFSET ]
: off16 ( -- ) 16Bits offXX ;   \ HWORD^ [ OFFSET ]
: off32 ( -- ) 32Bits offXX ;   \ WORD^  [ OFFSET ]

: relXX ( XX -- )   \ relocation needed .....  Not implemented yet.
        ExtremeCases 1   SetOperandPattern ;
: rel8  ( -- )  8Bits relXX ;   \ (E)IP + rel8
: rel16 ( -- ) 16Bits relXX ;   \    IP + rel16
: rel32 ( -- ) 32Bits relXX ;   \ (E)IP + rel32

: dispXX ( XX -- ) ExtremeCases DisplacementType 8/  SetOperandPattern ;
: disp16 ( -- ) 16Bits dispXX ;
: disp32 ( -- ) 32Bits dispXX ;

: memXX  ( XX -- ) ExtremeCases  MemoryOnlyType 8/  SetOperandPattern ;
: mem8   ( -- )  8Bits memXX ;
: mem16  ( -- ) 16Bits memXX ;
: mem32  ( -- ) 32Bits memXX ;
: mem64  ( -- ) 64Bits memXX ;
: mem>=80 ( -- ) 80Bits ExtremeCases Memory>=80Type 8/  SetOperandPattern ;

\ General operand patterns for defining instruction descriptor :

: r/mXX ( XX -- )  GeneralTypes MemoryType  SetOperandPattern ;
: r/m8  ( -- )  8Bits r/mXX ;
: r/m16 ( -- ) 16Bits r/mXX ;
: r/m32 ( -- ) 32Bits r/mXX ;

: regXX   ( XX -- )  GeneralTypes IntegerRegisterType  SetOperandPattern ;
: reg8    ( -- )  8Bits regXX ;
: reg16   ( -- ) 16Bits regXX ;
: reg32   ( -- ) 32Bits regXX ;

: freg    ( -- )  80Bits GeneralTypes FloatingRegisterType SetOperandPattern ;
: segreg  ( -- )  16Bits GeneralTypes SegmentRegisterType  SetOperandPattern ;
: ctrlreg ( -- )  32Bits GeneralTypes ControlRegisterType  SetOperandPattern ;
: testreg ( -- )  32Bits GeneralTypes TestRegisterType     SetOperandPattern ;
: dbgreg  ( -- )  32Bits GeneralTypes DebugRegisterType    SetOperandPattern ;

\ Opcode modifiers and extended opcode modifiers :

: SetInstDescFlags      ( flags -- )
        CurrInstDesc^@ .OverallDescription OR-C! ;
: ~prechkX ( X -- )  \ NO operand prefix check flag marker
        16* SetInstDescFlags ;
: ~prechk1  ( -- ) 1 ~prechkX ;
: ~prechk2  ( -- ) 2 ~prechkX ;

: immprechk ( -- ) 0x80 SetInstDescFlags ; \ force operand prefix check

: 2regpat ( -- ) [ 1 64* ] LITERAL SetInstDescFlags ;

: +reg    ( -- )  \ Opcode modifier. No 3-opcoded instruction have this.
        1   CurrInstDesc^@ .DetailDescription   OR-C!
        CurrInstDescIndex @ 1-   LAST-WORD-CFA
        CurrInstDesc^@ .Opcode1
        CurrOverallDescription MASK$03          ( index cfa ^opcode1 #opcodes )
        CASE
            1  OF  C@ ( 1-byte opcode )                      ( index cfa opc1 )
                   8 1 DO
                      1+ >R 2DUP R@ 1-opcodeDisassembler>>TableEntry R>
                   LOOP
                   -7 CurrInstDesc^@ .DisassemblerLinkIndex +!          ENDOF
            2  OF  W@ ( 2-byte opcode )                     ( index cfa opc21 )
                   8 1 DO
                      0x100 + >R 2DUP R@ 2-opcodeDisassembler>>TableEntry R>
                   LOOP
                   -7 CurrInstDesc^@ .DisassemblerLinkIndex +!          ENDOF
        ENDCASE
        2DROP DROP  ;

: rrr   ( X -- ) \ extended opcode modifier ( MOD|REG|R/M modifier )
        8* 2 OR   CurrInstDesc^@ .DetailDescription   OR-C!     ;
: rrr=0   0 rrr ;
: rrr=1   1 rrr ;
: rrr=2   2 rrr ;
: rrr=3   3 rrr ;
: rrr=4   4 rrr ;
: rrr=5   5 rrr ;
: rrr=6   6 rrr ;
: rrr=7   7 rrr ;

\ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
\ %                  Assembly   Language   Defining                        %
\ %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\ CR .( 8. Assembly Language Defining ...)

: CheckValidAddressingMode  ( OprNDec^ -- )
        DUP .Register1Pattern C@ DUP IF
            DUP DUP MASK$07 IntegerRegisterType =
            SWAP 64/ 8Bits <> AND  IF
               SWAP .Register2Pattern C@ DUP IF
                  MASK$C7 SWAP MASK$C7 <> IF InvalidAddressingMode Error THEN
               ELSE
                  2DROP
               THEN
            ELSE
               InvalidAddressingMode Error
            THEN
        ELSE
            2DROP
        THEN ;

: CheckAddressingMemory  ( -- )
        DefiningMemoryLocation @ NOT IF NotAddressingNow Error THEN ;

\ The following 2 words are used in interpreting mode for defining memory
\ location.
: {     ( -- )  CheckStillAddressing  TRUE  DefiningMemoryLocation !   ;
: }     ( -- )  CheckAddressingMemory
                FALSE DefiningMemoryLocation !
                Operand^@ CheckValidAddressingMode  Operand^++  ;

: (USEXX) ( XX -- )  UseXX !  ResetOperandDescriptors   ;

FORTH DEFINITIONS

: USE16 16Bits (USEXX) ;
: USE32 32Bits (USEXX) ;
: USE@ ( -- u ) UseXX @ 16Bits = IF 0x10 ELSE 0x20 THEN ;
: USE! ( u -- ) 0x20 OVER = IF USE32 ELSE 0x10 OVER = IF USE16 THEN THEN DROP ;

ASSEMBLER DEFINITIONS

: MemoryPointer ( size -- )  GeneralTypes MemoryType
        FormPatternByte   Operand^@ .OperandPattern   C! ;
: BYTE^  8Bits  MemoryPointer ;
: WORD^  16Bits MemoryPointer ;
: DWORD^ 32Bits MemoryPointer ;
: QWORD^ 64Bits MemoryPointer ;
: TBYTE^ 80Bits  ExtremeCases  Memory>=80Type 8/
        FormPatternByte   Operand^@ .OperandPattern   C! ;

: SHORT FALSE ChooseLongest ! ;
: LONG  TRUE ChooseLongest ! ;

: #     ( immediate-value -- immediate-value )
        DUP   SignedValueSize  Operand^@ .Scale  C! \ .Scale as piggyback
        DUP UnsignedValueSize   ExtremeCases  DUP  FormPatternByte
        Operand^@ .OperandPattern  C!   Operand^++      ;

: *Scale  ( Scale -- )
        CheckAddressingMemory
        Operand^@ .Register1Pattern C@ 0= IF  IndexNotDefined Error  THEN
        Operand^@ .Register2Pattern C@ IF
           0x80 OR       \ .Register2Pattern is the INDEX register
        THEN
        Operand^@ .Scale   C!   ;
: *1    0 *Scale ; \ default value
: *2    1 *Scale ;
: *4    2 *Scale ;
: *8    3 *Scale ;

: RESET-ASSEMBLER
        PreProcessing   OFF     \ 10/04/'95
        SHORT   \ Select shortest format
        AssemblingPhase   Assembler-Phase           !
        FALSE             DefiningMemoryLocation    !
        ClearInstructionBuffers  ResetOperandDescriptors  ;

VARIABLE   TRACER_STAT
FORTH DEFINITIONS

: .USE  UseXX @ 16Bits = IF ."  USE16" ELSE ."  USE32" THEN ."  now. " ;

\ For convenience's sake, it is in interpreting mode between CODE: and ;CODE.

: CODE: ( -- )
        HEADER    TRUE DefiningCode !
        ALSO ASSEMBLER RESET-ASSEMBLER ;

ASSEMBLER DEFINITIONS

: ;CODE ( -- )
        PreProcessing @ IF  \ 10/22/'95
           PreProcessing OFF PrefixSyntaxMultiInstr Error  
        THEN
        PREVIOUS
        ;

\ CR .( 9. Creating Instruction Tables and Linking Disassembling Tables ...)

\ Other Registers :

16Bits SegmentRegisterType    6  Registers:    ES  CS  SS  DS  FS  GS

80Bits FloatingRegisterType   0  Register:     ST
80Bits FloatingRegisterType
        8  Registers:   ST(0)  ST(1)  ST(2)  ST(3)  ST(4)  ST(5)  ST(6)  ST(7)

32Bits ControlRegisterType    0  Register:   CR0
32Bits ControlRegisterType    2  Register:   CR2
32Bits ControlRegisterType    3  Register:   CR3

32Bits TestRegisterType       6  Register:   TR6
32Bits TestRegisterType       7  Register:   TR7

32Bits DebugRegisterType      4  Registers:  DR0 DR1 DR2 DR3
32Bits DebugRegisterType      6  Register:   DR6
32Bits DebugRegisterType      7  Register:   DR7

\ Other Prefixes :

0x2E Prefix:     CS:             0x3E Prefix:     DS:
0x26 Prefix:     ES:             0x36 Prefix:     SS:
0x64 Prefix:     FS:             0x65 Prefix:     GS:

0xF2 Prefix: REPNZ       : REPNE REPNZ ;
0xF3 Prefix: REPZ        : REPE  REPZ ;          : REP   REPZ ;

0xF0 Prefix: LOCK:

\ Instructions : -------------------------------------------------------------

\ CR .( ...A)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  AAA
      1   0x37     0    AAA
Instruction:  AAD
      2   0x0AD5   0    AAD
Instruction:  AAM
      2   0x0AD4   0    AAM
Instruction:  AAS
      1   0x3F     0    AAS
Instruction:  ADC
      1   0x10     2    ADC     r/m8    reg8
      1   0x11     2    ADC     r/m16   reg16
      1   0x11     2    ADC     r/m32   reg32
      1   0x12     2    ADC     reg8    r/m8
      1   0x13     2    ADC     reg16   r/m16
      1   0x13     2    ADC     reg32   r/m32
      1   0x14     2    ADC     AL      imm8
      1   0x15     2    ADC     AX      imm16
      1   0x15     2    ADC     EAX     imm32
      1   0x80     2    ADC     r/m8    imm8            rrr=2
      1   0x81     2    ADC     r/m16   imm16           rrr=2
      1   0x81     2    ADC     r/m32   imm32           rrr=2
      1   0x83     2    ADC     r/m16   sgnimm8         rrr=2
      1   0x83     2    ADC     r/m32   sgnimm8         rrr=2
Instruction:  ADD
      1   0x00     2    ADD     r/m8    reg8
      1   0x01     2    ADD     r/m16   reg16
      1   0x01     2    ADD     r/m32   reg32
      1   0x02     2    ADD     reg8    r/m8
      1   0x03     2    ADD     reg16   r/m16
      1   0x03     2    ADD     reg32   r/m32
      1   0x04     2    ADD     AL      imm8
      1   0x05     2    ADD     AX      imm16
      1   0x05     2    ADD     EAX     imm32
      1   0x80     2    ADD     r/m8    imm8            rrr=0
      1   0x81     2    ADD     r/m16   imm16           rrr=0
      1   0x81     2    ADD     r/m32   imm32           rrr=0
      1   0x83     2    ADD     r/m16   sgnimm8         rrr=0
      1   0x83     2    ADD     r/m32   sgnimm8         rrr=0
Instruction:  AND
      1   0x20     2    AND     r/m8    reg8
      1   0x21     2    AND     r/m16   reg16
      1   0x21     2    AND     r/m32   reg32
      1   0x22     2    AND     reg8    r/m8
      1   0x23     2    AND     reg16   r/m16
      1   0x23     2    AND     reg32   r/m32
      1   0x24     2    AND     AL      imm8
      1   0x25     2    AND     AX      imm16
      1   0x25     2    AND     EAX     imm32
      1   0x80     2    AND     r/m8    imm8            rrr=4
      1   0x81     2    AND     r/m16   imm16           rrr=4
      1   0x81     2    AND     r/m32   imm32           rrr=4
      1   0x83     2    AND     r/m16   sgnimm8         rrr=4
      1   0x83     2    AND     r/m32   sgnimm8         rrr=4
Instruction:  ARPL
      1   0x63     2    ARPL    r/m16   reg16

\ .( .B)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  BOUND
      1   0x62     2    BOUND   reg16   r/m16
      1   0x62     2    BOUND   reg32   r/m32
Instruction:  BSF
      2   0xBC0F   2    BSF     reg16   r/m16
      2   0xBC0F   2    BSF     reg32   r/m32
Instruction:  BSR
      2   0xBD0F   2    BSR     reg16   r/m16
      2   0xBD0F   2    BSR     reg32   r/m32

Instruction:  BSWAP
      2   0xC80F   1    BSWAP   reg16                   +reg
      2   0xC80F   1    BSWAP   reg32                   +reg
Instruction:  BT
      2   0xA30F   2    BT      r/m16   reg16
      2   0xA30F   2    BT      r/m32   reg32
      2   0xBA0F   2    BT      r/m16   imm8            rrr=4
      2   0xBA0F   2    BT      r/m32   imm8            rrr=4
Instruction:  BTC
      2   0xBB0F   2    BTC     r/m16   reg16
      2   0xBB0F   2    BTC     r/m32   reg32
      2   0xBA0F   2    BTC     r/m16   imm8            rrr=7
      2   0xBA0F   2    BTC     r/m32   imm8            rrr=7
Instruction:  BTR
      2   0xB30F   2    BTR     r/m16   reg16
      2   0xB30F   2    BTR     r/m32   reg32
      2   0xBA0F   2    BTR     r/m16   imm8            rrr=6
      2   0xBA0F   2    BTR     r/m32   imm8            rrr=6
Instruction:  BTS
      2   0xAB0F   2    BTS     r/m16   reg16
      2   0xAB0F   2    BTS     r/m32   reg32
      2   0xBA0F   2    BTS     r/m16   imm8            rrr=5
      2   0xBA0F   2    BTS     r/m32   imm8            rrr=5

\ .( .C)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  CALL  \ near call
      1   0xE8     1    CALL    rel16
      1   0xE8     1    CALL    rel32
      1   0xFF     1    CALL    r/m16                   rrr=2
      1   0xFF     1    CALL    r/m32                   rrr=2
Instruction:  CALLF  \ far call
      1   0x9A     2    CALLF   imm16   disp16
      1   0x9A     2    CALLF   imm16   disp32
      1   0xFF     1    CALLF   mem16                   rrr=3
      1   0xFF     1    CALLF   mem32                   rrr=3
Instruction:  CBW
      1   0x98     0    CBW     AX  \ force prefix check
Instruction:  CWDE
      1   0x98     0    CWDE    EAX \ force prefix check
Instruction:  CLC
      1   0xF8     0    CLC
Instruction:  CLD
      1   0xFC     0    CLD
Instruction:  CLI
      1   0xFA     0    CLI
Instruction:  CLTS
      2   0x060F   0    CLTS
Instruction:  CMC
      1   0xF5     0    CMC
Instruction:  CMP
      1   0x38     2    CMP     r/m8    reg8
      1   0x39     2    CMP     r/m16   reg16
      1   0x39     2    CMP     r/m32   reg32
      1   0x3A     2    CMP     reg8    r/m8
      1   0x3B     2    CMP     reg16   r/m16
      1   0x3B     2    CMP     reg32   r/m32
      1   0x3C     2    CMP     AL      imm8
      1   0x3D     2    CMP     AX      imm16
      1   0x3D     2    CMP     EAX     imm32
      1   0x80     2    CMP     r/m8    imm8            rrr=7
      1   0x81     2    CMP     r/m16   imm16           rrr=7
      1   0x81     2    CMP     r/m32   imm32           rrr=7
      1   0x83     2    CMP     r/m16   sgnimm8         rrr=7
      1   0x83     2    CMP     r/m32   sgnimm8         rrr=7
Instruction:  CMPSB
      1   0xA6     0    CMPSB
Instruction:  CMPSW
      1   0xA7     0    CMPSW   DI  \ force prefix check
Instruction:  CMPSD
      1   0xA7     0    CMPSD   EDI \ force prefix check
Instruction:  CMPXCHG
      2   0xA60F   2    CMPXCHG r/m8    reg8
      2   0xA70F   2    CMPXCHG r/m16   reg16
      2   0xA70F   2    CMPXCHG r/m32   reg32
Instruction:  CWD
      1   0x99     0    CWD     DX  \ force prefix check
Instruction:  CDQ
      1   0x99     0    CDQ     EDX \ force prefix check

\ .( .D)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  DAA
      1   0x27     0    DAA
Instruction:  DAS
      1   0x2F     0    DAS
Instruction:  DEC
      1   0x48     1    DEC     reg16                   +reg
      1   0x48     1    DEC     reg32                   +reg
      1   0xFE     1    DEC     r/m8                    rrr=1
      1   0xFF     1    DEC     r/m16                   rrr=1
      1   0xFF     1    DEC     r/m32                   rrr=1
Instruction:  DIV
      1   0xF6     1    DIV     r/m8                    rrr=6
      1   0xF7     1    DIV     r/m16                   rrr=6
      1   0xF7     1    DIV     r/m32                   rrr=6

\ .( .E)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  ENTER
      1   0xC8     2    ENTER   imm16   imm8

\ .( .F)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  FWAIT
      1   0x9B     0    FWAIT
Instruction:  F2XM1
      2   0xF0D9   0    F2XM1
Instruction:  FABS
      2   0xE1D9   0    FABS
Instruction:  FADD
      2   0xC1DE   0    FADD
      1   0xD8     1    FADD    mem32                   rrr=0 ~prechk1
      1   0xDC     1    FADD    mem64                   rrr=0
      2   0xC0D8   2    FADD    ST      freg            +reg
      2   0xC0DC   2    FADD    freg    ST              +reg
Instruction:  FADDP
      2   0xC0DE   2    FADDP   freg    ST              +reg
Instruction:  FIADD
      1   0xDA     1    FIADD   mem32                   rrr=0 ~prechk1
      1   0xDE     1    FIADD   mem16                   rrr=0 ~prechk1
Instruction:  FBLD
      1   0xDF     1    FBLD    mem>=80                 rrr=4
Instruction:  FBSTP
      1   0xDF     1    FBSTP   mem>=80                 rrr=6
Instruction:  FCHS
      2   0xE0D9   0    FCHS
Instruction:  FNCLEX
      2   0xE2DB   0    FNCLEX
Instruction:  FCOM
      2   0xD1D8   0    FCOM
      2   0xD0D8   1    FCOM    freg                    +reg
      1   0xD8     1    FCOM    mem32                   rrr=2 ~prechk1
      1   0xDC     1    FCOM    mem64                   rrr=2
Instruction:  FCOMP
      2   0xD9D8   0    FCOMP
      2   0xD8D8   1    FCOMP   freg                    +reg
      1   0xD8     1    FCOMP   mem32                   rrr=3 ~prechk1
      1   0xDC     1    FCOMP   mem64                   rrr=3
Instruction:  FCOMPP
      2   0xD9DE   0    FCOMPP
Instruction:  FCOS
      2   0xFFD9   0    FCOS
Instruction:  FDECSTP
      2   0xF6D9   0    FDECSTP
Instruction:  FDIV
      2   0xF9DE   0    FDIV
      1   0xD8     1    FDIV    mem32                   rrr=6 ~prechk1
      1   0xDC     1    FDIV    mem64                   rrr=6
      2   0xF0D8   2    FDIV    ST      freg            +reg
      2   0xF8DC   2    FDIV    freg    ST              +reg
Instruction:  FDIVP
      2   0xF8DE   2    FDIVP   freg    ST              +reg
Instruction:  FIDIV
      1   0xDA     1    FIDIV   mem32                   rrr=6 ~prechk1
      1   0xDE     1    FIDIV   mem16                   rrr=6 ~prechk1
Instruction:  FDIVR
      2   0xF1DE   0    FDIVR
      1   0xD8     1    FDIVR   mem32                   rrr=7 ~prechk1
      1   0xDC     1    FDIVR   mem64                   rrr=7
      2   0xF8D8   2    FDIVR   ST      freg            +reg
      2   0xF0DC   2    FDIVR   freg    ST              +reg
Instruction:  FDIVRP
      2   0xF0DE   2    FDIVRP  freg    ST              +reg
Instruction:  FIDIVR
      1   0xDA     1    FIDIVR  mem32                   rrr=7 ~prechk1
      1   0xDE     1    FIDIVR  mem16                   rrr=7 ~prechk1
Instruction:  FFREE
      2   0xC0DD   1    FFREE   freg                    +reg
Instruction:  FICOM
      1   0xDE     1    FICOM   mem16                   rrr=2 ~prechk1
      1   0xDA     1    FICOM   mem32                   rrr=2 ~prechk1
Instruction:  FICOMP
      1   0xDE     1    FICOMP  mem16                   rrr=3 ~prechk1
      1   0xDA     1    FICOMP  mem32                   rrr=3 ~prechk1
Instruction:  FILD
      1   0xDF     1    FILD    mem16                   rrr=0 ~prechk1
      1   0xDB     1    FILD    mem32                   rrr=0 ~prechk1
      1   0xDF     1    FILD    mem64                   rrr=5
Instruction:  FINCSTP
      2   0xF7D9   0    FINCSTP
Instruction:  FNINIT
      2   0xE3DB   0    FNINIT
Instruction:  FIST
      1   0xDF     1    FIST    mem16                   rrr=2 ~prechk1
      1   0xDB     1    FIST    mem32                   rrr=2 ~prechk1
Instruction:  FISTP
      1   0xDF     1    FISTP   mem16                   rrr=3 ~prechk1
      1   0xDB     1    FISTP   mem32                   rrr=3 ~prechk1
      1   0xDF     1    FISTP   mem64                   rrr=7
Instruction:  FLD
      1   0xD9     1    FLD     mem32                   rrr=0 ~prechk1
      1   0xDD     1    FLD     mem64                   rrr=0
      1   0xDB     1    FLD     mem>=80                 rrr=5
      2   0xC0D9   1    FLD     freg                    +reg
Instruction:  FLD1
      2   0xE8D9   0    FLD1
Instruction:  FLDL2T
      2   0xE9D9   0    FLDL2T
Instruction:  FLDL2E
      2   0xEAD9   0    FLDL2E
Instruction:  FLDPI
      2   0xEBD9   0    FLDPI
Instruction:  FLDLG2
      2   0xECD9   0    FLDLG2
Instruction:  FLDLN2
      2   0xEDD9   0    FLDLN2
Instruction:  FLDZ
      2   0xEED9   0    FLDZ
Instruction:  FLDCW
      1   0xD9     1    FLDCW   mem16                   rrr=5 ~prechk1
Instruction:  FLDENV    \ any memory type
      1   0xD9     1    FLDENV  mem8                    rrr=4
      1   0xD9     1    FLDENV  mem16                   rrr=4 ~prechk1
      1   0xD9     1    FLDENV  mem32                   rrr=4 ~prechk1
      1   0xD9     1    FLDENV  mem>=80                 rrr=4
Instruction:  FMUL
      2   0xC9DE   0    FMUL
      1   0xD8     1    FMUL    mem32                   rrr=1 ~prechk1
      1   0xDC     1    FMUL    mem64                   rrr=1
      2   0xC8D8   2    FMUL    ST      freg            +reg
      2   0xC8DC   2    FMUL    freg    ST              +reg
Instruction:  FMULP
      2   0xC8DE   2    FMULP   freg    ST              +reg
Instruction:  FIMUL
      1   0xDA     1    FIMUL   mem32                   rrr=1 ~prechk1
      1   0xDE     1    FIMUL   mem16                   rrr=1 ~prechk1
Instruction:  FNOP
      2   0xD0D9   0    FNOP
Instruction:  FPATAN
      2   0xF3D9   0    FPATAN
Instruction:  FPREM
      2   0xF8D9   0    FPREM
Instruction:  FPREM1
      2   0xF5D9   0    FPREM1
Instruction:  FPTAN
      2   0xF2D9   0    FPTAN
Instruction:  FRNDINT
      2   0xFCD9   0    FRNDINT
Instruction:  FRSTOR
      1   0xDD     1    FRSTOR  mem8                    rrr=4
      1   0xDD     1    FRSTOR  mem16                   rrr=4 ~prechk1
      1   0xDD     1    FRSTOR  mem32                   rrr=4 ~prechk1
      1   0xDD     1    FRSTOR  mem>=80                 rrr=4
Instruction:  FNSAVE
      1   0xDD     1    FNSAVE  mem8                    rrr=6
      1   0xDD     1    FNSAVE  mem16                   rrr=6 ~prechk1
      1   0xDD     1    FNSAVE  mem32                   rrr=6 ~prechk1
      1   0xDD     1    FNSAVE  mem>=80                 rrr=6
Instruction:  FSCALE
      2   0xFDD9   0    FSCALE
Instruction:  FSIN
      2   0xFED9   0    FSIN
Instruction:  FSINCOS
      2   0xFBD9   0    FSINCOS
Instruction:  FSQRT
      2   0xFAD9   0    FSQRT
Instruction:  FST
      1   0xD9     1    FST     mem32                   rrr=2 ~prechk1
      1   0xDD     1    FST     mem64                   rrr=2
      2   0xD0DD   1    FST     freg                    +reg
Instruction:  FSTP
      1   0xD9     1    FSTP    mem32                   rrr=3 ~prechk1
      1   0xDD     1    FSTP    mem64                   rrr=3
      1   0xDB     1    FSTP    mem>=80                 rrr=7
      2   0xD8DD   1    FSTP    freg                    +reg
Instruction:  FNSTCW
      1   0xD9     1    FNSTCW  mem16                   rrr=7 ~prechk1
Instruction:  FNSTENV
      1   0xD9     1    FNSTENV mem8                    rrr=6
      1   0xD9     1    FNSTENV mem16                   rrr=6 ~prechk1
      1   0xD9     1    FNSTENV mem32                   rrr=6 ~prechk1
      1   0xD9     1    FNSTENV mem>=80                 rrr=6
Instruction:  FNSTSW
      1   0xDD     1    FNSTSW  mem16                   rrr=7 ~prechk1
      2   0xE0DF   1    FNSTSW  AX                      ~prechk1
Instruction:  FSUB
      2   0xE9DE   0    FSUB
      1   0xD8     1    FSUB    mem32                   rrr=4 ~prechk1
      1   0xDC     1    FSUB    mem64                   rrr=4
      2   0xE0D8   2    FSUB    ST      freg            +reg
      2   0xE8DC   2    FSUB    freg    ST              +reg
Instruction:  FSUBP
      2   0xE8DE   2    FSUBP   freg    ST              +reg
Instruction:  FISUB
      1   0xDA     1    FISUB   mem32                   rrr=4 ~prechk1
      1   0xDE     1    FISUB   mem16                   rrr=4 ~prechk1
Instruction:  FSUBR
      2   0xE1DE   0    FSUBR
      1   0xD8     1    FSUBR   mem32                   rrr=5 ~prechk1
      1   0xDC     1    FSUBR   mem64                   rrr=5
      2   0xE8D8   2    FSUBR   ST      freg            +reg
      2   0xE0DC   2    FSUBR   freg    ST              +reg
Instruction:  FSUBRP
      2   0xE0DE   2    FSUBRP  freg    ST              +reg
Instruction:  FISUBR
      1   0xDA     1    FISUBR  mem32                   rrr=5 ~prechk1
      1   0xDE     1    FISUBR  mem16                   rrr=5 ~prechk1
Instruction:  FTST
      2   0xE4D9   0    FTST
Instruction:  FUCOM
      2   0xE1DD   0    FUCOM
      2   0xE0DD   1    FUCOM   freg                    +reg
Instruction:  FUCOMP
      2   0xE9DD   0    FUCOMP
      2   0xE8DD   1    FUCOMP  freg                    +reg
Instruction:  FUCOMPP
      2   0xE9DA   0    FUCOMPP
Instruction:  FXAM
      2   0xE5D9   0    FXAM
Instruction:  FXCH
      2   0xC9D9   0    FXCH
      2   0xC8D9   1    FXCH    freg                    +reg
Instruction:  FXTRACT
      2   0xF4D9   0    FXTRACT
Instruction:  FYL2X
      2   0xF1D9   0    FYL2X
Instruction:  FYL2XP1
      2   0xF9D9   0    FYL2XP1

 \ Compound Instructions ( FWAIT + FNXXXX )

Instruction:  FCLEX
      3   0xE2DB9B 0    FCLEX
Instruction:  FINIT
      3   0xE3DB9B 0    FINIT
Instruction:  FSAVE
      2   0xDD9B   1    FSAVE   mem8                    rrr=6
      2   0xDD9B   1    FSAVE   mem16                   rrr=6 ~prechk1
      2   0xDD9B   1    FSAVE   mem32                   rrr=6 ~prechk1
      2   0xDD9B   1    FSAVE   mem>=80                 rrr=6
Instruction:  FSTCW
      2   0xD99B   1    FSTCW   mem16                   rrr=7 ~prechk1
Instruction:  FSTENV
      2   0xD99B   1    FSTENV  mem8                    rrr=6
      2   0xD99B   1    FSTENV  mem16                   rrr=6 ~prechk1
      2   0xD99B   1    FSTENV  mem32                   rrr=6 ~prechk1
      2   0xD99B   1    FSTENV  mem>=80                 rrr=6
Instruction:  FSTSW
      2   0xDD9B   1    FSTSW   mem16                   rrr=7 ~prechk1
      3   0xE0DF9B 1    FSTSW   AX                      ~prechk1

\ .( .H)

 \   #opc opcs   #opr   |     <opr1>  <opr2>  <opr3> | modifiers
Instruction:  HLT
      1   0xF4     0    HLT

\ .( .I)

 \   #opc opcs   #opr   |     <opr1>  <opr2>  <opr3> | modifiers
Instruction:  IDIV
      1   0xF6     1    IDIV    r/m8                    rrr=7
      1   0xF7     1    IDIV    r/m16                   rrr=7
      1   0xF7     1    IDIV    r/m32                   rrr=7
Instruction:  IMUL
      1   0xF6     1    IMUL    r/m8                    rrr=5
      1   0xF7     1    IMUL    r/m16                   rrr=5
      1   0xF7     1    IMUL    r/m32                   rrr=5
      2   0xAF0F   2    IMUL    reg16   r/m16
      2   0xAF0F   2    IMUL    reg32   r/m32
      1   0x6B     3    IMUL    reg16   r/m16   sgnimm8
      1   0x6B     3    IMUL    reg32   r/m32   sgnimm8
      1   0x69     3    IMUL    reg16   r/m16   imm16
      1   0x69     3    IMUL    reg32   r/m32   imm32
\ NOTE:  IMUL EDX EDX immed #    =    IMUL EDX,immed (MASM)
Instruction:  IN
      1   0xE4     2    IN      AL      imm8
      1   0xE5     2    IN      AX      imm8
      1   0xE5     2    IN      EAX     imm8
      1   0xEC     2    IN      AL      DX              ~prechk2
      1   0xED     2    IN      AX      DX              ~prechk2
      1   0xED     2    IN      EAX     DX              ~prechk2
Instruction:  INC
      1   0x40     1    INC     reg16                   +reg
      1   0x40     1    INC     reg32                   +reg
      1   0xFE     1    INC     r/m8                    rrr=0
      1   0xFF     1    INC     r/m16                   rrr=0
      1   0xFF     1    INC     r/m32                   rrr=0
Instruction:  INSB
      1   0x6C     0    INSB
Instruction:  INSW
      1   0x6D     0    INSW    DI  \ force prefix check
Instruction:  INSD
      1   0x6D     0    INSD    EDI \ force prefix check
Instruction:  INT3
      1   0xCC     0    INT3
Instruction:  INT
      1   0xCD     1    INT     imm8
Instruction:  INTO
      1   0xCE     0    INTO
Instruction:  INVD
      2   0x080F   0    INVD
Instruction:  INVLPG
      2   0x010F   1    INVLPG  mem8                    rrr=7
      2   0x010F   1    INVLPG  mem16                   rrr=7 ~prechk1
      2   0x010F   1    INVLPG  mem32                   rrr=7 ~prechk1
      2   0x010F   1    INVLPG  mem>=80                 rrr=7
Instruction:  IRET
      1   0xCF     0    IRET    SP  \ force prefix check
Instruction:  IRETD
      1   0xCF     0    IRETD   ESP \ force prefix check

\ .( .J)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  JMP  \ near jump
      1   0xEB     1    JMP     rel8
      1   0xE9     1    JMP     rel16
      1   0xE9     1    JMP     rel32
      1   0xFF     1    JMP     r/m16                   rrr=4
      1   0xFF     1    JMP     r/m32                   rrr=4
Instruction:  JMPF  \ far jump
      1   0xEA     2    JMPF    imm16   disp16
      1   0xEA     2    JMPF    imm16   disp32
      1   0xFF     1    JMPF    mem16                   rrr=5
      1   0xFF     1    JMPF    mem32                   rrr=5
Instruction:  JA
      1   0x77     1    JA      rel8
      2   0x870F   1    JA      rel16
      2   0x870F   1    JA      rel32
Instruction:  JAE
      1   0x73     1    JAE     rel8
      2   0x830F   1    JAE     rel16
      2   0x830F   1    JAE     rel32
Instruction:  JB
      1   0x72     1    JB      rel8
      2   0x820F   1    JB      rel16
      2   0x820F   1    JB      rel32
Instruction:  JBE
      1   0x76     1    JBE     rel8
      2   0x860F   1    JBE     rel16
      2   0x860F   1    JBE     rel32
Instruction:  JZ
      1   0x74     1    JZ      rel8
      2   0x840F   1    JZ      rel16
      2   0x840F   1    JZ      rel32
Instruction:  JG
      1   0x7F     1    JG      rel8
      2   0x8F0F   1    JG      rel16
      2   0x8F0F   1    JG      rel32
Instruction:  JGE
      1   0x7D     1    JGE     rel8
      2   0x8D0F   1    JGE     rel16
      2   0x8D0F   1    JGE     rel32
Instruction:  JL
      1   0x7C     1    JL      rel8
      2   0x8C0F   1    JL      rel16
      2   0x8C0F   1    JL      rel32
Instruction:  JLE
      1   0x7E     1    JLE     rel8
      2   0x8E0F   1    JLE     rel16
      2   0x8E0F   1    JLE     rel32
Instruction:  JNE
      1   0x75     1    JNE     rel8
      2   0x850F   1    JNE     rel16
      2   0x850F   1    JNE     rel32
Instruction:  JNO
      1   0x71     1    JNO     rel8
      2   0x810F   1    JNO     rel16
      2   0x810F   1    JNO     rel32
Instruction:  JNP
      1   0x7B     1    JNP     rel8
      2   0x8B0F   1    JNP     rel16
      2   0x8B0F   1    JNP     rel32
Instruction:  JNS
      1   0x79     1    JNS     rel8
      2   0x890F   1    JNS     rel16
      2   0x890F   1    JNS     rel32
Instruction:  JO
      1   0x70     1    JO      rel8
      2   0x800F   1    JO      rel16
      2   0x800F   1    JO      rel32
Instruction:  JP
      1   0x7A     1    JP      rel8
      2   0x8A0F   1    JP      rel16
      2   0x8A0F   1    JP      rel32
Instruction:  JS
      1   0x78     1    JS      rel8
      2   0x880F   1    JS      rel16
      2   0x880F   1    JS      rel32
Instruction:  J(E)CXZ  \ very special instruction
      1   0xE3     1    J(E)CXZ rel8
: JCXZ  ( -- )  UseXX @ 32Bits = IF AS: THEN J(E)CXZ ;
: JECXZ ( -- )  UseXX @ 16Bits = IF AS: THEN J(E)CXZ ;

: JNBE  JA  ;
: JNB   JAE ;   : JNC   JAE ;
: JC    JB  ;   : JNAE  JB ;
: JE    JZ  ;
: JNA   JBE ;
: JNLE  JG  ;
: JNL   JGE ;
: JNGE  JL  ;
: JNG   JLE ;
: JNZ   JNE ;
: JPO   JNP ;
: JPE   JP  ;

\ .( .L)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  LAHF
      1   0x9F     0    LAHF
Instruction:  LAR
      2   0x020F   2    LAR     reg16   r/m16
      2   0x020F   2    LAR     reg32   r/m32
Instruction:  LEA
      1   0x8D     2    LEA     reg16   mem8
      1   0x8D     2    LEA     reg16   mem16           ~prechk2
      1   0x8D     2    LEA     reg16   mem32           ~prechk2
      1   0x8D     2    LEA     reg16   mem>=80
      1   0x8D     2    LEA     reg32   mem8
      1   0x8D     2    LEA     reg32   mem16           ~prechk2
      1   0x8D     2    LEA     reg32   mem32           ~prechk2
      1   0x8D     2    LEA     reg32   mem>=80
Instruction:  LEAVE
      1   0xC9     0    LEAVE
Instruction:  LGDT
      2   0x010F   1    LGDT    mem64                   rrr=2
Instruction:  LIDT
      2   0x010F   1    LIDT    mem64                   rrr=3
Instruction:  LDS
      1   0xC5     2    LDS     reg16   mem8
      1   0xC5     2    LDS     reg16   mem16           ~prechk2
      1   0xC5     2    LDS     reg16   mem32           ~prechk2
      1   0xC5     2    LDS     reg16   mem>=80
      1   0xC5     2    LDS     reg32   mem8
      1   0xC5     2    LDS     reg32   mem16           ~prechk2
      1   0xC5     2    LDS     reg32   mem32           ~prechk2
      1   0xC5     2    LDS     reg32   mem>=80
Instruction:  LES
      1   0xC4     2    LES     reg16   mem8
      1   0xC4     2    LES     reg16   mem16           ~prechk2
      1   0xC4     2    LES     reg16   mem32           ~prechk2
      1   0xC4     2    LES     reg16   mem>=80
      1   0xC4     2    LES     reg32   mem8
      1   0xC4     2    LES     reg32   mem16           ~prechk2
      1   0xC4     2    LES     reg32   mem32           ~prechk2
      1   0xC4     2    LES     reg32   mem>=80
Instruction:  LSS
      2   0xB20F   2    LSS     reg16   mem8
      2   0xB20F   2    LSS     reg16   mem16           ~prechk2
      2   0xB20F   2    LSS     reg16   mem32           ~prechk2
      2   0xB20F   2    LSS     reg16   mem>=80
      2   0xB20F   2    LSS     reg32   mem8
      2   0xB20F   2    LSS     reg32   mem16           ~prechk2
      2   0xB20F   2    LSS     reg32   mem32           ~prechk2
      2   0xB20F   2    LSS     reg32   mem>=80
Instruction:  LFS
      2   0xB40F   2    LFS     reg16   mem8
      2   0xB40F   2    LFS     reg16   mem16           ~prechk2
      2   0xB40F   2    LFS     reg16   mem32           ~prechk2
      2   0xB40F   2    LFS     reg16   mem>=80
      2   0xB40F   2    LFS     reg32   mem8
      2   0xB40F   2    LFS     reg32   mem16           ~prechk2
      2   0xB40F   2    LFS     reg32   mem32           ~prechk2
      2   0xB40F   2    LFS     reg32   mem>=80
Instruction:  LGS
      2   0xB50F   2    LGS     reg16   mem8
      2   0xB50F   2    LGS     reg16   mem16           ~prechk2
      2   0xB50F   2    LGS     reg16   mem32           ~prechk2
      2   0xB50F   2    LGS     reg16   mem>=80
      2   0xB50F   2    LGS     reg32   mem8
      2   0xB50F   2    LGS     reg32   mem16           ~prechk2
      2   0xB50F   2    LGS     reg32   mem32           ~prechk2
      2   0xB50F   2    LGS     reg32   mem>=80
Instruction:  LLDT
      2   0x000F   1    LLDT    r/m16                   rrr=2 ~prechk1
Instruction:  LMSW
      2   0x010F   1    LMSW    r/m16                   rrr=6 ~prechk1
Instruction:  LODSB
      1   0xAC     0    LODSB
Instruction:  LODSW
      1   0xAD     0    LODSW    AX \ force prefix check
Instruction:  LODSD
      1   0xAD     0    LODSD   EAX \ force prefix check
Instruction:  LOOP
      1   0xE2     1    LOOP    rel8
Instruction:  LOOPZ
      1   0xE1     1    LOOPZ   rel8
Instruction:  LOOPNZ
      1   0xE0     1    LOOPNZ  rel8
: LOOPE  LOOPZ ;
: LOOPNE LOOPNZ ;
Instruction:  LSL
      2   0x030F   2    LSL     reg16   r/m16
      2   0x030F   2    LSL     reg32   r/m32
Instruction:  LTR
      2   0x000F   1    LTR     r/m16                   rrr=3 ~prechk1

\ .( .M)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  MOV
.( MOV) HERE H. CR
      1   0x88     2    MOV     r/m8    reg8
      1   0x89     2    MOV     r/m16   reg16
      1   0x89     2    MOV     r/m32   reg32
      1   0x8A     2    MOV     reg8    r/m8
      1   0x8B     2    MOV     reg16   r/m16
      1   0x8B     2    MOV     reg32   r/m32
HERE
      1   0xA0     2    MOV     AL      off8
      1   0xA1     2    MOV     AX      off16
      1   0xA1     2    MOV     EAX     off32
      1   0xA2     2    MOV     off8    AL
      1   0xA3     2    MOV     off16   AX
      1   0xA3     2    MOV     off32   EAX
100 DUMP KEY DROP
      1   0xB0     2    MOV     reg8    imm8            +reg
      1   0xB8     2    MOV     reg16   imm16           +reg
      1   0xB8     2    MOV     reg32   imm32           +reg
      1   0xC6     2    MOV     r/m8    imm8            rrr=0
      1   0xC7     2    MOV     r/m16   imm16           rrr=0
      1   0xC7     2    MOV     r/m32   imm32           rrr=0
      1   0x8C     2    MOV     r/m16   segreg
      1   0x8E     2    MOV     segreg  r/m16           ~prechk2
      2   0x200F   2    MOV     reg32   ctrlreg         2regpat
      2   0x220F   2    MOV     ctrlreg reg32           2regpat
      2   0x210F   2    MOV     reg32   dbgreg          2regpat
      2   0x230F   2    MOV     dbgreg  reg32           2regpat
      2   0x240F   2    MOV     reg32   testreg         2regpat
      2   0x260F   2    MOV     testreg reg32           2regpat
Instruction:  MOVSB
      1   0xA4     0    MOVSB
Instruction:  MOVSW
      1   0xA5     0    MOVSW   DI  \ force prefix check
Instruction:  MOVSD
      1   0xA5     0    MOVSD   EDI \ force prefix check
Instruction:  MOVSX
      2   0xBE0F   2    MOVSX   reg16   r/m8
      2   0xBE0F   2    MOVSX   reg32   r/m8
      2   0xBF0F   2    MOVSX   reg32   r/m16           ~prechk2
Instruction:  MOVZX
      2   0xB60F   2    MOVZX   reg16   r/m8
      2   0xB60F   2    MOVZX   reg32   r/m8
      2   0xB70F   2    MOVZX   reg32   r/m16           ~prechk2
Instruction:  MUL
      1   0xF6     1    MUL     r/m8                    rrr=4
      1   0xF7     1    MUL     r/m16                   rrr=4
      1   0xF7     1    MUL     r/m32                   rrr=4

\ .( .N)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  NEG
      1   0xF6     1    NEG     r/m8                    rrr=3
      1   0xF7     1    NEG     r/m16                   rrr=3
      1   0xF7     1    NEG     r/m32                   rrr=3
\ Move "NOP" instruction after "XCHG" for disassembling ( NOP = XCHG AX,AX )
Instruction:  NOT
      1   0xF6     1    NOT     r/m8                    rrr=2
      1   0xF7     1    NOT     r/m16                   rrr=2
      1   0xF7     1    NOT     r/m32                   rrr=2

\ .( .O)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  OR
      1   0x08     2    OR      r/m8    reg8
      1   0x09     2    OR      r/m16   reg16
      1   0x09     2    OR      r/m32   reg32
      1   0x0A     2    OR      reg8    r/m8
      1   0x0B     2    OR      reg16   r/m16
      1   0x0B     2    OR      reg32   r/m32
      1   0x0C     2    OR      AL      imm8
      1   0x0D     2    OR      AX      imm16
      1   0x0D     2    OR      EAX     imm32
      1   0x80     2    OR      r/m8    imm8            rrr=1
      1   0x81     2    OR      r/m16   imm16           rrr=1
      1   0x81     2    OR      r/m32   imm32           rrr=1
      1   0x83     2    OR      r/m16   sgnimm8         rrr=1
      1   0x83     2    OR      r/m32   sgnimm8         rrr=1
Instruction:  OUT
      1   0xE6     2    OUT     imm8    AL
      1   0xE7     2    OUT     imm8    AX
      1   0xE7     2    OUT     imm8    EAX
      1   0xEE     2    OUT     DX      AL              ~prechk1
      1   0xEF     2    OUT     DX      AX              ~prechk1
      1   0xEF     2    OUT     DX      EAX             ~prechk1
Instruction:  OUTSB
      1   0x6E     0    OUTSB
Instruction:  OUTSW
      1   0x6F     0    OUTSW   DX  \ force prefix check
Instruction:  OUTSD
      1   0x6F     0    OUTSD   EDX \ force prefix check

\ .( .P)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  POP
      1   0x8F     1    POP     mem16                   rrr=0
      1   0x8F     1    POP     mem32                   rrr=0
      1   0x58     1    POP     reg16                   +reg
      1   0x58     1    POP     reg32                   +reg
      1   0x1F     1    POP     DS
      1   0x07     1    POP     ES
      1   0x17     1    POP     SS
      2   0xA10F   1    POP     FS
      2   0xA90F   1    POP     GS
Instruction:  POPA
      1   0x61     0    POPA    SP  \ force prefix check
Instruction:  POPAD
      1   0x61     0    POPAD   ESP \ force prefix check
Instruction:  POPF
      1   0x9D     0    POPF    SP  \ force prefix check
Instruction:  POPFD
      1   0x9D     0    POPFD   ESP \ force prefix check
Instruction:  PUSH
      1   0xFF     1    PUSH    mem16                   rrr=6
      1   0xFF     1    PUSH    mem32                   rrr=6
      1   0x50     1    PUSH    reg16                   +reg
      1   0x50     1    PUSH    reg32                   +reg
      1   0x6A     1    PUSH    imm8
      1   0x68     1    PUSH    imm16                   immprechk
      1   0x68     1    PUSH    imm32                   immprechk
      1   0x0E     1    PUSH    CS
      1   0x16     1    PUSH    SS
      1   0x1E     1    PUSH    DS
      1   0x06     1    PUSH    ES
      2   0xA00F   1    PUSH    FS
      2   0xA80F   1    PUSH    GS
Instruction:  PUSHA
      1   0x60     0    PUSHA   SP  \ force prefix check
Instruction:  PUSHAD
      1   0x60     0    PUSHAD  ESP \ force prefix check
Instruction:  PUSHF
      1   0x9C     0    PUSHF   SP  \ force prefix check
Instruction:  PUSHFD
      1   0x9C     0    PUSHFD  ESP \ force prefix check

\ .( .R)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  RCL
      1   0xD0     1    RCL     r/m8                    rrr=2
      1   0xD2     2    RCL     r/m8    CL              rrr=2
      1   0xC0     2    RCL     r/m8    imm8            rrr=2
      1   0xD1     1    RCL     r/m16                   rrr=2
      1   0xD3     2    RCL     r/m16   CL              rrr=2
      1   0xC1     2    RCL     r/m16   imm8            rrr=2
      1   0xD1     1    RCL     r/m32                   rrr=2
      1   0xD3     2    RCL     r/m32   CL              rrr=2
      1   0xC1     2    RCL     r/m32   imm8            rrr=2
Instruction:  RCR
      1   0xD0     1    RCR     r/m8                    rrr=3
      1   0xD2     2    RCR     r/m8    CL              rrr=3
      1   0xC0     2    RCR     r/m8    imm8            rrr=3
      1   0xD1     1    RCR     r/m16                   rrr=3
      1   0xD3     2    RCR     r/m16   CL              rrr=3
      1   0xC1     2    RCR     r/m16   imm8            rrr=3
      1   0xD1     1    RCR     r/m32                   rrr=3
      1   0xD3     2    RCR     r/m32   CL              rrr=3
      1   0xC1     2    RCR     r/m32   imm8            rrr=3
Instruction:  ROL
      1   0xD0     1    ROL     r/m8                    rrr=0
      1   0xD2     2    ROL     r/m8    CL              rrr=0
      1   0xC0     2    ROL     r/m8    imm8            rrr=0
      1   0xD1     1    ROL     r/m16                   rrr=0
      1   0xD3     2    ROL     r/m16   CL              rrr=0
      1   0xC1     2    ROL     r/m16   imm8            rrr=0
      1   0xD1     1    ROL     r/m32                   rrr=0
      1   0xD3     2    ROL     r/m32   CL              rrr=0
      1   0xC1     2    ROL     r/m32   imm8            rrr=0
Instruction:  ROR
      1   0xD0     1    ROR     r/m8                    rrr=1
      1   0xD2     2    ROR     r/m8    CL              rrr=1
      1   0xC0     2    ROR     r/m8    imm8            rrr=1
      1   0xD1     1    ROR     r/m16                   rrr=1
      1   0xD3     2    ROR     r/m16   CL              rrr=1
      1   0xC1     2    ROR     r/m16   imm8            rrr=1
      1   0xD1     1    ROR     r/m32                   rrr=1
      1   0xD3     2    ROR     r/m32   CL              rrr=1
      1   0xC1     2    ROR     r/m32   imm8            rrr=1
Instruction:  RET
      1   0xC2     1    RET     imm16
      1   0xC3     0    RET
Instruction:  RETF
      1   0xCA     1    RETF    imm16
      1   0xCB     0    RETF

\ .( .S)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  SAHF
      1   0x9E     0    SAHF
Instruction:  SAL
      1   0xD0     1    SAL     r/m8                    rrr=4
      1   0xD2     2    SAL     r/m8    CL              rrr=4
      1   0xC0     2    SAL     r/m8    imm8            rrr=4
      1   0xD1     1    SAL     r/m16                   rrr=4
      1   0xD3     2    SAL     r/m16   CL              rrr=4
      1   0xC1     2    SAL     r/m16   imm8            rrr=4
      1   0xD1     1    SAL     r/m32                   rrr=4
      1   0xD3     2    SAL     r/m32   CL              rrr=4
      1   0xC1     2    SAL     r/m32   imm8            rrr=4
: SHL   SAL ;
Instruction:  SAR
      1   0xD0     1    SAR     r/m8                    rrr=7
      1   0xD2     2    SAR     r/m8    CL              rrr=7
      1   0xC0     2    SAR     r/m8    imm8            rrr=7
      1   0xD1     1    SAR     r/m16                   rrr=7
      1   0xD3     2    SAR     r/m16   CL              rrr=7
      1   0xC1     2    SAR     r/m16   imm8            rrr=7
      1   0xD1     1    SAR     r/m32                   rrr=7
      1   0xD3     2    SAR     r/m32   CL              rrr=7
      1   0xC1     2    SAR     r/m32   imm8            rrr=7
Instruction:  SHR
      1   0xD0     1    SHR     r/m8                    rrr=5
      1   0xD2     2    SHR     r/m8    CL              rrr=5
      1   0xC0     2    SHR     r/m8    imm8            rrr=5
      1   0xD1     1    SHR     r/m16                   rrr=5
      1   0xD3     2    SHR     r/m16   CL              rrr=5
      1   0xC1     2    SHR     r/m16   imm8            rrr=5
      1   0xD1     1    SHR     r/m32                   rrr=5
      1   0xD3     2    SHR     r/m32   CL              rrr=5
      1   0xC1     2    SHR     r/m32   imm8            rrr=5
Instruction:  SBB
      1   0x18     2    SBB     r/m8    reg8
      1   0x19     2    SBB     r/m16   reg16
      1   0x19     2    SBB     r/m32   reg32
      1   0x1A     2    SBB     reg8    r/m8
      1   0x1B     2    SBB     reg16   r/m16
      1   0x1B     2    SBB     reg32   r/m32
      1   0x1C     2    SBB     AL      imm8
      1   0x1D     2    SBB     AX      imm16
      1   0x1D     2    SBB     EAX     imm32
      1   0x80     2    SBB     r/m8    imm8            rrr=3
      1   0x81     2    SBB     r/m16   imm16           rrr=3
      1   0x81     2    SBB     r/m32   imm32           rrr=3
      1   0x83     2    SBB     r/m16   sgnimm8         rrr=3
      1   0x83     2    SBB     r/m32   sgnimm8         rrr=3
Instruction:  SCASB
      1   0xAE     0    SCASB
Instruction:  SCASW
      1   0xAF     0    SCASW   DI  \ force prefix check
Instruction:  SCASD
      1   0xAF     0    SCASD   EDI \ force prefix check
Instruction:  SETA
      2   0x970F   1    SETA    r/m8
Instruction:  SETAE
      2   0x930F   1    SETAE   r/m8
Instruction:  SETB
      2   0x920F   1    SETB    r/m8
Instruction:  SETBE
      2   0x960F   1    SETBE   r/m8
Instruction:  SETZ
      2   0x940F   1    SETZ    r/m8
Instruction:  SETG
      2   0x9F0F   1    SETG    r/m8
Instruction:  SETGE
      2   0x9D0F   1    SETGE   r/m8
Instruction:  SETL
      2   0x9C0F   1    SETL    r/m8
Instruction:  SETLE
      2   0x9E0F   1    SETLE   r/m8
Instruction:  SETNZ
      2   0x950F   1    SETNZ   r/m8
Instruction:  SETNO
      2   0x910F   1    SETNO   r/m8
Instruction:  SETPO
      2   0x9B0F   1    SETPO   r/m8
Instruction:  SETNS
      2   0x990F   1    SETNS   r/m8
Instruction:  SETO
      2   0x900F   1    SETO    r/m8
Instruction:  SETP
      2   0x9A0F   1    SETP    r/m8
Instruction:  SETS
      2   0x980F   1    SETS    r/m8
: SETNBE        SETA  ;
: SETNB         SETAE ;  : SETNC        SETAE ;
: SETNAE        SETB  ;  : SETC         SETB ;
: SETNA         SETBE ;
: SETE          SETZ  ;
: SETNLE        SETG  ;
: SETNL         SETGE ;
: SETNGE        SETL  ;
: SETNG         SETLE ;
: SETNE         SETNZ ;
: SETNP         SETPO ;
: SETPE         SETP  ;
Instruction:  SGDT
      2   0x010F   1    SGDT    mem8                    rrr=0
      2   0x010F   1    SGDT    mem16                   rrr=0 ~prechk1
      2   0x010F   1    SGDT    mem32                   rrr=0 ~prechk1
      2   0x010F   1    SGDT    mem64                   rrr=0
      2   0x010F   1    SGDT    mem>=80                 rrr=0
Instruction:  SIDT
      2   0x010F   1    SIDT    mem8                    rrr=1
      2   0x010F   1    SIDT    mem16                   rrr=1 ~prechk1
      2   0x010F   1    SIDT    mem32                   rrr=1 ~prechk1
      2   0x010F   1    SIDT    mem64                   rrr=1
      2   0x010F   1    SIDT    mem>=80                 rrr=1
Instruction:  SHLD
      2   0xA40F   3    SHLD    r/m16   reg16   imm8
      2   0xA40F   3    SHLD    r/m32   reg32   imm8
      2   0xA50F   3    SHLD    r/m16   reg16   CL
      2   0xA50F   3    SHLD    r/m32   reg32   CL
Instruction:  SHRD
      2   0xAC0F   3    SHRD    r/m16   reg16   imm8
      2   0xAC0F   3    SHRD    r/m32   reg32   imm8
      2   0xAD0F   3    SHRD    r/m16   reg16   CL
      2   0xAD0F   3    SHRD    r/m32   reg32   CL
Instruction:  SLDT
      2   0x000F   1    SLDT    r/m16                   rrr=0 ~prechk1
Instruction:  SMSW
      2   0x010F   1    SMSW    r/m16                   rrr=4 ~prechk1
Instruction:  STC
      1   0xF9     0    STC
Instruction:  STD
      1   0xFD     0    STD
Instruction:  STI
      1   0xFB     0    STI
Instruction:  STOSB
      1   0xAA     0    STOSB
Instruction:  STOSW
      1   0xAB     0    STOSW   DI  \ force prefix check
Instruction:  STOSD
      1   0xAB     0    STOSD   EDI \ force prefix check
Instruction:  STR
      2   0x000F   1    STR     r/m16                   rrr=1 ~prechk1
Instruction:  SUB
      1   0x28     2    SUB     r/m8    reg8
      1   0x29     2    SUB     r/m16   reg16
      1   0x29     2    SUB     r/m32   reg32
      1   0x2A     2    SUB     reg8    r/m8
      1   0x2B     2    SUB     reg16   r/m16
      1   0x2B     2    SUB     reg32   r/m32
      1   0x2C     2    SUB     AL      imm8
      1   0x2D     2    SUB     AX      imm16
      1   0x2D     2    SUB     EAX     imm32
      1   0x80     2    SUB     r/m8    imm8            rrr=5
      1   0x81     2    SUB     r/m16   imm16           rrr=5
      1   0x81     2    SUB     r/m32   imm32           rrr=5
      1   0x83     2    SUB     r/m16   sgnimm8         rrr=5
      1   0x83     2    SUB     r/m32   sgnimm8         rrr=5

\ .( .T)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  TEST
      1   0x84     2    TEST    r/m8    reg8
      1   0x85     2    TEST    r/m16   reg16
      1   0x85     2    TEST    r/m32   reg32
      1   0xA8     2    TEST    AL      imm8
      1   0xA9     2    TEST    AX      imm16
      1   0xA9     2    TEST    EAX     imm32
      1   0xF6     2    TEST    r/m8    imm8            rrr=0
      1   0xF7     2    TEST    r/m16   imm16           rrr=0
      1   0xF7     2    TEST    r/m32   imm32           rrr=0

\ .( .V)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  VERR
      2   0x000F   1    VERR    r/m16                   rrr=4
Instruction:  VERW
      2   0x000F   1    VERW    r/m16                   rrr=5

\ .( .W)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  WAIT
      1   0x9B     0    WAIT
Instruction:  WBINVD
      2   0x090F   0    WBINVD

\ .( .X)

 \   #opc opcs   #opr   |     <opr1>  <opr2> <opr3> | modifiers
Instruction:  XADD
      2   0xC00F   2    XADD    r/m8    reg8
      2   0xC10F   2    XADD    r/m16   reg16
      2   0xC10F   2    XADD    r/m32   reg32
Instruction:  XCHG
      1   0x86     2    XCHG    r/m8    reg8
      1   0x86     2    XCHG    reg8    r/m8
      1   0x87     2    XCHG    r/m16   reg16
      1   0x87     2    XCHG    reg16   r/m16
      1   0x87     2    XCHG    r/m32   reg32
      1   0x87     2    XCHG    reg32   r/m32
      1   0x90     2    XCHG    AX      reg16           +reg
      1   0x90     2    XCHG    reg16   AX              +reg
      1   0x90     2    XCHG    EAX     reg32           +reg
      1   0x90     2    XCHG    reg32   EAX             +reg
Instruction:  NOP
      1   0x90     0    NOP
Instruction:  XLAT
      1   0xD7     0    XLAT
Instruction:  XOR
      1   0x30     2    XOR     r/m8    reg8
      1   0x31     2    XOR     r/m16   reg16
      1   0x31     2    XOR     r/m32   reg32
      1   0x32     2    XOR     reg8    r/m8
      1   0x33     2    XOR     reg16   r/m16
      1   0x33     2    XOR     reg32   r/m32
      1   0x34     2    XOR     AL      imm8
      1   0x35     2    XOR     AX      imm16
      1   0x35     2    XOR     EAX     imm32
      1   0x80     2    XOR     r/m8    imm8            rrr=6
      1   0x81     2    XOR     r/m16   imm16           rrr=6
      1   0x81     2    XOR     r/m32   imm32           rrr=6
      1   0x83     2    XOR     r/m16   sgnimm8         rrr=6
      1   0x83     2    XOR     r/m32   sgnimm8         rrr=6

\ ----------------------------------------------------------------------------

\ CR .( 10. Structure Control Words and Global Labels ...)

: S-IF    ( condition -- A ) ( 5/31/'93 )
       SHORT HERE # SWAP EXECUTE  \ jump to zero
        HERE  ;

: S-THEN ( A -- ) ( 5/31/'93 )
        DUP HERE - NEGATE DUP 0x7F U> ABORT" S-THEN err" 
        SWAP 1- C! ;

: S-ELSE  ( A1 -- A2 )
        ['] JMP S-IF SWAP S-THEN ;


\ Target memory operations for LABELS ( 5/31/'93 )

: USE-CELL+ ( x -- x+cell, according to USE16 or USE32 ) ( 5/31/'93 )
        UseXX @ 16Bits = IF 2 + ELSE 4 + THEN ;
: USE-CELL- ( x -- x-cell, according to USE16 or USE32 ) ( 5/31/'93 )
        UseXX @ 16Bits = IF 2 - ELSE 4 - THEN ;
: USE-T@    ( according to USE16 or USE32, W@ or @ ) ( 5/31/'93 )
        UseXX @ 16Bits = IF W@ ELSE @ THEN ;
: USE-T!    ( according to USE16 or USE32, W! or ! ) ( 5/31/'93 )
        UseXX @ 16Bits = IF W! ELSE ! THEN ;

\ Structure control words : ( 5/31/'93, now target memory supported )

: IF    ( condition -- A ) ( 5/31/'93 )
        LONG 0 # SWAP EXECUTE   \ jump to zero
        HERE USE-CELL- ;

: THEN ( A -- ) ( 5/31/'93 )
        DUP USE-T@ HERE + SWAP USE-T! ;

: THEN THEN ;


: ELSE  ( A1 -- A2 )
        ['] JMP IF SWAP THEN ;
: BEGIN ( -- A )  HERE ;
: AGAIN ( A -- )  # JMP ;
: WHILE ( A1 condition -- A2 )
        IF SWAP ;
: REPEAT ( A1 A2 -- )
        AGAIN THEN ;

: S-WHILE ( A1 condition -- A2 )
        S-IF SWAP ;
: S-REPEAT ( A1 A2 -- )
        AGAIN S-THEN ;

: UNTIL ( A condition -- )
        SWAP # SWAP EXECUTE ;

CREATE tmpOperandDescriptor OperandDescriptor: ALLOT            \ 11/13/'95

: FOR ( -- A )
        ECX
            OperandDescriptor:  >R
            OperandDescriptors tmpOperandDescriptor R@ MOVE
            OperandDescriptors  DUP R@ +  SWAP R@ MOVE
            tmpOperandDescriptor OperandDescriptors R@ + R> MOVE
        SWAP MOV   HERE ;

: NEXT ( A -- )                         \ 11/13/'95
        ECX DEC   # JNZ
        ;  \ which is faster than LOOP and could branch more far

\ Label words : any label before using must be declared first.    (05/30/'93)
\ 09/18/'95 ..  New mechanism for Prefix syntax.

0
    CELL FIELD  |AssocAddr      \ Associated address if |Forward? is FALSE
 : |ForwardLink |AssocAddr ;    \ Forward link list  if |Forward? is TRUE
      1  FIELD  |Forward?       \ label address assigned ? unresolved forward ?
      4  FIELD  |LABEL-TST
DROP
FORTH ALSO DEFINITIONS

\ The method I used is quite tricky, in order to store the forward linkage
\ and still keep the ability to PREFIX and POSTFIX, the linked address is
\ used as the address to be jumped, so it will became relative address to
\ that instruction. So, if this node address is going to be retrieved, it
\ must be retrieved with a rough disassemble .
\ Of course, if the forward label has not been resolved but you are trying
\ to execute it, it will eventually jumps to NIL if all jumps occurs, or
\ results in unexpected branching sequence.

\   Label structure : while |Forward? is TRUE
\   LABEL:   LBL:
\   ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
\   º |ForwardLinkÄ×ÄÄÄ¿               JMP     LBL:
\   ÇÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¶   ³               ÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»
\   º |Forward?    º   ³       ÚÄÄÄÄÄ> º jmp  ³    þÄÄÄÄÄÄÄ×ÄÄÄÄÄÄ> NIL
\   ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼   ³       ³       ÈÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¼
\                      ³       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
\                      ³               JZ      LBL:               ³
\                      ³               ÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»       ³
\                      ³       ÚÄÄÄÄÄ> º  jz  ³    þÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÙ
\                      ³       ³       ÈÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¼
\                      ³       ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
\                      ³               JGE     LBL:               ³
\                      ³ pointer to theÉÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ» jump  ³ to
\                      ÀÄÄÄÄÄÄÄÄÄÄÄÄÄ> º jge  ³    þÄÄÄÄÄÄ×ÄÄÄÄÄÄÄÙ previous
\                        instruction   ÈÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¼ node instruction
\

: LABEL: ( <label-name> -- ) \ declare a label name
        CREATE  0 , -1 C, HERE ,
\       [ LAST @ NAME> ] LITERAL  LAST @ |USER-DEFINED !  \ for type-checking
        DOES> ( PFA -- addr_for_jmp_or_call )
                DUP |Forward? C@ IF \ not defined yet
                   DUP |ForwardLink @ \ use forward list as addr. to be JMPed
                   [ ASSEMBLER ] # [ FORTH ]    \ not using FORTH's '#'
                   LONG \ this must be applied with a JXX or CALL

                   SWAP HERE SWAP |ForwardLink !  \ forward linkage head
                ELSE \ defined
                   @ [ ASSEMBLER ] # [ FORTH ]
                THEN ;

ASSEMBLER DEFINITIONS

: IS-LABEL? ( cfa -- )        \ type checking
        >BODY |LABEL-TST DUP @ <>
        ABORT"  Not a label " ;

: RoughDisassembleJmps ( forward-instr -- next-forward-instr end-of-instr )
     \ Roughly disassemble jump instructions, only jumping destination addr
     \ and end of current instruction address is calculated.
        DUP C@ 0x0F =
        [ FORTH ] IF  1+  THEN  \ 2-opcode jumps are always leading with 0x0F
        [ ASSEMBLER ]
        1+ DUP USE-T@ SWAP USE-CELL+ \ the address at the end of forward-instr
        SWAP OVER + SWAP ;

FORTH DEFINITIONS

: LABELS: ( <name1> <name2> ... -- ) \ declare multiple label names
        BEGIN \ make label until end of line
           >IN @ BL WORD COUNT NIP SWAP >IN !
        WHILE \ length <> 0
           LABEL:
        REPEAT ;

: @@    ( <label-name> -- ) \ define label address, resolve forward list.
        ' DUP IS-LABEL? CFA>BODY
        DUP |Forward? C@ IF \ not resolved yet
             DUP |ForwardLink @      \ first node ( in target memory )
             BEGIN   \ resolve forward list
                DUP     \ is this node NIL ?
             WHILE
                RoughDisassembleJmps HERE OVER - \ relative address to HERE
                SWAP USE-CELL- USE-T!   \ resolve this forward reference
             REPEAT DROP
             0 OVER |Forward? C! \ mark resolved
        ELSE
             WARNING @ IF
                DUP WordByAddr TAB TYPE ."  : Label address reassigned "
             THEN
        THEN
        HERE SWAP !    \ store label address
        ; IMMEDIATE

: BLIND-LABEL:   ( <name> -- )        \ clear a label
        ' DUP IS-LABEL? CFA>BODY
        0  OVER |AssocAddr !
        -1 SWAP |Forward? C! ; IMMEDIATE

VARIABLE LLA  : LLA! LLA ! ; : LLA@ LLA @ ;
VARIABLE LLB  : LLB! LLB ! ; : LLB@ LLB @ ;
VARIABLE LLC  : LLC! LLC ! ; : LLC@ LLC @ ;
VARIABLE LLD  : LLD! LLD ! ; : LLD@ LLD @ ;
VARIABLE LLE  : LLE! LLE ! ; : LLE@ LLE @ ;


\ Both INLINE and MACRO definitions should be POSTFIX SYNTAX

: INLINE[       ( -- context syntax )
        CONTEXT @ ASSEMBLER RESET-ASSEMBLER
        SYNTAX? POSTFIX SYNTAX
        [COMPILE] [     ;  IMMEDIATE

: ]INLINE       ( syntax context -- )
        SYNTAX  CONTEXT !   ]   ; 

ASSEMBLER DEFINITIONS
\ Put the following at end of file in case misusing of 0= , 0<> , <> , = ....
\ condition words and alias

: No_0>,0<=     CompWithZeroCondition Error ; 
                   ' No_0>,0<=  CONSTANT  0>        \ 10/25/'95 added.
                   ' No_0>,0<=  CONSTANT  0<=       \ 10/25/'95 
: J0<>  JNE ;           ' J0<>  CONSTANT  0=
: J0=   JE ;            ' J0=   CONSTANT  0<>
: J0>=  JNS ;           ' J0>=  CONSTANT  0<
: J0<   JS ;            ' J0<   CONSTANT  0>=
: J<>   JNE ;           ' J<>   CONSTANT  =
: J=    JE ;            ' J=    CONSTANT  <>
: J>    JNLE ;          ' J>    CONSTANT  <=
: J<    JNGE ;          ' J<    CONSTANT  >=
: J>=   JNL ;           ' J>=   CONSTANT  <
: J<=   JNG ;           ' J<=   CONSTANT  >
: JU>   JNBE ;          ' JU>   CONSTANT  U<=
: JU<   JNAE ;          ' JU<   CONSTANT  U>=       \ Fixed in 10/23/'95
: JU>=  JNB ;           ' JU>=  CONSTANT  U<
: JU<=  JNA ;           ' JU<=  CONSTANT  U>        \ Fixed in 10/23/'95


ClearInstructionBuffers
AssemblingPhase   Assembler-Phase           !
ResetOperandDescriptors

ONLY FORTH ALSO DEFINITIONS

PREFIX  SYNTAX  \ 09/18/'95
WARNING !

\ CR .( ---------------   80486 Assembler/Disassembler Loaded   -------------- )


