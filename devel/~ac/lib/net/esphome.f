\ ~ac/lib/net/esphome.f -- DESKTOP platform layer for the ESPHome Native API server (spf64).  The protocol
\ engine is the SHARED esphome-core.f; here we supply the platform: VARIABLE/CREATE state, a winsock/POSIX TCP
\ SERVER, desktop sensor sources (uptime), console instead of an OLED, and a plain "blink frequency" value.
\ No crypto (plaintext protobuf).  Run:  ESPHOME-RUN  (blocking accept loop on :6053).  CRLF.
DECIMAL

\ ---- TCP sockets (classic spf CreateSocket/Accept/Read/Write/Close) ----
[DEFINED] WINAPI64: [IF]
   [UNDEFINED] socket [IF]
      3 WINAPI64: socket          WSOCK32.DLL      2 WINAPI64: listen          WSOCK32.DLL
      3 WINAPI64: accept          WSOCK32.DLL      3 WINAPI64: connect         WSOCK32.DLL
      4 WINAPI64: send            WSOCK32.DLL      4 WINAPI64: recv            WSOCK32.DLL
      1 WINAPI64: closesocket     WSOCK32.DLL      3 WINAPI64: bind            WSOCK32.DLL
      3 WINAPI64: ioctlsocket     WSOCK32.DLL      0 WINAPI64: WSAGetLastError WSOCK32.DLL
      3 WINAPI64: gethostbyaddr   WSOCK32.DLL      1 WINAPI64: gethostbyname   WSOCK32.DLL
      3 WINAPI64: getpeername     WSOCK32.DLL      2 WINAPI64: WSAStartup      WSOCK32.DLL
      0 WINAPI64: WSACleanup      WSOCK32.DLL      1 WINAPI64: inet_addr       WSOCK32.DLL
      1 WINAPI64: inet_ntoa       WSOCK32.DLL      5 WINAPI64: setsockopt      WSOCK32.DLL
      2 WINAPI64: shutdown        WSOCK32.DLL      2 WINAPI64: gethostname     WSOCK32.DLL
      5 WINAPI64: select          WSOCK32.DLL
   [THEN]
   [UNDEFINED] Sleep        [IF] 1 WINAPI64: Sleep        KERNEL32.DLL [THEN]
   [UNDEFINED] GetTickCount [IF] 0 WINAPI64: GetTickCount KERNEL32.DLL [THEN]
   REQUIRE ReadSocket ~ac/lib/win/winsock/sockets.f
   SocketsStartup DROP
   [UNDEFINED] MS [IF] : MS ( ms -- ) Sleep ; [THEN]
   : TICKS ( -- ms )  GetTickCount [ HEX ] FFFFFFFF [ DECIMAL ] AND ;
[ELSE]
   REQUIRE ReadSocket ~ac/lib/lin/net/sockets.f
   [UNDEFINED] MS [IF] : MS ( ms -- ) 1000 * USLEEP ; [THEN]
   : TICKS ( -- ms )  0 ;
[THEN]
: NoDelaySocket    ( s -- ior )     DROP 0 ;
: RecvTimeoutSocket ( ms s -- ior ) SetSocketTimeout ;

\ ---- state ----
8 CONSTANT HA-MAX    2048 CONSTANT RCAP    64 CONSTANT TEXT-MAX
VARIABLE ESP-LSOCK   VARIABLE ESP-CLIENT  VARIABLE ESP-SUB    VARIABLE RLEN
VARIABLE PLA         VARIABLE PLU         VARIABLE ESP-GOT    VARIABLE ESP-IDLE
VARIABLE TXT-N       VARIABLE HA-N        VARIABLE ESP-RESUB  VARIABLE HA-TVAL-N   VARIABLE PB-F
VARIABLE ESP-LASTPUB   \ S-UPTIME at last PUBLISH (proactive-publish timer, RX-independent)
CREATE HA-LENS  HA-MAX CELLS ALLOT   CREATE HA-XTS   HA-MAX CELLS ALLOT   CREATE HA-ENTS  HA-MAX 48 * ALLOT
CREATE TXTBUF   128 ALLOT   CREATE HA-TVAL  64 ALLOT   CREATE HP  512 ALLOT   CREATE HF  512 ALLOT   CREATE RBUF  RCAP ALLOT
: HA-ENT ( i -- a )  48 * HA-ENTS + ;
: HA-LEN ( i -- a )  CELLS HA-LENS + ;
: HA-XT  ( i -- a )  CELLS HA-XTS + ;

