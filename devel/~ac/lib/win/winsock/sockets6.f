REQUIRE CreateSocket  ~ac/lib/win/winsock/sockets.f
REQUIRE WinVer        ~ac/lib/win/winver.f 

VARIABLE IPV6_MODE \ при FALSE будет работать в режиме IPv4, не пыта€сь
                   \ получать из DNS IPv6-адреса и пытатьс€ и соедин€тьс€ с ними

23 CONSTANT AF_INET6     \ Internetwork Version 6

 0
 2 -- sin6_family
 2 -- sin6_port \ в сетевом пор€дке байтов
 4 -- sin6_flowinfo
16 -- sin6_addr \ в случае IPv4 здесь "0..0 FF FF IPv4_addr"
 4 -- sin6_scope_id
CONSTANT /sockaddr_in6

USER IP6_BUFFS
USER IP6_BUFFS_HERE
960 CONSTANT /IP6_BUFFS

: Ip6Buf ( -- addr )
  \ кольцевой буфер из 20 сегментов по 48 байт - достаточно дл€ sockaddr_in6,
  \ addrinfo или дл€ строчного представлени€ IPv6-адреса (46 симв. max)
  IP6_BUFFS @ 0= IF /IP6_BUFFS ALLOCATE THROW DUP IP6_BUFFS ! 48 + IP6_BUFFS_HERE ! THEN
  IP6_BUFFS_HERE @ IP6_BUFFS @ - /IP6_BUFFS < 0= IF IP6_BUFFS @ 48 + IP6_BUFFS_HERE ! THEN
  IP6_BUFFS_HERE @ DUP 48 + IP6_BUFFS_HERE !
  DUP 48 ERASE
;
: IsIPv6 ( ip -- flag )
  DUP 0= IF DROP FALSE EXIT THEN
  /IP6_BUFFS U<
;

\ ¬ WinXP не поддерживаютс€ "двухрежимные" сокеты, поэтому не будем
\ пока использовать эту опцию.
\ 27 CONSTANT IPV6_V6ONLY
\ CREATE NOT_IPV6_V6ONLY 0 ,
\ 41 CONSTANT IPPROTO_IPV6

: CreateSocket6 ( -- socket ior )
  0 SOCK_STREAM AF_INET6
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
\     OVER >R 4 NOT_IPV6_V6ONLY IPV6_V6ONLY IPPROTO_IPV6 R>
\     setsockopt OR
  THEN
;
: CreateSocket6WithTimeout ( -- socket ior )
  0 SOCK_STREAM AF_INET6
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
       OVER >R 4 TIMEOUT SO_SNDTIMEO SOL_SOCKET R>
       setsockopt OR
       OVER >R 4 TIMEOUT SO_RCVTIMEO SOL_SOCKET R>
       setsockopt OR
  THEN
;
: CreateUdpSocket6 ( -- socket ior )
  IPPROTO_UDP SOCK_DGRAM AF_INET6
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
  THEN
;
: CreateBroadcastSocket6 ( -- socket ior )
  IPPROTO_UDP SOCK_DGRAM AF_INET6
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
       OVER >R 4 BROADCAST SO_BROADCAST SOL_SOCKET R>
       setsockopt OR
  THEN
;


CREATE IPV6_ALL 0 , 0 , 0 , 0 ,

: RV16
  DUP 8 RSHIFT SWAP 0xFF AND 8 LSHIFT +
;
USER FE_IfIndex
USER FE_IfIndex6

: BindSocketInterface6 ( port ip6_addr s -- ior )
  >R /sockaddr_in6 ALLOCATE ?DUP IF NIP R> DROP EXIT THEN
  SWAP >R >R
  RV16 R@ sin6_port W!
  AF_INET6 R@ sin6_family W!
  FE_IfIndex6 @ R@ sin6_scope_id !
  R@
  R> R> SWAP >R R@ sin6_addr 16 MOVE
  /sockaddr_in6 R> R> bind SWAP FREE DROP SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
: BindSocketInterface ( port ip s -- ior )
  OVER 0= IF BindSocketInterface EXIT THEN \ "все_интерфейсы" в IPv4
  OVER IsIPv6
  IF SWAP IP6_BUFFS @ + SWAP BindSocketInterface6
  ELSE BindSocketInterface THEN
;
: GetPeerIP&Port ( s -- ip port ior )
  ( /sockaddr_in6 CELL+ ALLOCATE THROW) Ip6Buf >R
  /sockaddr_in6 R@ !
  R@ DUP CELL+ ROT getpeername SOCKET_ERROR =
  IF 0 0 WSAGetLastError
  ELSE \ R@ CELL+ sin6_addr R@ CELL+ sin6_port W@ RV16 0
    R@ CELL+ sin6_family W@ 2 =
    IF R@ CELL+ sin_addr @
    ELSE R@ CELL+ sin6_addr Ip6Buf DUP >R 16 MOVE R> IP6_BUFFS @ - THEN
    R@ CELL+ sin6_port W@ RV16
    0
  THEN
  RDROP
;
WINAPI: getaddrinfo WS2_32.DLL
WINAPI: freeaddrinfo WS2_32.DLL

0
4 -- ai_flags
4 -- ai_family
4 -- ai_socktype
4 -- ai_protocol
4 -- ai_addrlen
4 -- ai_canonname \ *
4 -- ai_addr \ *
4 -- ai_next \ *
CONSTANT /addrinfo

