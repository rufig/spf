( Целевой компилятор для компиляции SP-Forth v3.7x
  Copyright [C] 1992-2000 A.Cherezov ac@forth.org
)

HEX IMAGE-BASE 1034 + CONSTANT AddrOfLoadLibrary      \ адреса процедур в spf-stub.exe
    IMAGE-BASE 1038 + CONSTANT AddrOfGetProcAddress
DECIMAL

\ 4 ALIGN-BYTES !

: LOAD-VERSION ( -- n )
  S" src\version.spf" ['] INCLUDED CATCH IF 2DROP 400000 THEN
;
: SAVE-VERSION ( n -- )
  H-STDOUT >R
  S" src\version.spf" R/W CREATE-FILE THROW TO H-STDOUT
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
  DP @ DUP ROT 2DUP
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

: M\  POSTPONE \  ; IMMEDIATE

TRUE VALUE J_OPT?

S" src\macroopt.f"                   INCLUDED

TRUE TO ?C-JMP

: [TTO] TRUE TO OPT? ; IMMEDIATE
M\ ' DROP TO DTST

: TC-CALL, ( addr -- )
  \ так компилируется вызов слова в СП-Форте 3.0
  ?SET
  SetOP
  0E8 C,              \ машинная команда CALL
  DP @ CELL+ - ,
  DP @ TO LAST-HERE
;

: MCOMPILE, ( CFA -- )
    CON>LIT 
    IF  INLINE?
      IF     INLINE,
      ELSE   TC-CALL,
      THEN
    THEN
;

: TC-LIT,
  S" DUP" TC-FINDOUT INLINE,
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
  S" DROP" TC-FINDOUT
(  OPT_INIT SetOP ) 0xC00B W,    \ OR EAX, EAX
  OPT?  IF ( OP1 ToOP0 ) -2 ALLOT   \ ликвидация OR EAX, EAX
           OPT_INIT DP @ TO LAST-HERE
           ?BR-OPT 
           DP @ TO LAST-HERE
        THEN
  INLINE,  SetJP  SetOP
  J_COD    \  JX без 0x0F
  0x0F     \  кусок от JX
  C,  C,
  DP @ CELL+ - , DP @ TO LAST-HERE
;

: TC-BRANCH, ( ADDR -> ) \ скомпилировать инструкцию ADDR JMP
  SetOP SetJP E9 C,
  DP @ CELL+ - ,    DP @ TO LAST-HERE
;

: TC>RESOLVE1 ( A -> )
  DUP
    DP @ DUP TO :-SET
    OVER - 4 -
    SWAP !
\   J_OPT? IF ." R=" BASE @ HEX LAST-HERE U. DP @ U. BASE ! THEN
 RESOLVE_OPT

;

: TC>RESOLVE ( A, N -- )
  DUP 1 = IF   DROP TC>RESOLVE1
          ELSE 2 <> IF -2007 THROW THEN \ ABORT" Conditionals not paired"
               TC>RESOLVE1
          THEN
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


: __WIN:  ( CFA_INI "ИмяПроцедуры" "ИмяБиблиотеки" -- )

  COMPILE,
  HERE TC-WINAP !
  0 , \ address of winproc
  0 , \ address of library name
  0 , \ address of function name
  -1 , \ # of parameters
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

ALSO TC

: _WIN: ( CFA_INI "ИмяПроцедуры" "ИмяБиблиотеки" -- )
     >IN @ [T] HEADER [I]  >IN ! __WIN: ;


: WINAPI: ( "ИмяПроцедуры" "ИмяБиблиотеки" -- )
  WINAPI-CODE  _WIN:
;

 PREVIOUS


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
  DP @ SWAP DUP ALLOT MOVE 0 C,
  (.")-CODE COMPILE,
; IMMEDIATE

: SLITERAL  \ 94 STRING
  STATE @ IF
             SLITERAL-CODE COMPILE,
             DUP C,
             DP @ SWAP DUP ALLOT MOVE 0 C,
          ELSE
             2DUP + 0 SWAP C!
          THEN
; IMMEDIATE

: CLITERAL ( addr -- )
  STATE @ IF
            CLITERAL-CODE COMPILE,
            COUNT DUP C,
            DP @ SWAP DUP ALLOT MOVE 0 C,
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

C" SHERE-TAB-CUR" FIND NIP
[IF]
: ; PREVIOUS
  ?SET SetOP  POSTPONE ; [I] OPT OPT_CLOSE
  DP @ SHERE-TAB-CUR @ CELL- !  ; IMMEDIATE
[ELSE]
: ; PREVIOUS
  ?SET SetOP  POSTPONE ; [I] OPT OPT_CLOSE  ; IMMEDIATE
[THEN]

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

: EXIT
 ?SET SetOP 0xC3 C, OPT OPT_CLOSE   ; IMMEDIATE

: LITERAL
    STATE @ IF TC-LIT, THEN
; IMMEDIATE

: [CHAR]  \ 94
  ?COMP
  BL WORD 1+ C@ TC-LIT, ; IMMEDIATE

: IF  \ 94
  ?COMP DP @ TC-?BRANCH, >MARK 1
; IMMEDIATE

: UNTIL \ 94
  ?COMP 3 <> IF -2004 THROW THEN \ ABORT" UNTIL без BEGIN !"
  TC-?BRANCH,
  0xFFFFFF80  DP @ 4 - @  U<
  IF  DP @ 5 - W@ 0x3F0 + DP @ 6 - W!   -4 ALLOT
  THEN
; IMMEDIATE

: WHILE \ 94
  ?COMP DP @ TC-?BRANCH, >MARK 1
  2SWAP
; IMMEDIATE

: M_WL  2DUP [ ALSO TC-IMM ]
  POSTPONE WHILE
 [ PREVIOUS ] ; IMMEDIATE

: ELSE 
  ?COMP DP @ TC-BRANCH,
  TC>RESOLVE
  >MARK 2
; IMMEDIATE

: THEN  ?COMP  TC>RESOLVE ; IMMEDIATE

: REPEAT 
\ Продолжить выполнение с позиции, заданной dest.
  ?COMP
  3 <> IF -2005 THROW THEN \ ABORT" REPEAT без BEGIN !"
  DUP DP @ 2+ - DUP
  SHORT?
  IF SetJP 0xEB C, C, DROP
  ELSE DROP TC-BRANCH, THEN
  >RESOLVE
; IMMEDIATE

: AGAIN  POSTPONE AGAIN  ; IMMEDIATE
: RECURSE POSTPONE RECURSE ; IMMEDIATE
: BEGIN  POSTPONE BEGIN  DP @ TO :-SET  ; IMMEDIATE
\ : ORDER  ORDER ;

HEX

: DO   \ 94
  ?COMP
  OP0 @ :-SET  UMAX TO :-SET
  S" NIP" TC-FINDOUT DUP INLINE, INLINE,
  SetOP  0x68 C, DP @ 4 ALLOT
  S" C-DO" TC-FINDOUT INLINE,
  4 ALIGN-NOP
  DP @ DUP TO :-SET
; IMMEDIATE

: ?DO   \ 94 CORE EXT
  ?COMP
  OP0 @ :-SET  UMAX TO :-SET
  S" NIP" TC-FINDOUT DUP INLINE, INLINE,
  0xBB C, DP @ 4 ALLOT
  S" C-?DO" TC-FINDOUT INLINE,
  DP @ DUP TO :-SET
; IMMEDIATE

: LOOP   \ 94
  ?COMP
  24 04FF W, C, \ inc dword [esp]
  HERE 2+ - DUP SHORT?   SetOP SetJP
  IF
    71 C, C, \ jno short 
  ELSE
    4 - 0F C, 81 C, , \ jno near
  THEN    SetOP
  0C24648D , \ lea esp, 0c [esp]
  DP @ SWAP !
; IMMEDIATE

: +LOOP    \ 94
  ?COMP
    0x810FFC45
    0x8B240401
\ ADD     [ESP] , EAX
\ MOV     EAX , FC [EBP]
\ JNO 
  POSTPONE [ S" ' NIP" EVALUATE ]  INLINE, SetOP , , 
  -5 ALLOT SetOP 
   3 ALLOT SetOP
   2 ALLOT
  DP @ CELL+ -  ,
  SetOP 0x0C24648D , \ lea esp, 0xC [esp]
  DP @ SWAP !
; IMMEDIATE

: I   \ 94
  ?COMP S" C-I" TC-FINDOUT INLINE,
; IMMEDIATE

: UNLOOP  \ 94
  ?COMP
  SetOP  0C24648D , \ lea esp, 0c [esp]
; IMMEDIATE

: LEAVE    \ 94
  ?COMP
  SetOP 0824648D , \ lea esp, 08 [esp]
  SetOP C3 C,  \ ret
; IMMEDIATE

: >R   \ 94
  ?COMP
  S" C->R" TC-FINDOUT INLINE, ;   IMMEDIATE

: R>
  ?COMP
  S" C-R>" TC-FINDOUT INLINE, ;   IMMEDIATE

: RDROP
  ?COMP
  S" C-RDROP" TC-FINDOUT INLINE, ;   IMMEDIATE

  
: EXECUTE
  S" C-EXECUTE" TC-FINDOUT INLINE, ; IMMEDIATE


: ?DUP   STATE @
                 IF   HERE TO :-SET
                      S" C-?DUP" TC-FINDOUT  INLINE,
                      HERE TO :-SET
                 ELSE ?DUP
                 THEN ;   IMMEDIATE

: THROW
     STATE @ IF
     OPT_INIT OP0 @ C@ 0xB8 = 0 AND
     IF  0xE9 C,              \ машинная команда JMP
         THROW-CODE  DP @ CELL+ - ,
\          DP @ TO LAST-HERE
         EXIT 
     THEN
     OPT_CLOSE
     0x850FC00B , \  or eax, eax \  jnz near
     THROW-CODE DP @ CELL+ - ,
     'DROP    INLINE,
     ELSE THROW
     THEN ; IMMEDIATE

: NOTFOUND ( a u -- )  TC-?SLITERAL ;

: ... 0 TC-BRANCH, >MARK DUP , 1 >RESOLVE ; IMMEDIATE 
: ..: '  >BODY DUP @  1 >RESOLVE ] ;
: ;..  DUP CELL+ TC-BRANCH, >MARK SWAP ! [COMPILE] [ ; IMMEDIATE

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
