( Целевой компилятор для компиляции SP-Forth v3.7x
  Copyright [C] 1992-2000 A.Cherezov ac@forth.org

  Компиляция в виртуальные адреса
  Ю. Жиловец, 1.05.2007
)

\ ----------------------------------------------------

0 VALUE virt-offset

TARGET-POSIX [IF]
: >VIRT ( a -- va) virt-offset + ;
: VIRT> ( va -- a) virt-offset - ;
: >VIRT! ( a -- ) virt-offset SWAP +! ;
[ELSE]
: >VIRT ; 
[THEN]

: virtual-address ( va -- ) HERE - TO virt-offset ;
: *DP@ ( -- va) DP @ >VIRT ;

\ ----------------------------------------------------

: ASCIIZ" ( ->" ) [CHAR] " PARSE 
 HERE OVER ALLOT SWAP CMOVE 0 C,
;

0 VALUE elf-offset

: +elf-offset ( n -- ) elf-offset + TO elf-offset ;
: offset,size, ( n -- ) elf-offset , DUP , +elf-offset ;

\ ----------------------------------------------------

TARGET-POSIX [IF]
  S" src/tc-dl.f" INCLUDED
[ELSE]
  HEX 
  IMAGE-BASE 1034 + CONSTANT AddrOfLoadLibrary      \ адреса процедур в spf-stub.exe
  IMAGE-BASE 1038 + CONSTANT AddrOfGetProcAddress
  DECIMAL
[THEN]

: LOAD-BUILD-NUMBER ( -- n )
  S" src/version.spf" ['] INCLUDED CATCH IF 2DROP 0 THEN 
;

: SAVE-BUILD-NUMBER ( n -- )
  H-STDOUT >R
  S" src/version.spf" R/W CREATE-FILE THROW TO H-STDOUT
  . CR
  H-STDOUT CLOSE-FILE THROW
  R> TO H-STDOUT 
;

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

0 VALUE ()))-adr
0 VALUE symbol-call-adr
0 VALUE symbol-call2-adr

: TC-FINDOUT
   SFIND 0= ABORT" Can't find - TC-FINDOUT"
;

VARIABLE TC-WINAPLINK
VARIABLE TC-USER-OFFS 16 TC-USER-OFFS ! \ 16 байт зарезервировано

: TC-USER-ALLOT ( n -- )
  TC-USER-OFFS +!
;
: TC-USER-HERE ( -- n )
  TC-USER-OFFS @
;

: TC-USER-ALIGNED ( addr n )
   TC-USER-HERE ALIGNED DUP
   TC-USER-HERE -
;

WARNING 0!

ONLY FORTH DEFINITIONS

: UMIN 2DUP U< IF DROP ELSE NIP THEN ;
: UMAX 2DUP U< IF NIP ELSE DROP THEN ;

\ ~mak\listing3.f

HEX

: ALIGN-NOP ( n -- )
\ выровнять на n и заполнить NOP
  DP @ DUP ROT 2DUP
  MOD ?DUP IF - + ELSE DROP THEN
  OVER - DUP ALLOT 90 FILL
;

0 VALUE  'DUP_V
0 VALUE 'DROP_V

\ : H. BASE @ >R HEX . R> BASE ! ;

:  'DUP  'DUP_V ;
: 'DROP 'DROP_V ;

: M\  POSTPONE \ ; IMMEDIATE
: OS\ POSTPONE \ ; IMMEDIATE

: [>T] POSTPONE >VIRT ; IMMEDIATE
:  >T   ; IMMEDIATE

TRUE VALUE J_OPT?

USE-OPTIMIZER [IF]
S" src/macroopt.f"                   INCLUDED
[ELSE]
S" src/noopt.f"                      INCLUDED
[THEN]

TRUE TO ?C-JMP
0    TO ?C-JMP

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
    IF INLINE? 
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
  \ CR ." NEW 'DROP " CURFILE @ ASCIIZ> TYPE SPACE CURSTR @ .
  S" DROP" TC-FINDOUT >VIRT TC-LIT, ; IMMEDIATE

: TC-DLIT, ( D --)
  SWAP
  TC-LIT,
  TC-LIT,
;

: TC-?BRANCH,
  ?SET
  084 TO J_COD
  ???BR-OPT
  SetJP  SetOP
  J_COD    \  JX без 0x0F
  0x0F     \  кусок от JX
  C, C,
  DUP IF DP @ CELL+ - THEN , DP @ TO LAST-HERE
;

: TC-BRANCH, ( ADDR -> ) \ скомпилировать инструкцию ADDR JMP
  ?SET SetOP SetJP E9 C,
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

VECT VOC-LIST
VARIABLE _VOC-LIST ' _VOC-LIST TO VOC-LIST

: -ROT ( x1 x2 x3 -- x3 x1 x2 ) \ 94
    SWAP ROT SWAP
;

: S", ( addr u -- ) \ компиляция строки, заданной addr u, в виде строки со счетчиком
  DUP C, DP @ SWAP DUP ALLOT CMOVE
