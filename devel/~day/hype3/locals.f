\ (c) Dmitry Yakimov 2006, support@activekitten.com

( Local objects for Hype3.
  Memory for objects is allocated in return stack.
  Memory for nested objects is allocated via ALLOCATE word.

  Syntax:

  : test 
     || CObject obj CObject2 obj2 ||
     obj method
     obj2 method
  ;

  All methods for local objects is called statically, so there is no
  searches in runtime.

  It does not work with SPF4 locals in the same word. So it is impossible to make

  : test { a b c } || CTest c || ;

  That's why I 've implemented its own simple local variables:

  : test \ n1 n2 --
     || R: n1 R: n2 D: n3 CTest c1 ||
     n2 @ n3 !
  ;

  R: and D: is the simple classes that define methods ! and @.
  Method 'init' of R: initialize its value from the data stack.

)

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS ~day\hype3\hype3.f

VOCABULARY objLocalsSupport

GET-CURRENT ALSO objLocalsSupport DEFINITIONS

USER widLocals
USER uPrevCurrent
USER uCurrShift
USER uAddDepth

\ ???
: CompileMethod ( ta addr u -- f )
\    2 PICK >R    
    HYPE::MFIND-ERR TUCK 1 = IF -1 ABORT" do not support!" R@ SWAP HYPE::(SEND) ELSE LIT, THEN
\    R> DROP
;

: CompileLocalRec ( u -- )
  DUP
  ['] DUP MACRO,
  SHORT?
  OPT_INIT SetOP
  IF    0x8D C, 0x44 C, 0x24 C, C, \ lea eax, offset [esp]
  ELSE  0x8D C, 0x84 C, 0x24 C,  , \ lea eax, offset [esp]
  THEN  OPT
  OPT_CLOSE
;

: CompileCall ( ta shift addr u -- )
\    CELLS LIT, \ shift
\    ['] RP+ COMPILE, \ object
    ROT CELLS CompileLocalRec 
    CompileMethod \ method
    -1 =  \ non immediate means non object
    IF
      [ ALSO HYPE ]
      POSTPONE (SEND)
      [ PREVIOUS ]
    THEN
;

: AlignToCELL ( u -- u1 )
    3 +
    3 INVERT AND
;

: CELL/ 2 RSHIFT ;

: (objinit) ( xt ta size )
    ['] ALLOCATE HYPE::ALLOC-XT ! \ For nested objects use allocate
    R> SWAP RALLOT SWAP >R ( ta addr )
    TUCK ! SWAP HYPE::(SEND)
;

: ClassNormalizedSize ( ta -- size )
    ^ size AlignToCELL CELL/
;
: CompileInitObj ( ta )
    uPrevCurrent @ ALSO CONTEXT ! DEFINITIONS

    DUP S" init" CompileMethod DROP
    DUP LIT,
    ClassNormalizedSize LIT,
    ['] (objinit) COMPILE,

    PREVIOUS DEFINITIONS \ widLocals wordlist
;

: @Local ( addr -- ta shift )
    DUP @ SWAP CELL+ @ uCurrShift @ SWAP -
    2 +                   \ Skip (LocalsExit)
;

\ Proxy class

CLASS Ptr

: dispose ( -- obj )
   \ return copy of the object in the heap
   SELF @ NewObj >R
   SELF R@ SUPER size MOVE
   R>
;

: freenested ;

;CLASS

\ || Ptr CMyClass obj ||
\ Надо чтобы был создан 
: ptr ;

\ Simple local variables

CLASS D:

   CELL DEFS locVar

: @ locVar @ ;
: ! locVar ! ;

;CLASS

D: SUBCLASS R:

: init ( param -- ) SUPER locVar ! ;

;CLASS

: LocalsDoes@ ( ta )
\ addr u - class name
    DUP CompileInitObj
    DUP , ClassNormalizedSize
    uCurrShift @ + DUP ,
    uCurrShift !
    DOES> @Local ( ta shift )
          uAddDepth @ CELL/ +  \ Account >R R> DO LOOP
          PARSE-NAME CompileCall
;

: (preparedispose)
    ['] FREE HYPE::FREE-XT !
;

: CompileDispose
   widLocals @ @ ( nfa ) DUP
   IF
      ['] (preparedispose) COMPILE,
   THEN

   BEGIN
     DUP
   WHILE
     DUP NAME> >BODY ( data )     
     @Local
     OVER HYPE::CLASS-EMPTY-DISPOSE? 0=
     IF 2DUP S" dispose" CompileCall
        OVER HYPE::CLASS-HAS-NESTED-OBJECTS
        IF
           S" freenested" CompileCall
        ELSE 2DROP
        THEN
     ELSE 2DROP
     THEN
     CDR
   REPEAT DROP
;

: LocalsCleanup
  PREVIOUS PREVIOUS
  CompileDispose
  widLocals @ FREE-WORDLIST
;

: LocalsStartup
  TEMP-WORDLIST widLocals !
  0 uCurrShift !
  0 uAddDepth !
  GET-CURRENT uPrevCurrent !
  ALSO objLocalsSupport
  ALSO widLocals @ CONTEXT !

  DEFINITIONS
;

: CompileLocalsInit
  uPrevCurrent @ SET-CURRENT
  uCurrShift  @ CELLS ?DUP
  IF LIT, POSTPONE >R  ['] (LocalsExit) LIT, POSTPONE >R THEN
;

: ;; POSTPONE ; ; IMMEDIATE

WARNING @ WARNING 0!
\ ===
\ переопределение соответствующих слов для возможности использовать
\ временные переменные внутри  цикла DO LOOP  и независимо от изменения
\ содержимого стека возвратов  словами   >R   R>

: DO    POSTPONE DO     [  3 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: ?DO   POSTPONE ?DO    [  3 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: LOOP  POSTPONE LOOP   [ -3 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: +LOOP POSTPONE +LOOP  [ -3 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: >R    POSTPONE >R     [  1 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: R>    POSTPONE R>     [ -1 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: RDROP POSTPONE RDROP  [ -1 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: 2>R   POSTPONE 2>R    [  2 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
: 2R>   POSTPONE 2R>    [ -2 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE

: ;  LocalsCleanup POSTPONE ; ; IMMEDIATE

WARNING !

SET-CURRENT

: ||
  LocalsStartup
  BEGIN
    BL SKIP PeekChar [CHAR] | <>
    CharAddr 2 S" --" COMPARE 0=
    IF [CHAR] | SkipUpTo 0 ELSE TRUE THEN
    AND
  WHILE
    ' EXECUTE CREATE LocalsDoes@ IMMEDIATE
  REPEAT

  [CHAR] | SKIP
  CompileLocalsInit

;; IMMEDIATE

PREVIOUS

\EOF
   
CLASS CNested

init: ." init of CNested" CR ;
dispose: ." dispose of CNested" CR ;

;CLASS

CLASS CTest 

   CELL PROPERTY l
   0 DEFS n-addr
   CNested OBJ n

init: ." init of CTest" CR ;
dispose: ." dispose of CTest" CR ;

;CLASS

lib\ext\disasm.f

: test2
   || CTest a CTest a ||
\    ." CTest instance " a this . CR
\    ." a instance " a n this . CR
   
   ." obj size " CTest ^ size . CR
   ." top of return stack " 0 RP+ . CR
\   ." object a " a this . CR
\   ." object b " b this . CR
\   ." object c " c this . CR
;

\ test
\ SEE test2
test2