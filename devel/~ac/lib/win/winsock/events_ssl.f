REQUIRE CreateSocket  ~ac/lib/win/winsock/sockets.f
REQUIRE uSocketEvent  ~ac/lib/win/winsock/events.f 
REQUIRE SslServerSocket ~ac/lib/win/winsock/sockets_ssl.f

: SslWaitIdle2 ( -- )
  BEGIN
    1 0 0 0 PAD PeekMessageA
  WHILE
    PAD ['] vProcessMessage CATCH
    IF DROP EXIT THEN
  REPEAT
  100 PAUSE
;

' SslWaitIdle2 TO dSslWaitIdle

: SslWaitInit2 ( -- )
  uSSL_SOCKET @ vNoneventSocket? IF EXIT THEN
  uSocketEvent @ 0=
  IF
    0 0 0 0 CreateEventA DUP 0= IF GetLastError THROW THEN
    uSocketEvent !
    FD_ALL_EVENTS uSocketEvent @ uSSL_SOCKET @ WSAEventSelect IF GetLastError THROW THEN
  THEN
;

' SslWaitInit2 TO dSslWaitInit