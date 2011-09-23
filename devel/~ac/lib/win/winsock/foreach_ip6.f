REQUIRE IPV6_MODE             ~ac/lib/win/winsock/sockets6.f 
REQUIRE /IP_ADAPTER_ADDRESSES ~ac/lib/win/winsock/adapters.f 
REQUIRE ForEachIP             ~ac/lib/win/winsock/foreach_ip.f 

: IsSiteLocal ( ip -- flag )
  DUP IsIPv6
  IF IP6_BUFFS @ + W@ RV16 0xFEC0 0xFF00 WITHIN
  ELSE IsLanIP THEN
;
: IsLinkLocal ( ip -- flag )
  DUP IsIPv6
  IF IP6_BUFFS @ + W@ RV16 0xFE80 0xFEC0 WITHIN
  ELSE IsLanIP THEN
;
: IsUniqueLocal ( ip -- flag )
  \ FC00::/7 - "Unique Local IPv6 Unicast Addresses" (RFC4193)
  DUP IsIPv6
  IF IP6_BUFFS @ + W@ RV16 0xFE00 AND 0xFC00 =
  ELSE IsLanIP THEN
;

: IsIsatapLL ( ip -- flag )
  \ Link-Local IP6-автоинтерфейс на IP4-адресах FE80::0:5EFE:w.x.y.z
  DUP IsIPv6
  IF IP6_BUFFS @ + DUP W@ RV16 0xFE80 =
     SWAP 10 + W@ RV16 0x5EFE = AND
  ELSE DROP FALSE THEN
;

CREATE IPV6_LOCALHOST   0 ,                       0 , 0 , 0x01000000 ,
CREATE IPV6_LLLOCALHOST 0xFE C, 0x80 C, 0 C, 0 C, 0 , 0 , 0x01000000 , \ XP [fe80::1]

: ForEachLocalIP { xt \ gaa addr buf aa ua he ll -- ior }
\ xt - процедура ( IP -- ), запускаемая для каждого IP
\ На момент выполнения xt на стеке нет промежуточных значений,
\ поэтому xt может его использовать для своих данных.

\ xt должен сохранить у себя переданный IPv6 (и его NtoA, если нужен),
\ т.к. передаётся IPv6 во временном буфере Ip6Buf (см. sockets6.f)

\ под "LocalIP" здесь имеется в виду "IP этой машины", а не "интерфейсы
\ локальной сети" (для их опознания есть слова Is*Local и т.п. и IsLanIP).

  WinVer 50 = IF xt ForEachIP EXIT THEN

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
      aa aa.IfIndex @ FE_IfIndex !
                      FE_IfIndex6 0!
      aa aa.FirstUnicastAddress @
        BEGIN
          DUP -> ua
        WHILE
          FALSE -> ll
          ua ua.Address DUP @ SWAP CELL+ @
          /sockaddr_in6 =
          IF IPV6_MODE @
             IF
               DUP sin6_addr 16 IPV6_LLLOCALHOST 16 COMPARE 0= -> ll
               sin6_addr buf 16 MOVE buf IP6_BUFFS @ -
               DUP IsLinkLocal IF aa aa.Ipv6IfIndex @ FE_IfIndex6 ! THEN
                                  \ иначе "Ambiguous Scoped Addresses",
                                  \ http://msdn.microsoft.com/en-us/library/ms739166(v=vs.85).aspx
             ELSE TRUE -> ll THEN
          ELSE sin_addr @ THEN
          ll 0=
          IF 
            IP6_BUFFS_HERE @ -> he \ удерживаем кольцевой буфер от кольцевания...
            xt EXECUTE
            he IP6_BUFFS_HERE !
          ELSE DROP THEN \ [fe80::1] пропускаем
          ua ua.Next @
        REPEAT
    THEN
    aa aa.Next @
  REPEAT
  addr FREE THROW
  FE_IfIndex 0!
  FE_IfIndex6 0!
  0
;
: ForEachIP { xt -- ior }
  WinVer 50 = IF xt ForEachIP EXIT THEN
  xt ForEachLocalIP
  ExternIP @ ?DUP IF xt EXECUTE THEN
  ExternIPs @ ?DUP IF BEGIN DUP @ WHILE DUP @ xt EXECUTE CELL+ REPEAT DROP THEN
;
: IsLocalhost ( ip -- flag )
  DUP IsIPv6
  IF IP6_BUFFS @ + 16 IPV6_LOCALHOST 16 COMPARE 0=
  ELSE 0xFF AND 0x7F = THEN
;
: IsLanIP ( ip -- flag )
  DUP IsLocalhost IF DROP TRUE EXIT THEN
  DUP IsIPv6
  IF IP6_BUFFS @ + C@ 0xFE =
  ELSE IsLanIP THEN
;
: (IsMyIP) { flag ip1 ip -- flag ip1 }
  ip1 IsIPv6 ip IsIPv6 AND
  IF ip1 IP6_BUFFS @ + 16 ip IP6_BUFFS @ + 16 COMPARE 0= 
  ELSE ip1 ip = THEN
  IF TRUE ip1 ELSE flag ip1 THEN
;
: IsMyIP { ip -- flag }
  WinVer 50 = IF ip IsMyIP EXIT THEN
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
TRUE IPV6_MODE !
0 :NONAME NtoA TYPE CR 1+ ; ForEachIP . .
S" ra6" IsMyHostname .
S" ::1" IsMyHostnameAndNotLocalhost .
