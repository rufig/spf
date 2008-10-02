\ Windows Sockets

WINAPI: socket          WSOCK32.DLL
WINAPI: listen          WSOCK32.DLL
WINAPI: accept          WSOCK32.DLL
WINAPI: connect         WSOCK32.DLL
WINAPI: send            WSOCK32.DLL
WINAPI: recv            WSOCK32.DLL
WINAPI: closesocket     WSOCK32.DLL
WINAPI: bind            WSOCK32.DLL
WINAPI: ioctlsocket     WSOCK32.DLL
WINAPI: WSAGetLastError WSOCK32.DLL
WINAPI: gethostbyaddr   WSOCK32.DLL
WINAPI: gethostbyname   WSOCK32.DLL
WINAPI: getpeername     WSOCK32.DLL
WINAPI: WSAStartup      WSOCK32.DLL
WINAPI: WSACleanup      WSOCK32.DLL
WINAPI: inet_addr       WSOCK32.DLL
WINAPI: inet_ntoa       WSOCK32.DLL
WINAPI: setsockopt      WSOCK32.DLL
WINAPI: shutdown        WSOCK32.DLL
WINAPI: gethostname     WSOCK32.DLL
WINAPI: select          WSOCK32.DLL

1  CONSTANT SOCK_STREAM
2  CONSTANT SOCK_DGRAM
-1 CONSTANT INVALID_SOCKET
-1 CONSTANT SOCKET_ERROR
2  CONSTANT PF_INET
2  CONSTANT AF_INET
6  CONSTANT IPPROTO_TCP
17 CONSTANT IPPROTO_UDP
1000 VALUE ListenQlen

BASE @ HEX
FFFF CONSTANT SOL_SOCKET
0080 CONSTANT SO_LINGER
0020 CONSTANT SO_BROADCAST
1005 CONSTANT SO_SNDTIMEO
1006 CONSTANT SO_RCVTIMEO
0004 CONSTANT SO_REUSEADDR
BASE !

SO_LINGER INVERT CONSTANT SO_DONTLINGER

0
2 -- sin_family
2 -- sin_port
4 -- sin_addr
8 -- sin_zero
CONSTANT /sockaddr_in

\ CREATE sock_addr HERE /sockaddr_in DUP ALLOT ERASE
\ AF_INET sock_addr sin_family W!

USER-CREATE sock_addr /sockaddr_in USER-ALLOT

CREATE LINGER 1 W, 3 W,
\ 6000 W, слишком много, это в секундах, заменил на 30 - 26.06.2001 ~ac
\ 3 W, 16.01.2004 ~ac

CREATE BROADCAST -1 ,
CREATE REUSEADDR -1 ,

: CreateSocket ( -- socket ior )
  IPPROTO_TCP SOCK_STREAM PF_INET
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
\       OVER >R 4 LINGER SO_LINGER SOL_SOCKET R>
\       setsockopt OR
  THEN
;

USER TIMEOUT

: CreateSocketWithTimeout ( -- socket ior )
  IPPROTO_TCP SOCK_STREAM PF_INET
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
\       OVER >R 4 LINGER SO_LINGER SOL_SOCKET R>
\       setsockopt OR
       OVER >R 4 TIMEOUT SO_SNDTIMEO SOL_SOCKET R>
       setsockopt OR
       OVER >R 4 TIMEOUT SO_RCVTIMEO SOL_SOCKET R>
       setsockopt OR
  THEN
;
: SetSocketTimeout ( timeout socket -- ior )
  SWAP TIMEOUT !
  DUP >R 4 TIMEOUT SO_SNDTIMEO SOL_SOCKET R>
  setsockopt
  SWAP >R 4 TIMEOUT SO_RCVTIMEO SOL_SOCKET R>
  setsockopt OR
;
: CreateUdpSocket ( -- socket ior )
  IPPROTO_UDP SOCK_DGRAM PF_INET
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
  THEN
;
: CreateBroadcastSocket ( -- socket ior )
  IPPROTO_UDP SOCK_DGRAM PF_INET
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
       OVER >R 4 BROADCAST SO_BROADCAST SOL_SOCKET R>
       setsockopt OR
  THEN
;
: ToRead ( socket -- n ior )
  \ сколько байт можно сейчас прочесть из сокета
  \ можно использовать перед ReadSocket для того чтобы
  \ избежать блокирования при n=0
  4 ALLOCATE THROW >R R@ 0!
  R@ [ HEX ] 4004667F [ DECIMAL ] ROT ioctlsocket SOCKET_ERROR =
  IF 0 WSAGetLastError ELSE R@ @ 0 THEN R> FREE THROW
