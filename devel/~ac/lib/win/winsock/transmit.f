REQUIRE CreateSocket  ~ac/lib/win/winsock/sockets.f

WINAPI: TransmitFile Mswsock.dll

: PutFileTr ( h s -- ior )
  2>R 0 0 0 0 0 2R> TransmitFile IF 0 ELSE WSAGetLastError THEN
;

\EOF
\ Пример
S" session.txt" R/O OPEN-FILE THROW
SocketsStartup THROW
CreateSocket THROW S" localhost" GetHostIP THROW OVER 25 SWAP ConnectSocket THROW
2DUP PutFileTr THROW
CloseSocket THROW
CLOSE-FILE THROW
