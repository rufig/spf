( Simple example of an STA COM server )

REQUIRE WL-MODULES ~day\lib\includemodule.f

NEEDS  ~day\hype3\com.f
NEEDS  ~day\common\clparam.f
NEEDS  ~ac\lib\string\compare-u.f
NEEDS ~day\wfl\lib\messageloop.f

\ Event that is signaled when there is zero objects and we should
 \ to destroy a server
VARIABLE quitEvent

WINAPI: CreateEventA KERNEL32.DLL
WINAPI: SetEvent     KERNEL32.DLL
WINAPI: WaitForSingleObject  KERNEL32.DLL
WINAPI: GetCurrentProcessId  KERNEL32.DLL
WINAPI: PostThreadMessageA   USER32.DLL

IDispatch ISUBCLASS IForth {9F7A5561-8BD8-4B0D-93EC-A79A19C99330}


: testMethod ;

: Release ( cnt )
     SUPER Release DUP 0= 
     IF quitEvent @ SetEvent DROP THEN
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