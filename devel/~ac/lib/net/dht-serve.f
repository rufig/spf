\ ~ac/lib/net/dht-serve.f -- DHT announce + server, on top of dht.f.  Lets a node:
\   * announce_peer itself for an infohash (capture a token via get_peers, then announce to the
\     closest nodes with our listening port + implied_port), and
\   * run as a node: answer ping/find_node/get_peers/announce_peer, keep a tiny peer store for ONE
\     watched infohash, and LOG every incoming get_peers/announce_peer that names it -- so you can
\     watch the console and see whether the swarm is asking for that file.
\ To actually receive get_peers for a specific infohash we set our node id = the infohash, so lookups
\ for it converge on us (the standard single-infohash observation trick).  Token is opaque (ip XOR a
\ per-run secret); we do not strictly verify it on announce (fine for observation, a hardened node
\ would).  Windows only (uses BindSocket + GetTickCount).  CRLF.
REQUIRE FIND-PEERS ~ac/lib/net/dht.f
DECIMAL

[DEFINED] NOW-MS [IF]                             \ ===== has a millisecond clock (Windows or POSIX) =====

VARIABLE MY-PORT                                   \ our bound UDP port (announced)
VARIABLE MY-EXT-IP                                  \ our external IP (0 = unknown); used to advertise self in values
TRUE VALUE DHT-ANNOUNCE?                            \ FALSE = do NOT advertise ourselves as a peer (id=infohash only)
CREATE SECRET 8 ALLOT                              \ per-run token secret
CREATE TOKBUF 8 ALLOT                              \ scratch for the 4-byte token
VARIABLE Q-PING  VARIABLE Q-FIND  VARIABLE Q-GET  VARIABLE Q-ANN  VARIABLE Q-HIT  VARIABLE Q-UTP
VARIABLE ANN-TOK  VARIABLE ANN-ACK               \ our-announce diagnostics: tokens got / acks received

\ ---- peer store for the ONE watched infohash (compact 6-byte ip4+port entries) ----
256 CONSTANT PSTORE-MAX
100 CONSTANT MAX-REPLY-VALUES                      \ cap values[] in one get_peers reply (< BE-BUF / safe MTU)
CREATE PSTORE  PSTORE-MAX 6 * ALLOT
VARIABLE PSTORE-N
: PSTORE-ADD { ip port \ p -- }
   PSTORE-N @ PSTORE-MAX >= IF EXIT THEN
   PSTORE-N @ 6 * PSTORE +  -> p
   ip 255 AND p C!  ip 8 RSHIFT 255 AND p 1+ C!
   ip 16 RSHIFT 255 AND p 2 + C!  ip 24 RSHIFT 255 AND p 3 + C!
   port 8 RSHIFT 255 AND p 4 + C!  port 255 AND p 5 + C!
   1 PSTORE-N +! ;

\ ---- token = low 4 bytes of (ip XOR secret) ----
: MK-TOKEN ( ip -- a u )  SECRET @ XOR TOKBUF !  TOKBUF 4 ;

\ ---- helpers ----
: DFIND-STR ( dict-a key-a key-u -- s-a s-u true | false )
   B-DFIND IF  B-STR@ >R >R DROP R> R>  TRUE  ELSE  FALSE  THEN ;
: RX-A-STR { ka ku -- sa su true | false }        \ a.<key> as a string from the query in RX-BUF
   RX-BUF S" a" B-DFIND 0= IF FALSE EXIT THEN
   ka ku DFIND-STR ;
: .IPPORT { ip port -- }
   BASE @ >R DECIMAL
   ip 255 AND .#  [CHAR] . EMIT  ip 8 RSHIFT 255 AND .#  [CHAR] . EMIT
   ip 16 RSHIFT 255 AND .#  [CHAR] . EMIT  ip 24 RSHIFT 255 AND .#  [CHAR] : EMIT  port .#
   R> BASE ! ;