\ ---- platform hooks the shared core calls ----
: HELLO-NAME ( -- a u )  S" SP-Forth/4" ;
: DEV-NAME   ( -- a u )  S" spf64" ;
: DEV-MAC    ( -- a u )  S" 02:00:5A:64:00:01" ;
: DEV-VER    ( -- a u )  S" 0.9.0" ;
: DEV-MODEL  ( -- a u )  S" desktop" ;
: DEV-PROJ   ( -- a u )  S" SP-Forth" ;
VARIABLE T0
: S-UPTIME ( -- u )  TICKS T0 @ -  1000 / ;                \ seconds since ESPHOME-INIT
: S-HEAP   ( -- u )  TICKS 4096 MOD 262144 + ;             \ desktop has no MCU heap -- a mildly-varying placeholder
: S-RSSI   ( -- n )  -50 ;                                 \ no WiFi -- fixed demo dBm
VARIABLE BLINK-HZ   1 BLINK-HZ !
: HB-FREQ  ( -- hz )  BLINK-HZ @ ;
: HB-SET   ( hz -- )  ?DUP 0= IF 1 THEN  DUP 10 > IF DROP 10 THEN  BLINK-HZ ! ;
: SET-TEXT ( a u -- )  127 MIN DUP TXT-N !  TXTBUF SWAP CMOVE
   ." [esphome text] " TXTBUF TXT-N @ TYPE CR ;            \ desktop: echo to console instead of an OLED
: HA-TEMP! ( a u -- )  63 MIN DUP HA-TVAL-N !  HA-TVAL SWAP CMOVE
   ." [esphome HA-import] " HA-TVAL HA-TVAL-N @ TYPE CR ;  \ demo handler: store + echo an imported HA sensor

\ ---- the shared protocol engine (protobuf + parse + senders + DISPATCH + RECV-LOOP) ----
REQUIRE RECV-LOOP ~ac/lib/net/esphome-core.f

\ ---- accept loop (foreground) ----
: (ESPH-1) ( -- )
   ESP-LSOCK @ AcceptSocket THROW ESP-CLIENT !
   ESP-CLIENT @ NoDelaySocket DROP
   3000 ESP-CLIENT @ RecvTimeoutSocket DROP
   0 ESP-SUB !  RECV-LOOP ;
: ESPHOME-SERVE ( port -- )
   ." esphome api listening :" DUP . CR
   CreateSocket THROW ESP-LSOCK !
   ESP-LSOCK @ ReuseAddrSocket DROP
   ESP-LSOCK @ BindSocket THROW
   ESP-LSOCK @ ListenSocket THROW
   BEGIN
      ['] (ESPH-1) CATCH ?DUP IF  S" esph accept err " TYPE . CR  100 MS  THEN
      ESP-CLIENT @ IF ESP-CLIENT @ CloseSocket DROP 0 ESP-CLIENT ! THEN
      0 ESP-SUB !
   AGAIN ;
: ESPHOME-INIT ( -- )
   0 ESP-LSOCK !  0 ESP-CLIENT !  0 ESP-SUB !  0 RLEN !  0 HA-N !  0 ESP-RESUB !
   0 TXT-N !  0 HA-TVAL-N !  TICKS T0 !
   S" sensor.at4ptw_temperature" ['] HA-TEMP! HA-SUBSCRIBE ;
: ESPHOME-RUN ( -- )  ESPHOME-INIT  6053 ESPHOME-SERVE ;

\EOF
\ ---- self-test.  Past \EOF (not run on a normal load); to run it:  : \EOF ;  then INCLUDE this file.
\ Offline: verify the protobuf builders + float32 encoding.  For a LIVE check run  ESPHOME-RUN  and point Home
\ Assistant (or scratchpad/test-esph.py) at :6053 -- HA sees device "spf64" with 3 sensors + a Number + a Text.
DECIMAL
: EDUMP ( a u -- )  BASE @ >R HEX 0 ?DO DUP I + C@ 0 <# # # #> TYPE SPACE LOOP DROP R> BASE ! CR ;
: T-HELLO  HP RST  1 1 HP FU  13 2 HP FU  S" SP-Forth/4" 3 HP FS  S" spf64" 4 HP FS
   HP 2 HF FRAME!  ." HelloResponse: " HF PDATA HF PLEN EDUMP
   ."   want:        00 17 02 08 01 10 0D 1A 0A 53 50 2D 46 6F 72 74 68 2F 34 22 05 73 70 66 36 34" CR ;
: T-F32  ." U>F32(1)= " 1 U>F32 BASE @ >R HEX U. R> BASE !  ."  (want 3F800000) ; F32>U(3F800000)= "
   [ HEX ] 3F800000 [ DECIMAL ] F32>U .  ." (want 1)" CR ;
CR ." === esphome.f offline self-test ===" CR  T-HELLO  T-F32  CR
