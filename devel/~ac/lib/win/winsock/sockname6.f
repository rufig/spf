REQUIRE IPV6_MODE     ~ac/lib/win/winsock/sockets6.f 
REQUIRE sockIP&Port   ~ac/lib/win/winsock/SOCKNAME.F

: sockIP&Port6 ( socket -- ip port )
  Ip6Buf >R
  /sockaddr_in6 R@ !
  R@ DUP CELL+ ROT getsockname
  IF WSAGetLastError THROW THEN
  R@ CELL+ sin6_family W@ 2 =
  IF R@ CELL+ sin_addr @
  ELSE R@ CELL+ sin6_addr Ip6Buf DUP >R 16 MOVE R> IP6_BUFFS @ - THEN
  R> CELL+ sin6_port W@ RV16
;
: sockIP&Port ( socket -- IP port )
  sockIP&Port6
;
: ReadFrom ( addr u socket -- size IP port )
  { adr u sock \ sin }
  Ip6Buf -> sin
  /sockaddr_in6 sin /sockaddr_in6 + DUP >R !
  R> sin 0 u adr sock recvfrom
  DUP SOCKET_ERROR = OVER u > OR    \ ~ac 18.01.02  (*)
  IF DROP WSAGetLastError THROW -1 THROW ( *) THEN
  u MIN 0 MAX ( *)
  sin sin6_family W@ 2 =
  IF sin sin_addr @ sin sin_port W@ RV16
  ELSE sin sin6_addr Ip6Buf DUP >R 16 MOVE R> IP6_BUFFS @ -
     sin sin6_port W@ RV16
  THEN
;
: WriteTo ( IP port addr u socket -- )
  { adr u sock \ sin }
  Ip6Buf -> sin
  RV16
  OVER IsIPv6
  IF
    sin sin6_port W!
    IP6_BUFFS @ + sin sin6_addr 16 MOVE
    AF_INET6 sin sin6_family W!
    /sockaddr_in6
  ELSE
    sin sin_port W!
    sin sin_addr !
    AF_INET sin sin_family W! sin sin_zero 8 ERASE
    /sockaddr_in
  THEN
  sin 0 u adr sock sendto
  DUP SOCKET_ERROR = SWAP u < OR    \ ~ac 23.06.05
  IF WSAGetLastError THROW -1 THROW ( *) THEN
;
