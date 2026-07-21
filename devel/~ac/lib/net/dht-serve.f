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

\ Hex printers live up here because the endpoint table below logs node ids.
: .NIB   ( n -- )   15 AND DUP 10 < IF [CHAR] 0 + ELSE 10 - [CHAR] A + THEN EMIT ;
: .HEXB  ( c -- )   DUP 4 RSHIFT .NIB .NIB ;
: .IHPFX ( a -- )   4 0 DO DUP I + C@ .HEXB LOOP DROP ." .." ;   \ first 4 bytes of an infohash/target

\ The DHT can see us under MORE THAN ONE address, and the ADDRESS INCLUDES THE PORT.  With split-tunnel
\ routing some peers are reached through the VPN and the rest directly, so each peer reports a different
\ source address for us; and what any of them sees is the NAT translation, not the port we bound.
\ BEP 42 has every response echo an 'ip' key holding a SOCKADDR -- 4 bytes of address AND 2 of port --
\ i.e. the replies themselves report the whole set of endpoints we appear under.  We record the pairs.
\ Whether "our external port" is even a well-defined thing depends on the NAT:
\   - cone NAT: one translation per local socket, so every peer sees the same port -- worth announcing;
\   - symmetric NAT: a translation per destination, so the port p10 sees is useless to anyone else and
\     no single port can be announced at all.
\ These counts are what tells the two apart: several peers reporting the SAME port at the SAME time
\ means cone; different peers reporting different ports concurrently means symmetric.
\ Only a CORRELATED reply may feed this table (our tid, from the peer we actually asked).  Beyond that we
\ do NOT demand corroboration: a rare-but-real route legitimately has a single witness, and ageing (see
\ EXTIP-TTL) retires anything nobody keeps confirming, made-up addresses included.  xi.n is a diagnostic.
8 CONSTANT /EXTIP
0 CELL -- xi.ip  CELL -- xi.port  CELL -- xi.n
  CELL -- xi.first                                  \ when this endpoint first appeared
  CELL -- xi.last                                   \ when a peer last confirmed it
  IDLEN -- xi.id                                    \ the BEP42 identity bound to this ADDRESS
CONSTANT /XI
900000 VALUE EXTIP-TTL   \ 15 min.  An address nobody has reported for this long is no longer ours.
   \ Ageing, not vote-counting, is the right cure here.  A rare-but-real route can have a single witness
   \ (the tailscale one did), so demanding several would throw away a genuine address.  But a made-up
   \ address is never seen again, so it ages out by itself -- and the same rule follows a MOBILE node
   \ whose external address changes when it switches access points or providers.
CREATE EXTIPS  /EXTIP /XI *  ALLOT
VARIABLE EXTIP-N   0 EXTIP-N !
: XI ( i -- a )   /XI *  EXTIPS + ;
: .IP4 ( ip -- )
   DUP        255 AND .# [CHAR] . EMIT   DUP  8 RSHIFT 255 AND .# [CHAR] . EMIT
   DUP 16 RSHIFT 255 AND .# [CHAR] . EMIT      24 RSHIFT 255 AND .# ;
: EXTIP-OURS? { ip \ f -- f }                       \ an ADDRESS the DHT has reported us at (any port)?
   FALSE -> f   ip 0= IF f EXIT THEN
   EXTIP-N @ 0 ?DO  ip I XI xi.ip @ = IF TRUE -> f LEAVE THEN  LOOP  f ;
: EXTEP-OURS? { ip port \ f -- f }                  \ an exact ENDPOINT we have been reported at?
   FALSE -> f   ip 0= IF f EXIT THEN
   EXTIP-N @ 0 ?DO
      ip I XI xi.ip @ =  port I XI xi.port @ = AND IF TRUE -> f LEAVE THEN
   LOOP  f ;