;

: +SWORD ( addr u wid -> ) \ добавление заголовка статьи с именем,
         \ заданным строкой addr u, к списку, заданному wid.
         \ Формирует только поля имени и связи с
         \ отведением памяти по ALLOT.
  HERE LAST !
  HERE 2SWAP S", SWAP DUP @ , !
;


ALIGN-BYTES-CONSTANT ALIGN-BYTES !


: SHEADER ( addr u -- )
  HERE 0 , ( cfa )
\  DUP LAST-CFA !
  0 C,     ( flags )
  -ROT WARNING @
  IF 2DUP GET-CURRENT SEARCH-WORDLIST
     IF DROP 2DUP TYPE ."  isn't unique" CR THEN
  THEN
  CURRENT @ +SWORD
  ALIGN
  HERE SWAP ! ( заполнили cfa )
;

: HEADER
   PARSE-NAME SHEADER
;

ALSO ASSEMBLER ALSO ASM-HIDDEN
: CODE-ORIG
     HEADER HIDE !CSP INIT-ASM
;
PREVIOUS PREVIOUS

VOCABULARY TC     \ слова, работающие в режиме интерпретации при ЦК
VOCABULARY TC-IMM \ immediate-слова для режима компиляции при ЦК,
                  \ вынесены в отдельный словарь, т.к. их нельзя
                  \ переопределять словами из TC-WL

ALSO TC DEFINITIONS PREVIOUS

: CODE  TRUE StartColonHelp [T] CODE-ORIG CONTEXT @ PREVIOUS CONTEXT ! ;

: CODE1 \ для словаря не TC-WL
   CODE-ORIG
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
  TC-USER-ALIGNED SWAP ,
  CELL+ TC-USER-ALLOT
;
: USER-CREATE ( "<spaces>name" -- )
  [T] HEADER [I]
  USER-CODE COMPILE,
  TC-USER-ALIGNED SWAP ,
  TC-USER-ALLOT
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
  TC-USER-ALIGNED SWAP ,
  CELL+ TC-USER-ALLOT
  TOUSER-VALUE-CODE COMPILE,
;

: USER-VECT ( "<spaces>name" -- ) \ 94 CORE EXT
  [T] HEADER [I]
  USER-VECT-CODE COMPILE,
  TC-USER-ALIGNED SWAP ,
  CELL+ TC-USER-ALLOT
  TOUSER-VALUE-CODE COMPILE,
;

: VECT ( -> )
  [T] HEADER [I]
  VECT-CODE COMPILE, NOOP-CODE >VIRT ,
  TOVALUE-CODE COMPILE,
;
: ->VECT ( x -> )
  [T] HEADER [I]
  VECT-CODE COMPILE, ,
  TOVALUE-CODE COMPILE,
;

: WORDLIST
  HERE VOC-LIST @ , VOC-LIST !
  HERE 0 , \ здесь будет указатель на имя последнего слова списка
       0 , \ здесь будет указатель на имя списка для именованых
       0 , \ wid словаря-предка
       0 , \ класс словаря = wid словаря, определяющего свойства данного
       0 , \ reserved, для расширений
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

TARGET-POSIX [IF]

S" src/tc-dl-tc.f" INCLUDED

[ELSE]

ALSO TC

: WINAPI: ( "ИмяПроцедуры" "ИмяБиблиотеки" -- )
  >IN @ [T] HEADER [I]  >IN !
  WINAPI-CODE COMPILE,
  HERE >R
  0 , \ address of winproc
  0 , \ address of library name
  0 , \ address of function name
  -1 , \ # of parameters
  HERE TC-WINAPLINK @ , TC-WINAPLINK ! ( связь )
  HERE DUP R@ CELL+ CELL+ !
  PARSE-NAME HERE SWAP DUP ALLOT MOVE 0 C, \ имя функции
  HERE DUP R> CELL+ !
  PARSE-NAME HERE SWAP DUP ALLOT MOVE 0 C, \ имя библиотеки
  LoadLibraryA DUP 0= ABORT" Library not found"
  GetProcAddress 0= ABORT" Procedure not found"
;

PREVIOUS

[THEN]

(  Отличие от WNDPROC - на выходе не вызываем USER-EXIT, 
   потому что при завершении процесса нет необходимости вызывать AT-THREAD-FINISHING,
   AT-PROCESS-FINISHING вызовется в BYE в конце INIT
   ~day  )

TARGET-POSIX [IF]
: PROCESSPROC: ( xt "name" -- )
  HERE
  2 CELLS LIT,
[ELSE]  
: PROCESSPROC: ( xt "name" -- )
  HERE
  0 CELLS LIT,
[THEN]  
  TC-FORTH-INSTANCE> COMPILE,
  SWAP COMPILE,
  RET,
  [T] HEADER [I]
  WNDPROC-CODE COMPILE,
  >VIRT ,
;

