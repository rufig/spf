( GetDNS - получить IP-адреса или имена DNS-серверов по умолчанию и
  вернуть массив строк )

REQUIRE StrValue     ~ac/lib/win/registry2.f
REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f
REQUIRE WinNT?       ~ac/lib/win/winver.f

WINAPI: DeviceIoControl KERNEL32.DLL

VARIABLE DNS-SERVERS
: S, ( addr u -- )
  HERE SWAP DUP ALLOT MOVE
;
: DNS,
  DNS-SERVERS @ 0= IF HERE DNS-SERVERS ! THEN
  DUP C, S, 0 C,
;
: ,>BL ( addr u -- )
  0 ?DO DUP I + C@ [CHAR] , = IF BL OVER I + C! THEN LOOP DROP
;
: DNS,,x
  BEGIN
    BL WORD DUP C@
  WHILE
    COUNT DNS,
  REPEAT DROP
;
: DNS,, ( addr u -- )
  2DUP ,>BL
  ['] DNS,,x EVALUATE-WITH
\  #TIB ! TO TIB >IN 0!
\  BEGIN
\    BL WORD DUP C@
\  WHILE
\    COUNT DNS,
\  REPEAT DROP
;
: FindDNS ( addr u -- )
  S" NameServer" 2OVER StrValue ?DUP
  IF DNS,,
  ELSE DROP THEN
  S" DhcpNameServer" 2SWAP StrValue ?DUP
  IF DNS,,
  ELSE DROP THEN
;
: GetNT_MainDNS
  HKEY_LOCAL_MACHINE EK !
  S" NameServer"
  S" SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
  StrValue ?DUP IF DNS,, ELSE DROP THEN
  S" NameServer"
  S" SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Transient"
  StrValue ?DUP IF DNS,, ELSE DROP THEN
  S" DhcpNameServer"
  S" SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
  StrValue ?DUP IF DNS,, ELSE DROP THEN
;
: GetNT_DNS
  GetNT_MainDNS
  S" SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
  HKEY_LOCAL_MACHINE RG_OpenKey 
  IF DROP
  ELSE EK !
    ['] FindDNS EK @ RG_ForEachKey
    EK @ RegCloseKey DROP
  THEN
;
: Get95_DNS
  S" \\.\VDHCP" R/W OPEN-FILE 0=
  IF >R
     0 PAD 1000 PAD CELL+ 2DUP 1 R@ DeviceIoControl
     IF PAD CELL+ 54 +
        DUP @ ?DUP IF NtoA DNS, THEN
        CELL+ @ ?DUP IF NtoA DNS, THEN
     THEN
     R> CLOSE-FILE DROP
  ELSE DROP THEN
;
: GetDNS ( -- addr )
  WinNT? IF GetNT_DNS ELSE Get95_DNS THEN
  0 ,
  DNS-SERVERS @
;