: SELF-EP? { ip port -- f }
   \ Is this endpoint US?  Behind NAT the pair (MY-EXT-IP, MY-PORT) never matches what peers see -- we
   \ bind 6881 and appear as :1357 -- so the discovered endpoints are the only usable answer.  Must be
   \ an EXACT pair, not just the address: a neighbour behind the same router (u24) shares our external
   \ address, and matching on address alone would strike a real fleet peer off the list as "ourselves".
   ip port EXTEP-OURS? IF TRUE EXIT THEN
   ip MY-EXT-IP @ =  port MY-PORT @ = AND ;         \ the configured pair, for before anything is observed
: EP-ID-FOR { ip \ a -- id-a | 0 }                  \ identity already bound to this ADDRESS, 0 if new
   0 -> a
   EXTIP-N @ 0 ?DO  ip I XI xi.ip @ = IF I XI xi.id -> a LEAVE THEN  LOOP  a ;
: EXTIP-SEEN { ip port \ idx -- }                   \ a peer reported our query reached it from ip:port
   ip 0= IF EXIT THEN
   EXTIP-N @ 0 ?DO
      ip I XI xi.ip @ =  port I XI xi.port @ = AND IF
         1 I XI xi.n +!  NOW-MS I XI xi.last !  UNLOOP EXIT THEN
   LOOP
   EXTIP-N @ /EXTIP < IF
      EXTIP-N @ -> idx
      ip idx XI xi.ip !  port idx XI xi.port !  1 idx XI xi.n !
      NOW-MS idx XI xi.first !   NOW-MS idx XI xi.last !
      ip EP-ID-FOR ?DUP IF idx XI xi.id IDLEN CMOVE \ BEP 42 binds the id to the ADDRESS, so a second NAT
      ELSE ip idx XI xi.id BEP42-ID> THEN           \ port on an address we already know must reuse that
      1 EXTIP-N +!                                  \ address's identity -- issuing a fresh id per port
                                                    \ would advertise us as several nodes at one address,
                                                    \ which is what a sybil looks like, for no gain
      ." swarm: NEW external endpoint observed: " ip .IP4 [CHAR] : EMIT port .#   \ the (ip:port) pair is
      ."  (bound locally on " MY-PORT @ .# ." ) id=" idx XI xi.id .IHPFX          \ what stays stable for it
      ."  -- now " EXTIP-N @ . ." endpoint(s)" CR
   THEN ;
: ID-OURS? { ida \ f -- f }                         \ is this 20-byte node id any of ours?
   FALSE -> f
   ida MY-ID IDLEN MEM= IF TRUE EXIT THEN           \ the primary identity we currently sign with
   EXTIP-N @ 0 ?DO  ida I XI xi.id IDLEN MEM= IF TRUE -> f LEAVE THEN  LOOP  f ;
: EP-ID { ip \ a -- id-a }                          \ the identity bound to the endpoint at this address
   MY-ID -> a
   EXTIP-N @ 0 ?DO  ip I XI xi.ip @ = IF I XI xi.id -> a LEAVE THEN  LOOP  a ;
\ ---- which of our addresses does a given peer reach us at? -----------------------------------
\ The route -- and therefore the address a peer sees -- is chosen per DESTINATION, so this is a property
\ of the pair.  Filled in from the 'ip' each peer echoes back.  It is what makes the reply behave like a
\ network interface: answer a peer with the address IT can reach, signed with that address's identity.
64 CONSTANT /PEERMAP
0 CELL -- pm.ip  CELL -- pm.xip  CELL -- pm.last  CONSTANT /PM
CREATE PEERMAP  /PEERMAP /PM *  ALLOT
VARIABLE PEERMAP-N   0 PEERMAP-N !
: PM ( i -- a )   /PM *  PEERMAP + ;
: PEERMAP-SET { pip xip \ idx -- }                  \ peer pip reported reaching us at our address xip
   pip 0= xip 0= OR IF EXIT THEN
   PEERMAP-N @ 0 ?DO
      pip I PM pm.ip @ = IF xip I PM pm.xip !  NOW-MS I PM pm.last !  UNLOOP EXIT THEN
   LOOP
   PEERMAP-N @ /PEERMAP < IF  PEERMAP-N @ -> idx   1 PEERMAP-N +!
   ELSE 0 -> idx                                    \ full: drop the least recently confirmed entry
      PEERMAP-N @ 1 ?DO  I PM pm.last @  idx PM pm.last @ U< IF I -> idx THEN  LOOP
   THEN
   pip idx PM pm.ip !  xip idx PM pm.xip !  NOW-MS idx PM pm.last ! ;
