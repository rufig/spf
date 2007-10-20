\ http://home.netsurf.de/helge.horch/hype.html
\ upgrade by:
\ (c) Dmitry Yakimov 2006, support@activekitten.com

REQUIRE WL-MODULES ~day\lib\includemodule.f

NEEDED: [IF]  lib\include\tools.f
NEEDS        lib\ext\vocs.f

MODULE: HYPE

0
CELL -- .self
CELL -- .size
CELL -- .wl
CELL -- .super
CELL -- .nfa
CELL -- .objchain
CONSTANT /class

USER-VALUE SELF

\ For nested objects
USER ALLOC-XT
USER FREE-XT

: SELF+ ( n - a) SELF + ;

: (SEND) ( a xt) SELF >R SWAP TO SELF EXECUTE  R> TO SELF ;

VARIABLE CLS ( contains ta -> |size|wid|super|)
VARIABLE PREVIOUS-CURRENT

: CLASS@ ( - aa) CLS @ ?DUP 0= ABORT" Use in CLASS ;CLASS statements" ;
: OBJ-SIZE CLASS@ .size @ ;

: MFIND ( ta c-addr u - ta c-addr u 0 | xt 1 | xt -1 )
   ROT DUP >R
   ROT ROT 2>R
   BEGIN 
     DUP 
   WHILE
     DUP .wl @ 2R@
     ROT SEARCH-WORDLIST ?DUP IF ROT 2R> R> 2DROP 2DROP EXIT THEN
     .super @
   REPEAT 
   DROP 2R> R> ROT ROT 0
;

: SEND ( a ta addr u )
   MFIND
   IF (SEND)
   ELSE 2SWAP S" unknown" RECURSE
   THEN
;

: MFIND-ERR ( ta c-addr u - xt 1 | xt -1 | abort )
    MFIND ?DUP 0=
    IF
       ROT DUP S" unknown" SEND
    THEN
;

: SEND, ( a ta addr u )
   MFIND-ERR DROP SWAP LIT, LIT, POSTPONE (SEND)
;

: ALIGN-CUSTOM ( n -- )
\ выравивает CLASS@ на n
   OBJ-SIZE SWAP 2DUP MOD 
   DUP IF - + CLASS@ .size ! ELSE 2DROP DROP THEN
;

VARIABLE AlignFields?

: AlignDefs ( n -- )
   AlignFields? @ 0= IF DROP EXIT THEN
   
   DUP 1 = OVER 2 = OR IF DROP 2 ALIGN-CUSTOM EXIT THEN
   DUP 4 = SWAP 7 > OR IF 4 ALIGN-CUSTOM EXIT THEN
;

: AddOp
    HOLDS DROP R> DROP
;

: CompileOp ( n )
   DUP 8 = IF S" 2" AddOp THEN
   DUP 4 = IF DROP EXIT THEN
   DUP 2 = IF S" W" AddOp THEN
   DUP 1 = IF S" C" AddOp THEN         
   -1 ABORT" wrong size"
;

: CHOLD:
   CREATE 
     C,
   DOES> C@ HOLD 
;

CHAR ! CHOLD: !#
CHAR @ CHOLD: @#
BL     CHOLD: BL#

: CompileProperty ( n addr u )
   ROT >R
   <#
       S"  ;" HOLDS
       @# R@ CompileOp
       BL#
       2DUP HOLDS BL#
       @# 2DUP HOLDS
       S" : " HOLDS 
       BL#
       S"  ;" HOLDS
       !# R@ CompileOp
       BL#
       2DUP HOLDS BL#
       !# HOLDS
       S" : " HOLDS
       0.
   #> EVALUATE
   R> DROP
;

: TO-CONTEXT ( wl ) >R GET-ORDER R> SWAP 1+ SET-ORDER ;
: GET-CONTEXT ( -- wl ) GET-ORDER SWAP >R 1- 0 ?DO DROP LOOP R> ;

: METHODS ( ta) 
   DUP CLS ! .wl @ DUP SET-CURRENT
   TO-CONTEXT ;

