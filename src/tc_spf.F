( Целевой компилятор для компиляции SP-Forth v3.7x
  Copyright [C] 1992-2000 A.Cherezov ac@forth.org
)

HEX IMAGE-BASE 1034 + CONSTANT AddrOfLoadLibrary      \ адреса процедур в spf-stub.exe
    IMAGE-BASE 1038 + CONSTANT AddrOfGetProcAddress
DECIMAL

4 ALIGN-BYTES !

: LOAD-VERSION ( -- n )
  S" VERSION.SPF" ['] INCLUDED CATCH IF 2DROP 375000 THEN
;
: SAVE-VERSION ( n -- )
  H-STDOUT >R
  S" VERSION.SPF" R/W CREATE-FILE THROW TO H-STDOUT
  . CR
  H-STDOUT CLOSE-FILE THROW
  R> TO H-STDOUT
;
: HASH  ( c-addr u wid --  c-addr u HASHwid ) \ 94 SEARCH
    @  OVER DUP 1 U> IF XOR 2 PICK C@ XOR 2 PICK 1+ XOR THEN +   ;

VOCABULARY TC-WL
VARIABLE SAVED-CURRENT

: [T] GET-CURRENT SAVED-CURRENT ! ALSO TC-WL DEFINITIONS ;
: [I] PREVIOUS    SAVED-CURRENT @ SET-CURRENT ;

0 VALUE THROW-CODE
0 VALUE CREATE-CODE
0 VALUE CONSTANT-CODE
0 VALUE TOVALUE-CODE
0 VALUE VECT-CODE
0 VALUE NOOP-CODE
0 VALUE ---CODE
0 VALUE SLITERAL-CODE
0 VALUE CLITERAL-CODE
0 VALUE USER-CODE
0 VALUE (.")-CODE
0 VALUE USER-VALUE-CODE
0 VALUE USER-VECT-CODE
0 VALUE TOUSER-VALUE-CODE
' R>  VALUE  DOES-CODE

0 VALUE WINAPI-CODE
0 VALUE WNDPROC-CODE
0 VALUE TC-FORTH-INSTANCE>
0 VALUE TC-<FORTH-INSTANCE

0 VALUE DO-OFF
0 VALUE ?DO-OFF

0 VALUE OFF-LOOP
0 VALUE OFF-+LOOP

: TC-FINDOUT
   SFIND 0= ABORT" Can't find - TC-FINDOUT"
;

VARIABLE TC-WINAP
VARIABLE TC-WINAPLINK
VARIABLE TC-USER-OFFS 16 TC-USER-OFFS ! \ 16 байт зарезервировано

: TC-USER-ALLOT ( n -- )
  TC-USER-OFFS +!
;
: TC-USER-HERE ( -- n )
  TC-USER-OFFS @
;

S" lib\ext\disasm.f"             INCLUDED

WARNING 0!
ALSO DISASSEMBLER DEFINITIONS


: INST  ( ADR -- ADR' )
        DUP TO NEXT-INST
        COLS 0x29 <
        IF      DIS-OP
                S-BUF COUNT TYPE
        ELSE    DUP DIS-OP  
                OVER BASE-ADDR - 6  H.R SPACE
                DUP ROT 
                2DUP - DUP>R 0x10 U> ABORT" DECOMPILER ERROR"
                DO I C@ 2 H.N LOOP 
                R> 5 < IF 9 EMIT THEN
                9 EMIT S-BUF COUNT TYPE
        THEN    NEXT-INST C@ 0xE8 =
                IF  NEXT-INST 1+ @+ SWAP +
                    CASE
                    CLITERAL-CODE OF  X".   ENDOF
                    SLITERAL-CODE OF  X".   ENDOF
                    VECT-CODE     OF  VECT. ENDOF
                    CONSTANT-CODE OF  CONS. ENDOF
                    USER-CODE     OF  USER. ENDOF
                    CREATE-CODE   OF  CODE. ENDOF
                    USER-VALUE-CODE OF UVAL. ENDOF
                    ENDCASE
                THEN  ;

ONLY FORTH DEFINITIONS

C" UMIN" FIND NIP 0= 
[IF] : UMIN 2DUP U< IF DROP ELSE NIP THEN ;
[THEN]

\ ~mak\listing1.f


HEX

: ALIGN-NOP ( n -- )
\ выровнять на n и заполнить NOP
  HERE DUP ROT 2DUP
  MOD ?DUP IF - + ELSE DROP THEN
  OVER - DUP ALLOT 90 FILL
;
[UNDEFINED] DUP>R
[IF] : DUP>R  50 C, ; IMMEDIATE
[THEN]

0 VALUE  'DUP_V
0 VALUE 'DROP_V

:  'DUP  'DUP_V ;
: 'DROP 'DROP_V ;

S" src\macroopt.f"                   INCLUDED

: TC-CALL, ( addr -- )
  \ так компилируется вызов слова в СП-Форте 3.0
  ?SET
  SetOP
  0E8 C,              \ машинная команда CALL
  HERE CELL+ - ,
  HERE TO LAST-HERE
;

: MCOMPILE, ( CFA -- )
    CON>LIT 
    IF  MACRO?
      IF     MACRO,
      ELSE   TC-CALL,
      THEN
    THEN
;

: TC-LIT,
  S" DUP" TC-FINDOUT MACRO,
  OPT_INIT
  SetOP 0B8 C,  , OPT  \ MOV EAX, #
  OPT_CLOSE ;

: 'DUP
  S" DUP" TC-FINDOUT TC-LIT, ; IMMEDIATE

: 'DROP
  S" DROP" TC-FINDOUT TC-LIT, ; IMMEDIATE



: TC-DLIT, ( D --)
  SWAP
  TC-LIT,
  TC-LIT,
;

: TC-?BRANCH,
  084 TO J_COD
  OPT_INIT SetOP 0xC00B W,    \ OR EAX, EAX
  OPT?  IF ?BR-OPT THEN
  J_COD          \  JX без 0x0F
  0x0FFC458B     \  MOV     EAX , FC [EBP] и кусок от JX
  S" NIP" TC-FINDOUT MACRO, ,  C,
  HERE CELL+ - ,
;

DECIMAL

: TC-LITERAL \ 94 CORE
\ Интерпретация: семантика неопределена.
\ Компиляция: ( x -- )
\ Добавить семантику времени выполнения, данную ниже, к текущему определению.
\ Время выполнения: ( -- x )
\ Положить x на стек.
  STATE @ IF TC-LIT, THEN
; IMMEDIATE

: TC-2LITERAL \ 94 DOUBLE
\ Интерпретация: семантика неопределена.
\ Компиляция: ( x1 x2 -- )
\ Добавить семантику времени выполнения, данную ниже, к текущему определению.
\ Время выполнения: ( -- x1 x2 )
\ Положить пару ячеек x1 x2 на стек.
  STATE @ IF TC-DLIT, THEN
; IMMEDIATE

: HEX-TC-LITERAL ( c-addr u -> ... )
  BASE @ >R HEX
  0. 2SWAP 2- SWAP 2+ SWAP >NUMBER 2DROP D>S [COMPILE] TC-LITERAL
  R> BASE !
;

: TC-?SLITERAL ( c-addr u -> ... )
  \ преобразовать строку в число
  2DUP 2 MIN S" 0x" COMPARE 0= 
  IF HEX-TC-LITERAL EXIT THEN

  0. 2SWAP
  OVER C@ [CHAR] - = IF 1- SWAP 1+ SWAP TRUE ELSE FALSE THEN >R
  >NUMBER
  DUP 1 > IF -2001 THROW THEN \ ABORT" -?"
  IF C@ [CHAR] . <> IF -2002 THROW THEN \ ABORT" -??"
       R> IF DNEGATE THEN
       [COMPILE] TC-2LITERAL
  ELSE DROP D>S
       R> IF NEGATE THEN
       [COMPILE] TC-LITERAL
  THEN
;


VOCABULARY TC     \ слова, работающие в режиме интерпретации при ЦК
VOCABULARY TC-IMM \ immediate-слова для режима компиляции при ЦК,
                  \ вынесены в отдельный словарь, т.к. их нельзя
                  \ переопределять словами из TC-WL
: tmp ( VOC ADDR LEN -- )
   EVALUATE  ALSO CONTEXT !
;

: asd CONTEXT @ PREVIOUS ;

ALSO TC DEFINITIONS PREVIOUS

: CODE [T]  CODE CONTEXT @ PREVIOUS CONTEXT ! ;

: CODE1 \ для словаря не TC-WL
   CODE 
;

: CREATE ( "<spaces>name" -- ) \ 94
  [T] HEADER [I]
  CREATE-CODE COMPILE,
;
: VARIABLE ( "<spaces>name" -- ) \ 94
  [T] HEADER [I]
  CREATE-CODE COMPILE,
  0 ,
;
: ->VARIABLE ( x "<spaces>name" -- ) \ 94
  [T] HEADER [I]
  CREATE-CODE COMPILE,
  ,
;
: USER ( "<spaces>name" -- ) \ локальные переменные потока
  [T] HEADER [I]
  USER-CODE COMPILE,
  TC-USER-HERE ,
  4 TC-USER-ALLOT
;
: USER-CREATE ( "<spaces>name" -- )
  [T] HEADER [I]
  USER-CODE COMPILE,
  TC-USER-HERE ,
;
: CONSTANT ( x "<spaces>name" -- ) \ 94
  [T] HEADER [I]
  CONSTANT-CODE COMPILE, ,
;
: VALUE ( x "<spaces>name" -- ) \ 94 CORE EXT
  [T] HEADER [I]
  CONSTANT-CODE COMPILE, ,
  TOVALUE-CODE COMPILE,
;
: USER-VALUE ( "<spaces>name" -- ) \ 94 CORE EXT
  [T] HEADER [I]
  USER-VALUE-CODE COMPILE,
  TC-USER-HERE ,
  4 TC-USER-ALLOT
  TOUSER-VALUE-CODE COMPILE,
;

: USER-VECT ( "<spaces>name" -- ) \ 94 CORE EXT
  [T] HEADER [I]
  USER-VECT-CODE COMPILE,
  TC-USER-HERE ,
  4 TC-USER-ALLOT
  TOUSER-VALUE-CODE COMPILE,
;

: VECT ( -> )
  [T] HEADER [I]
  VECT-CODE COMPILE, NOOP-CODE ,
  TOVALUE-CODE COMPILE,
;
: ->VECT ( x -> )
  [T] HEADER [I]
  VECT-CODE COMPILE, ,
  TOVALUE-CODE COMPILE,
;

: --
  [T] HEADER [I]  
  OPT_INIT
  SetOP  05 C, OVER , OPT  \ add eax, # xxx 
  OPT_CLOSE 
  + RET,
\  ---CODE COMPILE,
\  OVER , +
;

: WINAPI: ( "ИмяПроцедуры" "ИмяБиблиотеки" -- )
  >IN @
  [T] HEADER [I]
  >IN !
  WINAPI-CODE COMPILE,
  HERE TC-WINAP !
  0 , \ address of winproc
  0 , \ address of library name
  0 , \ address of function name
\  0 , \ # of parameters
  HERE TC-WINAPLINK @ , TC-WINAPLINK ! ( связь )
  HERE TC-WINAP @ CELL+ CELL+ !
  HERE >R
  BL WORD COUNT HERE SWAP DUP ALLOT MOVE 0 C, \ имя функции
  HERE TC-WINAP @ CELL+ !
  HERE >R
  BL WORD COUNT HERE SWAP DUP ALLOT MOVE 0 C, \ имя библиотеки
  R> LoadLibraryA DUP 0= ABORT" Library not found"
  R> SWAP GetProcAddress 0= ABORT" Procedure not found"
;

: WNDPROC: ( xt "name" -- )
  HERE
  0 CELLS LIT,
  TC-FORTH-INSTANCE> COMPILE,
  SWAP COMPILE,
  TC-<FORTH-INSTANCE COMPILE,
  RET,
  [T] HEADER [I]
  WNDPROC-CODE COMPILE,
  ,
;

: ' ALSO TC-WL ' PREVIOUS ;

: SEE ALSO TC-WL ' PREVIOUS REST ;
(
CODE EXECUTE  \ выполнить jpf слово в контексте spf
   MOV EAX, 4 [EBP]
   MOV ECX, [EBP]
   ADD EBP, # 8
   CALL ECX
   SUB EBP, # 4
   MOV [EBP], EAX
   RET
END-CODE )

ALSO ASSEMBLER ALSO ASM-HIDDEN DEFINITIONS

: _END-CODE2
    _END-CODE
     [I] ALSO TC
;

' _END-CODE2 IS END-CODE

PREVIOUS TC DEFINITIONS PREVIOUS

: (TO)
  ALSO TC-WL '
  9 + STATE @
  IF COMPILE, ELSE [ ALSO TC ] EXECUTE [ PREVIOUS ] THEN
  PREVIOUS
; IMMEDIATE

: TC-LATEST->
  ALSO TC-WL CONTEXT @ @ ' [ ALSO TC ] EXECUTE ! [ PREVIOUS ] PREVIOUS
;

: IMMEDIATE [T] IMMEDIATE [I] ;

: :: : ;

: ;; POSTPONE ; ; IMMEDIATE

: :  [T] : ALSO TC-IMM ;

(
 Во время компиляции "двоеточечного" определения в ЦК порядок поиска
 представляет собой такой пирог:

  TC-IMM    \ imm-слова управления, которые опасно переопределять
  TC-WL     \ создаваемый целевой список слов, он же в CURRENT
  TC        \ словарь определяющих слов ЦК - ":", CREATE, CONSTANT, etc
  FORTH     \ основной словарь инструментальной форт-системы
)

ALSO TC-IMM DEFINITIONS PREVIOUS

: ."
  CLITERAL-CODE COMPILE,
  [CHAR] " PARSE DUP C,
  HERE SWAP DUP ALLOT MOVE 0 C,
  (.")-CODE COMPILE,
; IMMEDIATE

: SLITERAL  \ 94 STRING
  STATE @ IF
             SLITERAL-CODE COMPILE,
             DUP C,
             HERE SWAP DUP ALLOT MOVE 0 C,
          ELSE
             2DUP + 0 SWAP C!
          THEN
; IMMEDIATE

: CLITERAL ( addr -- )
  STATE @ IF
            CLITERAL-CODE COMPILE,
            COUNT DUP C,
            HERE SWAP DUP ALLOT MOVE 0 C,
          THEN
; IMMEDIATE

: S"   \ 94+FILE
  [CHAR] " PARSE [ ALSO TC-IMM ] [COMPILE] SLITERAL [ PREVIOUS ]
; IMMEDIATE

: C"   \ 94 CORE EXT
  [CHAR] " WORD DUP COUNT NIP 1+
  DUP ALLOCATE THROW DUP >R SWAP QCMOVE R>   \ WORD кладёт строку в HERE :(
  STATE @
  IF DUP [ ALSO TC-IMM ] [COMPILE] CLITERAL [ PREVIOUS ] FREE THROW THEN

; IMMEDIATE


: ; PREVIOUS POSTPONE ; [I] ; IMMEDIATE

: ['] ALSO TC-WL ' TC-LIT, PREVIOUS ; IMMEDIATE

: TO ALSO TC-WL [COMPILE] TO PREVIOUS ; IMMEDIATE

: POSTPONE \ 94
  ALSO TC-WL
  ?COMP
  BL WORD FIND DUP
  0= IF -321 THROW THEN
  1 = IF COMPILE,
      ELSE S" COMPILE," TC-FINDOUT COMPILE, THEN
  PREVIOUS
; IMMEDIATE 

: [COMPILE]  \ 94 CORE EXT
  ALSO TC-WL ' PREVIOUS
  COMPILE,
; IMMEDIATE

: \ [COMPILE] \ ; IMMEDIATE
: ( [COMPILE] ( ; IMMEDIATE
: [ [COMPILE] [ ; IMMEDIATE

: EXIT RET, ; IMMEDIATE

: LITERAL
    STATE @ IF TC-LIT, THEN
; IMMEDIATE

: [CHAR]  \ 94
  ?COMP
  BL WORD 1+ C@ TC-LIT, ; IMMEDIATE

: IF  \ 94
  ?COMP HERE TC-?BRANCH, >MARK 1
; IMMEDIATE

: UNTIL \ 94
  ?COMP 3 <> IF -2004 THROW THEN \ ABORT" UNTIL без BEGIN !"
  TC-?BRANCH,
  0xFFFFFF80  HERE 4 - @  U<
  IF  HERE 5 - W@ 0x3F0 + HERE 6 - W!   -4 ALLOT
  THEN
; IMMEDIATE

: WHILE \ 94
  ?COMP HERE TC-?BRANCH, >MARK 1
  2SWAP
; IMMEDIATE

: M_WL  2DUP [ ALSO TC-IMM ]
  POSTPONE WHILE
 [ PREVIOUS ] ; IMMEDIATE

: ELSE   POSTPONE ELSE   ; IMMEDIATE
: THEN   POSTPONE THEN  HERE TO :-SET  ; IMMEDIATE
: REPEAT 
\ Продолжить выполнение с позиции, заданной dest.
  ?COMP
  3 <> IF -2005 THROW THEN \ ABORT" REPEAT без BEGIN !"
  DUP HERE 2+ - DUP
  SHORT?
  IF   0xEB C, C, DROP
  ELSE DROP BRANCH, THEN
  >RESOLVE
; IMMEDIATE

: AGAIN  POSTPONE AGAIN  ; IMMEDIATE
: RECURSE POSTPONE RECURSE ; IMMEDIATE
: BEGIN  POSTPONE BEGIN  HERE TO :-SET  ; IMMEDIATE
\ : ORDER  ORDER ;

HEX

: DO   \ 94
  ?COMP
  S" NIP" TC-FINDOUT DUP MACRO, MACRO,
  0x68 C, HERE 4 ALLOT
  S" C-DO" TC-FINDOUT MACRO,  
  HERE  DUP TO :-SET 
; IMMEDIATE

: ?DO   \ 94 CORE EXT
  ?COMP
  S" NIP" TC-FINDOUT DUP MACRO, MACRO,
  0xBB C, HERE 4 ALLOT
  S" C-?DO" TC-FINDOUT MACRO,
  HERE  DUP TO :-SET 
; IMMEDIATE

: LOOP   \ 94
  ?COMP 
  FF C, 04 C, 24 C, \ inc dword [esp]
  HERE 2+ - DUP ABS 7F <
  IF
    71 C, C, \ jno short 
  ELSE
    4 - 0F C, 81 C, , \ jno far
  THEN
  0C24648D , \ lea esp, 0c [esp]
  HERE SWAP !
; IMMEDIATE

: +LOOP    \ 94
  ?COMP
  POSTPONE [ S" ' NIP" EVALUATE ]   MACRO,  
    0x8B240401 ,
    0x810FFC45 ,
\ ADD     [ESP] , EAX
\ MOV     EAX , FC [EBP]
\ JNO 
  HERE CELL+ -  ,
    0x0C24648D , \ lea esp, 0xC [esp]
  HERE SWAP !
; IMMEDIATE

: I   \ 94
  ?COMP S" C-I" TC-FINDOUT MACRO,
; IMMEDIATE

: UNLOOP  \ 94
  ?COMP
  0C24648D , \ lea esp, 0c [esp]
; IMMEDIATE

: LEAVE    \ 94
  ?COMP
  0824648D , \ lea esp, 8 [esp]
  C3 C,  \ ret
; IMMEDIATE

: >R   \ 94
  ?COMP
  S" C->R" TC-FINDOUT MACRO, ;   IMMEDIATE

: R>
  ?COMP
  S" C-R>" TC-FINDOUT MACRO, ;   IMMEDIATE

: RDROP
  ?COMP
  S" C-RDROP" TC-FINDOUT MACRO, ;   IMMEDIATE

  
: EXECUTE
  S" C-EXECUTE" TC-FINDOUT HERE TO :-SET MACRO, HERE TO :-SET ; IMMEDIATE


: ?DUP   STATE @
                 IF   HERE TO :-SET
                      S" C-?DUP" TC-FINDOUT  MACRO,
                      HERE TO :-SET
                 ELSE ?DUP
                 THEN ;   IMMEDIATE

: THROW STATE @ IF
     HERE TO :-SET
     0B C, C0 C, \  or eax, eax
     74 C, 05 C, \  jz $+05
     E8 C, THROW-CODE HERE CELL+ - ,
     'DROP    MACRO,
     ELSE THROW
     THEN ; IMMEDIATE

: NOTFOUND ( a u -- )  TC-?SLITERAL ;

: ... 0 BRANCH, >MARK DUP , 1 >RESOLVE ; IMMEDIATE 
: ..: '  >BODY DUP @  1 >RESOLVE ] ;
: ;..  DUP CELL+ BRANCH, >MARK SWAP ! [COMPILE] [ ; IMMEDIATE

: _@    8B C, 00 C, ; IMMEDIATE
: DUP>R   STATE @ 0= IF asd S" DUP >R"  tmp ELSE 50 C, THEN ; IMMEDIATE
\ : SEE SEE ;
HERE 10000 + 10000 / 10000 * 2000 + DP !    \ выравнивание
DECIMAL
\ *** поехали! ***
ONLY FORTH DEFINITIONS ALSO TC

' TC-?SLITERAL TO ?SLITERAL
0xE9 ' COMPILE, C!
' MCOMPILE,  ' COMPILE, 1+ CELL+ - ' COMPILE, 1+ !
