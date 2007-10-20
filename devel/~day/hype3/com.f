( export hype3 interfaces to automation, creation of COM objects )
\ (c) 2006 Dmitry Yakimov, support@activekitten.com

\ TODO: Semiautomatic compilation of typelib and c++ headers
\ ActiveX компонент

0 VALUE COM-TRACE

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS              ~day\hype3\hype3.f
NEEDS              ~day\hype3\locals.f
NEEDS               lib\win\winerr.f
NEEDS              ~ac\lib\win\registry2.f
NEEDS              ~day\common\link.f
NEEDS              ~day\hype3\lib\stack.f
NEEDS              ~day\lib\unicode.f

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
0x80004001  CONSTANT E_NOTIMPL
0x80020006  CONSTANT DISP_E_UNKNOWNNAME
0x8002000E  CONSTANT DISP_E_BADPARAMCOUNT
0x80020008  CONSTANT DISP_E_BADVARTYPE
0x80020009  CONSTANT DISP_E_EXCEPTION

-1 CONSTANT DISPID_UNKNOWN

WINAPI: CoRegisterClassObject OLE32.DLL
WINAPI: CoRevokeClassObject   OLE32.DLL
WINAPI: CoDisconnectObject    OLE32.DLl
WINAPI: CoCreateInstance      OLE32.DLL
WINAPI: MessageBoxA           USER32.DLL
WINAPI: CoGetClassObject      OLE32.DLL
WINAPI: InterlockedIncrement  KERNEL32.DLL
WINAPI: InterlockedDecrement   KERNEL32.DLL

WINAPI: VariantInit       OLEAUT32.DLL
WINAPI: VariantClear      OLEAUT32.DLL
WINAPI: VariantChangeType OLEAUT32.DLL
WINAPI: VariantCopy       OLEAUT32.DLL
WINAPI: SysAllocString    OLEAUT32.DLL
WINAPI: SysFreeString     OLEAUT32.DLL

: COM-THROW ( n -- )
    DUP S_OK = 0=
    IF
       WIN_ERROR DECODE-ERROR  ER-U ! ER-A ! -2 THROW
    ELSE DROP
    THEN
;

\ put log file near *.exe file
: STARTLOG2
  ENDLOG
  S" spf.log" +ModuleDirName  W/O     ( S: addr count attr -- )
  CREATE-FILE-SHARED  ( S: addr count attr -- handle ior )
  IF DROP
  ELSE TO H-STDLOG 
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
   (SEND)

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
CELL -- .instancesnumber \ number of instances created
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
    CLASS@ .instancesnumber 0!
    CLASS@ .vmt 0!

    PARSE-NAME DUP 0= ABORT" You should define com interface"
    OVER + 0 SWAP C!
    CLASS@ .clsid UUID:: >clsid
;

PREVIOUS
\ we should get ;CLASS from FORTH
: ;ICLASS
    HYPE:: FulfillVMT
    ;CLASS
;

ALSO HYPE

: METHOD
    ( we try to overload method? )
    GET-CURRENT @ ( last method of the class )
    COUNT CLASS@ MethodByName 0=

    CLASS@ .methodschain LINK,
    HERE >R
    /ichain ALLOT

    GET-CURRENT @ NAME> COMPROC R@ .xt !
    GET-CURRENT @ R@ .methodnfa !

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

: instances ( -- n )
    SELF @ .instancesnumber @
;

: unknown ( addr u )
    <# HOLDS S" can't find method " HOLDS 0. #>
    TUCK PAD SWAP CMOVE PAD SWAP ER-U ! ER-A !
    -2 THROW
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
    SELF @ .instancesnumber InterlockedIncrement DROP
; METHOD

: Release ( -- cnt )
\ Overload release in case you store object in some exotic storage
    refCount InterlockedDecrement
    SELF @ .instancesnumber InterlockedDecrement DROP

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
    THEN  COM-TRACE IF BL EMIT . ELSE DROP THEN S_OK
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
    childClass @ ^ clsid
    CoRegisterClassObject
;

: revokeLocalServer ( -- ior )
    registeredClassID @ DUP
    IF
       CoRevokeClassObject
    THEN
;

;ICLASS

VOCABULARY ENUM-VOC
GET-CURRENT ALSO ENUM-VOC DEFINITIONS

VARIABLE LastEnum

FALSE WARNING !

: = 
    PARSE-NAME 2DUP + 1- C@ 
    [CHAR] , = IF 1- THEN
    NOTFOUND LastEnum @ !
;

: NOTFOUND ( addr u -- )
    CREATED HERE LastEnum ! 0 ,
    DOES> @
;

: , ;

TRUE WARNING !


: { ;
: } PREVIOUS ;

SET-CURRENT PREVIOUS

: enum ( "name" )
    0 PARSE 2DROP
    ALSO ENUM-VOC
;

DECIMAL

