\ Windows Sockets

WINAPI: socket          WS2_32.DLL
WINAPI: WSASocketA      WS2_32.DLL
WINAPI: listen          WS2_32.DLL
WINAPI: accept          WS2_32.DLL
WINAPI: connect         WS2_32.DLL
WINAPI: send            WS2_32.DLL
WINAPI: recv            WS2_32.DLL
WINAPI: closesocket     WS2_32.DLL
WINAPI: bind            WS2_32.DLL
WINAPI: ioctlsocket     WS2_32.DLL
WINAPI: WSAGetLastError WS2_32.DLL
WINAPI: gethostbyaddr   WS2_32.DLL
WINAPI: gethostbyname   WS2_32.DLL
WINAPI: getpeername     WS2_32.DLL
WINAPI: WSAStartup      WS2_32.DLL
WINAPI: WSACleanup      WS2_32.DLL
WINAPI: inet_addr       WS2_32.DLL
WINAPI: inet_ntoa       WS2_32.DLL
WINAPI: setsockopt      WS2_32.DLL
WINAPI: shutdown        WS2_32.DLL

1  CONSTANT SOCK_STREAM
2  CONSTANT SOCK_DGRAM
-1 CONSTANT INVALID_SOCKET
-1 CONSTANT SOCKET_ERROR
2  CONSTANT PF_INET
2  CONSTANT AF_INET
6  CONSTANT IPPROTO_TCP
17 CONSTANT IPPROTO_UDP

BASE @ HEX
FFFF CONSTANT SOL_SOCKET
0080 CONSTANT SO_LINGER
0020 CONSTANT SO_BROADCAST
1005 CONSTANT SO_SNDTIMEO
1006 CONSTANT SO_RCVTIMEO
BASE !

0
2 -- sin_family
2 -- sin_port
4 -- sin_addr
8 -- sin_zero
CONSTANT /sockaddr_in

CREATE sock_addr HERE /sockaddr_in DUP ALLOT ERASE
AF_INET sock_addr sin_family W!

CREATE LINGER 1 W, 6000 W,
CREATE BROADCAST -1 ,

: CreateSocketO ( -- socket ior )
  IPPROTO_TCP SOCK_STREAM PF_INET
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
       OVER >R 4 LINGER SO_LINGER SOL_SOCKET R>
       setsockopt OR
  THEN
;
: CreateSocket ( -- socket ior )
  0 0 0
  IPPROTO_TCP SOCK_STREAM PF_INET
  WSASocketA DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
       OVER >R 4 LINGER SO_LINGER SOL_SOCKET R>
       setsockopt OR
  THEN
;

USER TIMEOUT

: CreateSocketWithTimeoutO ( -- socket ior )
  IPPROTO_TCP SOCK_STREAM PF_INET
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
       OVER >R 4 LINGER SO_LINGER SOL_SOCKET R>
       setsockopt OR
       OVER >R 4 TIMEOUT SO_SNDTIMEO SOL_SOCKET R>
       setsockopt OR
       OVER >R 4 TIMEOUT SO_RCVTIMEO SOL_SOCKET R>
       setsockopt OR
  THEN
;
: CreateSocketWithTimeout ( -- socket ior )
  0 0 0
  IPPROTO_TCP SOCK_STREAM PF_INET
  WSASocketA DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
       OVER >R 4 LINGER SO_LINGER SOL_SOCKET R>
       setsockopt OR
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
\       OVER >R 4 LINGER SO_LINGER SOL_SOCKET R>
\       setsockopt OR
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
: ConnectSocket ( IP port socket -- ior )
  >R
  256 /MOD SWAP 256 * +
  sock_addr sin_port W!
  sock_addr sin_addr !
  /sockaddr_in sock_addr R> connect SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
: CloseSocket ( s -- ior )
  DUP >R 4 LINGER SO_LINGER SOL_SOCKET R> setsockopt DROP
\  2 OVER shutdown DROP
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
  HERE 0 ROT WriteSocketLine
;
: ReadSocket ( addr u s -- rlen ior )
  >R SWAP 2>R 0 2R> R> recv DUP SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
  OVER 0= IF DROP -1002 THEN
  ( если принято 0, то обрыв соединения )
;
: GetHostName ( IP -- addr u ior )
  PAD ! PF_INET 4 PAD gethostbyaddr
  ?DUP IF @ ASCIIZ> 0 ELSE HERE 0 WSAGetLastError THEN
;
: Get.Host.Name ( addr u -- addr u ior )
  DROP inet_addr GetHostName
;
: GetHostIP ( addr u -- IP ior )
  OVER inet_addr DUP -1 <> IF NIP NIP 0 EXIT ELSE DROP THEN
  DROP gethostbyname DUP IF 3 CELLS + @ @ @ 0
                         ELSE WSAGetLastError THEN
;
CREATE sock_addr2 HERE /sockaddr_in DUP ALLOT ERASE
AF_INET sock_addr2 sin_family W!

: GetPeerName ( s -- addr u ior )
  /sockaddr_in HERE !
  HERE sock_addr2 ROT getpeername SOCKET_ERROR =
  IF HERE 0 WSAGetLastError
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
  HERE 2 WSAStartup
;
: SocketsCleanup ( -- ior )
  WSACleanup
;
: BindSocket ( port s -- ior )
  >R /sockaddr_in ALLOCATE ?DUP IF NIP R> DROP EXIT THEN
  >R
  256 /MOD SWAP 256 * +
  R@ sin_port W!
  AF_INET R@ sin_family W!
  R@
  0 R@ sin_addr !
  /sockaddr_in R> R> bind SWAP FREE DROP SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
: ListenSocket ( s -- ior )
  100 SWAP listen SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
CREATE SINLEN /sockaddr_in ,

: AcceptSocket ( s -- s2 ior )
\  SINLEN HERE
  0 0
  ROT accept DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE 0
       OVER >R 4 LINGER SO_LINGER SOL_SOCKET R>
       setsockopt OR
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
