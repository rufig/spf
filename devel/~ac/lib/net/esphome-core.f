\ ~ac/lib/net/esphome-core.f -- PORTABLE core of the ESPHome Native API (PLAINTEXT protobuf, NO crypto), a
\ Forth port of the user's esphome_app_server.  Shared by desktop spf64 (winsock, VARIABLE state) and the
\ ESP32-C3 (lwIP, @USER/EB state, OLED, LED).  The two differ ONLY in the platform layer + a handful of hooks,
\ all defined by the PLATFORM file before it INCLUDEs this one.  Wire format: 0x00 , varint(len) , varint(type)
\ , protobuf-payload.  CRLF.
\
\ The platform file MUST have already defined, before INCLUDE:
\   state buffers : HP HF RBUF TXTBUF  HA-LENS HA-XTS HA-ENTS  ( + accessors HA-ENT/HA-LEN/HA-XT )
\   state cells   : ESP-LSOCK ESP-CLIENT ESP-SUB RLEN PLA PLU ESP-GOT ESP-IDLE TXT-N HA-N ESP-RESUB PB-F  HA-TVAL-N HA-TVAL ESP-LASTPUB
\   consts        : HA-MAX RCAP TEXT-MAX
\   sockets       : WriteSocket ReadSocket  (RecvTimeoutSocket/NoDelaySocket used by the platform accept loop)
\   hooks         : HELLO-NAME ( -- a u )  DEV-NAME DEV-MAC DEV-VER DEV-MODEL DEV-PROJ ( -- a u )  device info
\                   S-UPTIME ( -- u )  S-HEAP ( -- u )  S-RSSI ( -- n )   raw sensor values (this file floats them)
\                   HB-FREQ ( -- hz )  HB-SET ( hz -- )   the "Blink frequency" number (LED on the C3, a value on desktop)
\                   SET-TEXT ( a u -- )   store the Text/OLED value (+ render on the C3 / echo on desktop)
DECIMAL

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
: FSEND ( fbuf sock -- )        >R  DUP PDATA SWAP PLEN R> WriteSocket  0< IF -8 THROW THEN ;   \ send err -> drop conn
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
\ fixed-point n/den -> IEEE-754 float32 (normalize into [1,2), 23-bit mantissa) -- lets sensors carry a decimal
: U/F32 ( num den -- bits )
   OVER 0= IF 2DROP 0 EXIT THEN  0 >R
   BEGIN 2DUP U< WHILE  SWAP 2* SWAP  R> 1- >R  REPEAT
   BEGIN 2DUP 2* U< 0= WHILE  2*  R> 1+ >R  REPEAT
   2DUP - 8388608 ROT */  NIP  R> 127 + 23 LSHIFT OR ;
: N/F32 ( num den -- bits )  OVER 0< IF SWAP NEGATE SWAP U/F32 1 31 LSHIFT OR ELSE U/F32 THEN ;
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

: PB-FIX32 ( a u field -- x found? )   \ read a wire-5 (fixed32) value at the given field#
   >R  OVER + SWAP
   BEGIN 2DUP U> WHILE
      DUP C@ DUP 3 RSHIFT R@ = OVER 7 AND 5 = AND IF DROP NIP 1+ @LE32 R> DROP TRUE EXIT THEN
      7 AND DUP 5 = IF DROP 5 + ELSE 0= IF 1+ SKIP-VARINT ELSE 1+ THEN THEN
   REPEAT  2DROP R> DROP 0 FALSE ;
: PB-VARINT ( a u field -- val found? )   \ read a wire-0 (varint) value at the given field#
   >R  OVER + SWAP
   BEGIN 2DUP U> WHILE
      DUP C@ DUP 3 RSHIFT R@ = OVER 7 AND 0= AND IF DROP NIP 1+ V@ DROP R> DROP TRUE EXIT THEN
      7 AND DUP 5 = IF DROP 5 + ELSE 0= IF 1+ SKIP-VARINT ELSE 1+ THEN THEN
   REPEAT  2DROP R> DROP 0 FALSE ;
\ ==== response builders (HP payload, HF frame) ; platform hooks supply the device-specific text ====
: SEND-HELLO ( -- )
   HP RST  1 1 HP FU  13 2 HP FU  HELLO-NAME 3 HP FS  DEV-NAME 4 HP FS  HP 2 HF ESP-CLIENT @ TX ;