enum VARENUM
    {	
    	VT_EMPTY	= 0,
	VT_NULL	= 1,
	VT_I2	= 2,
	VT_I4	= 3,
	VT_R4	= 4,
	VT_R8	= 5,
	VT_CY	= 6,
	VT_DATE	= 7,
	VT_BSTR	= 8,
	VT_DISPATCH	= 9,
	VT_ERROR	= 10,
	VT_BOOL	= 11,
	VT_VARIANT	= 12,
	VT_UNKNOWN	= 13,
	VT_DECIMAL	= 14,
	VT_I1	= 16,
	VT_UI1	= 17,
	VT_UI2	= 18,
	VT_UI4	= 19,
	VT_I8	= 20,
	VT_UI8	= 21,
	VT_INT	= 22,
	VT_UINT	= 23,
	VT_VOID	= 24,
	VT_HRESULT	= 25,
	VT_PTR	= 26,
	VT_SAFEARRAY	= 27,
	VT_CARRAY	= 28,
	VT_USERDEFINED	= 29,
	VT_LPSTR	= 30,
	VT_LPWSTR	= 31,
	VT_RECORD	= 36,
	VT_INT_PTR	= 37,
	VT_UINT_PTR	= 38,
	VT_FILETIME	= 64,
	VT_BLOB	= 65,
	VT_STREAM	= 66,
	VT_STORAGE	= 67,
	VT_STREAMED_OBJECT	= 68,
	VT_STORED_OBJECT	= 69,
	VT_BLOB_OBJECT	= 70,
	VT_CF	= 71,
	VT_CLSID	= 72,
	VT_VERSIONED_STREAM	= 73,
	VT_BSTR_BLOB	= 0xFFF,
	VT_VECTOR	= 0x1000,
	VT_ARRAY	= 0x2000,
	VT_BYREF	= 0x4000,
	VT_RESERVED	= 0x8000,
	VT_ILLEGAL	= 0xFFFF,
	VT_ILLEGALMASKED	= 0xFFF,
	VT_TYPEMASK	= 0xFFF
}

: W>S ( w -- s )
\ 16 -> 32
   DUP 0x8000 AND
   IF
      0xFFFF0000 OR
   THEN
;

1 CONSTANT DISPATCH_METHOD
0x2 CONSTANT DISPATCH_PROPERTYGET
0x4 CONSTANT DISPATCH_PROPERTYPUT
0x8 CONSTANT DISPATCH_PROPERTYPUTREF