;
: BindSocketInterface ( port ip s -- ior )
  >R /sockaddr_in ALLOCATE ?DUP IF NIP R> DROP EXIT THEN
  SWAP >R >R
  256 /MOD SWAP 256 * +
  R@ sin_port W!
  AF_INET R@ sin_family W!
  R@
  R> R> SWAP >R R@ sin_addr !
  /sockaddr_in R> R> bind SWAP FREE DROP SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
USER CONNECT-INTERFACE

: ConnectSocket ( IP port socket -- ior )
  CONNECT-INTERFACE @ ?DUP 
  IF OVER 0 ROT ROT BindSocketInterface ?DUP IF NIP NIP NIP EXIT THEN THEN
  >R
  256 /MOD SWAP 256 * +
  sock_addr sin_port W!
  sock_addr sin_addr !
  AF_INET sock_addr sin_family W!
  /sockaddr_in sock_addr R> connect SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
: CloseSocket ( s -- ior )
\ linger по умолчанию: graceful close без таймаута, устанавливаем таймаут на закрытие
  DUP >R 4 LINGER SO_LINGER SOL_SOCKET R> setsockopt DROP
  100 PAUSE \ без этой паузы пакеты закрытия иногда доходят раньше хвоста
            \ данных, что на клиенте выглядит как 10054, никакие варианты linger не спасают
  2 ( SD_BOTH) OVER shutdown DROP
  100 PAUSE
  closesocket SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
: FastCloseSocket ( s -- ior )
  DUP >R 4 LINGER SO_DONTLINGER SOL_SOCKET R> setsockopt DROP
\  2 ( SD_BOTH) OVER shutdown DROP
  closesocket SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
: WriteSocket ( addr u s -- ior )
  >R SWAP 2>R 0 2R> R> send SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
: WriteSocketLine ( addr u s -- ior )
  DUP >R WriteSocket ?DUP IF R> DROP EXIT THEN
  LT LTL @ R> WriteSocket
;
: WriteSocketCRLF ( s -- ior )
  PAD 0 ROT WriteSocketLine
;
: ReadSocket ( addr u s -- rlen ior )
  >R SWAP 2>R 0 2R> R> recv DUP SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
  OVER 0= IF DROP -1002 THEN
  ( если принято 0, то обрыв соединения )
;
\ : GetHostName ( IP -- addr u ior )
\   PAD ! PF_INET 4 PAD gethostbyaddr
\   ?DUP IF @ ASCIIZ> 0 ELSE HERE 0 WSAGetLastError THEN
\ ;

\ бывают случаи, когда не возвращают ошибку, но и имя не дают
\ на других линках тот же IP дает ошибку 11004

: GetHostName ( IP -- addr u ior )
  PAD ! PF_INET 4 PAD gethostbyaddr
  ?DUP IF @ ?DUP IF ASCIIZ> 0 ELSE S" ?" 11004 THEN
       ELSE PAD 0 WSAGetLastError THEN
;

: Get.Host.Name ( addr u -- addr u ior )
  DROP inet_addr GetHostName
;
: GetHostIP ( addr u -- IP ior )
  DUP 0= IF NIP 11004 EXIT THEN \ иначе пустой хост S" " дает 0 0
  OVER inet_addr DUP -1 <> IF NIP NIP 0 EXIT ELSE DROP THEN
  DROP gethostbyname DUP IF 3 CELLS + @ @ @ 0
                         ELSE WSAGetLastError THEN
;
\ CREATE sock_addr2 HERE /sockaddr_in DUP ALLOT ERASE
\ AF_INET sock_addr2 sin_family W!

USER-CREATE sock_addr2 /sockaddr_in USER-ALLOT

: GetPeerName ( s -- addr u ior )
  /sockaddr_in PAD !
  PAD sock_addr2 ROT getpeername SOCKET_ERROR =
  IF PAD 0 WSAGetLastError
  ELSE sock_addr2 sin_addr @ GetHostName THEN
;
: GetPeerIP ( s -- IP ior )
  /sockaddr_in CELL+ ALLOCATE THROW >R
  /sockaddr_in R@ !
  R@ DUP CELL+ ROT getpeername SOCKET_ERROR =
  IF 0 WSAGetLastError
  ELSE R@ CELL+ sin_addr @ 0 THEN
  R> FREE THROW
