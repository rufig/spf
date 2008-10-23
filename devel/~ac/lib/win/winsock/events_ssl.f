REQUIRE CreateSocket  ~ac/lib/win/winsock/sockets.f
REQUIRE uSocketEvent  ~ac/lib/win/winsock/events.f 
REQUIRE SslServerSocket ~ac/lib/win/winsock/sockets_ssl.f

: SslWaitIdle2
  BEGIN
    1 0 0 0 PAD PeekMessageA
  WHILE
    PAD ['] vProcessMessage CATCH
    IF DROP EXIT THEN
  REPEAT
  20 PAUSE
;

' SslWaitIdle2 TO vSslWaitIdle