( Andrey Cherezov )
\ старая библиотека для работы с UDP и добавления к TCP
\ надо бы убрать ALLOCATE, т.к. в SPF/3.7x можно под это дело 
\ буфер сделать безопасно

REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f
REQUIRE {            ~ac/lib/locals.f


WINAPI: getsockname     WSOCK32.DLL
WINAPI: recvfrom        WSOCK32.DLL
WINAPI: sendto          WSOCK32.DLL

: sockIP&Port ( socket -- IP port )
\ IP=0, если клиент уже отключился!
  { s \ nlen nam }
  32 ALLOCATE THROW -> nam
  32 -> nlen
  ^ nlen nam s getsockname
  IF WSAGetLastError THROW THEN
  nam sin_addr @
  nam sin_port DUP C@ 256 * SWAP CHAR+ C@ +
  nam FREE THROW
;
: ReadFrom ( addr u socket -- size IP port )
  { adr u sock \ sin }
  /sockaddr_in CELL+ ALLOCATE THROW -> sin
  /sockaddr_in sin /sockaddr_in + DUP >R !
  R> sin 0 u adr sock recvfrom
  DUP SOCKET_ERROR = OVER u > OR    \ ~ac 18.01.02  (*)
  IF DROP sin FREE DROP WSAGetLastError THROW -1 THROW ( *) THEN
  u MIN 0 MAX ( *)
  sin sin_addr @ sin sin_port W@ 256 /MOD SWAP 256 * +
  sin FREE DROP
;
: WriteTo ( IP port addr u socket -- )
  { adr u sock \ sin }
  /sockaddr_in ALLOCATE THROW -> sin
  256 /MOD SWAP 256 * + sin sin_port W!
  sin sin_addr !
  AF_INET sin sin_family W! sin sin_zero 8 ERASE
  /sockaddr_in sin 0 u adr sock sendto
  u < IF sin FREE DROP WSAGetLastError THROW -1 THROW ( *) THEN
  sin FREE DROP
;