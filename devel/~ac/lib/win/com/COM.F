( ������ � COM/DCOM, OLE, ActiveX )
( �.������� 4.02.2000 )

REQUIRE >UNICODE ~ac/lib/win/utf8.f 

WINAPI: CoInitializeEx        OLE32.DLL
WINAPI: CoUninitialize        OLE32.DLL
WINAPI: CoCreateGuid          OLE32.DLL
WINAPI: StringFromCLSID       OLE32.DLL
WINAPI: CLSIDFromString       OLE32.DLL
WINAPI: CLSIDFromProgID       OLE32.DLL
WINAPI: CoRegisterClassObject OLE32.DLL
WINAPI: CoCreateInstance      OLE32.DLL
WINAPI: CoGetClassObject      OLE32.DLL
WINAPI: SysAllocString        OLEAUT32.DLL
WINAPI: SysFreeString         OLEAUT32.DLL

HEX
80004002 CONSTANT E_NOINTERFACE
DECIMAL
       1 CONSTANT REGCLS_MULTIPLEUSE
       4 CONSTANT CLSCTX_LOCAL_SERVER
       1 CONSTANT CLSCTX_INPROC_SERVER 
      16 CONSTANT CLSCTX_REMOTE_SERVER

 CLSCTX_LOCAL_SERVER CLSCTX_INPROC_SERVER OR CLSCTX_REMOTE_SERVER OR
         CONSTANT CLSCTX_SERVER

: UASCIIZ> ( addr -- addr u ) \ ������� ASCIIZ> ��� Unicode
  0 OVER
  BEGIN
    DUP W@ 0<>
  WHILE
    2+ SWAP 1+ SWAP
  REPEAT DROP 2*
;
: >BSTR ( addr u -- bstr )
  >UNICODE DROP SysAllocString
;
: BSTR> ( bstr -- addr2 u2 )
  DUP 0= IF DROP S" " UNICODE> EXIT THEN \ ������ ������ ���������� � ��������� VT_0x400B
  DUP 4 - @ UNICODE>
;
: ComInit ( -- ior )
  0 0 CoInitializeEx
;
: ComInitAp ( -- ior ) \ COINIT_APARTMENTTHREADED
  2 0 CoInitializeEx
;
: ComExit ( -- )
  CoUninitialize DROP \ void
;
: ComCreateGUID ( GUIaddr -- ior )
  CoCreateGuid
;
: CLSID>String ( GUIaddr -- addr u ior )
  0 >R RP@ SWAP StringFromCLSID
  R> UASCIIZ> ROT
;
: String>CLSID ( addr u -- addr2 ior )
  DROP 16 ALLOCATE THROW DUP >R SWAP CLSIDFromString R> SWAP
;
: ProgID>CLSID ( addr u -- addr2 ior )
  DROP 16 ALLOCATE THROW DUP >R SWAP CLSIDFromProgID R> SWAP
;
: CLSID, ( addr u -- )
  >UNICODE String>CLSID THROW >R
  R@ HERE 16 DUP ALLOT MOVE R> FREE THROW
;
: ComGetForthGUID ( addr -- )
  S" {C6DFBA32-DF7B-4829-AA3B-EE4F90ED5961}" \ ������������ �� ���� ������
  >UNICODE OVER >R
  String>CLSID THROW DUP >R SWAP 16 MOVE R> FREE THROW R> FREE THROW
;
: InvokeMethod ( parameters interface_pointer method_number -- result )
  \ interface_pointer, �� �� oid, ����� ������������ ������ ���������� ������
  \ ��� � C++
  CELLS OVER @ + @ API-CALL
;

VARIABLE INTERFACES

: Methods# ( interface_id -- n )
  20 + @
;
: Methods#! ( n interface_id -- )
  20 + !
;
: Interface: ( parent_interface "name" "clsid" -- interface_id n )
  CREATE 
    HERE SWAP
    BL WORD COUNT CLSID, 
    DUP ,               \ ������
    Methods#            \ �-�� ������� ������
    DUP ,               \ ���� ������ (�-��)
    LATEST-NAME NAME>CSTRING ,       \ ��� ���
    HERE INTERFACES @ , INTERFACES ! \ ����������� � ������
;

: Interface; 2DROP ;

VARIABLE METHODS

: Method: ( interface_id n "name" -- interface_id n+1 )
  CREATE 
    DUP , 1+    \ ����� ������ � VTBL
    2DUP SWAP Methods#!
    OVER ,      \ ������ �� ���������, � ������� ��������� �����
    LATEST-NAME NAME>CSTRING , \ ��� ������
    HERE METHODS @ , METHODS ! \ ����������� � ������
  DOES> @ InvokeMethod
