\ 32 CONSTANT /SYSTEMTIME
REQUIRE /SYSTEMTIME lib/include/facil.f

 0
 4 -- Bias
64 -- StandardName
/SYSTEMTIME -- StandardDate
 4 -- StandardBias
64 -- DaylightName
/SYSTEMTIME -- DaylightDate
 4 -- DaylightBias
CONSTANT /TIME_ZONE_INFORMATION
 
WINAPI: GetTimeZoneInformation KERNEL32.DLL

CREATE TZ HERE /TIME_ZONE_INFORMATION DUP ALLOT ERASE

\ : TEST
\   TZ GetTimeZoneInformation .
\   TZ /TIME_ZONE_INFORMATION DUMP
\ ;

: GET-TIME-ZONE
  TZ GetTimeZoneInformation 2 = IF TZ Bias @ 60 - TZ Bias ! THEN
;
