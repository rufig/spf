\ 07.02.2000 А.Черезов
\ ------------------- пример реализации методов интерфейсов ----------------

REQUIRE CreateObject ~ac/lib/win/com/com.f

VARIABLE ForthComClassObject

\ реализованные интерфейсы (эти переменные [адреса] можно отдавать там, где требуется указатель интерфейса )
VARIABLE ForthIClassFactory
VARIABLE ForthIUnknown
VARIABLE ForthIForth

CREATE ForthComGUID  0 , 0 , 0 , 0 ,

VARIABLE FCNT


: (FQueryInterface) ( ppvObject iid oid - hresult )
  OVER 16 IID_IUnknown 16 COMPARE 0= 
          IF ." QI:IUnknown," 2DROP ForthIUnknown SWAP ! 0 EXIT THEN
  OVER 16 IID_IClassFactory 16 COMPARE 0= 
          IF ." QI:IClassFactory," 2DROP ForthIClassFactory SWAP ! 0 EXIT THEN
  OVER 16 ForthComGUID 16 COMPARE 0= 
          IF ." QI:IForth," 2DROP ForthIForth SWAP ! 0 EXIT THEN
  ." QI:"
\  . 16 DUMP . ." ;" 
  DROP CLSID>String THROW UNICODE> TYPE ." ;" 0!
  E_NOINTERFACE
;
' (FQueryInterface) WNDPROC: FQueryInterface

: (FAddRef) ( oid -- cnt )
  ." AR," 
  DROP FCNT 1+! FCNT @
;
' (FAddRef) WNDPROC: FAddRef

: (FRelease) ( oid -- cnt )
  ." RR," 
  DROP FCNT @ 1- DUP FCNT !
;
' (FRelease) WNDPROC: FRelease

: (FCreateInstance) ( ppvObject riid pUnkOuter oid -- hresult )
  ." CI," 
\   . . 16 DUMP . ." ;" -1
  NIP NIP SWAP ! 0
;
' (FCreateInstance) WNDPROC: FCreateInstance

VARIABLE LOCKCNT

: (FLockServer) ( fLock oid -- hresult )
  ." LS,"
  DROP
  IF LOCKCNT 1+! ELSE LOCKCNT @ 1- LOCKCNT ! THEN
  0
;
' (FLockServer) WNDPROC: FLockServer

: (FStub) ( -- 0 )
  ." It calls me! " 0
;
' (FStub) WNDPROC: FStub

CREATE ForthVTable
' FQueryInterface ,         \ методы интерфейса IUnknown
' FAddRef ,
' FRelease ,

' FCreateInstance ,         \ методы интерфейса IClassFactory
' FLockServer ,

' FStub ,
' FStub ,
' FStub ,
' FStub ,
' FStub ,
' FStub ,
' FStub ,
0 ,

ForthVTable ForthIUnknown !
ForthVTable ForthIClassFactory !
ForthVTable ForthIForth !


: ComRegisterForth ( -- ior )
  ForthComGUID ComGetForthGUID
  ForthComClassObject
  REGCLS_MULTIPLEUSE
  CLSCTX_LOCAL_SERVER
  ForthIUnknown
  ForthComGUID
  CoRegisterClassObject
;
VARIABLE ForthComInterface

: ComConnectToForth1 ( -- ior )
  ForthComGUID ComGetForthGUID
  ForthComInterface
  ForthComGUID \ iid
  CLSCTX_LOCAL_SERVER
  0 \ outer
  ForthComGUID
  CoCreateInstance ( это вызывает на сервере IClassFactory.CreateInstance)
;
: ComConnectToForth ( -- ior )
  ForthComGUID ComGetForthGUID
  ForthComInterface
  IID_IClassFactory \ iid
  0 \ server
  CLSCTX_LOCAL_SERVER
  ForthComGUID
  CoGetClassObject ( это вызывает на сервере LockServer, но не CreateInstance)
;

: TEST
  ComInit 0=
  IF
    ComRegisterForth HEX U. DECIMAL
  THEN
;
: TEST2
  ComInit 0=
  IF
    ComConnectToForth HEX U. ForthComInterface @ U.
  THEN
;