: PEERMAP-GET { pip \ x -- xip | 0 }
   0 -> x
   PEERMAP-N @ 0 ?DO  pip I PM pm.ip @ = IF I PM pm.xip @ -> x LEAVE THEN  LOOP  x ;
: SIGN-FOR ( destip -- )                            \ sign the next message with the id this peer expects
   PEERMAP-GET ?DUP IF EP-ID ELSE MY-ID THEN  CUR-ID ! ;
: SIGN-DEFAULT ( -- )   MY-ID CUR-ID ! ;

: EXTIP-EXPIRE { \ i now last -- }                  \ forget endpoints nobody has confirmed lately
   NOW-MS -> now   0 -> i
   BEGIN i EXTIP-N @ < WHILE
      i XI xi.last @ -> last
      now last - EXTIP-TTL U> IF
         ." swarm: endpoint aged out: " i XI xi.ip @ .IP4 [CHAR] : EMIT i XI xi.port @ .#
         ."  (unseen " now last - 1000 / .# ." s, held " now i XI xi.first @ - 1000 / .# ." s)" CR
         EXTIP-N @ 1-  DUP i <> IF DUP XI  i XI  /XI CMOVE THEN DROP   \ compact: last entry fills the hole
         -1 EXTIP-N +!                                                 \ (order carries no meaning here)
      ELSE i 1+ -> i THEN
   REPEAT ;
: .EXTIPS ( -- )
   ." swarm: routes out (local port " MY-PORT @ .# ." ): "
   EXTIP-N @ 0= IF ." none observed yet" CR EXIT THEN
   EXTIP-N @ 0 ?DO
      I XI xi.ip @ .IP4 [CHAR] : EMIT I XI xi.port @ .#
      ." x" I XI xi.n @ .#  ." /" I XI xi.id .IHPFX
      ." age" NOW-MS I XI xi.first @ - 1000 / .#     \ how long we have held it ...
      ." seen" NOW-MS I XI xi.last @ - 1000 / .#     \ ... and how stale the last confirmation is
      SPACE
   LOOP CR ;
TRUE VALUE DHT-ANNOUNCE?                            \ FALSE = do NOT advertise ourselves as a peer (id=infohash only)
CREATE SECRET 8 ALLOT                              \ per-run token secret
CREATE TOKBUF 8 ALLOT                              \ scratch for the 4-byte token
VARIABLE Q-PING  VARIABLE Q-FIND  VARIABLE Q-GET  VARIABLE Q-ANN  VARIABLE Q-HIT  VARIABLE Q-UTP
VARIABLE Q-SAMPLE                                 \ BEP 51 crawlers asking us to enumerate our store
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
: .CLIENT ( -- )  ."  client=" .V-CLIENT ;       \ tail of every incoming-packet log line; '?' if no 'v'

