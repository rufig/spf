REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f
REQUIRE ToRead2      ~ac/lib/win/winsock/toread2.f 

WINAPI: CreateEventA              KERNEL32.DLL
WINAPI: WSAEventSelect            WS2_32.DLL
WINAPI: MsgWaitForMultipleObjects USER32.DLL
WINAPI: PostThreadMessageA        USER32.DLL
WINAPI: PeekMessageA              USER32.DLL

1 10 LSHIFT 1- CONSTANT FD_ALL_EVENTS
        0x04FF CONSTANT QS_ALLINPUT

USER uSocketEvent

VECT vProcessMessage

: ProcessMessage1 ( msg -- )
  BASE @ >R HEX
  CELL+ @ 0 <# #S S" EMSG_" HOLDS #> R> BASE !
  TYPE CR
;
' ProcessMessage1 TO vProcessMessage

: ReadSocket ( addr u s -- rlen ior )
  uSocketEvent @ 0= IF
    0 0 0 0 CreateEventA DUP 0= IF 2DROP 2DROP 0 GetLastError EXIT THEN
    uSocketEvent !
    DUP FD_ALL_EVENTS uSocketEvent @ ROT WSAEventSelect IF DROP 2DROP 0 GetLastError EXIT THEN
  THEN
  BEGIN
    QS_ALLINPUT -1 0 uSocketEvent 1 MsgWaitForMultipleObjects
    DUP 2 U< 0=
    IF ." MsgWFMO error " 2DROP 2DROP 0 -1003 TRUE
    ELSE 0=
      IF \ 0=сокеты
         DUP ToRead2 ?DUP IF 2>R DROP 2DROP 2R> EXIT THEN
         IF ReadSocket TRUE ELSE FALSE THEN
      ELSE \ 1=сообщения
         BEGIN
           1 0 0 0 PAD PeekMessageA
         WHILE
           PAD ['] vProcessMessage CATCH ?DUP
           IF NIP NIP NIP 0 SWAP EXIT THEN
         REPEAT
         FALSE
      THEN
    THEN
  UNTIL
;

\EOF

WINAPI: GetCurrentThreadId        KERNEL32.DLL

USER SOO USER PPP

:NONAME ( tid -- )
  >R
  ." Poster started" CR
  BEGIN
    5000 PAUSE
    ." Posting..."
    0 0 0x401 R@ PostThreadMessageA .
    ." OK" CR
  AGAIN
  RDROP
; TASK: Poster

: TEST
  SocketsStartup THROW
  S" localhost" 25 ConnectHost THROW SOO !

  GetCurrentThreadId DUP . Poster START PPP !

  ( WAIT_TIMEOUT 258L)
  BEGIN
    ." w..."
    PAD 10 SOO @ ReadSocket 2DUP . . THROW PAD SWAP TYPE
    ." ." CR
    1000 PAUSE
." depth2=" DEPTH . CR
  AGAIN
;
: TTT ['] TEST CATCH . PPP @ STOP ;
TTT