;

\ S" WordPad.Document.1" CreateObject THROW -> WPDOC  WPDOC ::Release - �������� ������� (� ������� ��� ������� wordpad.exe)

\ IDispatch interface


CREATE IID_NULL  S" {00000000-0000-0000-0000-000000000000}" CLSID, 0 , 0 , 0 ,

IID_NULL 
Interface: IID_IUnknown {00000000-0000-0000-C000-000000000046}
  Method: ::QueryInterface   ( ppvObj riid oid -- hresult )
  Method: ::AddRef           ( oid -- cnt )
  Method: ::Release          ( oid -- cnt )
Interface;

IID_IUnknown
Interface: IID_IClassFactory {00000001-0000-0000-C000-000000000046}
  Method: ::CreateInstance   ( ppvObj riid pUnkOuter oid -- hresult )
  Method: ::LockServer       ( fLock oid -- hresult )
Interface;

IID_IUnknown
Interface: IID_IDispatch {00020400-0000-0000-C000-000000000046}
  Method: ::GetTypeInfoCount ( pctinfo oid -- 0 | 1 )
  Method: ::GetTypeInfo      ( ppTInfo lcid iTInfo oid -- hresult )
  Method: ::GetIDsOfNames    ( rgDispId lcid cNames rgszNames riid oid -- hresult )
  Method: ::Invoke           ( puArgErr pExcepInfo pVarResult pDispParams wFlags lcid riid dispIdMember oid -- hresult )
\  Method: ::RemoteInvoke ( ��� � ��� ����? 8-O ����� 3.03.2002 ~ac)
Interface;

\ IID_IUnknown
\ Interface: IID_IMarshal {00000003-0000-0000-C000-000000000046}
\   Method: ::GetUnmarshalClass
\   Method: ::GetMarshalSizeMax
\   Method: ::MarshalInterface
\   Method: ::UnmarshalInterface
\   Method: ::ReleaseMarshalData
\   Method: ::DisconnectObject
\ Interface;
\ �� ����� ����������� ��������� IMarshal, ����� Windows ��� � ��� ��������� :)

( ��� �������� ������� Win2000 ����� �������� ��������� ����������
  IStdMarshalInfo, IExternalConnection, � ����������� � ������ ������ 1B..)

: CreateObject ( addr u -- oid ior ) 
  \ addr u - ��� ���������, ��������� ��������� �������
  \ �������� S" WordPad.Document.1" CreateObject THROW -> WPDOC
  OVER C@ [CHAR] { = >R
  >UNICODE 
  R> IF   String>CLSID ?DUP IF EXIT THEN
     ELSE ProgID>CLSID ?DUP IF EXIT THEN THEN
  0 >R RP@ SWAP >R
  IID_IUnknown  \ ��� ActiveX ������� ���� �� ����� ������� IDispatch, �� �� �� � ���� ����
  CLSCTX_SERVER
  0 \ outer
  R>
  CoCreateInstance ( ��� �������� �� ������� IClassFactory.CreateInstance)
  R> SWAP
;
: CreateClass ( addr u -- oid ior )
  >UNICODE ProgID>CLSID ?DUP IF EXIT THEN
  0 >R RP@ SWAP >R
  IID_IUnknown  \ ��� �������� �������� ������� ���� �� ����� ������� IClassFactory, �� �� �� � ���� ����
  0
  CLSCTX_SERVER
  R>
  CoGetClassObject
  R> SWAP
;

: GetIDispatch ( oid -- idispatch ior )
  0 >R RP@ IID_IDispatch ROT ::QueryInterface R> SWAP
;
: GetIdOfName ( idisp addr u -- n ior )
  >UNICODE DROP >R RP@
  0 >R RP@
  ROT >R
  SWAP 0 ( LOCALE_SYSTEM_DEFAULT) 1 ROT IID_NULL R> ::GetIDsOfNames
  R> SWAP R> FREE THROW
;

\ ���, ���������� ������ ��� ������ ��������� dispID
\ �� �� ������ �������� ���� � ������ �������� :)
\ � �����, ��������, ��������
\ ������ ��. � variant.f

\ : InvokeNamedMethod ( params idisp addr u -- results )
\   2>R DUP 2R> GetIdOfName THROW ( params idisp n )
\   65535 AND \ ���� ������������� ��� - �� ������, � property, �� ��� ��� �����
\   6 + InvokeMethod \ 6 - ����� ���������� ������ � IDispatch
\ ;
