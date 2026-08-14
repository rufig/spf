\ ~ac/lib/net/tuya-scan.f -- GENERIC Tuya discovery + key-probe + poll + decode for desktop spf64.
\ Desktop analog of the ESP32-C3 tuya-creds.f workflow.  On the C3 device discovery came from the NEIGH
\ .NB table (passive sniff of the Tuya UDP discovery broadcasts); here we listen for those :6667 broadcasts
\ directly with a UDP socket and take each device's IP from the datagram source + its version from the frame
\ magic (00 00 55 AA = v3.1-3.4, 00 00 66 99 = v3.5) -- no decryption, exactly like c3-neigh.f TUYA?.
\ Struct fields (records + sockaddr) are named with -- like ~ac/lib/net/dtls-net.f, not numeric offsets.
\ NO SECRETS here.  The key/id tables (TU-KEYS TU-IDS #TU TU-DEC) come from a gitignored tuya-creds.f that
\ is loaded FIRST and then REQUIREs this file.  CRLF.
REQUIRE TUYA-STATUS ~ac/lib/net/tuya.f
DECIMAL
: (U.) ( u -- )  0 <# #S #> TYPE ;

\ ---- registry accessors (tables live in the gitignored creds file) ----
16 CONSTANT /KEY   26 CONSTANT /IDREC
: TU-KEY ( n -- a )    /KEY * TU-KEYS + ;
: TU-ID  ( n -- a u )  /IDREC * TU-IDS + COUNT ;

\ ---- device records (ip + protocol version), one layout for the discovered set and the located set ----
0  CELL -- rec.ip  CELL -- rec.ver  CONSTANT /REC

\ ---- probe: only the right key negotiates / decrypts to valid JSON ----
: RT! ( -- )  900 TSOCK @ SetSocketTimeout DROP ;   \ short recv timeout so a wrong key/version fails fast
: TUYA-TRY   ( ip key-a -- ok )  DKEY ! DIP ! TUYA-OPEN 0= IF 0 EXIT THEN RT! NEG   TCLOSE ;
: TUYA34-TRY ( ip key-a -- ok )  DKEY ! DIP ! TUYA-OPEN 0= IF 0 EXIT THEN RT! NEG34 TCLOSE ;
: TUYA33-TRY ( ip id-a id-u key-a -- ok )   \ ECB DP_QUERY; ok = retcode 0 AND reply decrypts to JSON
   DKEY ! ROT DIP !
   S" 1700000000" JSON-DPQ PKCS7
   DUP >R DKEY @ -ROT TXB f55.pl ECB-ENC DROP R>
   10 PACK55
   TUYA-OPEN 0= IF 2DROP 0 EXIT THEN RT!
   TSEND TRECV 28 < IF TCLOSE 0 EXIT THEN
   RXB f55.pl BE@ IF TCLOSE 0 EXIT THEN                 \ retcode != 0 = device rejected this key
   RXB f55.len BE@ 12 - DUP 0 > OVER 353 < AND 0= IF DROP TCLOSE 0 EXIT THEN
   DKEY @ RXB f55.pl /RETCODE + 2 PICK PTB ECB-DEC DROP
   PTB SWAP FIND{ NIP 0<> TCLOSE ;
: TU-M35 ( ip -- n )  #TU 0 DO DUP I TU-KEY TUYA-TRY   IF DROP I UNLOOP EXIT THEN LOOP DROP -1 ;
: TU-M33 ( ip -- n )  #TU 0 DO DUP I TU-ID I TU-KEY TUYA33-TRY IF DROP I UNLOOP EXIT THEN LOOP DROP -1 ;
: TU-M34 ( ip -- n )  #TU 0 DO DUP I TU-KEY TUYA34-TRY IF DROP I UNLOOP EXIT THEN LOOP DROP -1 ;

\ ---- located-device table (registry index -> ip + protocol used) ----
CREATE TU-LOC  #TU /REC * ALLOT
: TU-ROW ( n -- a )  /REC * TU-LOC + ;
: TU-IP  ( n -- a )  TU-ROW rec.ip ;
: TU-VER ( n -- a )  TU-ROW rec.ver ;
: REACH? ( ip -- ok )  DIP ! TUYA-OPEN DUP IF TCLOSE THEN ;
: TU-MATCH ( ip ver -- n proto )   \ n = accepted index (-1 none, -2 offline); proto = 33/34/35
   OVER REACH? 0= IF 2DROP -2 0 EXIT THEN
   35 = IF TU-M35 35 EXIT THEN
   DUP TU-M33 DUP 0< 0= IF NIP 33 EXIT THEN
   DROP TU-M34 34 ;

\ ---- discovery: listen for the Tuya :6667 discovery broadcasts, collect (ip, ver) ----
[DEFINED] WINAPI64: [IF]
   [UNDEFINED] recvfrom    [IF] 6 WINAPI64: recvfrom    WSOCK32.DLL [THEN]
   [UNDEFINED] GetTickCount [IF] 0 WINAPI64: GetTickCount KERNEL32.DLL [THEN]
[THEN]
64 CONSTANT #DISCO
CREATE DISCO #DISCO /REC * ALLOT   VARIABLE DISCO-N
CREATE DFROM 32 ALLOT   VARIABLE DFLEN   CREATE UBUF 1024 ALLOT   VARIABLE USOCK
: SX32 ( n -- n )  [ HEX ] FFFFFFFF [ DECIMAL ] AND [ HEX ] 80000000 [ DECIMAL ] XOR [ HEX ] 80000000 [ DECIMAL ] - ;
: TMS  ( -- ms )   GetTickCount [ HEX ] FFFFFFFF [ DECIMAL ] AND ;
: .IP# ( ip -- )   DUP 24 RSHIFT (U.) [CHAR] . EMIT  DUP 16 RSHIFT 255 AND (U.) [CHAR] . EMIT
                   DUP 8 RSHIFT 255 AND (U.) [CHAR] . EMIT  255 AND (U.) ;
: MAGIC>VER ( a -- ver|0 )   \ payload[0:2]=0000 then magic: 55 AA -> 33 ; 66 99 -> 35 ; else 0
   DUP C@ OVER 1+ C@ OR IF DROP 0 EXIT THEN
   DUP 2 + C@ SWAP 3 + C@                            ( b2 b3 )
   OVER 85 = OVER 170 = AND IF 2DROP 33 EXIT THEN     \ 55 AA
   OVER 102 = OVER 153 = AND IF 2DROP 35 EXIT THEN    \ 66 99
   2DROP 0 ;
: DISCO-ROW ( i -- a )  /REC * DISCO + ;
: DISCO-FIND ( ip -- idx|-1 )  DISCO-N @ 0 ?DO DUP I DISCO-ROW rec.ip @ = IF DROP I UNLOOP EXIT THEN LOOP DROP -1 ;
: DISCO-ADD ( ip ver -- )
   OVER DISCO-FIND 0< 0= IF 2DROP EXIT THEN
   DISCO-N @ #DISCO < 0= IF 2DROP EXIT THEN
   DISCO-N @ DISCO-ROW   ( ip ver a )   DUP >R rec.ver !  R> rec.ip !  1 DISCO-N +! ;
: (DISCO-1) ( -- )   \ one recvfrom; record a valid Tuya discovery broadcast
   16 DFLEN !
   DFLEN DFROM 0 1024 UBUF USOCK @ recvfrom  SX32
   0 > IF  UBUF MAGIC>VER ?DUP IF  DFROM sin_addr BE@ SWAP DISCO-ADD  THEN  THEN ;
: TU-DISCOVER ( secs -- )
   0 DISCO-N !
   CreateUdpSocket IF DROP ." udp socket fail" CR EXIT THEN USOCK !
   USOCK @ ReuseAddrSocket DROP
   6667 USOCK @ BindSocket IF ." bind :6667 fail (port busy?)" CR USOCK @ FastCloseSocket DROP EXIT THEN
   400 USOCK @ SetSocketTimeout DROP                 \ short recv timeout so the loop can watch the deadline
   ." tuya discover: listening :6667 for " DUP . ." s ..." CR
   TMS SWAP 1000 * +                                 ( deadline )
   BEGIN TMS OVER U< WHILE (DISCO-1) REPEAT DROP
   USOCK @ FastCloseSocket DROP
   ." discovered " DISCO-N @ . ." Tuya broadcaster(s)" CR ;

\ ---- scan: discover, then probe every broadcaster with the registry ----
: TU-SCAN ( -- )
   7 TU-DISCOVER
   TU-LOC #TU /REC * 0 FILL
   ." tuya scan (probing discovered hosts):" CR
   DISCO-N @ 0 ?DO
      I DISCO-ROW  DUP rec.ip @  SWAP rec.ver @      ( ip ver )
      OVER .IP#  ."  -> "
      >R DUP R>  TU-MATCH                            ( ip n proto )
      OVER 0< IF  DROP NIP  -2 = IF ." offline" ELSE ." (no key)" THEN
      ELSE  OVER TU-VER !  SWAP OVER TU-IP !  ." key TU-" .  THEN  CR
   LOOP  ." scan done -- <n> TU-READ, TU-READ-ALL, <n> TU-SHOW, or TU-SHOW-ALL" CR ;

\ ---- raw poll ----
: TU-READ ( n -- )
   ." TU-" DUP .
   DUP TU-IP @ 0= IF ." : not located -- run TU-SCAN" CR DROP EXIT THEN
   ." : " DUP TU-VER @
   DUP 35 = IF DROP DUP TU-IP @ SWAP TU-KEY TUYA-STATUS   EXIT THEN
   DUP 34 = IF DROP DUP TU-IP @ SWAP TU-KEY TUYA34-STATUS EXIT THEN
   DROP DUP TU-IP @ OVER TU-ID 3 PICK TU-KEY TUYA33-STATUS DROP ;
: TU-READ-ALL ( -- )  0 #TU 0 DO I TU-IP @ IF I TU-READ 1+ THEN LOOP
   0= IF ." (nothing located -- run TU-SCAN first)" CR THEN ;

\ ---- dps decode (analog of the per-device tuya *.py): a tiny JSON reader + labelled per-device print ----
CREATE NDL 16 ALLOT   CREATE DPSBUF 600 ALLOT
VARIABLE DPS#   VARIABLE SR-NA   VARIABLE SR-NU
: >NDL ( dpnum -- )   \ build the "dpnum": needle in NDL ; SR-NA/SR-NU point at it
   [CHAR] " NDL C!  0 <# #S #> DUP >R  NDL 1 + SWAP CMOVE  R> 1 +
   [CHAR] " OVER NDL + C!  1 +  [CHAR] : OVER NDL + C!  1 +  NDL SR-NA !  SR-NU ! ;
: MATCH? ( a -- flag )  SR-NA @ SR-NU @ DUP >R SWAP R> COMPARE 0= ;
: SRCH ( ha hu -- a2|0 )  OVER + SR-NU @ -  SWAP
   BEGIN 2DUP U< 0= WHILE DUP MATCH? IF SR-NU @ + NIP EXIT THEN 1 + REPEAT 2DROP 0 ;
: DPV ( dpnum -- a u )   \ value text after "dpnum": up to the next , or }
   >NDL  DPSBUF DPS# @ SRCH  DUP 0= IF 0 EXIT THEN
   DUP BEGIN DUP C@ DUP [CHAR] , = SWAP [CHAR] } = OR 0= WHILE 1+ REPEAT OVER - ;