CREATE FIRST-OBJCHAIN
0 ,
0 ,
0 ,

: (CLASS) ( n "c ")
   GET-CURRENT PREVIOUS-CURRENT ! 
   -1 AlignFields? !
   CREATE HERE 
   SWAP ALLOT
   DUP DUP .self !
   CELL OVER .size ! \ pointer to class
   WORDLIST OVER .wl !

   \ make this wordlist named for better debug output
   LATEST OVER .wl @ CELL+ !

   0 OVER .super !
   LATEST OVER .nfa !
   FIRST-OBJCHAIN OVER .objchain !
   METHODS 
;

: CLASS /class (CLASS) ;

: ;CLASS ( ) 
    CLASS@ DROP PREVIOUS PREVIOUS-CURRENT @ SET-CURRENT 
    4 ALIGN-CUSTOM \ for array of objects on data-align aware platforms
    0 CLS ! 
;

: ^ ( obj "word" )
   STATE @
   IF
     POSTPONE DUP
     POSTPONE @
     PARSE-NAME
     POSTPONE SLITERAL
     POSTPONE SEND
   ELSE DUP @ PARSE-NAME SEND
   THEN
; IMMEDIATE

: (') ( a addr u -- xt )
   2>R @ 2R>
   MFIND-ERR  ( xt n )
   DROP
;
: ^' ( obj "word" )
   BL PARSE
   STATE @
   IF
     POSTPONE SLITERAL
     POSTPONE (')
   ELSE (')
   THEN
; IMMEDIATE

: CLASS-HAS-NESTED-OBJECTS ( ta )
   .objchain @ FIRST-OBJCHAIN = 0=
;

\ For static objects we use only ^ dispose

: FreeNestedObjects ( obj ta )
    DUP CLASS-HAS-NESTED-OBJECTS
    IF
       OVER >R DUP .objchain
       BEGIN
         @ DUP @
       WHILE
         DUP CELL+ CELL+ @ ( size ) R@ +
         DUP @ FREE-XT @ EXECUTE THROW 0!
       REPEAT R> 2DROP 

       .super @ DUP
       IF
         RECURSE
       ELSE 2DROP
       THEN

    ELSE 2DROP
    THEN
;

: FreeObjWith ( obj xt )
    DUP FREE-XT !
    OVER ^ dispose
    OVER DUP @ FreeNestedObjects
    EXECUTE THROW
;

: AllocObjWith ( ta xt -- addr )
    OVER .size @ TUCK SWAP EXECUTE THROW ( ta size addr )
    TUCK SWAP ERASE
    TUCK !
;

: NewObjWith ( ta xt )
     DUP ALLOC-XT !
     AllocObjWith
     DUP ^ init
;

\ We can safely combine initializing and allocating steps

: INIT-OBJ-CHAIN ( a-chain )
   BEGIN
     @ DUP @
   WHILE
     DUP CELL+ @ ALLOC-XT @ NewObjWith ( obj )
     OVER CELL+ CELL+ @ SELF+ !
   REPEAT DROP
;

: OBJ@ ( obj-data -- obj )
   2 CELLS + @ SELF+ @
;

: DISPOSE-OBJ-CHAIN ( a-chain )
   BEGIN
     @ DUP @
   WHILE
     DUP OBJ@ ^ dispose
   REPEAT DROP
;

: INIT-SUBOBJECTS
   CLASS@ CLASS-HAS-NESTED-OBJECTS
   IF
      CLASS@ .objchain 
      POSTPONE LITERAL
      ['] INIT-OBJ-CHAIN COMPILE,
   THEN
; IMMEDIATE

: DISPOSE-SUBOBJECTS
   CLASS@ CLASS-HAS-NESTED-OBJECTS
   IF
      CLASS@ .objchain
      POSTPONE LITERAL
      ['] DISPOSE-OBJ-CHAIN COMPILE,
   THEN
; IMMEDIATE

: SUPER ( "m ")
   CLASS@ .super @ BL WORD COUNT MFIND-ERR 0<
   IF COMPILE, ELSE EXECUTE THEN ; IMMEDIATE

: init: S" : init HYPE::INIT-SUBOBJECTS SUPER init" EVALUATE ;

\ destructors are called in inverse order


VOCABULARY HypeDisposeVoc

GET-CURRENT ALSO HypeDisposeVoc DEFINITIONS

: ; S" HYPE::DISPOSE-SUBOBJECTS SUPER dispose " EVALUATE PREVIOUS S" ;" EVAL-WORD ; IMMEDIATE

PREVIOUS SET-CURRENT

: dispose: S" : dispose [ ALSO HypeDisposeVoc ] " EVALUATE ;

CLASS MetaClass

: this SELF ( -- obj ) ;
: class ( -- ta ) SELF @ ;
: isClass ( -- f ) class SELF = ;

: also ( -- ) SELF @ .wl @ TO-CONTEXT ;

\ save\load objects

: name ( -- addr u ) SELF @ .nfa @ COUNT ;

: size ( -- u ) SELF @ .size @ ;

: methods.
    SELF
    BEGIN
      @ DUP
    WHILE
      DUP ^ name <# [CHAR] : HOLD HOLDS S" Methods of " HOLDS 0. #> TYPE CR
      DUP .wl @ NLIST CR
      .super
    REPEAT DROP
;

: returnStack. ( n )
\ n cells to skip
    3 +
    ." OBJECTS RETURN STACK:" CR
    12 0 DO
       DUP I + CELLS RP+ @
       DUP NEAR_NFA DROP VocByNFA ?DUP
       IF VOC-NAME. ." ::" THEN
       WordByAddr TYPE CR
    LOOP DROP
;

: abort ( f addr u )
    ROT
    IF
       1 returnStack.
       <# R@ WordByAddr HOLDS [CHAR] . HOLD name HOLDS S"  in " HOLDS HOLDS 0. #>
       TUCK PAD SWAP CMOVE
       PAD SWAP
       ER-U ! ER-A ! -2 THROW
    ELSE 2DROP
    THEN
;

: unknown ( addr u )
    <# name HOLDS S"  in class " HOLDS HOLDS S" can't find method " HOLDS 0. #>
    TUCK PAD SWAP CMOVE PAD SWAP ER-U ! ER-A !
    -2 THROW
;

;CLASS

: (SUBCLASS)
    CLASS@ ( ta ca )
    OVER .size @ OVER .size !
    .super ! 
;

: SUBCLASS ( ta "c ") 
     CLASS (SUBCLASS)
;

MetaClass SUBCLASS ProtoObj

: init ;

: dispose ;

: freenested
\ FREE-XT should be set
    SELF DUP @ FreeNestedObjects
;

;CLASS

: DEFINED-IN-CLASS ( addr u ta )
    .wl @ SEARCH-WORDLIST DUP
    IF NIP THEN
;

: ZALLOT ( n -- addr ior )
    HERE OVER ALLOT ( n addr )
    TUCK SWAP ERASE 0
;

: CLASS-EMPTY-DISPOSE? ( ta -- f )
    S" dispose" MFIND-ERR DROP
    ProtoObj S" dispose" MFIND-ERR DROP =
;

EXPORT

: CLASS ProtoObj SUBCLASS ;

: SUBCLASS SUBCLASS ;

: DEFS ( n "f ")
   CREATE DUP AlignDefs OBJ-SIZE , CLASS@ .size +!
   DOES> @ SELF+
;

: PROPERTY ( n "f ")
   DUP >IN @ >R
   DEFS R> >IN !
   BL PARSE CompileProperty
;

: (send-obj) ( xt shift )
   SELF+ @ SWAP (SEND)
;

: (enter-subobject) ( shift -- R: prev-self )
   SELF SWAP SELF+ @ TO SELF
   R> SWAP >R >R
;

: (enter-subobject0) ( obj -- R: prev-self )
   SELF SWAP TO SELF
   R> SWAP >R >R
;

: (exit-subobject)
   R> R> TO SELF >R
;

\ with support of syntax: var var var prop

: OBJ-SEND, ( class shift addr u )
   2>R SWAP 2R> MFIND-ERR
   STATE @
   IF \ compilation
     -1 = ( shift xt )
     IF \ nonimmediate     
        LIT, LIT,
        ['] (send-obj) COMPILE,
     ELSE \ again object
          ( shift xt )
          SWAP LIT,
          ['] (enter-subobject) COMPILE,
          EXECUTE
          ['] (exit-subobject) COMPILE,
     THEN
   ELSE
     DROP SWAP (send-obj)
   THEN
;

: OBJ ( ta "f" )
   CREATE HERE IMMEDIATE
          CLASS@ .objchain @ , ( prev obj in chain )
          CLASS@ .objchain !
          , CELL AlignDefs OBJ-SIZE ,
          CELL CLASS@ .size +!
   DOES>  DUP CELL+ @ ( chain class )
          SWAP CELL+ CELL+ @ ( shift )
          PARSE-NAME OBJ-SEND,
;
 
: VAR 1 CELLS DEFS ;

: ;CLASS
    \ default constructor and destructor to initialize
     \ and destroy objects-attributes

    CLASS@ CLASS-HAS-NESTED-OBJECTS
    IF
        S" init" CLASS@ DEFINED-IN-CLASS 0=
        IF 
          S" init: ; " EVALUATE
        THEN

        S" dispose" CLASS@ DEFINED-IN-CLASS 0=
        IF 
          S" dispose: ; " EVALUATE
        THEN
    THEN
    ;CLASS
;

: CompileDeferredStatic ( a ta "name" )
    PARSE-NAME MFIND-ERR
    STATE @ 0=
    IF
       DROP (SEND)
    ELSE
       -1 = \ var or method
       IF
            LIT, POSTPONE (SEND)
       ELSE \ [obj] var-xt
            \ owner.child method
            >BODY CELL+ DUP @ ( class ) SWAP CELL+ @ LIT, ( shift )
            POSTPONE +
            POSTPONE @
            RECURSE
      THEN
    THEN
;

: :: ( obj "word" )
    [CHAR] . WORD FIND 0= IF ABORT" can't find class name!" THEN
    EXECUTE ( ta )
    CompileDeferredStatic
; IMMEDIATE

VOCABULARY HypeSupport

GET-CURRENT
ALSO HypeSupport DEFINITIONS

: }} PREVIOUS PREVIOUS ; IMMEDIATE

SET-CURRENT PREVIOUS

\ с with{ не работает subclassing !!!
: with{ ( " class" -- )
    ' EXECUTE .wl @
    ALSO HYPE
    TO-CONTEXT
; IMMEDIATE

\ Export some needed words
: OBJ-SIZE OBJ-SIZE ;

: ^ POSTPONE ^ ; IMMEDIATE

\ ^ is used in SPF4 locals
: => POSTPONE ^ ; IMMEDIATE

: SUPER POSTPONE SUPER ; IMMEDIATE

: init: init: ;
: dispose: dispose: ;

: SELF POSTPONE SELF ; IMMEDIATE

: NewObj ( ta -- addr )
    ['] ALLOCATE NewObjWith
;

: FreeObj ( obj )
    ['] FREE FreeObjWith
;

: NEW ( ta "name ")
    CREATE ['] ZALLOT NewObjWith DROP IMMEDIATE
    DOES> DUP @ ( fetch class ) 
          STATE @ 0= INVERT
          IF SWAP LIT,
          THEN
          CompileDeferredStatic
;

: HypeDisposeVoc HypeDisposeVoc ;


\ Methods inheritance

: INHERIT ( -- )
   SMUDGE
   LATEST COUNT 
   CLASS@ .super @ 
   ROT ROT MFIND-ERR DROP COMPILE,
   SMUDGE
; IMMEDIATE

: DoNotAlign
   0 AlignFields? !
;

;MODULE
