\ ToRead2 - расширенный вариант ToRead, возвращающий ошибку -1002
\ при обрыве или закрытии соединения (старый ToRead обрывов не замечает)
\ ср. PAD 0x541B ( FIONREAD) s ioctlsocket ...

REQUIRE {             lib/ext/locals.f
REQUIRE CreateSocket  ~ac/lib/win/winsock/sockets.f

: ToRead2 { s1 \ mem -- n ior }
  5 CELLS ALLOCATE THROW -> mem
  1  mem !
  s1 mem CELL+ !
  0  mem 2 CELLS + !

  0  mem 3 CELLS + !
  50  mem 4 CELLS + ! \ таймаут 50ms

  mem 3 CELLS +  mem 0 mem 0 select
  mem FREE ?DUP IF 0 SWAP EXIT THEN

  DUP SOCKET_ERROR = IF DROP 0 WSAGetLastError EXIT THEN
  s1 ToRead ?DUP IF ROT DROP EXIT THEN

  DUP ROT 0 1 D= IF -1002 EXIT THEN
  0
;

\EOF

SocketsStartup . 
: TEST
  CreateSocket THROW >R
  10000 R@ BindSocket THROW
  R@ ListenSocket THROW
  R@ AcceptSocket THROW
  BEGIN
    DUP ToRead2 . . DEPTH . CR
    2000 PAUSE
  AGAIN
;
TEST