: IsHypeProperty ( xt -- f )
   DUP C@ 0xE8 = \ call
   IF
      DUP 1+ @ + DUP DUP C@ 0xE8 =
      IF 1+ @ ['] (DOES1) SWAP CFL + - =
      ELSE 2DROP 0
      THEN
   ELSE DROP 0
   THEN
;


\ Variant variables
ProtoObj SUBCLASS ComVar
   0 DEFS addr
   2 DEFS type
   6 DEFS reserved
   8 DEFS value
   2 DEFS decimalPart

init: addr VariantInit ;

: set ( variant )
   addr VariantCopy COM-THROW
;

: objAddr
    value
    type W@ VT_BYREF AND
    IF @ THEN
;

: get ( addr-to -- )
    addr SWAP VariantCopy COM-THROW
;

dispose: addr VariantClear COM-THROW ;

;CLASS

ComVar SUBCLASS ComString
;CLASS

ComVar SUBCLASS ComInt

: @ SUPER objAddr @ ;
: ! SUPER objAddr ! ;

;CLASS

\ Forth method could override VT_BSTR and set its own type in VarType
 \ In this case a method should return an address of variant data (bstr and so on)
USER VarType

: BSTR> ( bstr -- addr2 u2 )
     -1 unicode>
;

: >BSTR ( addr u -- bstr )
     >unicode DROP DUP
     SysAllocString SWAP FREE THROW
;

: bool 0= 0= ;

ICLASS IDispatch {00020400-0000-0000-C000-000000000046}

     CStack OBJ strStack \ stack of strings to delete automagically
     ProtoObj OBJ objEtalon

: IsHypeObjectVar ( xt -- f )
     DUP C@ 0xE8 =
     IF
        DUP 1+ @ +
        ['] objEtalon DUP 1+ @ + =
     ELSE DROP 0
     THEN 
;

\ We do not provide type information yet
 \ To do it we need either to create type lib or to describe type info
  \ in a forth code

: GetTypeInfoCount ( pctinfo -- hresult )
     DUP 0= IF DROP E_INVALIDARG EXIT THEN
     0 SWAP ! S_OK
; METHOD

: GetTypeInfo   ( ppTInfo lcid iTInfo -- hresult )
     2DROP 0! E_NOTIMPL
; METHOD

: GetIDsOfNames  { rgDispId lcid cNames rgszNames riid \ result -- hresult }
\ in this version parameters of methods are omitted

     rgszNames @
     UUID:: unicode>buf DUP >R
     ASCIIZ> COM-TRACE IF ." GetIDsOfNames: " 2DUP TYPE THEN

     SELF @ ROT ROT MFIND
     0= IF 2DROP DROP DISPID_UNKNOWN DISP_E_UNKNOWNNAME -> result THEN

     rgDispId TUCK ! CELL+ -> rgDispId
     R> FREE THROW

     result
; METHOD

: vararg@ { p \ type fetch addr -- args }
     p W@
     DUP VT_BYREF AND 
     IF 
        VT_BYREF INVERT AND
        TRUE -> fetch
     THEN -> type

     p 2 CELLS + fetch IF @ THEN -> addr
     type VT_UI4 =
     type VT_I4  = OR
     type VT_INT = OR
     type VT_UINT = OR
     IF
         addr @ EXIT
     THEN

     type VT_R4 =
     IF addr @ DATA>FLOAT32 EXIT THEN

     type VT_R8 =
     IF addr 2@ SWAP DATA>FLOAT EXIT THEN

     type VT_I8 =
     type VT_UI8 = OR
     IF addr 2@ SWAP EXIT THEN

     type VT_UI2 =
     IF  addr W@ EXIT THEN

     type VT_I2 =
     type VT_BOOL = OR
     IF addr W@ W>S EXIT THEN

     type VT_UI1 = 
     IF addr C@ EXIT THEN

     type VT_I1 =
     IF addr C@ C>S EXIT THEN

     type VT_VARIANT =
     IF addr @ RECURSE EXIT THEN

     type VT_BSTR = 
     IF addr @ BSTR> OVER strStack push EXIT THEN
;

: varargs@ { p }
     p 2 CELLS + @ 0
     ?DO
        p @ I 4 * CELLS + vararg@
     LOOP
;

: freeStrings
     BEGIN
       strStack count@
     WHILE
       strStack pop FREE THROW
     REPEAT
;

: cleanupParams
     freeStrings
     BEGIN
        FDEPTH
     WHILE FDROP
     REPEAT
;

: Invoke  { puArgErr pExcepInfo pVarResult pDispParams wFlags lcid riid dispIdMember \ spInvoke -- hresult }

     \ Special case for hype3 object vars
     dispIdMember IsHypeObjectVar
     IF
        wFlags DISPATCH_METHOD AND bool
        wFlags DISPATCH_PROPERTYGET AND bool OR
        IF \ get variant
           pVarResult
           dispIdMember >BODY OBJ@ ( object )
           => get
        ELSE
           \ put first object in params@
           pDispParams @ dispIdMember >BODY OBJ@ => set
        THEN
        S_OK EXIT
     THEN

     0 VarType !
     SP@ DUP -> spInvoke  S0 !

     pDispParams varargs@

     dispIdMember CATCH ?DUP
     IF
        spInvoke SP!
        cleanupParams

        pExcepInfo W!
        dispIdMember WordByAddr 
        <# HOLDS [CHAR] : HOLD SUPER name HOLDS 0. #>
        >BSTR pExcepInfo CELL+ !
        DISP_E_EXCEPTION EXIT
     THEN

     cleanupParams

     \ variable?
     dispIdMember IsHypeProperty
     IF
        wFlags DISPATCH_METHOD AND bool
        wFlags DISPATCH_PROPERTYGET AND bool OR
        IF
            @ VT_I4 pVarResult W!
            pVarResult 2 CELLS + !
            spInvoke SP!
            S_OK EXIT           
        ELSE
            SP@ spInvoke -
            -8 =
            IF
               ! 
               spInvoke SP!
               S_OK  EXIT
            ELSE
                \ BSTR to forth variable
                NIP !
                spInvoke SP!
                S_OK EXIT
            THEN
        THEN
     ELSE \ Forth word
        wFlags DISPATCH_METHOD AND bool
        wFlags DISPATCH_PROPERTYGET AND bool OR
        IF
           SP@ spInvoke - DUP
           -4 =
           IF DROP 
              VarType @ ?DUP 0= IF VT_I4 THEN
              pVarResult W!
              pVarResult 2 CELLS + !
              spInvoke SP!
              S_OK EXIT
           THEN

           -8 =
           IF \ string or double
              VarType @ ?DUP 0= IF VT_BSTR THEN
              DUP pVarResult W!
              VT_BSTR =
              IF
                 >BSTR pVarResult 2 CELLS + !
              ELSE
                 SWAP pVarResult 2 CELLS + 2!
              THEN
              spInvoke SP!
              S_OK EXIT
           THEN
        THEN
     THEN

     \ Forth word
     SP@ spInvoke -
     0 = IF S_OK EXIT THEN

     spInvoke SP!
     DISP_E_BADPARAMCOUNT
; METHOD

;ICLASS

\ It will present in every server, so create it
IClassFactory NEW AppClassFactory

;MODULE

\EOF


lib\ext\disasm.f

CLASS Test 

  VAR prop
  CStack OBJ obj
  CStack OBJ objEtalon


: method WORDS ;

: testProp ['] prop IsHypeProperty . ;
: testMethod ['] method IsHypeProperty . ;

: testObj ['] obj IsHypeObjectVar .
     ['] objEtalon REST
;

;CLASS

\ Test ^ testProp
\ Test ^ testMethod
Test ^ testObj