;
: GetPeerIP&Port ( s -- IP port ior )
  /sockaddr_in CELL+ ALLOCATE THROW >R
  /sockaddr_in R@ !
  R@ DUP CELL+ ROT getpeername SOCKET_ERROR =
  IF 0 0 WSAGetLastError
  ELSE R@ CELL+ sin_addr @ R@ CELL+ sin_port W@ 256 /MOD SWAP 256 * + 0 THEN
  R> FREE THROW
;
: SocketsStartup ( -- ior )
  PAD 257 WSAStartup
;
: SocketsCleanup ( -- ior )
  WSACleanup
;
: BindSocket ( port s -- ior )
  0 SWAP BindSocketInterface
;
: ReuseAddrSocket ( s -- ior )
  >R 4 REUSEADDR SO_REUSEADDR SOL_SOCKET R>
  setsockopt
;
: ReusedBindSocket ( port s -- ior )
  DUP ReuseAddrSocket ?DUP IF NIP NIP EXIT THEN
  BindSocket
;
: ListenSocket ( s -- ior )
  ListenQlen SWAP listen SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
CREATE SINLEN /sockaddr_in ,

: AcceptSocket ( s -- s2 ior )
\  SINLEN HERE
  0 0
  ROT accept DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
\       OVER >R 4 LINGER SO_LINGER SOL_SOCKET R>
\       setsockopt OR
  THEN
;
: NtoA ( IP -- addr u )
\  [ BASE @ HEX ]
\  >R 0 0 <# 2DROP R@  1000000 U/ FF AND 0 #S [CHAR] . HOLD
\            2DROP R@    10000 U/ FF AND 0 #S [CHAR] . HOLD
\            2DROP R@      100 U/ FF AND 0 #S [CHAR] . HOLD
\            2DROP R>             FF AND 0 #S
\         #>
\  [ BASE ! ]
  inet_ntoa ASCIIZ>
;
: AcceptSocketNotBlock ( s -- s2 ior )
  0 >R 60 >R RP@ \ timeout 60 sec
  SWAP
  0 \ exc
  0 \ write
  ROT >R 1 >R RP@ \ read
  0
  select 
  RDROP R> RDROP RDROP SWAP
  DUP 0= IF DROP 10060 EXIT THEN
  SOCKET_ERROR = IF WSAGetLastError EXIT THEN
  AcceptSocket
;
USER _GetHostIPs

: GetHostIPs ( addr u -- IPab IPae ior )
\ Получить список IP multihomed-хоста
\ IPab IPae возвращаются в формате для последующего цикла DO, см. ConnectHost
  DUP 0= IF 11004 EXIT THEN \ иначе пустой хост S" " дает ior=0
  OVER inet_addr DUP -1 <> IF NIP NIP _GetHostIPs ! _GetHostIPs DUP CELL+ SWAP 
                              0 EXIT
                           ELSE DROP THEN
  DROP gethostbyname DUP IF DUP @ SWAP 3 CELLS + @ @ 0
                         ELSE 0 WSAGetLastError THEN
;

\ todo: в Vista и Win2008 можно переключиться на WSAConnectByName

: ConnectHost ( addr u port -- sock ior )
\ Подключиться к хосту addr u на порт port
\ с автоматическим перебором всех IP хоста.
\ Если коннект не удался, то ior - код ошибки (на последнем хосте из списка)
\ и socks=0.
\ Если удался, то sock - новый соединенный сокет, ior=0.
  >R
  GetHostIPs ?DUP IF ROT DROP RDROP EXIT THEN
  ( IPab IPae )
  0 ROT ROT
  CreateSocketWithTimeout ?DUP IF 2SWAP 2DROP ROT DROP RDROP EXIT THEN
  R> SWAP 2SWAP DO ( ior port socket )
    2DUP I @       ( ior port socket port socket ip )
    ROT ROT ConnectSocket ?DUP 
    IF ( ior1 port socket ior )
       >R ROT DROP R> ROT ROT
    ELSE NIP NIP 0 UNLOOP EXIT THEN
  4 +LOOP CloseSocket THROW DROP 0 SWAP
;

\ ~pinka/lib/sockets-ext.f 

: READ-SOCK-EXACT ( a u socket -- ior )
  >R BEGIN DUP WHILE
    2DUP R@ ReadSocket ?DUP IF NIP NIP NIP RDROP EXIT THEN ( a1 u1 u2 )
    ( в случае, если принято 0, ReadSocket возвращает ior -1002,
    в отличии от READ-FILE, который возвращет ior 0 и длину 0)
    TUCK - -ROT + SWAP
  REPEAT ( a1 0 )
  NIP RDROP
;
: ReadSocketExact ( a u socket -- ior ) \ см. также "read" в sock2.f
  READ-SOCK-EXACT
;
