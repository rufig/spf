\ $Id$
\ 
\ Get current local date and time
\
\ TIME&DATE ( -- sec min hour day month year )
\
\ ms@ ( -- n ) \ the number of milliseconds since some fixed point in the past

REQUIRE [IF] lib/include/tools.f

[DEFINED] WINAPI: [IF]

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

: ms@ GetTickCount ;

[ELSE]

: NSYM: ( num "name" -- ) PARSE-NAME 2DUP CREATED symbol-lookup , , DOES> DUP CELL+ @ SWAP @ symbol-call ;

\ 1 NSYM: time
\ 2 NSYM: localtime_r
\ 1 NSYM: times \ 10 ms resolution (everywhere?)
\ alternatives :
\ clock_gettime CLOCK_MONOTONIC (librt)
\ clock()
\ gettimeofday (as GetTickCount in wine)

\ tm struct
0
CELL -- tm_sec
CELL -- tm_min
CELL -- tm_hour
CELL -- tm_mday
CELL -- tm_mon
CELL -- tm_year
CELL -- tm_wday
CELL -- tm_yday
CELL -- tm_isdst_nouse
\       The glibc version of struct tm has additional fields
\
\              long tm_gmtoff;           /* Seconds east of UTC */
\              const char *tm_zone;      /* Timezone abbreviation */
\
\       defined when _BSD_SOURCE was set before including <time.h>.  This is a
\       BSD extension, present in 4.3BSD-Reno.
CELL -- tm_gmtoff
CELL -- tm_zone
CONSTANT /TM

USER-CREATE TM /TM USER-ALLOT

: TIME&DATE ( -- sec min hr day mt year )
  (( 0 )) time 
  (( SP@ TM )) localtime_r DROP 
  DROP
  TM tm_sec @
  TM tm_min @
  TM tm_hour @
  TM tm_mday @
  TM tm_mon @ 1 +
  TM tm_year @ 1900 +
;

\ ok to pass NULL?
: ms@ (( 0 )) times 10 * ;

[THEN]