: SEND-REPLY ( a u ip port -- )  2SWAP DHT-SOCK @ UDP-SEND ;
: .UTP-KIND ( type -- )                          \ name a uTP message type (BEP 29)
   DUP 4 = IF DROP ." SYN"   EXIT THEN            \ ST_SYN   -- a peer opening a connection to download
   DUP 0 = IF DROP ." DATA"  EXIT THEN
   DUP 2 = IF DROP ." STATE" EXIT THEN
   DUP 1 = IF DROP ." FIN"   EXIT THEN
   DUP 3 = IF DROP ." RESET" EXIT THEN  ." type" . ;
: .PRCH ( c -- )  DUP 32 127 WITHIN IF EMIT ELSE DROP [CHAR] ? EMIT THEN ;   \ printable char or '?'
: .V-CLIENT ( -- )                               \ BEP 20 top-level 'v': 2-char client code + 2-byte version
   RX-BUF S" v" DFIND-STR 0= IF ." ?" EXIT THEN
   { va vu }
   vu 1 >= IF va C@ .PRCH THEN
   vu 2 >= IF va 1+ C@ .PRCH THEN
   vu 4 >= IF [CHAR] . EMIT  va 2 + C@ 8 LSHIFT va 3 + C@ +  BASE @ >R DECIMAL .# R> BASE ! THEN ;

