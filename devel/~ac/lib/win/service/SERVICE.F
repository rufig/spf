REQUIRE OpenServiceA ~ac/lib/win/service/service_struct.f

WARNING @ WARNING 0!
: DeleteService ( addr u -- ior )
  2>R DELETE_SERVICE 2R> DROP
  SC_MANAGER_ALL_ACCESS 0 0 OpenSCManagerA DUP >R
  OpenServiceA DUP >R DeleteService
  R> CloseServiceHandle DROP
  R> CloseServiceHandle DROP
;
WARNING !

: CreateService ( addr u -- ior )
  2DUP DeleteService DROP
  2>R
  0 0 0 0 0
  0 0 ModuleName DROP
  SERVICE_ERROR_NORMAL S_AUTO \ SERVICE_DEMAND_START 
  SERVICE_WIN32_OWN_PROCESS SERVICE_INTERACTIVE_PROCESS OR
  SERVICE_ALL_ACCESS
  2R@ DROP
  2R> DROP
  SC_MANAGER_ALL_ACCESS 0 0 OpenSCManagerA
  CreateServiceA
;

\ ***********************
VARIABLE CtrlHandler

: (ServiceControlHandler) ( fdwControl -- )
  \ управл€юща€ процедура сервиса
  \ поступают аргументы =1 или =4
  SERVICE_CONTROL_STOP =
  IF
    SERVICE_WIN32 SERVICE_INTERACTIVE_PROCESS OR
                        SERVICE_STATUS dwServiceType !
    SERVICE_STOPPED     SERVICE_STATUS dwCurrentState !
    SERVICE_ACCEPT_STOP SERVICE_STATUS dwControlsAccepted !
    SERVICE_STATUS CtrlHandler @ SetServiceStatus DROP
  THEN 0
;
' (ServiceControlHandler) WNDPROC: ServiceControlHandler

0 VALUE SERVICE_TABLE

VECT ServiceProc  ' NOOP TO ServiceProc


: (ServiceMain) ( dwArgc *lpszArgv -- )
  2DROP
  SERVICE_WIN32 SERVICE_INTERACTIVE_PROCESS OR
                      SERVICE_STATUS dwServiceType !
  SERVICE_RUNNING     SERVICE_STATUS dwCurrentState !
  SERVICE_ACCEPT_STOP SERVICE_STATUS dwControlsAccepted !

  ['] ServiceControlHandler SERVICE_TABLE @ \ на этом участке ошибки
  RegisterServiceCtrlHandlerA DUP CtrlHandler !  \ означают скорее всего Win95
  SERVICE_STATUS SWAP SetServiceStatus DROP      \ поэтому игнорируем

  ServiceProc
;
' (ServiceMain) WNDPROC: ServiceMain

: StartService ( addr u -- flag )
  HERE DUP >R SWAP DUP ALLOT MOVE 0 C,
  HERE TO SERVICE_TABLE R> , ['] ServiceMain , 0 , 0 ,
  SERVICE_TABLE StartServiceCtrlDispatcherA 0=
  ( flag=true функци€ не работает, возможно Win95 
    иначе выход из сервиса - останов )
;