: SEND-AUTH ( -- )  HP RST  0 1 HP FU  HP 4 HF ESP-CLIENT @ TX ;
: SEND-PONG ( -- )  HP RST  HP 8 HF ESP-CLIENT @ TX ;
: SEND-PING ( -- )  HP RST  HP 7 HF ESP-CLIENT @ TX ;
: SEND-BYE  ( -- )  HP RST  HP 6 HF ESP-CLIENT @ TX ;
: SEND-DEVINFO ( -- )
   HP RST
   0 1 HP FU  DEV-NAME 2 HP FS  DEV-MAC 3 HP FS  DEV-VER 4 HP FS
   S" n/a" 5 HP FS  DEV-MODEL 6 HP FS  DEV-PROJ 12 HP FS  HELLO-NAME 13 HP FS
   HP 10 HF ESP-CLIENT @ TX ;
: SEND-ENTITIES ( -- )                                    \ 3 sensors(16) + number(49) + text(97) + Done(19)
   HP RST  S" uptime" 1 HP FS  1 2 HP FF  S" Uptime"    3 HP FS  S" s"     6 HP FS  S" duration" 9 HP FS  1 10 HP FU   HP 16 HF ESP-CLIENT @ TX
   HP RST  S" heap"   1 HP FS  2 2 HP FF  S" Free heap" 3 HP FS  S" bytes" 6 HP FS  1 10 HP FU   HP 16 HF ESP-CLIENT @ TX
   HP RST  S" rssi"   1 HP FS  3 2 HP FF  S" WiFi RSSI" 3 HP FS  S" dBm"   6 HP FS  S" signal_strength" 9 HP FS  1 10 HP FU   HP 16 HF ESP-CLIENT @ TX
   HP RST  S" blink_freq" 1 HP FS  4 2 HP FF  S" Blink frequency" 3 HP FS
      1 U>F32 6 HP FF  10 U>F32 7 HP FF  1 U>F32 8 HP FF  S" Hz" 11 HP FS   HP 49 HF ESP-CLIENT @ TX
   HP RST  S" text" 1 HP FS  5 2 HP FF  S" Text" 3 HP FS  TEXT-MAX 9 HP FU  0 11 HP FU   HP 97 HF ESP-CLIENT @ TX
   [DEFINED] S-CO2 [IF]
      HP RST  S" co2"  1 HP FS  6 2 HP FF  S" CO2" 3 HP FS  S" ppm" 6 HP FS  S" carbon_dioxide" 9 HP FS  1 10 HP FU   HP 16 HF ESP-CLIENT @ TX
      HP RST  S" temp" 1 HP FS  7 2 HP FF  S" Temperature" 3 HP FS  S" °C" 6 HP FS  1 7 HP FU  S" temperature" 9 HP FS  1 10 HP FU   HP 16 HF ESP-CLIENT @ TX
      HP RST  S" hum"  1 HP FS  8 2 HP FF  S" Humidity" 3 HP FS  S" %" 6 HP FS  1 7 HP FU  S" humidity" 9 HP FS  1 10 HP FU   HP 16 HF ESP-CLIENT @ TX
   [THEN]
   [DEFINED] SET-RGB [IF]
      HP RST  S" led_r" 1 HP FS  9  2 HP FF  S" LED R" 3 HP FS  0 U>F32 6 HP FF  255 U>F32 7 HP FF  1 U>F32 8 HP FF  HP 49 HF ESP-CLIENT @ TX
      HP RST  S" led_g" 1 HP FS  10 2 HP FF  S" LED G" 3 HP FS  0 U>F32 6 HP FF  255 U>F32 7 HP FF  1 U>F32 8 HP FF  HP 49 HF ESP-CLIENT @ TX
      HP RST  S" led_b" 1 HP FS  11 2 HP FF  S" LED B" 3 HP FS  0 U>F32 6 HP FF  255 U>F32 7 HP FF  1 U>F32 8 HP FF  HP 49 HF ESP-CLIENT @ TX
      HP RST  S" rgb" 1 HP FS  12 2 HP FF  S" RGB LED" 3 HP FS  35 12 HP FU  HP 15 HF ESP-CLIENT @ TX   \ ListEntitiesLight: ColorMode RGB=35
   [THEN]
   HP RST  HP 19 HF ESP-CLIENT @ TX ;

