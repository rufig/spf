( export hype3 interfaces to automation, creation of COM objects )
\ (c) 2006 Dmitry Yakimov, support@activekitten.com

( See example below )

\ TODO: Semiautomatic compilation of typelib and c++ headers
\ Реализовать IDispatch - как описывать информацию о типах?
\ ActiveX компонент
\ Inproc server in dll

0 VALUE COM-TRACE

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS              ~day\hype3\hype3.f
NEEDS              ~day\hype3\locals.f
NEEDS               lib\win\winerr.f
NEEDS              ~ac\lib\win\registry2.f
NEEDS              ~day\common\link.f

MODULE: UUID

NEEDS              ~yz/lib/UUID.f

;MODULE

NEEDS              ~day\hype3\lib\string.f

DECIMAL
       1 CONSTANT REGCLS_MULTIPLEUSE
       4 CONSTANT CLSCTX_LOCAL_SERVER
       1 CONSTANT CLSCTX_INPROC_SERVER 
      16 CONSTANT CLSCTX_REMOTE_SERVER
   65001 CONSTANT CP_UTF8

 CLSCTX_LOCAL_SERVER CLSCTX_INPROC_SERVER OR CLSCTX_REMOTE_SERVER OR
         CONSTANT CLSCTX_SERVER

0 CONSTANT S_OK
0x80070057L CONSTANT E_INVALIDARG
0x8000FFFFL CONSTANT E_UNEXPECTED
0x800401FCL CONSTANT CO_E_OBJISREG
0x800401F0  CONSTANT CO_E_NOTINITIALIZED
0x80040110  CONSTANT CLASS_E_NOAGGREGATION 
0x8007000E  CONSTANT E_OUTOFMEMORY

WINAPI: CoRegisterClassObject OLE32.DLL
WINAPI: CoRevokeClassObject   OLE32.DLL
WINAPI: CoDisconnectObject    OLE32.DLl
WINAPI: CoCreateInstance      OLE32.DLL
WINAPI: MessageBoxA           USER32.DLL
WINAPI: CoGetClassObject      OLE32.DLL
WINAPI: InterlockedIncrement  KERNEL32.DLL
WINAPI: InterlockedDecrement   KERNEL32.DLL

: COM-THROW ( n -- )
    DUP S_OK = 0=
    IF
       WIN_ERROR DECODE-ERROR  ER-U ! ER-A ! -2 THROW
    ELSE DROP
    THEN
;

WINAPI: CoInitializeEx   OLE32.DLL

: ComInitApartment ( -- ior )
    2 ( COINIT_APARTMENTTHREADED  )
    0 CoInitializeEx
;

MODULE: HYPE

\ Com object to forth object
: I>F
   CELL- CELL-
;

\ Forth object to Com object
: F>I
   CELL+ CELL+
;

: ComCall. ( obj xt )
   ." Called " SWAP ^ name TYPE S" ::" TYPE
   WordByAddr TYPE
;

: EnterComMethod ( x*i com-obj xt n -- ior )
   2 PICK CELL- @ ( threadUserData@ hack! ) TlsIndex!

   <SET-EXC-HANDLER>

   S0 @ >R
   SP@  + 2 CELLS + S0 ! \ We can guarantee 2 CELLS only
   >R I>F R> 
   
   COM-TRACE IF 2DUP ComCall. THEN
   SEND

   COM-TRACE IF ."  OK" CR THEN

   R> S0 !
;

