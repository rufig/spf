WARNING 0!
\ --------- пример ActiveX-сервера ----------------
\ см. исходный вариант samples\com-sample4.f

REQUIRE Class: ~ac/lib/win/com/com_server.f

VARIABLE ForthComClassObject

VARIABLE FCNT
VARIABLE LOCKCNT

VECT vSPF.Application
VECT vSPF.IDispatch


\ ===================== базовый класс IUnknown ========================
IID_IUnknown
Class: SPF.IUnknown {C6DFBA32-DF7B-4829-AA3B-EE4F90ED5961}

: ::QueryInterface ( ppvObject iid oid - hresult )
\  Class.
  OVER 16 IID_IUnknown 16 COMPARE 0= 
          IF ( ." QI:Unknown,") 2DROP SPF.IUnknown SWAP ! 0 EXIT THEN
  OVER 16 IID_IClassFactory 16 COMPARE 0= 
          IF ( ." QI:IClassFactory,") 2DROP vSPF.Application SWAP ! 0 EXIT THEN
  OVER 16 IID_IDispatch 16 COMPARE 0= 
          IF ( ." QI:IDispatch,") 2DROP vSPF.IDispatch SWAP ! 0 EXIT THEN
  OVER 16 vSPF.Application Class 16 COMPARE 0= 
          IF ( ." QI:IForth,") 2DROP vSPF.Application SWAP ! 0 EXIT THEN
\  ." QI:"
  DROP CLSID>String THROW 2DROP ( UNICODE> TYPE ." ;") 0!
  E_NOINTERFACE
; METHOD

: ::AddRef ( oid -- cnt )
\  Class.
  DROP FCNT 1+! FCNT @
; METHOD

: ::Release ( oid -- cnt )
\  Class.
  DROP FCNT @ 1- DUP FCNT !
; METHOD

Class;

\ ===================== IClassFactory ===================================
IID_IClassFactory
Class: SPF.Application {C6DFBA32-DF7B-4829-AA3B-EE4F90ED5961}
Extends SPF.IUnknown


: ::CreateInstance ( ppvObject riid pUnkOuter oid -- hresult )
\  Class.
  DROP DROP DROP ( ForthIForth) SPF.Application SWAP ! 0
; METHOD

: ::LockServer ( fLock oid -- hresult )
\  Class.
  DROP
  IF LOCKCNT 1+! ELSE LOCKCNT @ 1- LOCKCNT ! THEN
  0
; METHOD

Class;

' SPF.Application TO vSPF.Application

USER uParams
USER uSPInvoke
USER uExcep
USER uFlags

: param@ ( variant -- ... )
\ переданные по ссылке переменные (обычный FORTH.NEGATE(VAR)) рекурсивно
\ разворачиваются, как если бы были переданы значения.
\ Это лишает некоторых возможностей, но зато логически чище,
\ и удобнее использовать.
  >R
\  ." TYPE=" R@ W@ .
  R@ W@ 2 = IF R> 2 CELLS + @ ( DUP . ." ,") EXIT THEN
  R@ W@ 3 = IF R> 2 CELLS + @ ( DUP . ." ,") EXIT THEN
  R@ W@ 8 = IF R> 2 CELLS + @ BSTR> ( 2DUP TYPE ." ,") EXIT THEN
  R@ W@ 0x400C = IF R> 2 CELLS + @ ( ." recurse variant:") RECURSE EXIT THEN
\ ." UNKNOWN PTYPE=" R@ W@ . R> 2 CELLS + @ 16 DUMP
  RDROP
;
: params@ ( dispid -- ... )
\  ." params="
  DUP @ uParams ! 2 CELLS + @ ( DUP .) 0 ?DO
    uParams @ I 4 * CELLS + param@
  LOOP