\ ==== state pushers ====
: STATE-1 ( key fbits -- )  HP RST  SWAP 1 HP FF  2 HP FF  HP 25 HF ESP-CLIENT @ TX ;
: NUM-STATE ( -- )          HP RST  4 1 HP FF  HB-FREQ U>F32 2 HP FF  HP 50 HF ESP-CLIENT @ TX ;
: NSTATE ( key fbits -- )   HP RST  SWAP 1 HP FF  2 HP FF  HP 50 HF ESP-CLIENT @ TX ;   \ a number state for any key
: TEXT-STATE ( -- )         HP RST  5 1 HP FF  TXTBUF TXT-N @ 2 HP FS  HP 98 HF ESP-CLIENT @ TX ;
: DO-TEXT-CMD ( a u -- )    2 PB-FIELD 0= IF  TXTBUF 0  THEN  SET-TEXT  TEXT-STATE ;
: MX2 ( a b -- m )  2DUP < IF SWAP THEN DROP ;
: MX3 ( a b c -- m )  MX2 MX2 ;
[DEFINED] SET-RGB [IF]                                    \ NanoC6: RGB LED also exposed as an HA light (key 12)
: F255 ( bits -- u )   \ trunc(f*255), f in [0,1] : light colour/brightness float -> 0..255
   DUP 23 RSHIFT 255 AND  DUP 0= IF 2DROP 0 EXIT THEN
   127 -  SWAP 8388607 AND 8388608 OR  255 *
   SWAP 23 SWAP -  DUP 0< IF NEGATE LSHIFT ELSE RSHIFT THEN  255 MIN ;
: LIGHT-STATE ( -- )   \ LightStateResponse(24): on/off + brightness + rgb, decomposed from RGB@ (mx>=0 -> IF tests >0)
   RGB@ DUP 16 RSHIFT 255 AND LC-R !  DUP 8 RSHIFT 255 AND LC-G !  255 AND LC-B !
   LC-R @ LC-G @ LC-B @ MX3 LC-MX !
   HP RST  12 1 HP FF  LC-MX @ 0= 0= 1 AND 2 HP FU  LC-MX @ 255 U/F32 3 HP FF
   1 U>F32 10 HP FF  35 11 HP FU
   LC-MX @ IF LC-R @ LC-MX @ U/F32 ELSE 0 THEN 4 HP FF
   LC-MX @ IF LC-G @ LC-MX @ U/F32 ELSE 0 THEN 5 HP FF
   LC-MX @ IF LC-B @ LC-MX @ U/F32 ELSE 0 THEN 6 HP FF
   HP 24 HF ESP-CLIENT @ TX ;
: PUB-RGB ( -- )   9 RGB@ 16 RSHIFT 255 AND U>F32 NSTATE  10 RGB@ 8 RSHIFT 255 AND U>F32 NSTATE  11 RGB@ 255 AND U>F32 NSTATE
   LIGHT-STATE  RGB@ ESP-RGB-LAST ! ;                     \ push R/G/B numbers + the light state + remember (change detect)
[THEN]
: PUBLISH ( -- )
   1  S-UPTIME U>F32  STATE-1
   2  S-HEAP   U>F32  STATE-1
   3  S-RSSI   I>F32  STATE-1
   NUM-STATE  TEXT-STATE
   [DEFINED] S-CO2 [IF]  S-SENSE  6 S-CO2 U>F32 STATE-1  7 S-TEMP 10 N/F32 STATE-1  8 S-HUM 10 U/F32 STATE-1  [THEN]
   [DEFINED] SET-RGB [IF]  PUB-RGB  [THEN]  S-UPTIME ESP-LASTPUB ! ;   \ stamp the proactive-publish timer
: DO-NUMBER-CMD ( a u -- )   \ route the NumberCommand by key: 4 = blink ; 9/10/11 = LED R/G/B
   2DUP 1 PB-FIX32 0= IF 2DROP DROP EXIT THEN
   -ROT 2 PB-FIX32 0= IF 2DROP EXIT THEN                        ( key fbits )
   OVER 4 = IF  NIP F32>U HB-SET  NUM-STATE  EXIT THEN
   [DEFINED] SET-RGB [IF]  OVER 9 12 WITHIN IF  OVER 9 -  OVER F32>U  SET-RGB  NSTATE  EXIT THEN  [THEN]
   2DROP ;

[DEFINED] SET-RGB [IF]
: DO-LIGHT-CMD ( a u -- )   \ LightCommandRequest(32): state/brightness/rgb -> RGB!  (payload kept in LC-PA/LC-PU)
   LC-PU !  LC-PA !                                       \ save payload -> scratch (working stack stays clean)
   RGB@ DUP 16 RSHIFT 255 AND LC-R !  DUP 8 RSHIFT 255 AND LC-G !  255 AND LC-B !
   LC-R @ LC-G @ LC-B @ MX3 LC-MX !
   LC-PA @ LC-PU @ 2 PB-VARINT NIP IF                     \ has_state present
      LC-PA @ LC-PU @ 3 PB-VARINT DROP 0= IF  0 0 0 RGB!  LIGHT-STATE PUB-RGB EXIT  THEN
   THEN
   LC-PA @ LC-PU @ 4 PB-VARINT NIP IF  LC-PA @ LC-PU @ 5 PB-FIX32 DROP F255  ELSE  LC-MX @  THEN  LC-BM !
   LC-PA @ LC-PU @ 6 PB-VARINT NIP IF                     \ has_rgb: sent colour * brightness
      LC-PA @ LC-PU @ 7 PB-FIX32 DROP F255  LC-BM @ * 255 /
      LC-PA @ LC-PU @ 8 PB-FIX32 DROP F255  LC-BM @ * 255 /
      LC-PA @ LC-PU @ 9 PB-FIX32 DROP F255  LC-BM @ * 255 /
   ELSE                                                   \ no rgb: rescale current colour to the new brightness
      LC-MX @ 0= IF  LC-BM @ DUP DUP  ELSE
         LC-R @ LC-BM @ * LC-MX @ /  LC-G @ LC-BM @ * LC-MX @ /  LC-B @ LC-BM @ * LC-MX @ /
      THEN
   THEN
   RGB!  LIGHT-STATE PUB-RGB ;
