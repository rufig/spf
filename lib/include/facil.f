\ _SYSTEMTIME
0
2 -- wYear
2 -- wMonth
2 -- wDayOfWeek
2 -- wDay
2 -- wHour
2 -- wMinute
2 -- wSecond
2 -- wMilliseconds
CONSTANT /SYSTEMTIME
CREATE SYSTEMTIME /SYSTEMTIME ALLOT

WINAPI: GetLocalTime KERNEL32.DLL
WINAPI: GetTickCount KERNEL32.DLL

: TIME&DATE ( -- sec min hr day mt year ) \ 94 FACIL
  SYSTEMTIME GetLocalTime DROP
  SYSTEMTIME wSecond W@
  SYSTEMTIME wMinute W@
  SYSTEMTIME wHour W@
  SYSTEMTIME wDay W@
  SYSTEMTIME wMonth W@
  SYSTEMTIME wYear W@
;