WINAPI: WSAAddressToStringA WS2_32.DLL

: IPtoStr ( sockaddr len -- addr u )
  DUP >R
  46 >R RP@
  ROT ROT 2>R
  Ip6Buf 1+ DUP ROT SWAP 0 2R> SWAP WSAAddressToStringA 0=
  IF ( Ip6Buf) R> 1- ELSE RDROP S" error" WSAGetLastError . THEN
  R> /sockaddr_in6 =
  IF 1+ SWAP 1- SWAP OVER [CHAR] [ SWAP C!
     2DUP + S" ]" DROP SWAP 2 MOVE 1+
  THEN
;
: NtoA ( IP -- addr u )
  DUP IsIPv6
  IF Ip6Buf >R
     IP6_BUFFS @ + R@ sin6_addr 16 MOVE
     AF_INET6 R@ sin6_family W!
     R> /sockaddr_in6 IPtoStr
  ELSE NtoA THEN
;

: GetHostIP ( addr u -- IP ior )
  WinVer 50 = IF GetHostIP EXIT THEN
  v>IDN
  DUP 0= IF NIP 11004 EXIT THEN \ иначе пустой хост S" " дает 0 0
\  OVER inet_addr DUP -1 <> IF NIP NIP 0 EXIT ELSE DROP THEN

  DROP
  Ip6Buf DUP >R
  IPV6_MODE @ IF 0 ( любой IP)
              ELSE Ip6Buf DUP ai_family AF_INET SWAP ! ( только IPv4)
              THEN
  ROT 0 SWAP getaddrinfo DUP 0=
  IF
    DROP R@ @
    DUP ai_addr @
    SWAP ai_family @ 2 =
    IF
      sin_addr @ 0
    ELSE
      sin6_addr Ip6Buf DUP >R 16 MOVE R> IP6_BUFFS @ - 0
    THEN
  ELSE
    0 SWAP
  THEN
  R> freeaddrinfo DROP \ *** fixme Win2000
;
: GetHostName ( IP -- addr u ior )
  DUP IsIPv6 0= IF GetHostName EXIT THEN
  IP6_BUFFS @ + AF_INET6 16 ROT gethostbyaddr
  ?DUP IF @ ?DUP IF ASCIIZ> 0 ELSE S" ?" 11004 THEN
       ELSE PAD 0 WSAGetLastError THEN
;
: ConnectSocket6 ( ip6_addr port socket -- ior )
  CONNECT-INTERFACE @ ?DUP 
  IF OVER 0 ROT ROT BindSocketInterface ?DUP IF NIP NIP NIP EXIT THEN THEN
  >R
  Ip6Buf >R
  RV16 R@ sin6_port W!
  R@ sin6_addr 16 MOVE
  AF_INET6 R@ sin6_family W!
  /sockaddr_in6 R> R> connect SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
: ConnectSocket ( ip port socket -- ior )
  2>R DUP IsIPv6
  IF IP6_BUFFS @ + 2R> ConnectSocket6
  ELSE 2R> ConnectSocket THEN
;

USER _ch_port
USER _ch_s4
USER _ch_s6
USER _ch_lerr

: ConnectHost ( addr u port -- sock ior )
\ ѕодключитьс€ к хосту addr u на порт port
\ с автоматическим перебором всех IP хоста.
\ ≈сли коннект не удалс€, то ior - код ошибки (на последнем хосте из списка)
\ и socks=0.
\ ≈сли удалс€, то sock - новый соединенный сокет, ior=0.

  IPV6_MODE @ 0= IF ConnectHost EXIT THEN
  WinVer 50 = IF ConnectHost EXIT THEN \ в win2000 нет getaddrinfo

  uLastCH_IP 0! _ch_port 0! _ch_s4 0! _ch_s6 0! _ch_lerr 0!

  >R OVER inet_addr -1 <> IF R> ConnectHost EXIT THEN

  v>IDN R>

  _ch_port ! DROP
  Ip6Buf DUP >R SWAP
  0 0 ROT getaddrinfo DUP 0=
  IF
    DROP R@
    BEGIN
      @ DUP
    WHILE
      DUP ai_family @ 2 =
      IF _ch_s4 @ 0= IF CreateSocketWithTimeout ?DUP IF NIP EXIT THEN _ch_s4 ! THEN
         DUP ai_addr @ sin_addr @
         DUP uLastCH_IP !
         _ch_port @ _ch_s4 @ DUP >R ConnectSocket
      ELSE _ch_s6 @ 0= IF CreateSocket6WithTimeout ?DUP IF NIP EXIT THEN _ch_s6 ! THEN
         DUP ai_addr @ sin6_addr
         _ch_port @ _ch_s6 @ DUP >R ConnectSocket6
      THEN
      R> SWAP
      ?DUP
      IF _ch_lerr ! DROP ai_next
      ELSE
         DUP _ch_s6 @ = IF _ch_s4 @ ELSE _ch_s6 @ THEN
         ?DUP IF CloseSocket DROP THEN
         R> freeaddrinfo DROP \ *** fixme Win2000
         NIP 0 EXIT
      THEN
    REPEAT DROP
    0 _ch_lerr @
  ELSE
    0 SWAP
  THEN
  R> freeaddrinfo DROP \ *** fixme Win2000
;