[THEN]
\ ==== HA entity-state import ====
: HA-SUBSCRIBE ( a u xt -- )
   HA-N @ HA-MAX < 0= IF 2DROP DROP EXIT THEN
   HA-N @ >R  R@ HA-XT !  47 MIN DUP R@ HA-LEN !  R@ HA-ENT SWAP CMOVE  R> DROP  1 HA-N +!  1 ESP-RESUB ! ;
: HA-SUB-ONE ( slot -- )
   >R  HP RST  R@ HA-ENT  R@ HA-LEN @  1 HP FS  HP 39 HF ESP-CLIENT @ TX  R> DROP ;
: HA-SUB-ALL ( -- )   HA-N @ 0 ?DO I HA-SUB-ONE LOOP ;
: HA-STATE-IN ( -- )
   PLA @ PLU @  1 PB-FIELD 0= IF EXIT THEN
   PLA @ PLU @  2 PB-FIELD 0= IF 2DROP EXIT THEN
   HA-N @ 0 ?DO
      2OVER  I HA-ENT  I HA-LEN @  COMPARE 0= IF  2DUP  I HA-XT @ EXECUTE  THEN
   LOOP  2DROP 2DROP ;

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
   DUP 32 = IF DROP [DEFINED] DO-LIGHT-CMD [IF] PLA @ PLU @ DO-LIGHT-CMD [THEN] EXIT THEN
   DUP 99 = IF DROP PLA @ PLU @ DO-TEXT-CMD    EXIT THEN
   DUP 40 = IF DROP HA-STATE-IN  EXIT THEN
   DROP ;

\ ==== incoming frame parsing (sliding RBUF) ====
: SHIFT-BUF ( n -- )  DUP RLEN @ SWAP -  >R  RBUF OVER +  RBUF  R@ CMOVE  R> RLEN !  DROP ;
: PARSE-ONE ( -- done? )
   RLEN @ 2 < IF TRUE EXIT THEN
   RBUF C@   IF 0 RLEN ! TRUE EXIT THEN
   RBUF 1+ V@ 1+
   DUP RBUF + V@
   >R SWAP R> +
   DUP RBUF + PLA !
   2 PICK PLU !
   2 PICK +
   RLEN @ OVER < IF DROP 2DROP TRUE EXIT THEN
   SWAP DISPATCH  NIP SHIFT-BUF  FALSE ;
: RECV-LOOP ( -- )
   0 RLEN !  0 ESP-GOT !  0 ESP-IDLE !  S-UPTIME ESP-LASTPUB !
   BEGIN
      ESP-RESUB @ ESP-SUB @ AND IF  HA-SUB-ALL  0 ESP-RESUB !  THEN
      ESP-SUB @ IF  S-UPTIME ESP-LASTPUB @ -  29 >  IF  PUBLISH  THEN  THEN   \ time-based proactive push (~30s), RX-independent: HA keeps the link alive by ponging our pings, which resets ESP-IDLE, so the idle counter alone never fires
      [DEFINED] SET-RGB [IF]  ESP-SUB @ IF  RGB@ ESP-RGB-LAST @ <> IF  PUB-RGB  THEN  THEN  [THEN]   \ console/blink -> HA
      RBUF RLEN @ +  RCAP RLEN @ -  ESP-CLIENT @ ReadSocket  DROP
      DUP 0= IF DROP EXIT THEN
      DUP 0< IF
         DROP  1 ESP-IDLE +!
         ESP-GOT @ 0= IF EXIT THEN
         ESP-IDLE @ 4 MOD 0= IF SEND-PING THEN
         ESP-IDLE @ 16 > IF EXIT THEN
      ELSE
         1 ESP-GOT !  0 ESP-IDLE !  RLEN +!
         RBUF C@ IF EXIT THEN
         BEGIN PARSE-ONE UNTIL
      THEN
   AGAIN ;
