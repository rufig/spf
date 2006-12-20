( Simple example of an STA COM server )

REQUIRE WL-MODULES ~day\lib\includemodule.f

NEEDS  ~day\hype3\com.f
NEEDS  ~day\common\clparam.f
NEEDS  ~ac\lib\string\compare-u.f
NEEDS  ~day\wfl\lib\messageloop.f
NEEDS  lib\include\float2.f

\ Event that is signaled when there is zero objects and we should
 \ to destroy a server
VARIABLE quitEvent

WINAPI: CreateEventA KERNEL32.DLL
WINAPI: SetEvent     KERNEL32.DLL
WINAPI: WaitForSingleObject  KERNEL32.DLL
WINAPI: GetCurrentProcessId  KERNEL32.DLL
WINAPI: PostThreadMessageA   USER32.DLL

WINAPI: GlobalAlloc KERNEL32.DLL

IDispatch ISUBCLASS IForth {9F7A5561-8BD8-4B0D-93EC-A79A19C99330}

  VAR testVar

\ return string
: testMethod1 S" Hello, world" ;

\ return custom variant type - a byte (-10) in this case
: testMethod2 ( -- vardata )
    VT_I1 VarType ! -10 
;

\ return complex custom variant type - a double float value
: testMethod3 ( R: r1 r2 -- vardata )
    F+ VT_R8 VarType !
    FLOAT>DATA
;

\ string concatenation
 \ mind that we could return a BSTR and VT_BSTR in VarType
: testMethod4 ( addr1 u1 addr2 u2 add3 u3 -- addr u )
    "" >R
    R@ STR+ R@ STR+ R@ STR+
    R@ STR@ TUCK PAD SWAP MOVE
    R> STRFREE
    PAD SWAP
;

: Release ( cnt )
     SUPER Release

     \ get number of all AddRef's of this class
      \ and if it is zero than unload COM factory
     SUPER instances 0= IF quitEvent @ SetEvent DROP THEN
; METHOD

;ICLASS

: Register
\ Register STA server in the registry
    || CComRegisterHelper h ||
    S" SPF COM Server" h setComment
    S" SPF.Example.Automate" h setProgID
    S" Apartment" h setModel

    IForth h register
;

:NONAME ( process-thread-id )
    >R
    INFINITE quitEvent @ WaitForSingleObject DROP
    0 0 WM_QUIT R> PostThreadMessageA COM-THROW
; TASK: MonitorTask


: RUN
  STARTLOG2 
  TRUE TO COM-TRACE

  NEXT-PARAM 2DROP
  NEXT-PARAM 2DUP S" /RegServer" COMPARE-U 0=
  IF Register BYE
  THEN

  ComInitApartment COM-THROW

  0 FALSE FALSE 0 CreateEventA quitEvent !

  \ register IClassFactory in table of current process

  IForth AppClassFactory setClass
  AppClassFactory registerLocalServer COM-THROW

  \ Wait until all instances are released, then shutdown the server

  GetCurrentThreadId MonitorTask START 

  \ All STA objects should have message loop to dispatch the calls

  || R: monitor CWinMessage msg ||

  BEGIN
    0 0 0 msg addr GetMessageA
  WHILE
    ." dispatch message" CR
    msg addr DispatchMessageA DROP
  REPEAT

  \ Termination
  AppClassFactory revokeLocalServer COM-THROW
  quitEvent @ CloseHandle DROP
  UUID:: ComDestroy
  BYE
;

' RUN MAINX !
TRUE TO ?GUI
S" comserver.exe" SAVE BYE