\ ---- KRPC reply builders (y=r; echo the query's transaction id t) ----
: REPLY-PING { ta tu -- a u }                     \ also the announce_peer reply
   BE-RESET  BE-D{
      S" r" BE-KEY  BE-D{ S" id" BE-KEY CUR-ID @ IDLEN BE-STR BE-}
      S" t" BE-KEY  ta tu BE-STR
      BE-V
      S" y" BE-KEY  S" r" BE-STR
   BE-}  BE-BUF BE-LEN ;
: REPLY-ERROR { ta tu code msga msgu -- a u }      \ KRPC error: {"e":[code,msg],"t":<tid>,"y":"e"}
   BE-RESET  BE-D{
      S" e" BE-KEY  BE-L[  code BE-INT  msga msgu BE-STR  BE-}
      S" t" BE-KEY  ta tu BE-STR
      BE-V
      S" y" BE-KEY  S" e" BE-STR
   BE-}  BE-BUF BE-LEN ;
: REPLY-UNKNOWN ( ta tu -- a u )   204 S" Method Unknown" REPLY-ERROR ;
\ Answering 204 rather than staying silent: it discloses nothing, and a node that never replies at all
\ eventually gets counted as unresponsive and dropped from other nodes' routing tables, which costs us
\ the very reachability we need to be found.
: REPLY-FINDNODE { ta tu \ na nu -- a u }          \ answer with the K nodes closest to a.target
   0 -> na  0 -> nu
   S" target" RX-A-STR IF
      20 = IF RT-CLOSEST-NODES -> nu -> na ELSE DROP THEN
   THEN
   BE-RESET  BE-D{
      S" r" BE-KEY  BE-D{ S" id" BE-KEY CUR-ID @ IDLEN BE-STR  S" nodes" BE-KEY na nu BE-STR BE-}
      S" t" BE-KEY  ta tu BE-STR
      BE-V
      S" y" BE-KEY  S" r" BE-STR
   BE-}  BE-BUF BE-LEN ;
CREATE CP-BUF 6 ALLOT                             \ scratch: our own compact peer (ip4+port)
: BE-EP { ip port -- }                            \ one endpoint as a compact 6-byte peer value
   ip        255 AND CP-BUF    C!   ip  8 RSHIFT 255 AND CP-BUF 1+ C!
   ip 16 RSHIFT 255 AND CP-BUF 2 + C!   ip 24 RSHIFT 255 AND CP-BUF 3 + C!
   port 8 RSHIFT 255 AND CP-BUF 4 + C!  port 255 AND CP-BUF 5 + C!
   CP-BUF 6 BE-STR ;
: BE-SELF ( -- )   \ Advertise every endpoint we have actually been OBSERVED at, not the port we bound:
                   \ behind NAT the local port is unreachable from outside (u24 binds 6882 and appears
                   \ as :3138), and with split-tunnel routing there is more than one route out, each
                   \ with its own stable pair.  The asker tries them and keeps whichever it can reach.
   EXTIP-N @ 0= IF MY-EXT-IP @ MY-PORT @ BE-EP EXIT THEN     \ nothing observed yet -> the configured guess
   EXTIP-N @ 0 ?DO
      I XI xi.port @ ?DUP 0= IF MY-PORT @ THEN               \ some nodes report only the 4 address bytes
      I XI xi.ip @ SWAP BE-EP
   LOOP ;
: BE-SELF-FOR { askerip \ x n -- }
   \ Answer on the interface the question arrived on: hand this asker only the address IT reaches us at.
   \ That also contains a forged endpoint -- if a peer feeds us a bogus 'ip', we only ever quote it back
   \ to that same peer, which learnt nothing it did not invent.  Unknown asker: offer everything.
   askerip PEERMAP-GET -> x
   x 0= IF BE-SELF EXIT THEN
   0 -> n
   EXTIP-N @ 0 ?DO
      I XI xi.ip @ x = IF
         I XI xi.ip @   I XI xi.port @ ?DUP 0= IF MY-PORT @ THEN   BE-EP   n 1+ -> n
      THEN
   LOOP
   n 0= IF BE-SELF THEN ;                           \ that address has aged out -> fall back to all
: REPLY-GETPEERS { ta tu ip ours? iha \ na nu -- a u }   \ our TARGET -> values; foreign hash -> closest nodes
   ours? IF 0 0 ELSE iha RT-CLOSEST-NODES THEN -> nu -> na
   BE-RESET  BE-D{
      S" r" BE-KEY  BE-D{
         S" id" BE-KEY CUR-ID @ IDLEN BE-STR
         S" token" BE-KEY ip MK-TOKEN BE-STR
         ours? IF
            S" values" BE-KEY BE-L[                            \ our infohash: our own peers
               DHT-ANNOUNCE? IF ip BE-SELF-FOR THEN
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
: .RX-A-IH { ka ku -- }   \ print a.<key> hash prefix (4 bytes), or ? -- guard the fixed-width .IHPFX read
   ka ku RX-A-STR IF  4 < IF DROP ." ?" ELSE .IHPFX THEN  ELSE ." ?" THEN ;
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

\ ---- capture malformed incoming datagrams as binary samples for later study ----
\ A datagram the bencode parser rejects (BE-BAD) is appended to a file as a self-describing record:
\   ip(4 bytes, C-IP order) | port(2, big-endian) | len(2, big-endian) | len raw bytes.
\ Bounded by BADPKT-MAX records so a flood can't fill the disk.  Offline: read the 8-byte header, then
\ `len` bytes, repeat.  These accumulate a real-world corpus for the bencode fuzz/regression tests.
TRUE VALUE BADPKT-ON?
256  VALUE BADPKT-MAX
2048 CONSTANT BADPKT-MAXLEN
VARIABLE BADPKT-N   0 BADPKT-N !
CREATE BADPKT-NAME 2 CELLS ALLOT   S" swarm-badpkt.bin" BADPKT-NAME 2!   \ relative to node cwd; override via SET
: SET-BADPKT-FILE ( a u -- )  BADPKT-NAME 2! ;
CREATE BADPKT-HDR 8 ALLOT
FALSE VALUE BADPKT-WARNED?
VARIABLE BADPKT-FID   0 BADPKT-FID !              \ file kept OPEN for the run: WRITE-FILE advances the
: BADPKT-CLOSE ( -- )                            \ position, so we never need FILE-SIZE/REPOSITION-FILE
   BADPKT-FID @ IF BADPKT-FID @ CLOSE-FILE DROP  0 BADPKT-FID ! THEN ;   \ (both are broken on spf64: FILE-SIZE
: BADPKT-WANT? ( -- f )  BADPKT-ON?  BADPKT-N @ BADPKT-MAX < AND ;       \ leaves garbage cells on the stack)
: SAVE-BADPKT { a u ip port -- }
   BADPKT-ON? 0= IF EXIT THEN
   BADPKT-N @ BADPKT-MAX >= IF EXIT THEN
   u 0= u BADPKT-MAXLEN > OR IF EXIT THEN
   BADPKT-FID @ 0= IF                            \ first capture this run: create the file fresh, keep it open
      BADPKT-NAME 2@ R/W BIN CREATE-FILE         ( fid ior )   \ NB a RELATIVE path fails to create on Linux;
      0= IF BADPKT-FID !                                       \ the boot script sets an ABSOLUTE path
      ELSE DROP  BADPKT-WARNED? 0= IF  TRUE TO BADPKT-WARNED?
              ." swarm: badpkt capture DISABLED -- cannot create " BADPKT-NAME 2@ TYPE ."  (absolute path?)" CR
           THEN  EXIT THEN
   THEN
   ip        255 AND BADPKT-HDR    C!   ip  8 RSHIFT 255 AND BADPKT-HDR 1+ C!
   ip 16 RSHIFT 255 AND BADPKT-HDR 2 + C!  ip 24 RSHIFT 255 AND BADPKT-HDR 3 + C!
   port 8 RSHIFT 255 AND BADPKT-HDR 4 + C!  port 255 AND BADPKT-HDR 5 + C!
   u  8 RSHIFT 255 AND BADPKT-HDR 6 + C!  u  255 AND BADPKT-HDR 7 + C!
   BADPKT-HDR 8  BADPKT-FID @ WRITE-FILE DROP
   a u  BADPKT-FID @ WRITE-FILE DROP
   1 BADPKT-N +! ;

\ ---- request dispatch ----
: SERVE-GETPEERS { ip port ta tu \ iha ours -- }
   RX-BUF S" a" B-DFIND 0= IF EXIT THEN                          ( a-dict )
   S" info_hash" DFIND-STR 0= IF EXIT THEN  20 <> IF DROP EXIT THEN  -> iha   \ P0.3: must be exactly 20 bytes
   iha TARGET ID= -> ours
   ." <<< get_peers from " ip port .IPPORT ."  ih=" iha .IHPFX
   ours IF 1 Q-HIT +! ."  (OURS)" ELSE ."  (foreign)" THEN  .CLIENT CR
   ta tu ip ours iha REPLY-GETPEERS  ip port SEND-REPLY ;
: SERVE-ANNOUNCE { ip port ta tu \ ad iha aport -- }
   RX-BUF S" a" B-DFIND 0= IF ta tu REPLY-PING ip port SEND-REPLY EXIT THEN -> ad
   ad S" info_hash" DFIND-STR 0= IF EXIT THEN 20 <> IF DROP EXIT THEN -> iha   \ P0.3: exactly 20 bytes
   ad S" implied_port" B-DFIND IF B-INT@ NIP ELSE 0 THEN
   IF port ELSE ad S" port" B-DFIND IF B-INT@ NIP ELSE port THEN THEN -> aport
   ." <<< announce_peer from " ip aport .IPPORT ."  ih=" iha .IHPFX
   iha TARGET ID= IF
      ad ip TOKEN-OK?  BE-OK? AND  aport 1 65536 WITHIN AND   \ P1(3rd): token ok, integers well-formed,
      IF ip aport PSTORE-ADD  1 Q-HIT +! ."  (OURS)"          \ and port in 1..65535 -- else do not store
      ELSE ."  (OURS, bad token / port -- not stored)" THEN
   ELSE ."  (foreign)" THEN  .CLIENT CR
   ta tu REPLY-PING ip port SEND-REPLY ;

: SERVE-1 { size ip port \ ta tu qa qu b0 -- }     \ handle one datagram already in RX-BUF
   size 0= IF EXIT THEN
   ip SIGN-FOR                                     \ reply as the identity bound to the address
                                                   \ THIS querier reaches us at
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
   BE-OK? 0= IF EXIT THEN                          \ P0.2/P0.3: drop a datagram that tripped the bounds guard
   ip port LEARN-QUERIER                           \ a live node just contacted us: remember it (routing table)
   qa qu S" ping"          STR= IF 1 Q-PING +!  ." <<< ping from " ip port .IPPORT .CLIENT CR
                                    ta tu REPLY-PING     ip port SEND-REPLY EXIT THEN
   qa qu S" find_node"     STR= IF 1 Q-FIND +!  ." <<< find_node from " ip port .IPPORT
                                    ."  target=" S" target" .RX-A-IH .CLIENT CR
                                    ta tu REPLY-FINDNODE ip port SEND-REPLY EXIT THEN
   qa qu S" get_peers"     STR= IF 1 Q-GET  +!  ip port ta tu SERVE-GETPEERS  EXIT THEN
   qa qu S" announce_peer" STR= IF 1 Q-ANN  +!  ip port ta tu SERVE-ANNOUNCE  EXIT THEN
   \ BEP 51 sample_infohashes asks us to hand out a sample of the infohashes we store.  We REFUSE, and
   \ this branch exists so the refusal stays deliberate: our peer store holds essentially one infohash --
   \ IH-GROUP, the SHA1 of our CA's public key -- so answering would hand a crawler the exact key that
   \ identifies the fleet.  It could then get_peers that key and map every member's address.  Joining
   \ would still fail (DTLS + our CA), but the membership map would be public.  Never implement this.
   qa qu S" sample_infohashes" STR= IF 1 Q-SAMPLE +!
                                    ." <<< sample_infohashes from " ip port .IPPORT .CLIENT
                                    ."  (refused: would leak IH-GROUP)" CR
                                    ta tu REPLY-UNKNOWN ip port SEND-REPLY EXIT THEN
   ." <<< query '" qa qu TYPE ." ' from " ip port .IPPORT .CLIENT ."  -> 204" CR
   ta tu REPLY-UNKNOWN ip port SEND-REPLY ;                            \ unrecognised query type

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
         S" id" BE-KEY CUR-ID @ IDLEN BE-STR
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
