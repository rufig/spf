WINAPI: RegisterEventSourceA  ADVAPI32.DLL
WINAPI: ReportEventA          ADVAPI32.DLL
WINAPI: DeregisterEventSource ADVAPI32.DLL

: LogEvent ( ior -- )
  S" Application" DROP 0 RegisterEventSourceA >R
  R@ 1 < IF DROP RDROP EXIT THEN
  >R
  0 S" " DROP     0 0 0 R> 6 0x0001 R@ ReportEventA DROP
  R> DeregisterEventSource DROP
;
\ 55 32000 + LogEvent