;
: IsVariable@ ( xt -- flag )
  DUP 1+ @ + CFL + ['] _CREATE-CODE =
  uFlags @ DISPATCH_PROPERTYPUT AND 0= AND
  DUP IF ( ."  VARIABLE@ ") THEN
;
: EXECUTE-COM ( ... xt -- ... )
  DUP IsVariable@ IF EXECUTE @ EXIT THEN
  EXECUTE
;
\ ===================== IDispatch ===================================

IID_IClassFactory
Class: SPF.IDispatch {C6DFBA32-DF7B-4829-AA3B-EE4F90ED5961}
Extends SPF.IUnknown

: ::GetTypeInfoCount ( pctinfo oid -- 0 | 1 )
  ( Class.) 2DROP 0
; METHOD

: ::GetTypeInfo      ( ppTInfo lcid iTInfo oid -- hresult )
  ( Class.) 2DROP 2DROP 1
; METHOD

: ::GetIDsOfNames    ( rgDispId lcid cNames rgszNames riid oid -- hresult )
  ( Class.) 2DROP
  ( ." rgszNames=") @ UASCIIZ> UNICODE> ( 2DUP) 2>R ( TYPE)
\  ."  cNames=" .
DROP
\  ." lcid=" .
DROP
\  ." rgDispId=" DUP .
  2R> SFIND 
  IF SWAP ! 0 
  ELSE 2DROP -1 SWAP ! DISP_E_UNKNOWNNAME THEN
; METHOD

: ::Invoke           ( puArgErr pExcepInfo pVarResult pDispParams wFlags lcid riid dispIdMember oid -- hresult )
\  Class.
  ( ." oid=" .)
DROP
  ( ." dispIdMember=" DUP .) >R
  DROP ( reserved)
\  ." lcid=" .
DROP
  ( ." wFlags=" DUP .) uFlags !
  ( ." pDispParams=" DUP .) >R \ R@ 20 DUMP
  ( ." pVarResult=" DUP .) 2R> ROT >R 2>R
  ( ." pExcepInfo=" DUP .) uExcep !
\  ." puArgErr=" .
DROP
  SP@ DUP uSPInvoke ! S0 !
  R> params@
  R> ['] EXECUTE-COM CATCH ?DUP 
     IF ( DUP .) uExcep @ W! S" FORTH" >BSTR uExcep @ CELL+ !
        uSPInvoke @ SP! RDROP
        DISP_E_EXCEPTION EXIT
     THEN
  SP@ uSPInvoke @ - \ DUP .
  DUP -4 = IF DROP
              3 R@ ! ( uFlags @ 3 = IF @ THEN) \ бейсик не делает разницы между method и property_get
              R> 2 CELLS + ! 0 EXIT
           THEN \ число
  DUP -8 = IF DROP
              uFlags @ DISPATCH_PROPERTYPUT AND 
              IF ! RDROP 0 EXIT THEN \ присвоение переменной форта
              8 R@ ! >BSTR R> 2 CELLS + ! 0 EXIT
           THEN \ строка
  0 = IF RDROP 0 EXIT THEN \ нет результатов
  uSPInvoke @ SP! RDROP 
  DISP_E_BADPARAMCOUNT
; METHOD

Class;

' SPF.IDispatch TO vSPF.IDispatch

: ComRegisterForth ( -- ior )
  ForthComClassObject
  REGCLS_MULTIPLEUSE
  CLSCTX_LOCAL_SERVER
  SPF.Application
  SPF.Application Class
  CoRegisterClassObject
;

: RUN
  ComInit 0=
  IF
    ComRegisterForth DROP \ HEX U. DECIMAL
  THEN
  ?GUI IF -1 PAUSE ELSE MAIN1 THEN
;
\ : -Embedding RUN ;
: -Embedding ;

\EOF
REQUIRE KoiWin ~ac/lib/string/conv2.f

FALSE TO SPF-INIT?
TRUE TO ?GUI
\ FALSE TO ?CONSOLE
' RUN TO <MAIN>
\ ' RUN MAINX !
S" spfcs.exe" SAVE BYE
