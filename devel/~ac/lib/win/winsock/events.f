REQUIRE CreateSocket ~ac/lib/win/winsock/sockets.f
REQUIRE ToRead2      ~ac/lib/win/winsock/toread2.f 

WINAPI: CreateEventA              KERNEL32.DLL
WINAPI: WSAEventSelect            WS2_32.DLL
WINAPI: MsgWaitForMultipleObjects USER32.DLL
WINAPI: PostThreadMessageA        USER32.DLL
WINAPI: PeekMessageA              USER32.DLL
WINAPI: GetTickCount              KERNEL32.DLL

1 10 LSHIFT 1- CONSTANT FD_ALL_EVENTS
        0x04FF CONSTANT QS_ALLINPUT

USER uSocketEvent \ event-сокет может быть только один per thread!
                  \ vNoneventSocket? нужно переопределять, если могут быть еще обычные сокеты
USER uLastSocketRead \ когда последний раз был ReadSocket, а не сообщение
\ Если таймаут сокета больше частоты поступления сообщений,
\ например если поставить 500 вместо 5000 в примере ниже,
\ то таймаут MsgWFMO не сработает, поэтому в этом случае стоит проверять
\ сокет в обработчике сообщений тоже.
\ Для упрощения (отмены :) этой заботы сделан трюк с uLastSocketRead.
\ К тому же теперь поток может в ответе на сообщение указать, как давно он
\ висит на текущем ReadSocket.

VARIABLE vSEvDebug

VECT vProcessMessage

: ProcessMessage1 ( msg -- )
  BASE @ >R HEX
  CELL+ @ 0 <# #S S" EMSG_" HOLDS #> R> BASE !
  TYPE CR
;
' ProcessMessage1 TO vProcessMessage

VECT vNoneventSocket?

: NoneventSocket?1 ( socket -- flag )
  DROP FALSE
; ' NoneventSocket?1 TO vNoneventSocket?

: ReadSocketB ReadSocket ; \ старая (блокирующая) версия

WARNING @ WARNING 0!

: ReadSocket ( addr u s -- rlen ior )
  DUP vNoneventSocket? IF ReadSocket GetTickCount uLastSocketRead ! EXIT THEN

  uSocketEvent @ 0= IF
    0 0 0 0 CreateEventA DUP 0= IF 2DROP 2DROP 0 GetLastError EXIT THEN
    uSocketEvent !
    DUP FD_ALL_EVENTS uSocketEvent @ ROT WSAEventSelect IF DROP 2DROP 0 GetLastError EXIT THEN
  THEN

  DUP ToRead2 ?DUP IF 2>R DROP 2DROP 2R> EXIT THEN
  IF ReadSocket GetTickCount uLastSocketRead ! EXIT THEN \ если сокет уже готов, то сразу читаем порцию (без событий) и выходим

  BEGIN
    QS_ALLINPUT
    TIMEOUT @ DUP 0= IF DROP -1 THEN
    0 uSocketEvent 1 MsgWaitForMultipleObjects
    DUP 258 = ( WAIT_TIMEOUT) IF 2DROP 2DROP 0 10060 EXIT THEN
    DUP 2 U< 0=
    IF vSEvDebug @ IF ." MsgWFMO error " THEN 2DROP 2DROP 0 -1003 TRUE
    ELSE 0=
      IF \ 0=сокеты
         DUP ToRead2 ?DUP IF 2>R DROP 2DROP 2R> EXIT THEN
         IF ReadSocket GetTickCount uLastSocketRead ! TRUE ELSE FALSE THEN
      ELSE \ 1=сообщения
         \ DUP ToRead2 ?DUP IF 2>R DROP 2DROP 2R> EXIT THEN \ а жив ли сокет?
         \ ^ здесь ToRead2 или ioctlsocket использовать нельзя, будет 10038
         TIMEOUT @ 0<>
         IF
           GetTickCount uLastSocketRead @ - TIMEOUT @ >
           IF DROP 2DROP 0 10060 EXIT THEN
         THEN
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
: WriteSocketB WriteSocket ;

200 VALUE WriteSocketRetryDelay

: WriteSocket { addr u s -- ior }
  s vNoneventSocket? IF addr u s WriteSocket EXIT THEN
  BEGIN
    addr u s WriteSocket DUP 10035 = \ WSAEWOULDBLOCK
  WHILE
    DROP WriteSocketRetryDelay PAUSE
  REPEAT
;
WARNING !

: InitEventsQueue
  0 ( PM_NOREMOVE)
  0x0400 DUP ( PM_NOREMOVE WM_USER WM_USER)
  0 PAD PeekMessageA DROP
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
    PAD 10 SOO @ ReadSocket 2DUP . . ." D3=" DEPTH .
    THROW PAD SWAP TYPE
    ." ." CR
    1000 PAUSE
." depth2=" DEPTH . CR
  AGAIN
;
: TTT ['] TEST CATCH . PPP @ STOP ;
3000 TIMEOUT !
TTT