: TC-CALLBACK: ( xt n "name" -- )
  HERE
  SWAP 2* 2* LIT,
  TC-FORTH-INSTANCE> COMPILE,
  SWAP COMPILE,
  TC-<FORTH-INSTANCE COMPILE,
  RET,
  HEADER
  WNDPROC-CODE COMPILE,
  >VIRT ,
;

: ' ALSO TC-WL ' PREVIOUS ;

ALSO ASSEMBLER ALSO ASM-HIDDEN DEFINITIONS

: _END-CODE2
    EndColonHelp
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

: TC-VECT! ( xt xt-vect -- )
  >R >VIRT R>
  9 + 
  [ ALSO TC ] EXECUTE [ PREVIOUS ]
;
: TC-ADDR! ( addr xt-variable -- )
  >R >VIRT R>
  [ ALSO TC ] EXECUTE [ PREVIOUS ] !
;

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
  DUP ALLOCATE THROW DUP >R SWAP CMOVE R>   \ WORD кладёт строку в HERE :(
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

: ['] ALSO TC-WL ' >VIRT TC-LIT, PREVIOUS ; IMMEDIATE

: TO ALSO TC-WL [COMPILE] TO PREVIOUS ; IMMEDIATE

: POSTPONE \ 94
  ALSO TC-WL
  ?COMP
  PARSE-NAME SFIND DUP
  0= IF -321 THROW THEN
  1 = IF COMPILE,
      ELSE LIT, S" COMPILE," TC-FINDOUT COMPILE, THEN
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
  PARSE-NAME DROP C@ TC-LIT, ; IMMEDIATE

: IF  \ 94
  ?COMP 0 TC-?BRANCH, >MARK 1
; IMMEDIATE

: UNTIL \ 94
  ?COMP 3 <> IF -2004 THROW THEN \ ABORT" UNTIL без BEGIN !"
  TC-?BRANCH,
  0xFFFFFF80  DP @ 4 - @  U<
  IF  DP @ 5 - W@ 0x3F0 + DP @ 6 - W!   -4 ALLOT
  THEN DP @ TO :-SET
; IMMEDIATE

: WHILE \ 94
  ?COMP 0 TC-?BRANCH, >MARK 1
  2SWAP
; IMMEDIATE

: M_WL  2DUP [ ALSO TC-IMM ]
  POSTPONE WHILE
 [ PREVIOUS ] ; IMMEDIATE

: ELSE 
  ?COMP 0 TC-BRANCH,
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

: AGAIN  POSTPONE AGAIN DP @ TO :-SET ; IMMEDIATE
: RECURSE POSTPONE RECURSE ; IMMEDIATE
: BEGIN  POSTPONE BEGIN  DP @ TO :-SET  ; IMMEDIATE
\ : ORDER  ORDER ;

HEX

: DO   \ 94
  ?COMP
  S" C-DO" TC-FINDOUT INLINE,
  SetOP  0x68 C, DP @ 4 ALLOT  \ PUSH #
  SetOP  0x52 C,               \ PUSH EDX
  SetOP  0x53 C,               \ PUSH EBX
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
  042444FF , \ inc dword 4 [esp]
  HERE 2+ - DUP SHORT?   SetOP SetJP
  IF
    71 C, C, \ jno short 
  ELSE
    4 - 0F C, 81 C, , \ jno near
  THEN    SetOP
  0C24648D , \ lea esp, 0c [esp]
  *DP@ SWAP !
; IMMEDIATE

: +LOOP    \ 94
  ?COMP
  1 C, 4 C, 24 C, SetOP \ ADD     [ESP], EAX
  04244401 , \ ADD     4 [ESP] , EAX 
  'DROP INLINE,
  HERE 2+ - DUP SHORT?   SetOP SetJP
  IF
    71 C, C, \ jno short 
  ELSE
    4 - 0F C, 81 C, , \ jno near
  THEN    SetOP

  SetOP 0x0C24648D , \ lea esp, 0xC [esp]
  *DP@ SWAP !
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

: ... 0 TC-BRANCH, >MARK DUP >VIRT , 1 >RESOLVE ; IMMEDIATE 
: ..: '  >BODY DUP @  1 >RESOLVE ] ;
: ;..  DUP CELL+ TC-BRANCH, >MARK SWAP ! [COMPILE] [ ; IMMEDIATE

: _@    8B C, 00 C, ; IMMEDIATE

TARGET-POSIX [IF]
S" src/tc-dl-imm.f" INCLUDED
[THEN]

HERE 10000 + 10000 / 10000 * 2000 + DP !    \ выравнивание
DECIMAL

IMAGE-START virtual-address

\ *** поехали! ***
ONLY FORTH DEFINITIONS ALSO TC

' TC-?SLITERAL TO ?SLITERAL
0xE9 ' COMPILE, C!
' MCOMPILE,  ' COMPILE, 1+ CELL+ - ' COMPILE, 1+ !

\ Avoid words of target compiler in spf xml help
HERE TO TC-IMAGE-BASE
