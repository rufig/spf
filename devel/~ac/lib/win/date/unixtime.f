\ CurrentTimeSql дает локальные дата-время в формате 2005-12-06 10:33:07

WINAPI: time      MSVCRT.DLL
WINAPI: strftime  MSVCRT.DLL
WINAPI: localtime MSVCRT.DLL
WINAPI: gmtime    MSVCRT.DLL

\ WINAPI: clock MSVCRT.DLL
\ clock .

: UnixTime ( -- n ) 0 >R RP@ time NIP RDROP ;

USER-CREATE uLocalTime 30 USER-ALLOT

: UnixTimeSql ( unixtime -- addr u ) \ LOCAL
  >R RP@ localtime NIP 
  S" %Y-%m-%d %H:%M:%S" DROP 21 uLocalTime strftime NIP NIP NIP NIP 
  uLocalTime SWAP
  RDROP
;
: UnixTimeRus ( unixtime -- addr u ) \ LOCAL
  >R RP@ localtime NIP 
  S" %d.%m.%Y %H:%M" DROP 18 uLocalTime strftime NIP NIP NIP NIP 
  uLocalTime SWAP
  RDROP
;
: UnixTimeRss ( unixtime -- addr u ) \ UTC
  >R RP@ gmtime NIP 
  S" %a, %d %b %Y %H:%M:%S GMT" DROP 30 uLocalTime strftime NIP NIP NIP NIP 
  uLocalTime SWAP
  RDROP
;
: CurrentTimeSql ( -- addr u )
  UnixTime UnixTimeSql
;
: CurrentTimeRus ( -- addr u )
  UnixTime UnixTimeRus
;
\ CurrentTimeRus TYPE

: CurrentTimeRss ( -- addr u )
  UnixTime UnixTimeRss
;
: UNIXTIME>FILETIME ( unixtime -- filetime ) \ UTC
  10000000 M* 116444736000000000. D+  \ см. http://support.microsoft.com/kb/167296
;
: FILETIME>UNIXTIME ( filetime -- unixtime ) \ UTC
  116444736000000000. D- 10000000 UM/MOD NIP
;
