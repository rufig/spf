SOCKNAME.f

\ struct ip_mreq {
\         struct in_addr  imr_multiaddr;  /* IP multicast address of group */
\         struct in_addr  imr_interface;  /* local IP address of interface */
\ };

\ 5 CONSTANT IP_ADD_MEMBERSHIP
\ 6 CONSTANT IP_DROP_MEMBERSHIP
\ вот и верь после этого winsock.h
12 CONSTANT IP_ADD_MEMBERSHIP
13 CONSTANT IP_DROP_MEMBERSHIP


: SocketAddMembership ( port ip s -- ior )
  >R /sockaddr_in 2* ALLOCATE ?DUP IF NIP R> DROP EXIT THEN
  SWAP >R >R
  256 /MOD SWAP 256 * +
  R@ sin_port W!
  AF_INET R@ sin_family W!
  AF_INET R@ /sockaddr_in + sin_family W!
\  0 ( INADDR_ANY) R@ /sockaddr_in + sin_addr !
  R@
  R> R> SWAP >R R@ sin_addr !
  /sockaddr_in 2* R> IP_ADD_MEMBERSHIP 0 ( IPPROTO_IP) R> setsockopt SWAP FREE DROP SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
: SocketAddMembership ( ip s -- ior )
  >R 8 ALLOCATE ?DUP IF NIP RDROP EXIT THEN
  >R
  R@ !
\ интерфейс указывать обязательно!
 S" 10.1.1.1" ( S" 224.0.0.251") GetHostIP THROW R@ CELL+ !
  8 R> IP_ADD_MEMBERSHIP 0 ( IPPROTO_IP) R> setsockopt SOCKET_ERROR =
  IF WSAGetLastError ELSE 0 THEN
;
: CreateMcSocket ( -- socket ior )
  0 SOCK_DGRAM PF_INET
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE
     DUP ReuseAddrSocket THROW
     0
  THEN
;

0 VALUE MC
: TEST
SocketsStartup THROW
CreateMcSocket THROW TO MC

\ порт для bind указывать обязательно!

\ 5353 = mDNS
5353 ( S" 10.1.1.1" GetHostIP THROW DROP) 0 MC BindSocketInterface .

\ 5355 = LLMNR
 S" 224.0.0.252" GetHostIP THROW MC SocketAddMembership THROW

\ Web Services Dynamic Discovery, port 3702
  S" 239.255.255.250" GetHostIP THROW MC SocketAddMembership THROW

\ 5353 = mDNS
 S" 224.0.0.251" GetHostIP THROW MC SocketAddMembership THROW
 PAD 1500 MC ReadFrom ." A"
;
TEST
