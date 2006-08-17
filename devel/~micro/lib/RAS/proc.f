WINAPI: RasHangUpA rasapi32.dll

: HangUp ( h -- )
  >R
  BEGIN
    R@ RasHangUpA
    6 <>
  WHILE
    10 PAUSE
  REPEAT
  RDROP
;