\ ---- KRPC reply builders (y=r; echo the query's transaction id t) ----
: REPLY-PING { ta tu -- a u }                     \ also the announce_peer reply
   BE-RESET  BE-D{
      S" r" BE-KEY  BE-D{ S" id" BE-KEY MY-ID IDLEN BE-STR BE-}
      S" t" BE-KEY  ta tu BE-STR
      BE-V
      S" y" BE-KEY  S" r" BE-STR
   BE-}  BE-BUF BE-LEN ;
: REPLY-FINDNODE { ta tu \ na nu -- a u }          \ answer with the K nodes closest to a.target
   0 -> na  0 -> nu
   S" target" RX-A-STR IF
      20 = IF RT-CLOSEST-NODES -> nu -> na ELSE DROP THEN
   THEN
   BE-RESET  BE-D{
      S" r" BE-KEY  BE-D{ S" id" BE-KEY MY-ID IDLEN BE-STR  S" nodes" BE-KEY na nu BE-STR BE-}
      S" t" BE-KEY  ta tu BE-STR
      BE-V
      S" y" BE-KEY  S" r" BE-STR
   BE-}  BE-BUF BE-LEN ;
CREATE CP-BUF 6 ALLOT                             \ scratch: our own compact peer (ip4+port)
: BE-SELF ( -- )                                  \ emit our own (MY-EXT-IP:MY-PORT) as a compact 6-byte value
   MY-EXT-IP @ 255 AND CP-BUF C!  MY-EXT-IP @ 8 RSHIFT 255 AND CP-BUF 1+ C!
   MY-EXT-IP @ 16 RSHIFT 255 AND CP-BUF 2 + C!  MY-EXT-IP @ 24 RSHIFT 255 AND CP-BUF 3 + C!
   MY-PORT @ 8 RSHIFT 255 AND CP-BUF 4 + C!  MY-PORT @ 255 AND CP-BUF 5 + C!
   CP-BUF 6 BE-STR ;
: REPLY-GETPEERS { ta tu ip ours? iha \ na nu -- a u }   \ our TARGET -> values; foreign hash -> closest nodes
   ours? IF 0 0 ELSE iha RT-CLOSEST-NODES THEN -> nu -> na
   BE-RESET  BE-D{
      S" r" BE-KEY  BE-D{
         S" id" BE-KEY MY-ID IDLEN BE-STR
         S" token" BE-KEY ip MK-TOKEN BE-STR
         ours? IF
            S" values" BE-KEY BE-L[                            \ our infohash: our own peers
               DHT-ANNOUNCE? IF MY-EXT-IP @ IF BE-SELF THEN THEN
               PSTORE-N @ MAX-REPLY-VALUES MIN 0 ?DO PSTORE I 6 * + 6 BE-STR LOOP
            BE-}
         ELSE
            S" nodes" BE-KEY na nu BE-STR                      \ foreign: the closest nodes we know (never our swarm)
         THEN
      BE-}
      S" t" BE-KEY  ta tu BE-STR
      BE-V
      S" y" BE-KEY  S" r" BE-STR
   BE-}  BE-BUF BE-LEN ;

\ ---- verbose incoming-query logging (diagnostics: see EVERY DHT query the swarm node receives) ----
: .NIB   ( n -- )   15 AND DUP 10 < IF [CHAR] 0 + ELSE 10 - [CHAR] A + THEN EMIT ;
: .HEXB  ( c -- )   DUP 4 RSHIFT .NIB .NIB ;
: .IHPFX ( a -- )   4 0 DO DUP I + C@ .HEXB LOOP DROP ." .." ;   \ first 4 bytes of an infohash/target
: .RX-A-IH { ka ku -- }   ka ku RX-A-STR IF DROP .IHPFX ELSE ." ?" THEN ;   \ print a.<key> hash prefix, or ?
: TOKEN-OK? { ad ip \ ka ku ta tu -- f }          \ ad.token == the opaque token we'd have issued to ip?
   ad S" token" DFIND-STR 0= IF FALSE EXIT THEN -> ku -> ka
   ip MK-TOKEN -> tu -> ta
   ka ku ta tu STR= ;
CREATE QNODE 26 ALLOT
: LEARN-QUERIER { ip port \ ida idu -- }          \ add the querying node (a.id + its src ip:port) to the routing table
   RX-BUF S" a" B-DFIND 0= IF EXIT THEN
   S" id" DFIND-STR 0= IF EXIT THEN -> idu -> ida
   idu 20 <> IF EXIT THEN
   ida QNODE 20 MOVE
   ip 255 AND QNODE 20 + C!  ip 8 RSHIFT 255 AND QNODE 21 + C!
   ip 16 RSHIFT 255 AND QNODE 22 + C!  ip 24 RSHIFT 255 AND QNODE 23 + C!
   port 8 RSHIFT 255 AND QNODE 24 + C!  port 255 AND QNODE 25 + C!
   QNODE RT-ADD ;

\ ---- request dispatch ----
: SERVE-GETPEERS { ip port ta tu \ iha ours -- }
   RX-BUF S" a" B-DFIND 0= IF EXIT THEN                          ( a-dict )
   S" info_hash" DFIND-STR 0= IF EXIT THEN  DROP  -> iha         ( drop u, keep iha )
   iha TARGET ID= -> ours
   ." <<< get_peers from " ip port .IPPORT ."  ih=" iha .IHPFX
   ours IF 1 Q-HIT +! ."  (OURS) client=" .V-CLIENT ELSE ."  (foreign)" THEN CR
   ta tu ip ours iha REPLY-GETPEERS  ip port SEND-REPLY ;
: SERVE-ANNOUNCE { ip port ta tu \ ad iha aport -- }
   RX-BUF S" a" B-DFIND 0= IF ta tu REPLY-PING ip port SEND-REPLY EXIT THEN -> ad
   ad S" info_hash" DFIND-STR 0= IF EXIT THEN DROP -> iha        ( keep addr )
   ad S" implied_port" B-DFIND IF B-INT@ NIP ELSE 0 THEN
   IF port ELSE ad S" port" B-DFIND IF B-INT@ NIP ELSE port THEN THEN -> aport
   ." <<< announce_peer from " ip aport .IPPORT ."  ih=" iha .IHPFX
   iha TARGET ID= IF
      ad ip TOKEN-OK? IF ip aport PSTORE-ADD  1 Q-HIT +! ."  (OURS) client=" .V-CLIENT
                     ELSE ."  (OURS, bad/missing token -- not stored)" THEN
   ELSE ."  (foreign)" THEN CR
   ta tu REPLY-PING ip port SEND-REPLY ;

: SERVE-1 { size ip port \ ta tu qa qu b0 -- }     \ handle one datagram already in RX-BUF
   size 0= IF EXIT THEN
   RX-BUF size BE-SETEND DROP                       \ bound the bencode parser to this datagram
   RX-BUF C@ -> b0
   b0 [CHAR] d <> IF                               \ not bencoded DHT -> peer-wire (uTP) or junk; log it
      1 Q-UTP +!
      b0 15 AND 1 =  b0 4 RSHIFT 5 U< AND          \ low nibble=version(1), high nibble=type(0..4) -> uTP
      IF   ." <<< uTP " b0 4 RSHIFT .UTP-KIND ."  (peer-wire connect, not DHT) from " ip port .IPPORT CR
      ELSE ." <<< non-DHT datagram (byte0=" b0 . ." ) from " ip port .IPPORT CR  THEN
      EXIT
   THEN
   RX-BUF S" y" DFIND-STR 0= IF EXIT THEN  S" q" STR= 0= IF EXIT THEN   \ queries only
   RX-BUF S" t" DFIND-STR 0= IF EXIT THEN -> tu -> ta
   RX-BUF S" q" DFIND-STR 0= IF EXIT THEN -> qu -> qa
   ip port LEARN-QUERIER                           \ a live node just contacted us: remember it (routing table)
   qa qu S" ping"          STR= IF 1 Q-PING +!  ." <<< ping from " ip port .IPPORT CR
                                    ta tu REPLY-PING     ip port SEND-REPLY EXIT THEN
   qa qu S" find_node"     STR= IF 1 Q-FIND +!  ." <<< find_node from " ip port .IPPORT
                                    ."  target=" S" target" .RX-A-IH CR
                                    ta tu REPLY-FINDNODE ip port SEND-REPLY EXIT THEN
   qa qu S" get_peers"     STR= IF 1 Q-GET  +!  ip port ta tu SERVE-GETPEERS  EXIT THEN
   qa qu S" announce_peer" STR= IF 1 Q-ANN  +!  ip port ta tu SERVE-ANNOUNCE  EXIT THEN
   ." <<< query '" qa qu TYPE ." ' from " ip port .IPPORT CR ;   \ unrecognised query type

\ ---- our own announce_peer (outgoing) ----
: EXTRACT-TOKEN ( rlen -- tok-a tok-u | 0 0 )      \ pull 'r'.'token' from a get_peers reply in RX-BUF
   DUP 0= IF DROP 0 0 EXIT THEN
   RX-BUF SWAP BE-SETEND DROP                       \ bound the parser to the received reply
   RX-BUF C@ [CHAR] d <> IF 0 0 EXIT THEN
   RX-BUF S" r" B-DFIND 0= IF 0 0 EXIT THEN
   S" token" DFIND-STR 0= IF 0 0 EXIT THEN ;
: ANNOUNCE-MSG { ta tu -- a u }                    \ announce_peer for CUR-IH, our MY-PORT, implied_port
   BE-RESET  BE-D{
      S" a" BE-KEY  BE-D{
         S" id" BE-KEY MY-ID IDLEN BE-STR
         S" implied_port" BE-KEY 1 BE-INT
         S" info_hash" BE-KEY CUR-IH @ IDLEN BE-STR
         S" port" BE-KEY MY-PORT @ BE-INT
         S" token" BE-KEY ta tu BE-STR
      BE-}
      S" q" BE-KEY S" announce_peer" BE-STR
      S" t" BE-KEY NEW-TXN BE-STR
      BE-V
      S" y" BE-KEY S" q" BE-STR
   BE-}  BE-BUF BE-LEN ;
: ANNOUNCE-1 { ip port \ ta tu -- }                \ get_peers (for a fresh token) then announce_peer
   ip port GETPEERS-MSG DHT-QUERY  EXTRACT-TOKEN -> tu -> ta
   ta 0= IF EXIT THEN
   1 ANN-TOK +!
   ip port  ta tu ANNOUNCE-MSG  DHT-QUERY          \ send announce, read the ack
   DUP IF RX-BUF SWAP BE-SETEND DROP
      RX-BUF C@ [CHAR] d = IF RX-BUF S" r" B-DFIND IF 1 ANN-ACK +! THEN THEN
   ELSE DROP THEN ;
8 CONSTANT ANNOUNCE-K
: DO-ANNOUNCE ( -- )                               \ announce to the K closest nodes in the shortlist
   0 ANN-TOK !  0 ANN-ACK !
   SL-N @ 0 ?DO 0 I SL-Q + C! LOOP                 \ reuse SL-Q as a "picked" flag
   ANNOUNCE-K 0 DO
      SL-PICK DUP 0< IF DROP LEAVE THEN            ( idx )
      DUP 1 SWAP SL-Q + C!
      SL-NODE DUP NODE-IP SWAP NODE-PORT ANNOUNCE-1
   LOOP
   ." announce: tokens=" ANN-TOK @ .  ." acks=" ANN-ACK @ . CR ;

\ ---- bind + serve loop ----
: BIND-PORT { sock -- port }                       \ first free port in 6881..6890 (0 if none)
   6891 6881 DO  I sock BindSocket 0= IF I UNLOOP EXIT THEN  LOOP  0 ;
: RESET-STATS ( -- )  Q-PING 0!  Q-FIND 0!  Q-GET 0!  Q-ANN 0!  Q-HIT 0!  Q-UTP 0! ;
: .STATS ( -- )
   ." queries seen -- ping:" Q-PING @ .  ." find_node:" Q-FIND @ .
   ." get_peers:" Q-GET @ .  ." announce:" Q-ANN @ .  ." | for OUR file:" Q-HIT @ .
   ." | uTP/peer-wire connects:" Q-UTP @ . CR ;
: DHT-SERVE { secs \ deadline size ip port -- }    \ answer queries for `secs` seconds
   NOW-MS secs 1000 * + -> deadline
   BEGIN NOW-MS deadline U< WHILE
      RX-BUF 2048 DHT-SOCK @ UDP-RECV  -> port -> ip -> size
      size IF size ip port SERVE-1 THEN
   REPEAT ;

\ ---- top-level: announce + watch one infohash ----
: WATCH-INFOHASH { ih-a secs -- }                  \ ih-a = 20-byte infohash
   ih-a CUR-IH !
   ih-a TARGET IDLEN MOVE
   ih-a MY-ID  IDLEN MOVE                          \ node id = infohash -> lookups for it reach us
   SOCK-START  RNG-SEED  0 TXN !
   RND SECRET !                                    \ token secret
   UDP-OPEN DHT-SOCK !
   DHT-SOCK @ BIND-PORT  DUP MY-PORT !
   ?DUP IF ." bound UDP port " . CR ELSE ." (could not bind 6881-6890; using ephemeral port)" CR THEN
   SL-RESET  PEERS-RESET  0 PSTORE-N !  RESET-STATS
   ." bootstrapping + locating nodes near the infohash..." CR
   SEED-BOOTSTRAP
   MAX-QUERIES 0 DO LOOKUP-ROUND 0= IF LEAVE THEN LOOP
   ." shortlist nodes: " SL-N @ . CR
   DHT-ANNOUNCE? IF ." watching " secs . ." s (announcing self as peer every 12 s)..." CR
                ELSE ." watching " secs . ." s (NOT announcing self; node id = infohash only)..." CR THEN
   secs 12 / 1+ 0 DO
      DHT-ANNOUNCE? IF DO-ANNOUNCE THEN            \ self-announce (re-)registers us as a peer + refreshes contacts
      12 DHT-SERVE
   LOOP
   CR .STATS
   PSTORE-N @ IF ." peers announced to us for this file: " PSTORE-N @ . CR
      PSTORE-N @ 0 DO PSTORE I 6 * + .PEER LOOP THEN
   DHT-DONE ;

[ELSE]                                             \ ===== POSIX (no GetTickCount) =====
.( dht-serve.f: server mode needs the Windows backend -- POSIX TODO) CR
: WATCH-INFOHASH ( ih-a secs -- )  2DROP -1 THROW ;
[THEN]