: DPN ( dpnum -- n )   \ value as a signed integer (0 if absent / non-numeric)
   DPV DUP 0= IF 2DROP 0 EXIT THEN
   OVER C@ [CHAR] - = >R  R@ IF 1 /STRING THEN
   0 -ROT OVER + SWAP ?DO I C@ [CHAR] 0 - DUP 0 < OVER 9 > OR IF DROP ELSE SWAP 10 * + THEN LOOP
   R> IF NEGATE THEN ;
: DP$ ( dpnum -- a u )  DPV DUP 1 > IF OVER C@ [CHAR] " = IF 1 /STRING 1- THEN THEN ;
: DPB ( dpnum -- flag )  DPV DUP 0= IF 2DROP 0 ELSE DROP C@ [CHAR] t = THEN ;
: .10  ( n -- )  DUP 0< IF [CHAR] - EMIT NEGATE THEN 10 /MOD SWAP >R (U.) [CHAR] . EMIT R> (U.) ;
: .100 ( n -- )  DUP 0< IF [CHAR] - EMIT NEGATE THEN 100 /MOD SWAP >R (U.) [CHAR] . EMIT R@ 10 < IF [CHAR] 0 EMIT THEN R> (U.) ;
: .1000 ( n -- )  DUP 0< IF [CHAR] - EMIT NEGATE THEN 1000 /MOD SWAP >R (U.) [CHAR] . EMIT R@ 100 < IF [CHAR] 0 EMIT THEN R@ 10 < IF [CHAR] 0 EMIT THEN R> (U.) ;
: CONTAINS? ( ha hu na nu -- flag )  SR-NU !  SR-NA !  SRCH 0<> ;
\ ---- poll-to-string: the reader RETURNS the {...} JSON, so no console-output capture is needed ----
: TUYA-STATUS$ ( ip key -- a u )   \ v3.5
   DKEY ! DIP !  TUYA-OPEN 0= IF 0 0 EXIT THEN
   NEG 0= IF TCLOSE 0 0 EXIT THEN  DPQ 0= IF 2DROP TCLOSE 0 0 EXIT THEN  FIND{ TCLOSE ;
: TUYA34-STATUS$ ( ip key -- a u )   \ v3.4
   DKEY ! DIP !  TUYA-OPEN 0= IF 0 0 EXIT THEN
   NEG34 0= IF TCLOSE 0 0 EXIT THEN  10 DPQ34 0= IF 2DROP TCLOSE 0 0 EXIT THEN
   DUP PTB + 1- C@ OVER MIN -  FIND{ TCLOSE ;
: TUYA33-STATUS$ ( ip id-a id-u key -- a u )   \ v3.3
   DKEY ! ROT DIP !
   S" 1700000000" JSON-DPQ PKCS7  DUP >R DKEY @ -ROT TXB f55.pl ECB-ENC DROP R>  10 PACK55
   TUYA-OPEN 0= IF 2DROP 0 0 EXIT THEN
   TSEND TRECV 28 < IF TCLOSE 0 0 EXIT THEN
   RXB f55.pl BE@ ?DUP IF DROP TCLOSE 0 0 EXIT THEN
   RXB f55.len BE@ 12 - DUP 0 > OVER 353 < AND 0= IF DROP TCLOSE 0 0 EXIT THEN
   DKEY @ RXB f55.pl /RETCODE + 2 PICK PTB ECB-DEC DROP
   DUP PTB + 1- C@ OVER MIN -  PTB SWAP FIND{ TCLOSE ;
: TU-READ$ ( n -- a u )   \ poll device n with the recorded protocol; return the JSON (0 0 on fail)
   DUP TU-IP @ 0= IF DROP 0 0 EXIT THEN
   DUP TU-VER @ 35 = IF  DUP TU-IP @ SWAP TU-KEY  TUYA-STATUS$   EXIT THEN
   DUP TU-VER @ 34 = IF  DUP TU-IP @ SWAP TU-KEY  TUYA34-STATUS$ EXIT THEN
   DUP TU-IP @  OVER TU-ID  3 PICK TU-KEY  TUYA33-STATUS$  ROT DROP ;
: (CAP1) ( n -- )   \ one poll -> DPSBUF (clamped) + DPS#
   TU-READ$  DUP 599 > IF DROP 599 THEN  DUP DPS# !  DPSBUF SWAP CMOVE ;
: CAP-POLL ( n -- )   \ poll into DPSBUF ; retry past a v3.4 async "protocol" push to reach the DP_QUERY reply
   4 0 DO DUP (CAP1) DPSBUF DPS# @ S" protocol" CONTAINS? 0= IF DROP UNLOOP EXIT THEN LOOP DROP ;
: DEC-ATORCH ( -- )
   ." mode=" 101 DP$ TYPE ."  T=" 102 DPN .10 ." C  on=" 104 DPN .10 ."  off=" 106 DPN .10
   ."  U=" 110 DPN .100 ." V  P=" 114 DPN .10 ." W peak=" 115 DPN .10 ." W" CR ;
: DEC-4CH ( -- )
   5 1 DO ." R" [CHAR] 0 I + EMIT [CHAR] = EMIT I DPB IF ." ON " ELSE ." off " THEN LOOP
   ." mode=" 15 DP$ TYPE ."  all=" 14 DP$ TYPE CR ;
: DEC-EM ( -- )
   1 DPB IF ." ON " ELSE ." off " THEN
   ." U=" 20 DPN .10 ." V  I=" 18 DPN .1000 ." A  P=" 19 DPN .10 ." W" CR ;
: DEC-TP260 ( -- )
   1 DPB IF ." ON " ELSE ." off " THEN
   ." T=" 24 DPN .10 ." C target=" 16 DPN .10 ." C  relay=" 25 DP$ TYPE ."  mode=" 2 DP$ TYPE
   ."  offset=" 27 DPN . ." kWh cur=" 116 DPN .100 ."  last=" 114 DPN .100 CR ;
: DEC-TEMPHUM ( -- )  ." T=" 1 DPN .10 ." C  RH=" 2 DPN (U.) ." %" CR ;
: DEC-RELAY ( -- )
   1 DPB IF ." ON  " ELSE ." OFF " THEN ." U=" 20 DPN .10 ." V  P=" 19 DPN .10 ." W" CR ;
: DEC-GENERIC ( -- )  DPSBUF DPS# @ FIND{ TYPE ;
: TU-SHOW ( n -- )   \ poll device n and print DECODED, labelled readings (analog of the *.py)
   DUP TU-IP @ 0= IF ." TU-" . ."  not located -- run TU-SCAN" CR DROP EXIT THEN
   DUP CAP-POLL  ." TU-" DUP .  ." : "  TU-DEC + C@
   DUP 1 = IF DROP DEC-ATORCH  EXIT THEN
   DUP 2 = IF DROP DEC-4CH     EXIT THEN
   DUP 3 = IF DROP DEC-EM      EXIT THEN
   DUP 4 = IF DROP DEC-TP260   EXIT THEN
   DUP 5 = IF DROP DEC-TEMPHUM EXIT THEN
   DUP 6 = IF DROP DEC-RELAY   EXIT THEN
   DROP DEC-GENERIC ;
: TU-SHOW-ALL ( -- )  0 #TU 0 DO I TU-IP @ IF I TU-SHOW 1+ THEN LOOP
   0= IF ." (nothing located -- run TU-SCAN first)" CR THEN ;
CR ." tuya-scan: ready -- run  TU-SCAN , then  TU-READ-ALL / TU-SHOW-ALL" CR

\EOF
\ ---- usage + discovery self-test.  Past \EOF (not run on a normal load).  Full poll needs the gitignored
\ tuya-creds.f (key/id tables) loaded first -- it REQUIREs this file -- then:  TU-SCAN  TU-READ-ALL  TU-SHOW-ALL
\ Discovery alone needs no keys; to run it:  : \EOF ;  then INCLUDE tuya-creds.f (or this file after the tables).
: .DISCO ( -- )  DISCO-N @ 0 ?DO  ."   "  I DISCO-ROW DUP rec.ip @ .IP#  ."  v" rec.ver @ .  CR  LOOP ;
CR ." === tuya-scan.f discovery self-test (10s, no keys) ===" CR
10 TU-DISCOVER  .DISCO  CR
