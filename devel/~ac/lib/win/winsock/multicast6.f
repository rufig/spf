REQUIRE CreateSocket6  ~ac/lib/win/winsock/sockets6.f 
REQUIRE CreateMcSocket ~ac/lib/win/winsock/multicast.f 

: CreateMcSocket6 ( -- socket ior )
  0 SOCK_DGRAM AF_INET6
  socket DUP INVALID_SOCKET =
  IF WSAGetLastError
  ELSE
     DUP ReuseAddrSocket THROW
     0
  THEN
;
