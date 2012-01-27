\ Пример использования протокола NTP.

REQUIRE WriteTo     ~ac/lib/win/winsock/sockname.f

: NTP_SERVER_IP ( -- ip )
\  S" 192.43.244.18" GetHostIP THROW \ time.nist.gov не работает
\  S" time.windows.com" GetHostIP THROW
  S" 207.46.250.85" GetHostIP THROW \ time.windows.com
\  S" 1.ru.pool.ntp.org" GetHostIP THROW
;
\ rfc1361
   0
   1 -- sntp.livnmode
   1 -- sntp.stratum
   1 -- sntp.poll
   1 -- sntp.precision
CELL -- sntp.rootdelay
CELL -- sntp.rootdisp
CELL -- sntp.refident
   8 -- sntp.refts
   8 -- sntp.orgts
   8 -- sntp.rcvts
   8 -- sntp.trnts
CONSTANT /SNTP

VARIABLE NTPS

: >ENDIAN<  ( x1 -- x2 )
  >R
  R@       0xFF AND 24 LSHIFT
  R@     0xFF00 AND  8 LSHIFT OR
  R@   0xFF0000 AND  8 RSHIFT OR
  R> 0xFF000000 AND 24 RSHIFT OR
;
: NtpGetTime ( -- unixtime ) \ или 0 при ошибке (таймауте)
  /SNTP ALLOCATE THROW >R
  0xEC0600E3 R@ sntp.livnmode !
  0x34314E31 R@ sntp.refident !

  CreateUdpSocket THROW ( s )
  4000 OVER SetUdpSocketTimeout THROW ( s )
  NTPS !

  NTP_SERVER_IP 123 R@ /SNTP NTPS @
  WriteTo

  R@ /SNTP NTPS @ ['] ReadFrom CATCH
  R@ sntp.trnts @ R> FREE THROW
  NTPS @ CloseSocket THROW
  SWAP IF 2DROP 2DROP 0 EXIT THEN
  >R 2DROP 48 <> IF RDROP 0 EXIT THEN R>
  >ENDIAN< 2208988800 -
;

\EOF
REQUIRE UnixTimeRus ~ac/lib/win/date/unixtime.f 
SocketsStartup DROP
NtpGetTime
UnixTimeRus TYPE
