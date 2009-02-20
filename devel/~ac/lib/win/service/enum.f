\ перебор установленных в системе сервисов/драйверов и их состояний

REQUIRE {              ~ac/lib/locals.f
REQUIRE OpenSCManagerA ~ac/lib/win/service/service_struct.f 

WINAPI: EnumServicesStatusExA ADVAPI32.DLL
0x0004 CONSTANT SC_MANAGER_ENUMERATE_SERVICE

0
CELL -- ssp.lpServiceName
CELL -- ssp.lpDisplayName
CELL -- ssp.dwServiceType
CELL -- ssp.dwCurrentState
CELL -- ssp.dwControlsAccepted
CELL -- ssp.dwWin32ExitCode
CELL -- ssp.dwServiceSpecificExitCode
CELL -- ssp.dwCheckPoint
CELL -- ssp.dwWaitHint
CELL -- ssp.dwProcessId
CELL -- ssp.dwServiceFlags
CONSTANT /ENUM_SERVICE_STATUS_PROCESS

: ForEachService { par xt \ mem r cnt size ssp -- }
\ для всех сервисов, драйверов ядра и драйверов ФС выполнить xt ( a u na nu pid state type par -- flag )
\ где a u - "экранное имя", na nu - имя сервиса, type - тип (1-драйвер,2-фс.драйвер,0x10или0x20-сервис,0x100-интерактивный)
\ state (1-остановлен,2-стартует,3-останавливается,4-работает,5-продолжается,6-приостанавливается,7-приостановлен)
\ pid - id процесса
  0 ^ r ^ cnt ^ size 256 1024 * DUP ALLOCATE THROW DUP -> mem 3 0x3B 0 
  0x0004 0 0 OpenSCManagerA EnumServicesStatusExA
  IF
    cnt 0 ?DO
      mem I /ENUM_SERVICE_STATUS_PROCESS * + -> ssp
      ssp ssp.lpDisplayName @ ASCIIZ>
      ssp ssp.lpServiceName @ ASCIIZ>
      ssp ssp.dwProcessId @
      ssp ssp.dwCurrentState @
      ssp ssp.dwServiceType @
      par xt EXECUTE 0= IF UNLOOP EXIT THEN
    LOOP
  THEN
;
\EOF
0 :NONAME . . . . TYPE SPACE TYPE CR TRUE ; ForEachService
