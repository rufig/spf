( export hype3 interfaces to automation, creation of COM objects )
\ (c) 2006 Dmitry Yakimov, support@activekitten.com

( See example below )

\ TODO: Semiautomatic compilation of typelib and c++ headers
\ Разбор inproc \ outproc сервера
\ Реализовать IDispatch
\ ActiveX компонент

0 VALUE COM-TRACE

REQUIRE HYPE          ~day\hype3\hype3.f
REQUIRE WTHROW         lib\win\winerr.f
REQUIRE INHERIT-CHAIN ~day\common\link.f
REQUIRE InsertNodeEnd ~day\lib\staticlist.f

MODULE: UUID

S" ~yz/lib/UUID.f" INCLUDED

;MODULE

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
   ." Called " WordByAddr TYPE ."  of class "
   ^ name TYPE
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
 
/node
CELL -- .xt
CONSTANT /mlist

/class
CELL -- .vmt
CELL -- .methodscount
  16 -- .clsid
CONSTANT /iclass

USER-VALUE mlist
USER VMT-ADDR

: vmt! ( node )
   .xt @  VMT-ADDR @ !
   CELL VMT-ADDR +!
;

: FulfillVMT
   \ get size of parent vmt
   CLASS@ .super @ DUP
   IF
      .methodscount @
   THEN DUP >R
        
   \ create vmt
   CLASS@ .methodscount @ +
   HERE SWAP CELLS ALLOT
   CLASS@ .vmt !

   \ fix count of methods
   R@ CLASS@ .methodscount +!

   \ copy parent's vmt
   R@
   IF ( super-vmt-size )
      CLASS@ .super @ .vmt @
      CLASS@ .vmt @ R@ CELLS MOVE
   THEN
   HEX

   \ fill out vmt
   CLASS@ .vmt @ R> CELLS + VMT-ADDR !
   ['] vmt! mlist ForEach DECIMAL
;

: HasInterface ( iid ta -- f )
    BEGIN
       2DUP .clsid UUID:: guid= IF 2DROP TRUE EXIT THEN
       .super @ DUP 0=
    UNTIL 2DROP FALSE
;

EXPORT

: ICLASS
    /iclass (CLASS)
    CLASS@ .methodscount 0!
    CLASS@ .vmt 0!
    /mlist CreateList TO mlist

    PARSE-NAME DUP 0= ABORT" You should define com interface"
    OVER + 0 SWAP C!
    CLASS@ .clsid UUID:: >clsid
;

: ;ICLASS
    FulfillVMT
    mlist FreeList
    mlist FREE THROW
    ;CLASS
;

: METHOD
    LAST @ NAME> COMPROC mlist AllocateNodeEnd .xt !
    1 CLASS@ .methodscount +!
;


ICLASS IUnknown {00000000-0000-0000-C000-000000000046}

    \ Should be in this order
    VAR threadUserData \ memory context, it is used in EnterComMethod
    VAR vmt             \ vmt gives us addr of COM object
    VAR refCount

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

: also ( -- ) SELF @ .wl @ ALSO TO-CONTEXT ;

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

: QueryInterface ( ppvObject iid - hresult )
     COM-TRACE IF ." , asked for interface " DUP UUID:: .guid THEN
     SELF @ HasInterface  COM-TRACE IF DUP 0= IF ."  - not" THEN ."  found" THEN
     IF
        iself SWAP !
        SELF ^ AddRef DROP S_OK
     ELSE 0! UUID:: E_NOINTERFACE
     THEN
; METHOD

: AddRef ( -- cnt )
    refCount DUP @ 1+ TUCK SWAP !
; METHOD

: Release ( -- cnt )
\ Overload release in case you store object in some exotic storage
    refCount @ 1- refCount !

    refCount @ 0= 
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


: ISUBCLASS
    ICLASS (SUBCLASS)
;

: ICLASS IUnknown ISUBCLASS ;

\ All instances should be static!

ICLASS IClassFactory {00000001-0000-0000-C000-000000000046}

VARIABLE lockCount

    VAR registeredClassID

CHAIN childClasses

: (findClass) ( riid a-class -- riid 0 | riid class -1 )
    @ 2DUP HasInterface
    IF
       TRUE
    ELSE DROP
    THEN
(
    @ 2DUP .clsid UUID:: guid=
    IF
       TRUE
    ELSE DROP 0
    THEN )
;

: CreateInstance ( ppvObject riid pUnkOuter -- hresult )
    IF 2DROP CLASS_E_NOAGGREGATION EXIT THEN
    OVER 0!
    \ find class
    childClasses ['] (findClass) ITERATE-LIST2
    IF
       ['] NewObj CATCH 0= ( obj f )
       IF
          ^ QueryInterface
       ELSE 2DROP E_OUTOFMEMORY
       THEN
    ELSE 2DROP UUID:: E_NOINTERFACE
    THEN
; METHOD

: LockServer ( fLock -- hresult )
    IF 1 ELSE -1 THEN
    lockCount +! S_OK
; METHOD

: addClass ( hype-class )
    IUnknown .clsid OVER
    HasInterface 0= ABORT" COM interface required"
    childClasses LINK, ,
;

: registerLocalServer ( -- ior )
    registeredClassID
    REGCLS_MULTIPLEUSE
    CLSCTX_LOCAL_SERVER
    SUPER iself  \ Pointer to the IUnknown interface 
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

: GetTypeInfoCount ( pctinfo -- 0 | 1 )
; METHOD

: GetTypeInfo   ( ppTInfo lcid iTInfo -- hresult )
; METHOD

: GetIDsOfNames ( rgDispId lcid cNames rgszNames riid -- hresult )
; METHOD

: Invoke        ( puArgErr pExcepInfo pVarResult pDispParams wFlags lcid riid dispIdMember -- hresult )
; METHOD

;ICLASS

\ global object, always should be static
IClassFactory NEW AppClassFactory

IUnknown ISUBCLASS IForth {9F7A5561-8BD8-4B0D-93EC-A79A19C99330}

: Test ." Test method called" S_OK ; METHOD

: Evaluate ( ppRetVal rgszString -- hresult )
     PAD SWAP UUID:: unicode>
     PAD ASCIIZ> EVALUATE SWAP ! S_OK
; METHOD

;ICLASS

: COM-THROW ( n -- )
    DUP S_OK = 0=
    IF
       WIN_ERROR DECODE-ERROR  ER-U ! ER-A ! -2 THROW
    ELSE DROP
    THEN
;

;MODULE

\EOF ( Example )
\ TRUE TO COM-TRACE

UUID:: ComInit COM-THROW

IForth AppClassFactory addClass
AppClassFactory registerLocalServer COM-THROW
.( Local com server registered OK ) CR

VARIABLE vClass

: GetClassObject ( -- ior )
    vClass
    AppClassFactory clsid
    0
    CLSCTX_LOCAL_SERVER
    AppClassFactory clsid
    CoGetClassObject
;

WARNING 0!
REQUIRE IID_NULL ~ac\lib\win\com\com.f

IID_IUnknown Interface: IID_Forth {9F7A5561-8BD8-4B0D-93EC-A79A19C99330}
    Method: ::Test ( -- hresult )
Interface;

VARIABLE vForth

CR 
.( Create instance of IForth manually ) CR
GetClassObject COM-THROW

.( Got class ) vClass @ . .( AppClassFactory object is ) AppClassFactory iself . CR
vForth IForth ^ clsid 0 vClass @ ::CreateInstance COM-THROW

.( Call test method: )
vForth @ ::Test COM-THROW

CR .( Delete created object )
vForth @ ::Release COM-THROW
vForth 0!

CR .( Create instance of IForth via CoCreateInstance ) CR

: CreateForthInstance ( -- ior )
    vForth    
    \ IForth ^ clsid
    IUnknown ^ clsid \ Why IForth does not work here?
    CLSCTX_LOCAL_SERVER
    0
    AppClassFactory clsid
    CoCreateInstance
;

CreateForthInstance COM-THROW

.( Call test method: )
vForth @ ::Test COM-THROW

CR .( Delete created object )
vForth @ ::Release COM-THROW
vForth 0!

AppClassFactory revokeLocalServer COM-THROW .( Local server destroyed OK )
