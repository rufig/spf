\ Таймер

REQUIRE /SYSTEMTIME lib/include/facil.f

0 VALUE start-time

: get-local-time ( -- )         \ get the local computer date and time
  SYSTEMTIME GetLocalTime DROP
;

: ms@ ( -- ms )
  get-local-time
  SYSTEMTIME wHour         W@     60 *
  SYSTEMTIME wMinute       W@ +   60 *
  SYSTEMTIME wSecond       W@ + 1000 *
  SYSTEMTIME wMilliseconds W@ +
;

: time-reset ( -- )  ms@ TO start-time ;

: .elapsed ( -- )
  ms@ start-time -
  1000 /MOD
  60 /MOD
  60 /MOD
  ." Elapsed time: "
  2 .0 [CHAR] : EMIT
  2 .0 [CHAR] : EMIT
  2 .0 [CHAR] : EMIT
  3 .0
;

: elapse ( -<commandline>- )
  time-reset EVALUATE CR .elapsed
;
