\ CurrentTimeSql дает локальные дата-время в формате 2005-12-06 10:33:07

WINAPI: time MSVCRT.DLL
WINAPI: strftime  MSVCRT.DLL
WINAPI: localtime  MSVCRT.DLL
\ WINAPI: clock MSVCRT.DLL
\ clock .

: UnixTime ( -- n ) 0 >R RP@ time NIP RDROP ;

USER-CREATE uLocalTime 21 USER-ALLOT

: CurrentTimeSql ( -- addr u )
  UnixTime >R RP@ localtime NIP 
  S" %Y-%m-%d %H:%M:%S" DROP 21 uLocalTime strftime NIP NIP NIP NIP 
  uLocalTime SWAP
  RDROP
;
\ CurrentTimeSql TYPE