: COMEXTERN ( xt1 n -- xt2 )
  HERE
  ROT LIT, \ xt
  SWAP LIT, \ n
  ['] EnterComMethod COMPILE,
  RET,
;

: COMPROC ( xt1 -- xt2 )
  CELL COMEXTERN
  HERE SWAP
  ['] _WNDPROC-CODE COMPILE,
  ,
;

( format of chain )
0
CELL -- .xt
CELL -- .methodnfa
2    -- .nmethod
CONSTANT /ichain

/class
CELL -- .vmt
CELL -- .methodscount
CELL -- .methodschain
  16 -- .clsid
CONSTANT /iclass

: vmt! ( node -- f )
   DUP .nmethod W@ CELLS CLASS@ .vmt @ +
   SWAP .xt @ SWAP ! 0
;

: fillVMT ( chain )
    @ DUP 0= 
    IF DROP EXIT 
    ELSE
       \ prevent overflow of data stack
       DUP CELL+ >R RECURSE
       R@ .xt @
       R> .nmethod W@ CELLS CLASS@ .vmt @ + !
    THEN
;

: FulfillVMT         
   \ create vmt
   CLASS@ .methodscount @
   HERE SWAP CELLS ALLOT
   CLASS@ .vmt !


   \ fill out vmt, in reverse order to handle overloaded methods
   CLASS@ .methodschain fillVMT
;

: HasInterface ( iid ta -- f )
    BEGIN
       2DUP .clsid UUID:: guid= IF 2DROP TRUE EXIT THEN
       .super @ DUP 0=
    UNTIL 2DROP FALSE
;

: (findmethod) ( addr u data -- n -1 | addr u 0 )
    >R 2DUP R@ .methodnfa @ COUNT COMPARE 0=
    IF 
       2DROP R> .nmethod W@ TRUE
    ELSE R> DROP 0
    THEN
;

: MethodByName ( addr u class -- n -1 | 0 )
    .methodschain ['] (findmethod) ITERATE-LIST2
    DUP 0= IF NIP NIP THEN
;

EXPORT

: ICLASS
    /iclass (CLASS)
    CLASS@ .methodscount 0!
    CLASS@ .methodschain 0!
    CLASS@ .vmt 0!

    PARSE-NAME DUP 0= ABORT" You should define com interface"
    OVER + 0 SWAP C!
    CLASS@ .clsid UUID:: >clsid
;

: ;ICLASS
    FulfillVMT
    ;CLASS
;

(
VOCABULARY VOC-VARIANTS
GET-CURRENT ALSO VOC-VARIANTS DEFINITIONS

ALSO objLocalsSupport

R: SUBCLASS BOOL
11 CONSTANT id
;CLASS

R: SUBCLASS char
10 CONSTANT id
;CLASS

R: SUBCLASS REFIID
13 CONSTANT id
;CLASS

R: SUBCLASS void**

;CLASS

: ; PREVIOUS S" ;" EVAL-WORD ; IMMEDIATE

SET-CURRENT PREVIOUS PREVIOUS

: I|
    POSTPONE ||
; IMMEDIATE
)

: METHOD
    ( we try to overload method? )
    LAST @ COUNT CLASS@ MethodByName 0=

    CLASS@ .methodschain LINK,
    HERE >R
    /ichain ALLOT

    LAST @ NAME> COMPROC R@ .xt !
    LAST @ R@ .methodnfa !

    IF  \ new method
       CLASS@ .methodscount DUP @ SWAP 1+!
    THEN R> .nmethod W!
;

ProtoObj SUBCLASS CComRegisterHelper

    CString OBJ threadingModel
    CString OBJ progID
    CString OBJ comment
    VAR inproc?
    VAR version

: setInproc ( -- ) TRUE inproc? ! ;
: setLocal FALSE inproc? ! ;

: setModel ( addr u ) threadingModel S! ;
: setProgID ( addr u ) progID S! ;
: setComment ( addr u ) comment S! ;
: setVersion ( n ) version ! ;

init:
    1 setVersion
    setLocal
;

: UHOLDS ( addr u )
    TUCK + SWAP 0 ?DO DUP I - 1- 0 HOLD C@ HOLD LOOP DROP
;

: register ( class ) 
    { class \ r h r2 }

    <# 
       PAD 100 class => clsidstr PAD SWAP 2* HOLDS 
       S" CLSID\" UHOLDS 0. #> DROP 
    UUID:: unicode>buf DUP >R ASCIIZ>

    HKEY_CLASSES_ROOT
    RG_CreateKey THROW -> r

    progID @ STR@ HKEY_CLASSES_ROOT
    RG_CreateKey THROW -> r2

    inproc? @ 0=
    IF
       S" LocalServer32"
    ELSE S" InprocServer32"
    THEN
    r RG_CreateKey THROW -> h

    256 PAD 0 GetModuleFileNameA PAD SWAP
    REG_SZ S" "
    h RG_SetValue

    threadingModel @ STR@
    REG_SZ
    S" ThreadingModel" h RG_SetValue

    h RegCloseKey DROP

    S" ProgID" r RG_CreateKey THROW -> h
    BASE @ >R DECIMAL
    version @ S>D <# #S 2DROP [CHAR] . HOLD progID @ STR@ HOLDS 0. #> 2DUP
    R> BASE !
    REG_SZ S" "
    h RG_SetValue
    h RegCloseKey DROP

    S" CurVer" r2 RG_CreateKey THROW -> h
    REG_SZ S" "
    h RG_SetValue
    h RegCloseKey DROP

    <# 
       PAD 100 class => clsidstr PAD SWAP 2* HOLDS 0. #> DROP
    UUID:: unicode>buf DUP >R ASCIIZ> \ clsid

    S" CLSID" r2 RG_CreateKey THROW -> h
    REG_SZ S" "
    h RG_SetValue
    h RegCloseKey DROP

    S" VersionIndependentProgID" r RG_CreateKey THROW -> h
    progID @ STR@ REG_SZ S" "
    h RG_SetValue
    h RegCloseKey DROP

    comment @ STR@ 2DUP
    REG_SZ S" " r  RG_SetValue
    REG_SZ S" " r2 RG_SetValue 

    r r2 SELF => registerCustom

    R> FREE THROW
    R> FREE THROW
    r2 RegCloseKey DROP
    r RegCloseKey DROP
;

: registerCustom ( h1 h2 )
    2DROP
;

;CLASS

ICLASS CComBase {00000000-0000-0000-0000-000000000000}
    \ Should be in this order
    VAR threadUserData \ memory context, it is used in EnterComMethod
    VAR vmt             \ vmt gives us addr of COM object

: init
    TlsIndex@ threadUserData !
    SELF @ .vmt @ vmt !
;

: clsid ( -- clsid )
    SELF @ .clsid
;

: iself ( -- com-object )
    vmt
;

: this SELF ( -- obj ) ;
: class ( -- ta ) SELF @ ;
: isClass ( -- f ) class SELF = ;

: also ( -- ) SELF @ .wl @ TO-CONTEXT ;

\ save\load objects

: name ( -- addr u ) SELF @ .nfa @ COUNT ;

: size ( -- u ) SELF @ .size @ ;

: vmt.
    ." vmt of class " SELF @ .nfa @ COUNT TYPE CR
    BASE @ HEX

    SELF @ .vmt @
    SELF @ .methodscount @ 0
    ?DO
       DUP I CELLS + @ ." method " . CR
    LOOP  DROP BASE !
;

: dispose ;

: freenested
\ FREE-XT should be set
    SELF DUP @ FreeNestedObjects
;

: clsidstr ( addr u -- u1 )
    SWAP clsid UUID:: StringFromGUID2
;

;ICLASS

: ISUBCLASS
    ICLASS DUP (SUBCLASS)
    DUP .methodschain @ CLASS@ .methodschain !
    .methodscount @ CLASS@ .methodscount !
;

CComBase ISUBCLASS IUnknown {00000000-0000-0000-C000-000000000046}

    VAR refCount

: QueryInterface ( ppvObject iid - hresult )
\    I| REFIID iid void** ppvObj |

     DUP 0= OVER 0= OR IF 2DROP E_INVALIDARG EXIT THEN

     COM-TRACE IF ." , asked for interface " DUP UUID:: .guid THEN
     SELF @ HasInterface  COM-TRACE IF DUP 0= IF ."  - not" THEN ."  found" THEN
     IF
        SUPER iself SWAP !
        SELF ^ AddRef DROP S_OK
     ELSE 0! UUID:: E_NOINTERFACE
     THEN
; METHOD

: AddRef ( -- cnt )
    refCount InterlockedIncrement
; METHOD

: Release ( -- cnt )
\ Overload release in case you store object in some exotic storage
    refCount InterlockedDecrement

    0= 
    IF
       \ in forth vocabulary?
       SELF DUP IMAGE-BASE HERE WITHIN 0=
       IF
          FreeObj
       ELSE ^ dispose
       THEN
    THEN

    COM-TRACE IF BL EMIT refCount @ . THEN
    refCount @
; METHOD

;ICLASS

: ICLASS IUnknown ISUBCLASS ;

ICLASS IClassFactory {00000001-0000-0000-C000-000000000046}

	VAR lockCount
	VAR registeredClassID
	VAR childClass
		
: CreateInstance ( ppvObject riid pUnkOuter -- hresult )
    IF 2DROP CLASS_E_NOAGGREGATION EXIT THEN
    DUP 0= OVER 0= OR IF 2DROP E_INVALIDARG EXIT THEN

    OVER 0!
    \ find class
    DUP childClass @ HasInterface
    IF
       childClass @ ['] NewObj CATCH 0= ( obj f )
       IF
          ^ QueryInterface
       ELSE 2DROP E_OUTOFMEMORY
       THEN
    ELSE 2DROP UUID:: E_NOINTERFACE
    THEN
; METHOD

: LockServer ( fLock -- hresult )
    lockCount SWAP
    IF InterlockedIncrement 
    ELSE InterlockedDecrement
    THEN  DROP S_OK
; METHOD

: setClass ( hype-class )
    IUnknown .clsid OVER
    HasInterface 0= ABORT" COM interface required"
    childClass !
;

: registerLocalServer ( -- ior )
    registeredClassID
    REGCLS_MULTIPLEUSE
    CLSCTX_LOCAL_SERVER
    SUPER iself  \ Pointer to the IUnknown interface of class factory
    SUPER clsid   \ CLSID to be registered
    CoRegisterClassObject
;

: revokeLocalServer ( -- ior )
    registeredClassID @ DUP
    IF
       CoRevokeClassObject
    THEN
;

;ICLASS

ICLASS IDispatch {00020400-0000-0000-C000-000000000046}


: GetTypeInfoCount ( pctinfo -- hresult )
     DUP 0= IF DROP E_INVALIDARG EXIT THEN
     1 SWAP ! S_OK
; METHOD

: GetTypeInfo   ( ppTInfo lcid iTInfo -- hresult )
     NIP
     OVER 0!
\     0 = 0= IF DROP DISP_E_BADINDEX THEN
     DUP 0= IF DROP E_INVALIDARG EXIT THEN
 \    typeInfo addRef DROP
  \   typeInfo iself SWAP !
     S_OK
; METHOD

: GetIDsOfNames ( rgDispId lcid cNames rgszNames riid -- hresult )
     DROP

     
; METHOD

: Invoke        ( puArgErr pExcepInfo pVarResult pDispParams wFlags lcid riid dispIdMember -- hresult )
; METHOD

;ICLASS

\ It will present in every server, so create it
IClassFactory NEW AppClassFactory

;MODULE
