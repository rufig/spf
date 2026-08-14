\ ~ac/lib/net/esphome.f -- ESPHome Native API server (PLAINTEXT protobuf, NO crypto) for desktop spf64.
\ A Forth port of the ESP32-C3 c3-esphome.f (itself a port of github.com/ac/esphome_app_server).  The device
\ is a TCP server on :6053 that Home Assistant connects INTO.  The protobuf engine + message handling are the
\ same as the C3; only the platform layer differs: plain VARIABLE/CREATE state (no freeze), winsock/POSIX
\ server sockets, desktop sensor sources (uptime), and the console in place of the OLED.  CRLF.
\ Wire format: frame = 0x00 , varint(payload_len) , varint(msg_type) , protobuf-payload.  Run:  ESPHOME-RUN .
DECIMAL

\ ---- TCP sockets (same surface as tuya.f: the classic spf CreateSocket/Accept/Read/Write/Close) ----
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
   : TICKS ( -- ms )  0 ;                                 \ (POSIX uptime hook -- fill in if needed)
[THEN]
: NoDelaySocket    ( s -- ior )     DROP 0 ;              \ desktop: skip TCP_NODELAY (latency only)
: RecvTimeoutSocket ( ms s -- ior ) SetSocketTimeout ;

\ ---- state (plain VARIABLE/CREATE; single accept thread, so unshared) ----
8 CONSTANT HA-MAX    2048 CONSTANT RCAP
VARIABLE ESP-LSOCK   VARIABLE ESP-CLIENT  VARIABLE ESP-SUB    VARIABLE RLEN
VARIABLE PLA         VARIABLE PLU         VARIABLE ESP-GOT    VARIABLE ESP-IDLE
VARIABLE TXT-N       VARIABLE HA-N        VARIABLE ESP-RESUB  VARIABLE HA-TVAL-N   VARIABLE PB-F
CREATE HA-LENS  HA-MAX CELLS ALLOT        \ entity_id lengths
CREATE HA-XTS   HA-MAX CELLS ALLOT        \ handler xts
CREATE HA-ENTS  HA-MAX 48 * ALLOT         \ entity_ids (48 B/slot)
CREATE TXTBUF   128 ALLOT                  \ text value (<=127)
CREATE HA-TVAL  64 ALLOT                   \ imported-sensor value (<=63)
CREATE HP       512 ALLOT                  \ response / state payload
CREATE HF       512 ALLOT                  \ framed message
CREATE RBUF     RCAP ALLOT                 \ incoming frame accumulator
: HA-ENT ( i -- a )  48 * HA-ENTS + ;
: HA-LEN ( i -- a )  CELLS HA-LENS + ;
: HA-XT  ( i -- a )  CELLS HA-XTS + ;

\ ==== protobuf byte builders (each threads its buffer; cell 0 = running write-ptr) ====
: RST   ( buf -- )     DUP CELL+ SWAP ! ;
: PDATA ( buf -- a )   CELL+ ;
: PLEN  ( buf -- u )   DUP @ SWAP CELL+ - ;
: C+    ( c buf -- )   >R  R@ @  TUCK C!  1+ R> ! ;
: V+    ( u buf -- )   SWAP BEGIN DUP 127 > WHILE 2DUP 127 AND 128 OR SWAP C+ 7 RSHIFT REPEAT SWAP C+ ;
: 32+   ( x buf -- )   >R  DUP 255 AND R@ C+  8 RSHIFT DUP 255 AND R@ C+  8 RSHIFT DUP 255 AND R@ C+  8 RSHIFT 255 AND R> C+ ;
: S+    ( a u buf -- ) DUP @ >R  OVER R@ + SWAP !  R> SWAP CMOVE ;
: TAG   ( field wire buf -- )   >R  SWAP 3 LSHIFT OR  R> V+ ;
: FU    ( u field buf -- )      >R  0 R@ TAG  R> V+ ;              \ uint32 / bool  (wire 0)
: FS    ( a u field buf -- )    >R  2 R@ TAG  DUP R@ V+  R> S+ ;   \ string (wire 2)
: FF    ( x field buf -- )      >R  5 R@ TAG  R> 32+ ;             \ fixed32 / float (wire 5)
: FRAME! ( pbuf type fbuf -- )  DUP RST  0 OVER C+  >R  OVER PLEN R@ V+  R@ V+  DUP PDATA SWAP PLEN R@ S+  R> DROP ;
: FSEND ( fbuf sock -- )        >R  DUP PDATA SWAP PLEN R> WriteSocket DROP ;
: TX    ( pbuf type fbuf sock -- )  >R  DUP >R  FRAME!  R> R> FSEND ;

