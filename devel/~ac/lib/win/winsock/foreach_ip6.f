REQUIRE IPV6_MODE             ~ac/lib/win/winsock/sockets6.f 
REQUIRE /IP_ADAPTER_ADDRESSES ~ac/lib/win/winsock/adapters.f 
REQUIRE ForEachIP             ~ac/lib/win/winsock/foreach_ip.f 

: ForEachLocalIP { xt \ gaa addr buf aa ua he -- ior }
\ xt - процедура ( IP -- ), запускаемая для каждого IP
\ На момент выполнения xt на стеке нет промежуточных значений,
\ поэтому xt может его использовать для своих данных.

  15000 -> gaa
  BEGIN
    gaa ALLOCATE THROW -> addr
    ^ gaa addr 0 ( 0x0010) 0 0 GetAdaptersAddresses
    IF addr FREE THROW FALSE ELSE TRUE THEN
  UNTIL
  Ip6Buf -> buf

  addr
  BEGIN
    DUP -> aa
  WHILE
    aa aa.OperStatus C@ 1 =
    IF
      aa aa.FirstUnicastAddress @
        BEGIN
          DUP -> ua
        WHILE
          ua ua.Address DUP @ SWAP CELL+ @
          /sockaddr_in6 =
          IF sin6_addr buf 16 MOVE buf IP6_BUFFS @ -
          ELSE sin_addr @ THEN
          IP6_BUFFS_HERE @ -> he \ удерживаем кольцевой буфер от кольцевания...
          xt EXECUTE
          he IP6_BUFFS_HERE !
          ua ua.Next @
        REPEAT
    THEN
    aa aa.Next @
  REPEAT
  addr FREE THROW
  0
;
: ForEachIP { xt -- ior }
  xt ForEachLocalIP
  ExternIP @ ?DUP IF xt EXECUTE THEN
  ExternIPs @ ?DUP IF BEGIN DUP @ WHILE DUP @ xt EXECUTE CELL+ REPEAT DROP THEN
;
CREATE IPV6_LOCALHOST 0 , 0 , 0 , 0x01000000 ,

: IsLocalhost ( ip -- flag )
  DUP IsIPv6
  IF IP6_BUFFS @ + 16 IPV6_LOCALHOST 16 COMPARE 0=
  ELSE 0xFF AND 0x7F = THEN
;
: (IsMyIP) { flag ip1 ip -- flag ip1 }
  ip1 IsIPv6 ip IsIPv6 AND
  IF ip1 IP6_BUFFS @ + 16 ip IP6_BUFFS @ + 16 COMPARE 0= 
  ELSE ip1 ip = THEN
  IF TRUE ip1 ELSE flag ip1 THEN
;
: IsMyIP { ip -- flag }
  ip ( 0x0100007F =) IsLocalhost IF TRUE EXIT THEN
  ExternIP @ ?DUP IF ip = IF TRUE EXIT THEN THEN
  ExternIPs @ ?DUP IF BEGIN DUP @ WHILE DUP @ ip = IF DROP TRUE EXIT THEN CELL+ REPEAT DROP THEN
  FALSE ip ['] (IsMyIP) ForEachLocalIP 2DROP
;
: IsMyHostname ( addr u -- flag )
  GetHostIP IF DROP FALSE EXIT THEN
  IsMyIP
;
: IsMyHostnameAndNotLocalhost ( addr u -- flag )
  GetHostIP IF DROP FALSE EXIT THEN
  DUP IsLocalhost IF DROP FALSE EXIT THEN
  IsMyIP
;

\EOF

SocketsStartup THROW 
0 :NONAME NtoA TYPE CR 1+ ; ForEachIP . .
TRUE IPV6_MODE !
S" ra6" IsMyHostname .
S" ::1" IsMyHostnameAndNotLocalhost .