\ ==== integer <-> IEEE-754 float32 ====
: HIBIT ( u -- e )   0 >R  BEGIN DUP 1 > WHILE 1 RSHIFT R> 1+ >R REPEAT DROP R> ;
: U>F32 ( u -- bits )
   ?DUP 0= IF 0 EXIT THEN
   DUP HIBIT  DUP 127 + 23 LSHIFT  -ROT  23 SWAP -
   DUP 0< IF NEGATE RSHIFT ELSE LSHIFT THEN  8388607 AND  OR ;
: I>F32 ( n -- bits )  DUP 0< IF NEGATE U>F32 1 31 LSHIFT OR ELSE U>F32 THEN ;
: F32>U ( bits -- u )
   DUP 23 RSHIFT 255 AND 127 -  DUP 0< IF 2DROP 0 EXIT THEN
   SWAP 8388607 AND 8388608 OR  SWAP 23 -
   DUP 0< IF NEGATE RSHIFT ELSE LSHIFT THEN ;
: @LE32 ( a -- x )  DUP C@  OVER 1+ C@ 8 LSHIFT OR  OVER 2 + C@ 16 LSHIFT OR  SWAP 3 + C@ 24 LSHIFT OR ;
: SKIP-VARINT ( a -- a' )  BEGIN DUP C@ 128 AND WHILE 1+ REPEAT 1+ ;
: V@ ( a -- val nbytes )
   DUP C@  DUP 128 AND 0= IF  NIP 1 EXIT  THEN
   127 AND  SWAP 1+ C@  7 LSHIFT OR  2 ;
: FSKIP ( a -- a' )
   DUP C@ 7 AND
   DUP 0= IF DROP 1+ SKIP-VARINT EXIT THEN
   DUP 5 =  IF DROP 5 + EXIT THEN
   DUP 1 =  IF DROP 9 + EXIT THEN
   DROP 1+ DUP V@ >R + R> + ;
: PB-FIELD ( a u field# -- str-a str-u TRUE | FALSE )
   PB-F !  OVER + SWAP
   BEGIN 2DUP U> WHILE
      DUP C@  DUP 3 RSHIFT PB-F @ =  SWAP 7 AND 2 = AND IF
         NIP 1+ DUP V@  SWAP >R +  R>  TRUE EXIT
      THEN
      FSKIP
   REPEAT  2DROP FALSE ;
: PB-STATE ( a u -- bits found? )
   OVER + SWAP
   BEGIN 2DUP U> WHILE
      DUP C@ DUP 3 RSHIFT 2 = OVER 7 AND 5 = AND IF DROP NIP 1+ @LE32 TRUE EXIT THEN
      7 AND DUP 5 = IF DROP 5 + ELSE 0= IF 1+ SKIP-VARINT ELSE 1+ THEN THEN
   REPEAT  2DROP 0 FALSE ;

\ ==== a settable "Blink frequency" number (no LED on desktop -- just a value HA can set/read) ====
VARIABLE BLINK-HZ   1 BLINK-HZ !
: HB-FREQ ( -- hz )  BLINK-HZ @ ;
: HB-SET  ( hz -- )  ?DUP 0= IF 1 THEN  DUP 10 > IF DROP 10 THEN  BLINK-HZ ! ;

\ ==== desktop sensor sources ====
VARIABLE T0
: UPTIME-S ( -- s )  TICKS T0 @ -  1000 / ;
: DEMO-HEAP ( -- u )  TICKS 4096 MOD 262144 + ;          \ desktop has no MCU heap -- a mildly-varying placeholder
: DEMO-RSSI ( -- n )  -50 ;                               \ no WiFi -- report a fixed demo dBm

\ ==== response builders (HP payload, HF frame) ====
: SEND-HELLO ( -- )
   HP RST  1 1 HP FU  13 2 HP FU  S" SP-Forth/4" 3 HP FS  S" spf64" 4 HP FS  HP 2 HF ESP-CLIENT @ TX ;
: SEND-AUTH ( -- )  HP RST  0 1 HP FU  HP 4 HF ESP-CLIENT @ TX ;
: SEND-PONG ( -- )  HP RST  HP 8 HF ESP-CLIENT @ TX ;
: SEND-PING ( -- )  HP RST  HP 7 HF ESP-CLIENT @ TX ;
: SEND-BYE  ( -- )  HP RST  HP 6 HF ESP-CLIENT @ TX ;
: SEND-DEVINFO ( -- )
   HP RST
   0 1 HP FU  S" spf64" 2 HP FS  S" 02:00:5A:64:00:01" 3 HP FS  S" 0.9.0" 4 HP FS
   S" n/a" 5 HP FS  S" desktop" 6 HP FS  S" SP-Forth" 12 HP FS  S" SPF64" 13 HP FS
   HP 10 HF ESP-CLIENT @ TX ;
: SEND-ENTITIES ( -- )                                    \ 3 sensors(16) + number(49) + text(97) + Done(19)
   HP RST  S" uptime" 1 HP FS  1 2 HP FF  S" Uptime"    3 HP FS  S" s"     6 HP FS   HP 16 HF ESP-CLIENT @ TX
   HP RST  S" heap"   1 HP FS  2 2 HP FF  S" Free heap" 3 HP FS  S" bytes" 6 HP FS   HP 16 HF ESP-CLIENT @ TX
   HP RST  S" rssi"   1 HP FS  3 2 HP FF  S" WiFi RSSI" 3 HP FS  S" dBm"   6 HP FS   HP 16 HF ESP-CLIENT @ TX
   HP RST  S" blink_freq" 1 HP FS  4 2 HP FF  S" Blink frequency" 3 HP FS
      1 U>F32 6 HP FF  10 U>F32 7 HP FF  1 U>F32 8 HP FF  S" Hz" 11 HP FS   HP 49 HF ESP-CLIENT @ TX
   HP RST  S" text" 1 HP FS  5 2 HP FF  S" Text" 3 HP FS  64 9 HP FU  0 11 HP FU   HP 97 HF ESP-CLIENT @ TX
   HP RST  HP 19 HF ESP-CLIENT @ TX ;

\ ==== state pushers ====
: STATE-1 ( key fbits -- )  HP RST  SWAP 1 HP FF  2 HP FF  HP 25 HF ESP-CLIENT @ TX ;
: NUM-STATE ( -- )          HP RST  4 1 HP FF  HB-FREQ U>F32 2 HP FF  HP 50 HF ESP-CLIENT @ TX ;
: SET-TEXT ( a u -- )       127 MIN DUP TXT-N !  TXTBUF SWAP CMOVE
   ." [esphome text] " TXTBUF TXT-N @ TYPE CR ;           \ desktop: echo to console instead of the OLED
: TEXT-STATE ( -- )         HP RST  5 1 HP FF  TXTBUF TXT-N @ 2 HP FS  HP 98 HF ESP-CLIENT @ TX ;
: DO-TEXT-CMD ( a u -- )    2 PB-FIELD 0= IF  TXTBUF 0  THEN  SET-TEXT  TEXT-STATE ;
: PUBLISH ( -- )
   1  UPTIME-S   U>F32  STATE-1
   2  DEMO-HEAP  U>F32  STATE-1
   3  DEMO-RSSI  I>F32  STATE-1
   NUM-STATE  TEXT-STATE ;
: DO-NUMBER-CMD ( a u -- )  PB-STATE IF  F32>U HB-SET  NUM-STATE  ELSE DROP THEN ;

\ ==== HA entity-state import ====
: HA-SUBSCRIBE ( a u xt -- )
   HA-N @ HA-MAX < 0= IF 2DROP DROP EXIT THEN
   HA-N @ >R  R@ HA-XT !  47 MIN DUP R@ HA-LEN !  R@ HA-ENT SWAP CMOVE  R> DROP  1 HA-N +!  1 ESP-RESUB ! ;
: HA-SUB-ONE ( slot -- )
   >R  HP RST  R@ HA-ENT  R@ HA-LEN @  1 HP FS  HP 39 HF ESP-CLIENT @ TX  R> DROP ;
: HA-SUB-ALL ( -- )   HA-N @ 0 ?DO I HA-SUB-ONE LOOP ;
: HA-STATE-IN ( -- )
   PLA @ PLU @  1 PB-FIELD 0= IF EXIT THEN                 ( ent-a ent-u )
   PLA @ PLU @  2 PB-FIELD 0= IF 2DROP EXIT THEN           ( ent-a ent-u st-a st-u )
   HA-N @ 0 ?DO
      2OVER  I HA-ENT  I HA-LEN @  COMPARE 0= IF  2DUP  I HA-XT @ EXECUTE  THEN
   LOOP  2DROP 2DROP ;
: HA-TEMP! ( a u -- )   63 MIN DUP HA-TVAL-N !  HA-TVAL SWAP CMOVE
   ." [esphome HA-import] " HA-TVAL HA-TVAL-N @ TYPE CR ;  \ demo handler: store + echo

\ ==== dispatch on msg-type ====
: DISPATCH ( type -- )
   DUP 1  = IF DROP SEND-HELLO    EXIT THEN
   DUP 3  = IF DROP SEND-AUTH     EXIT THEN
   DUP 7  = IF DROP SEND-PONG  ESP-SUB @ IF PUBLISH THEN  EXIT THEN
   DUP 9  = IF DROP SEND-DEVINFO  EXIT THEN
   DUP 5  = IF DROP SEND-BYE      EXIT THEN
   DUP 11 = IF DROP SEND-ENTITIES EXIT THEN
   DUP 20 = IF DROP 1 ESP-SUB !  PUBLISH  HA-SUB-ALL  EXIT THEN
   DUP 38 = IF DROP HA-SUB-ALL  EXIT THEN
   DUP 51 = IF DROP PLA @ PLU @ DO-NUMBER-CMD  EXIT THEN
   DUP 99 = IF DROP PLA @ PLU @ DO-TEXT-CMD    EXIT THEN
   DUP 40 = IF DROP HA-STATE-IN  EXIT THEN
   DROP ;

\ ==== incoming frame parsing (sliding RBUF) ====
: SHIFT-BUF ( n -- )  DUP RLEN @ SWAP -  >R  RBUF OVER +  RBUF  R@ CMOVE  R> RLEN !  DROP ;
: PARSE-ONE ( -- done? )
   RLEN @ 2 < IF TRUE EXIT THEN
   RBUF C@   IF 0 RLEN ! TRUE EXIT THEN
   RBUF 1+ V@ 1+                 ( fsize off1 )
   DUP RBUF + V@                 ( fsize off1 type n2 )
   >R SWAP R> +                  ( fsize type poff )
   DUP RBUF + PLA !
   2 PICK PLU !
   2 PICK +                      ( fsize type total )
   RLEN @ OVER < IF DROP 2DROP TRUE EXIT THEN
   SWAP DISPATCH  NIP SHIFT-BUF  FALSE ;
: RECV-LOOP ( -- )
   0 RLEN !  0 ESP-GOT !  0 ESP-IDLE !
   BEGIN
      ESP-RESUB @ ESP-SUB @ AND IF  HA-SUB-ALL  0 ESP-RESUB !  THEN
      RBUF RLEN @ +  RCAP RLEN @ -  ESP-CLIENT @ ReadSocket  DROP   ( rlen )
      DUP 0= IF DROP EXIT THEN
      DUP 0< IF
         DROP  1 ESP-IDLE +!
         ESP-GOT @ 0= IF EXIT THEN
         ESP-IDLE @ 4 MOD 0= IF SEND-PING THEN
         ESP-IDLE @ 30 > IF EXIT THEN
      ELSE
         1 ESP-GOT !  0 ESP-IDLE !  RLEN +!
         RBUF C@ IF EXIT THEN
         BEGIN PARSE-ONE UNTIL
      THEN
   AGAIN ;

\ ==== accept loop (foreground; Ctrl-C to stop) ====
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
: ESPHOME-INIT ( -- )   \ zero the live cells + register the demo HA import
   0 ESP-LSOCK !  0 ESP-CLIENT !  0 ESP-SUB !  0 RLEN !  0 HA-N !  0 ESP-RESUB !
   0 TXT-N !  0 HA-TVAL-N !  TICKS T0 !
   S" sensor.at4ptw_temperature" ['] HA-TEMP! HA-SUBSCRIBE ;   \ demo import (adapt/remove for your own entities)
: ESPHOME-RUN ( -- )  ESPHOME-INIT  6053 ESPHOME-SERVE ;       \ blocking: serve HA on :6053

\EOF
\ ---- self-test.  Past \EOF (not run on a normal load); to run it:  : \EOF ;  then INCLUDE this file.
\ Offline: verify the protobuf builders + float32 encoding.  For a LIVE check run  ESPHOME-RUN  and point Home
\ Assistant (or any plaintext ESPHome-API client) at :6053 -- HA sees device "spf64" with 3 sensors + a Number + a Text.
DECIMAL
: EDUMP ( a u -- )  BASE @ >R HEX 0 ?DO DUP I + C@ 0 <# # # #> TYPE SPACE LOOP DROP R> BASE ! CR ;
: T-HELLO  HP RST  1 1 HP FU  13 2 HP FU  S" SP-Forth/4" 3 HP FS  S" spf64" 4 HP FS
   HP 2 HF FRAME!  ." HelloResponse: " HF PDATA HF PLEN EDUMP
   ."   want:        00 17 02 08 01 10 0D 1A 0A 53 50 2D 46 6F 72 74 68 2F 34 22 05 73 70 66 36 34" CR ;
: T-F32  ." U>F32(1)= " 1 U>F32 BASE @ >R HEX U. R> BASE !  ."  (want 3F800000) ; F32>U(3F800000)= "
   [ HEX ] 3F800000 [ DECIMAL ] F32>U .  ." (want 1)" CR ;
CR ." === esphome.f offline self-test ===" CR  T-HELLO  T-F32  CR
