\ ~ac/lib/net/dtls-net.f -- DTLS multiplexed onto the one DHT UDP socket, with a per-peer table and
\ timers.  One socket carries: DHT/KRPC (datagrams starting 'd'=0x64) and DTLS (records starting
\ 0x14..0x17).  Incoming DTLS is fed into the matching peer's SSL (mem-BIO); the SSL's output is sent
\ back via UDP-SEND.  Timers per peer: DTLS retransmit (DTLSv1_handle_timeout) and a NAT-keepalive DHT
\ ping every PING-INTERVAL so the 4-tuple mapping stays open for DTLS.
\ On top of that: a verify-callback that LOGS every certificate a peer presents (impostors included);
\ reverse DIAL-BACK -- we initiate DTLS toward any peer whose DHT query carries one of our announced
\ infohashes (server-initiated NAT punch); non-blocking fleet DISCOVERY+announce driven off the serve
\ loop (a persistent converging shortlist; each round dials+verifies the newly harvested peers); and a
\ negative cache so rejected/dead peers aren't re-verified every round.
\ Load order: swarm.f (DHT + CERT-SPKI/SHA1) then dtls.f then this.  CRLF.
REQUIRE SWARM-ANNOUNCE ~ac/lib/net/swarm.f     \ DHT (UDP-SEND/RECV, DHT-SOCK, PING-MSG, NOW-MS, SERVE-1, .IPPORT), CERT-SPKI, SHA1, .HASH
REQUIRE DTLS-CTX       ~ac/lib/net/dtls.f      \ DTLS context + wrappers
DECIMAL

\ ===== verify-callback: LOG every certificate a peer presents during a handshake ================
\ Armed by dtls.f's DTLS-CTX via the DTLS-VERIFY-CB hook.  OpenSSL calls it SYNCHRONOUSLY from inside
\ SSL_do_handshake, once per chain cert, for BOTH accepted and rejected certs -- so a self-signed
\ WebRTC ClientHello, or an impostor whose cert chains to a foreign CA, shows up here with
\ preverify=0 and its REAL subject + SPKI hash, just before the handshake aborts.
\ GOTCHA (seed callback.f): at entry the C caller leaves the base register (USER base) pointing into
\ OpenSSL's frame, so USER vars (BASE, ...) are garbage until restored.  Like acWEB64 tls.f's SNI
\ callback we stashed our base in the SSL ex_data (DTLS-WRAP) and recover it here via the
\ X509_STORE_CTX -> SSL link, then run the body under CATCH so no Forth THROW unwinds through C.
\ SHA1/CERT-SPKI/.HASH here are the swarm.f Forth words (dtls.f already did PREVIOUS PREVIOUS).
CREATE CB-IDBUF 20 ALLOT

: (VERIFY-LOG) { sctx preverify \ x509 -- }               \ base already restored; print the presented cert
   sctx SCTX-CERT -> x509
   ." ~~~ peer cert  depth=" sctx SCTX-DEPTH .  ." preverify=" preverify .
   x509 0= IF ." (no cert)" CR EXIT THEN
   x509 X509-SUBJECT ." subj=" TYPE
   x509 X509>DER DUP IF CERT-SPKI CB-IDBUF SHA1  ."  SPKI=" CB-IDBUF .HASH
                  ELSE 2DROP THEN
   preverify 0= IF ."  REJECT(" sctx SCTX-ERR VERR-STR TYPE ." )" THEN
   CR ;

:NONAME { sctx preverify \ tls ssl base -- ret }          \ C callback: (preverify_ok, X509_STORE_CTX*)
   TlsIndex@ -> tls                                       \ save the base the C caller left (garbage)
   sctx SCTX>SSL -> ssl
   ssl IF ssl SSL>BASE -> base  base IF base TlsIndex! THEN THEN   \ restore OUR USER base
   sctx preverify ['] (VERIFY-LOG) CATCH DROP             \ log; a THROW must never cross into C
   tls TlsIndex!                                          \ hand the caller's base back
   preverify ;                                            \ verdict unchanged (log-only)
2 CELLS CALLBACK: SWARM-VERIFY-CB
' SWARM-VERIFY-CB TO DTLS-VERIFY-CB                        \ DTLS-CTX now arms verify WITH logging

\ ---- our node identity: one server ctx (accept inbound) + one client ctx (dial outbound) ----
VARIABLE NODE-SCTX   VARIABLE NODE-CCTX
: SWARM-DTLS-CONFIG { cert-c key-c ca-c -- }
   cert-c key-c ca-c DTLS-SERVER-CTX NODE-SCTX !
   cert-c key-c ca-c DTLS-CLIENT-CTX NODE-CCTX ! ;

\ ---- per-peer table:  ip port ssl rbio wbio state ping-ms expect deadline  (9 cells) ----
\ expect = addr of the 20-byte SPKI hash this candidate must present (0 = any CA-signed member is fine)
64 CONSTANT MAXPEERS
0 CONSTANT ST-FREE   1 CONSTANT ST-HS   2 CONSTANT ST-UP   3 CONSTANT ST-FAIL
0                          \ peer record fields
CELL -- pr.ip
CELL -- pr.port
CELL -- pr.ssl
CELL -- pr.rbio
CELL -- pr.wbio
CELL -- pr.state
CELL -- pr.ping
CELL -- pr.expect          \ expected SPKI-hash addr, or 0
CELL -- pr.dl              \ connect deadline
CELL -- pr.rx              \ last time ANY datagram arrived from this peer (liveness)
CONSTANT /PR
CREATE PEERTAB  MAXPEERS /PR *  ALLOT   PEERTAB MAXPEERS /PR * ERASE
25000 VALUE PING-INTERVAL          \ NAT-keepalive interval, ms (<30s: UDP mappings often expire ~30-60s)
8000  VALUE CONNECT-TIMEOUT        \ ms for a candidate to reach ST-UP before we give up
90000 VALUE PEER-IDLE              \ ms of total silence before an established peer is reclaimed (> 3 pings)
600000 VALUE NCACHE-BAD-TTL        \ ms to shun a peer whose cert was REJECTED (won't become ours; cache long)
90000  VALUE NCACHE-SLOW-TTL       \ ms before re-dialing a peer that TIMED OUT (> round period, but keep retrying: maybe NAT)
16384 CONSTANT /DNET-BUF   CREATE DNET-BUF /DNET-BUF ALLOT   \ big enough to send a whole flight in one datagram (don't split DTLS records)
16384 CONSTANT /RXBIG      CREATE RXBIG /RXBIG ALLOT          \ receive buffer (DTLS flights exceed the 2048 DHT RX-BUF)
CREATE PEER-IDBUF 20 ALLOT

\ ---- negative cache: (ip port expire-ms) so we don't re-DTLS impostors/dead peers every lookup ----
128 CONSTANT /NCACHE
0                          \ negative-cache record fields
CELL -- nc.ip
CELL -- nc.port
CELL -- nc.expire
CONSTANT /NC
CREATE NCACHE  /NCACHE /NC *  ALLOT   NCACHE /NCACHE /NC *  ERASE
: NC ( i -- a )  /NC *  NCACHE + ;
: NCACHE-HAS? { ip port \ now -- f }
   NOW-MS -> now
   /NCACHE 0 ?DO
      I NC nc.expire @ now U> IF                             \ entry not expired
         I NC nc.ip @ ip = I NC nc.port @ port = AND IF TRUE UNLOOP EXIT THEN
      THEN
   LOOP FALSE ;
: NCACHE-ADD { ip port ttl \ now slot -- }
   NOW-MS -> now  -1 -> slot
   /NCACHE 0 ?DO I NC nc.expire @ now U< IF I -> slot LEAVE THEN LOOP  \ reuse an expired slot
   slot 0< IF 0 -> slot THEN                                 \ none free: overwrite slot 0
   ip slot NC nc.ip !  port slot NC nc.port !  now ttl + slot NC nc.expire ! ;

: PR       ( idx -- a )     /PR * PEERTAB + ;
: PR-IP    ( idx -- ip )    PR pr.ip @ ;
: PR-PORT  ( idx -- port )  PR pr.port @ ;
: PR-SSL   ( idx -- ssl )   PR pr.ssl @ ;
: PR-RBIO  ( idx -- bio )   PR pr.rbio @ ;
: PR-WBIO  ( idx -- bio )   PR pr.wbio @ ;
: PR-STATE ( idx -- st )    PR pr.state @ ;
: PR-STATE! ( st idx -- )   PR pr.state ! ;
: PR-PING@ ( idx -- ms )    PR pr.ping @ ;
: PR-PING! ( ms idx -- )    PR pr.ping ! ;
: PR-EXPECT@ ( idx -- a )   PR pr.expect @ ;
: PR-EXPECT! ( a idx -- )   PR pr.expect ! ;
: PR-DL@ ( idx -- ms )      PR pr.dl @ ;
: PR-DL! ( ms idx -- )      PR pr.dl ! ;
: PR-RX@ ( idx -- ms )      PR pr.rx @ ;
: PR-RX! ( ms idx -- )      PR pr.rx ! ;

: PR-ALLOC ( -- idx | -1 )
   MAXPEERS 0 ?DO I PR-STATE ST-FREE = IF I UNLOOP EXIT THEN LOOP -1 ;
: PR-FIND { ip port -- idx }
   MAXPEERS 0 ?DO
      I PR-STATE ST-FREE <> IF
         I PR-IP ip = I PR-PORT port = AND IF I UNLOOP EXIT THEN
      THEN
   LOOP -1 ;
: PR-NEW { ip port server? \ idx ssl rb wb p -- idx }
   PR-ALLOC DUP 0< IF EXIT THEN -> idx
   server? IF NODE-SCTX @ ELSE NODE-CCTX @ THEN  server? DTLS-WRAP1  -> wb -> rb -> ssl
   idx PR -> p
   ip p pr.ip !  port p pr.port !  ssl p pr.ssl !  rb p pr.rbio !  wb p pr.wbio !
   ST-HS idx PR-STATE!   NOW-MS PING-INTERVAL + idx PR-PING!
   0 idx PR-EXPECT!  NOW-MS CONNECT-TIMEOUT + idx PR-DL!
   NOW-MS idx PR-RX!
   idx ;

\ ---- pump: send everything the SSL has produced; deliver an inbound datagram; advance ----
\ A DTLS record = 13-byte header (type/version/epoch/seq/length) + `length` bytes; length @ offset 11-12.
: DTLS-RECLEN ( rec-a -- total )  11 + DUP C@ 8 LSHIFT SWAP 1+ C@ +  13 + ;
: PR-PUMP-OUT { idx \ wbio total p end rl -- }     \ send each DTLS RECORD as its own datagram (MTU-safe)
   idx PR-WBIO -> wbio
   wbio BIO-PENDING 0= IF EXIT THEN
   wbio DNET-BUF /DNET-BUF WBIO-READ -> total       \ pull the whole queued flight at once
   total 0> 0= IF EXIT THEN
   DNET-BUF -> p   DNET-BUF total + -> end
   BEGIN p end U< WHILE
      p 13 + end U> IF EXIT THEN                     \ not even a full record header left
      p DTLS-RECLEN -> rl
      rl 13 < IF EXIT THEN                           \ malformed -> stop
      p rl + end U> IF EXIT THEN                     \ record runs past buffer -> stop
      idx PR-IP idx PR-PORT p rl DHT-SOCK @ UDP-SEND
      p rl + -> p
   REPEAT ;
: PR-FAIL { idx reason-a reason-u ttl -- }        \ reject a peer: log, negative-cache for ttl ms, free its SSL
   ." >>> REJECTED " idx PR-IP idx PR-PORT .IPPORT ."  (" reason-a reason-u TYPE ." )" CR
   idx PR-IP idx PR-PORT ttl NCACHE-ADD
   idx PR-SSL SSL-FREE   ST-FREE idx PR-STATE! ;
: PR-UP { idx \ ssl -- }                          \ handshake done: verify identity, keep or reject
   idx PR-SSL -> ssl
   ssl DTLS-VERIFIED? 0= IF idx S" cert not signed by our CA" NCACHE-BAD-TTL PR-FAIL EXIT THEN
   ssl DTLS-PEER-DER  DUP 0= IF                                     \ 0 0 = no cert, or cert > /PEER-DER (4096)
      2DROP idx S" peer cert missing/too large" NCACHE-BAD-TTL PR-FAIL EXIT THEN
   CERT-SPKI PEER-IDBUF SHA1                                        \ the peer's real SPKI hash
   idx PR-EXPECT@ ?DUP IF                                           \ a specific server was expected
      PEER-IDBUF SWAP 20 MEM= 0= IF idx S" identity hash mismatch" NCACHE-BAD-TTL PR-FAIL EXIT THEN
   THEN
   ." <<< MEMBER verified " idx PR-IP idx PR-PORT .IPPORT ."  SPKI=" PEER-IDBUF .HASH CR ;
: PR-ADVANCE { idx \ ret -- }
   idx PR-STATE ST-HS = IF
      idx PR-SSL DTLS-HS1 -> ret
      ret 1 = IF  ST-UP idx PR-STATE!  idx PR-UP                       \ PR-UP may reject -> ST-FREE
      ELSE  idx PR-SSL ret DTLS-ERR                                    \ not done: fatal, or just WANT_READ?
            DUP SSL_ERROR_WANT_READ = SWAP SSL_ERROR_WANT_WRITE = OR 0= IF
               idx S" DTLS handshake failed (bad/foreign cert)" NCACHE-BAD-TTL PR-FAIL   \ fatal alert -> reject fast
            THEN
      THEN
   THEN
   idx PR-STATE ST-FREE <> IF idx PR-PUMP-OUT THEN ;
: PR-DELIVER { idx a u -- }
   idx PR-RBIO a u RBIO-WRITE DROP
   idx PR-ADVANCE ;

\ ---- outbound connect ----
: SWARM-DTLS-CONNECT { ip port expect-a -- idx }  \ dial a peer; expect-a = addr of required SPKI hash or 0
   ip port FALSE PR-NEW  DUP 0< IF EXIT THEN
   expect-a OVER PR-EXPECT!
   DUP PR-ADVANCE ;

\ ===== non-blocking re-announce ============================================================
\ A DHT lookup+announce as a state machine driven by the shared serve loop, so re-announcing never
\ blocks DTLS.  ANN-START fires get_peers (send-only) at the bootstrap routers; each DHT REPLY that
\ arrives in the loop harvests nodes toward the target, announces us to the responder if it is close,
\ and fires the next get_peers.  After LOOKUP-WINDOW ms the round ends; REANNOUNCE-EVERY ms later the
\ next round starts.  All sends are fire-and-forget -- no blocking recv anywhere.
CREATE ANN-IH 20 ALLOT
VARIABLE ANN-ACTIVE   VARIABLE ANN-DEADLINE   VARIABLE ANN-NEXT   VARIABLE ANN-QUERIES
CREATE ROUTER-IPS 3 CELLS ALLOT   VARIABLE ROUTERS-RESOLVED
30000 VALUE REANNOUNCE-EVERY       \ ms between re-announce rounds
8000  VALUE LOOKUP-WINDOW          \ ms each round runs before it stops
: RESOLVE-ROUTERS ( -- )           \ resolve the bootstrap routers ONCE (the only blocking bit, at startup)
   ROUTERS-RESOLVED @ IF EXIT THEN
   S" router.bittorrent.com"  NAME>IP IF DROP 0 THEN ROUTER-IPS !
   S" dht.transmissionbt.com" NAME>IP IF DROP 0 THEN ROUTER-IPS CELL+ !
   S" router.utorrent.com"    NAME>IP IF DROP 0 THEN ROUTER-IPS 2 CELLS + !
   TRUE ROUTERS-RESOLVED ! ;
\ ---- outstanding get_peers queries (KRPC transaction correlation) -------------------------------
\ Only a reply carrying OUR transaction id AND coming FROM the peer we asked may feed the lookup.
\ Without this anyone can poison the shortlist/PEERS, burn our query budget, or hand us a token and
\ make us announce ourselves to an arbitrary address.
128 CONSTANT /OUTQ
0
CELL -- oq.tid                     \ the 2-byte transaction id as an int
CELL -- oq.ip
CELL -- oq.port
CELL -- oq.expire                  \ ms deadline; past it the slot is free
CELL -- oq.sent                    \ ms we sent it (per-query timeout / in-flight accounting)
CONSTANT /OQ
CREATE OUTQ  /OUTQ /OQ *  ALLOT   OUTQ /OUTQ /OQ *  ERASE
8000 VALUE OUTQ-TTL                \ ms an outstanding query stays matchable
: OQ ( i -- a )   /OQ *  OUTQ + ;
: TID@ ( a -- n )  DUP C@ 8 LSHIFT  SWAP 1+ C@ + ;    \ 2 bytes big-endian -> int
: OQ-ADD { tid ip port \ now slot -- }                \ remember a query we just sent
   NOW-MS -> now  -1 -> slot
   /OUTQ 0 ?DO I OQ oq.expire @ now U< IF I -> slot LEAVE THEN LOOP   \ reuse an expired slot
   slot 0< IF 0 -> slot THEN
   tid slot OQ oq.tid !  ip slot OQ oq.ip !  port slot OQ oq.port !
   now OUTQ-TTL + slot OQ oq.expire !   now slot OQ oq.sent ! ;
: OQ-MATCH? { tid ip port \ now -- f }                \ our tid AND the peer we asked? (consumes the slot)
   NOW-MS -> now
   /OUTQ 0 ?DO
      I OQ oq.expire @ now U> IF
         I OQ oq.tid @ tid =  I OQ oq.ip @ ip = AND  I OQ oq.port @ port = AND IF
            0 I OQ oq.sent !    \ answered: drops out of in-flight, but stays matchable until oq.expire
            TRUE UNLOOP EXIT THEN   \ (so a retransmitted/duplicate reply still correlates)
      THEN
   LOOP FALSE ;
: OQ-IP? { ip \ now f -- f }       \ diagnosis: do we have a live query to this IP (any port)?
   NOW-MS -> now  FALSE -> f
   /OUTQ 0 ?DO  I OQ oq.expire @ now U>  I OQ oq.ip @ ip = AND IF TRUE -> f LEAVE THEN  LOOP  f ;
: OQ-TID-FOR { ip port \ now t -- tid|-1 }   \ diagnosis: the tid we recorded for this exact ip:port
   NOW-MS -> now  -1 -> t
   /OUTQ 0 ?DO
      I OQ oq.expire @ now U>  I OQ oq.ip @ ip = AND  I OQ oq.port @ port = AND
      IF I OQ oq.tid @ -> t LEAVE THEN
   LOOP t ;

\ ---- P1.3: keep ALPHA queries in flight, each with its own timeout ------------------------------
\ The chain used to advance ONLY when a reply arrived, so one silent node stalled it for the whole
\ round.  Now the tick tops the in-flight set back up to ALPHA: a query that goes unanswered for
\ QUERY-TIMEOUT simply frees its slot and the next closest candidate is queried.
3    VALUE LOOKUP-ALPHA             \ concurrent in-flight get_peers (Kademlia alpha)
2000 VALUE QUERY-TIMEOUT            \ ms before an unanswered query stops counting as in-flight
: OQ-INFLIGHT { \ now n -- n }      \ queries still awaiting a reply and not yet timed out
   NOW-MS -> now  0 -> n
   /OUTQ 0 ?DO
      I OQ oq.expire @ now U>  I OQ oq.sent @ QUERY-TIMEOUT + now U>  AND IF n 1+ -> n THEN
   LOOP n ;

\ ---- P1.4: announce to the K CLOSEST responders, not to everyone who answers --------------------
\ A wide announce wastes traffic and stores us on nodes FAR from the target, where later lookups never
\ look.  Collect (responder id, endpoint, token) from correlated replies during the round; when the
\ round closes, announce only to the K closest to TARGET.
8  CONSTANT ANNOUNCE-K
32 CONSTANT /AQ-TOK
0
IDLEN   -- aq.id                   \ responder node id (for the XOR-distance choice)
CELL    -- aq.ip
CELL    -- aq.port
CELL    -- aq.tlen
/AQ-TOK -- aq.tok
CONSTANT /AQ
CREATE ANNQ  ANNOUNCE-K /AQ *  ALLOT
VARIABLE ANNQ-N   0 ANNQ-N !
: AQ ( i -- a )  /AQ *  ANNQ + ;
: ANNQ-RESET ( -- )  0 ANNQ-N ! ;
: AQ-FARTHEST ( -- idx )           \ collected slot farthest from TARGET
   0  ANNQ-N @ 1 ?DO  DUP AQ aq.id  I AQ aq.id  TARGET XOR-CLOSER? IF DROP I THEN  LOOP ;
: ANNQ-ADD { ida ip port toka toku \ idx -- }     \ keep the K closest responders that gave us a token
   toku /AQ-TOK > IF EXIT THEN
   ANNQ-N @ ANNOUNCE-K < IF  ANNQ-N @ -> idx  1 ANNQ-N +!
   ELSE  AQ-FARTHEST -> idx
      ida  idx AQ aq.id  TARGET XOR-CLOSER? 0= IF EXIT THEN     \ not closer than the farthest -> drop it
   THEN
   ida idx AQ aq.id IDLEN MOVE
   ip idx AQ aq.ip !  port idx AQ aq.port !
   toka idx AQ aq.tok toku MOVE  toku idx AQ aq.tlen ! ;
: ANNQ-FLUSH ( -- )                \ announce ourselves to the K closest collected responders
   ANNQ-N @ 0 ?DO
      ." > announce " CUR-IH @ .IHPFX ."  -> " I AQ aq.ip @ I AQ aq.port @ .IPPORT ."  (K-closest)" CR
      I AQ aq.ip @  I AQ aq.port @   I AQ aq.tok  I AQ aq.tlen @  ANNOUNCE-MSG  DHT-SOCK @ UDP-SEND
      TXBUF TID@  I AQ aq.ip @  I AQ aq.port @  OQ-ADD
   LOOP  ANNQ-RESET ;

: SEED-SEND { \ rip -- }
   RESOLVE-ROUTERS
   3 0 DO ROUTER-IPS I CELLS + @ ?DUP IF -> rip
      ." > get_peers " CUR-IH @ .IHPFX ."  -> " rip 6881 .IPPORT CR
      rip 6881 GETPEERS-MSG DHT-SOCK @ UDP-SEND
      TXBUF TID@ rip 6881 OQ-ADD                      \ only this router may answer with this tid
   THEN LOOP ;
: LOOKUP-SEND-NEXT { \ idx ip port -- sent? }   \ get_peers to the next closest un-queried node
   ANN-QUERIES @ MAX-QUERIES >= IF FALSE EXIT THEN
   SL-PICK -> idx  idx 0< IF FALSE EXIT THEN
   1 idx SL-Q + C!
   idx SL-NODE DUP NODE-IP -> ip  NODE-PORT -> port
   ." > get_peers " CUR-IH @ .IHPFX ."  -> " ip port .IPPORT CR
   ip port GETPEERS-MSG DHT-SOCK @ UDP-SEND
   TXBUF TID@ ip port OQ-ADD                          \ only this peer may answer with this tid
   1 ANN-QUERIES +!  TRUE ;
: LOOKUP-PUMP ( -- )                \ keep ALPHA queries in flight (drives the lookup on TIME, not only on replies)
   BEGIN ANN-ACTIVE @  OQ-INFLIGHT LOOKUP-ALPHA <  AND WHILE
      LOOKUP-SEND-NEXT 0= IF EXIT THEN
   REPEAT ;
: ANN-START ( ih-a -- )                              \ start a lookup round; keep the CONVERGING shortlist
   DUP TARGET IDLEN MOVE  CUR-IH !                    \ + accumulated PEERS across rounds (real-DHT style)
   SL-REQUERY  0 ANN-QUERIES !  ANNQ-RESET  SEED-SEND             \ re-probe every known node + pull fresh router nodes
   TRUE ANN-ACTIVE !  NOW-MS LOOKUP-WINDOW + ANN-DEADLINE !
   ." swarm: fleet lookup round started (SL=" SL-N @ .  ." nodes PEERS=" PEERS-N @ .  ." )" CR ;
: RESP-CLOSE? ( ra -- f )          \ responder id's first byte == TARGET's (i.e. near the infohash)
   S" id" B-DFIND 0= IF FALSE EXIT THEN
   B-STR@ DROP NIP C@  TARGET C@ = ;
VARIABLE OQ-HIT   VARIABLE OQ-MISS                \ correlated vs uncorrelated replies seen (diagnostics)
: LOOKUP-FEED { ip port \ ra ta tu ok rtid -- }   \ a DHT reply is in RX-BUF: advance the announce round
   ANN-ACTIVE @ 0= IF EXIT THEN
   RX-BUF C@ [CHAR] d <> IF EXIT THEN
   \ P1.1: does this reply carry OUR transaction id AND come FROM the peer we asked?  Only a correlated
   \ reply may make us ANNOUNCE (an attacker could otherwise hand us a token and aim our announce).
   \ Harvesting is NOT gated on it: a strict gate stalled the lookup chain (kept for later tightening).
   FALSE -> ok   -1 -> rtid
   RX-BUF S" t" DFIND-STR IF
      2 = IF TID@ -> rtid  rtid ip port OQ-MATCH? -> ok  ELSE DROP THEN
   THEN
   RX-BUF S" r" B-DFIND 0= IF EXIT THEN -> ra      \ 'r' reply (incoming QUERIES have no 'r' -> not counted)
   ok IF 1 OQ-HIT +! ELSE 1 OQ-MISS +!             \ P1.1 FULL: an uncorrelated reply is DROPPED here --
      ." ? uncorrelated reply from " ip port .IPPORT \ it may not poison the shortlist/PEERS, burn our query
      ."  reply-tid=" rtid .  ." our-tid-for-that-endpoint=" ip port OQ-TID-FOR . CR
      EXIT                                          \ budget, or hand us a token.  (Measured miss=0/73.)
   THEN
   ra S" nodes" B-DFIND IF DROP TRUE ELSE ra S" values" B-DFIND IF DROP TRUE ELSE FALSE THEN THEN
   0= IF EXIT THEN                                 \ must be a get_peers reply (nodes/values), not a bare ping (P1.1)
   ra S" token" B-DFIND IF                         \ (correlated) token -> remember as an announce candidate;
      B-STR@ ROT DROP -> tu -> ta                  \ the K closest are announced to when the round closes
      ra S" id" DFIND-STR IF                       ( id-a id-u )
         20 = IF ip port ta tu ANNQ-ADD ELSE DROP THEN
      THEN
   THEN
   ra HARVEST  LOOKUP-PUMP ;
0 VALUE ROUND-END-XT               \ hook run once a lookup round closes: dial+verify harvested peers
: ANN-TICK ( -- )
   ANN-ACTIVE @ IF
      NOW-MS ANN-DEADLINE @ U< 0= IF
         FALSE ANN-ACTIVE !  NOW-MS REANNOUNCE-EVERY + ANN-NEXT !
         ANNQ-FLUSH                                              \ P1.4: announce to the K closest found
         ROUND-END-XT ?DUP IF EXECUTE THEN                       \ verify the fleet peers this round found
      ELSE LOOKUP-PUMP                                           \ round still open: keep ALPHA in flight
      THEN
   ELSE ANN-NEXT @ ?DUP IF NOW-MS SWAP U< 0= IF ANN-IH ANN-START THEN THEN THEN ;
: SWARM-REANNOUNCE ( ih-a -- )     \ arm periodic non-blocking re-announce of ih (first round starts now)
   ANN-IH IDLEN MOVE  NOW-MS ANN-NEXT ! ;

\ ===== dial-back: server-initiated DTLS toward a peer that contacted us at the DHT level ==========
\ The protocol is symmetric: every node keeps announcing itself AND looking up its own kind by the CA
\ hash, so an unknown peer whose DHT query carries one of OUR announced infohashes is, by definition,
\ looking for our swarm.  We dial it with an outbound DTLS handshake -- which both verifies it (real
\ member vs fake) AND, if it is a NAT'd node that just opened a mapping toward us by querying, punches
\ that mapping from our side.  This is the "reverse" direction; no separate probe phase is needed --
\ the handshake IS the probe.  The negative cache stops us from re-dialing fakes/dead peers each time.
4 CONSTANT /DBKEYS
CREATE DBKEYS  /DBKEYS IDLEN *  ALLOT   VARIABLE DBKEYS-N
: SWARM-DIALBACK-KEY ( ih-a -- )       \ register an infohash whose queriers we dial back
   DBKEYS-N @ /DBKEYS < IF
      DBKEYS-N @ IDLEN *  DBKEYS +  IDLEN MOVE   1 DBKEYS-N +!
   ELSE DROP THEN ;
: DBKEY-MATCH? { ih-a -- f }           \ ih-a equals one of our registered keys?
   DBKEYS-N @ 0 ?DO
      ih-a  I IDLEN *  DBKEYS +  IDLEN MEM= IF TRUE UNLOOP EXIT THEN
   LOOP FALSE ;
: RX-QUERY-IH ( -- ih-a true | false ) \ info_hash of a get_peers/announce_peer query in RX-BUF
   RX-BUF S" y" DFIND-STR 0= IF FALSE EXIT THEN  S" q" STR= 0= IF FALSE EXIT THEN   \ must be a QUERY (y=q)
   RX-BUF S" q" DFIND-STR 0= IF FALSE EXIT THEN          ( qa qu )                  \ q in {get_peers, announce_peer}
   2DUP S" get_peers" STR=  >R  S" announce_peer" STR=  R> OR 0= IF FALSE EXIT THEN
   RX-BUF S" a" B-DFIND 0= IF FALSE EXIT THEN            \ the 'a' arguments dict
   S" info_hash" B-DFIND 0= IF FALSE EXIT THEN
   B-STR@ ROT DROP 20 = IF TRUE ELSE DROP FALSE THEN ;   \ 20-byte info_hash -> ( ih-a true )
: SWARM-DIAL-BACK { ip port -- }       \ dial an unknown swarm querier (skip self / known / cached-bad)
   ip MY-EXT-IP @ = port MY-PORT @ = AND IF EXIT THEN
   ip port PR-FIND 0< 0= IF EXIT THEN
   ip port NCACHE-HAS? IF EXIT THEN
   ." <-> dial-back to swarm querier " ip port .IPPORT CR
   ip port 0 SWARM-DTLS-CONNECT DROP ;                   \ outbound DTLS, any CA-signed member is fine

\ ---- DTLS admission control: only a genuine initial ClientHello from an unknown source may create
\ state, and no more than HS-MAX unfinished handshakes at once -- so stray alert/app records and a
\ flood of 0x14..0x17 bytes can't allocate SSL/peer slots.  (Full anti-amplification against SPOOFED-
\ source ClientHellos still needs a stateless cookie / HelloVerifyRequest -- a later step.)
: CLIENTHELLO? ( a len -- f )                     \ a fresh initial DTLS ClientHello record?
   14 < IF DROP FALSE EXIT THEN                    \ need 13-byte record header + >=1 handshake byte
   DUP C@ 22 <> IF DROP FALSE EXIT THEN            \ content_type = handshake (0x16)
   DUP 3 + C@ OVER 4 + C@ OR IF DROP FALSE EXIT THEN   \ epoch == 0 (initial flight)
   13 + C@ 1 = ;                                   \ handshake msg_type = client_hello (1)
16 VALUE HS-MAX                                    \ cap on concurrent unfinished inbound handshakes
: HS-COUNT ( -- n )  0  MAXPEERS 0 ?DO I PR-STATE ST-HS = IF 1+ THEN LOOP ;

\ ---- receive dispatch on the shared socket (datagram already in RX-BUF, length = len) ----
: SWARM-RX { len ip port \ b0 idx -- }
   len 0= IF EXIT THEN
   ip port PR-FIND DUP 0< 0= IF NOW-MS SWAP PR-RX! ELSE DROP THEN   \ any datagram from a known peer = it's alive
   RXBIG C@ -> b0
   b0 [CHAR] d = IF                                          \ DHT KRPC: copy to RX-BUF for SERVE-1 + lookup
      RXBIG RX-BUF len 2048 MIN MOVE
      len 2048 MIN ip port SERVE-1                           \ y=q queries: answer + log (value to the DHT)
      ip port LOOKUP-FEED                                    \ y=r replies: advance our re-announce round
      RX-QUERY-IH IF DBKEY-MATCH? IF ip port SWARM-DIAL-BACK THEN THEN  \ swarm querier -> reverse DTLS
      EXIT THEN
   b0 20 24 WITHIN IF                                        \ 0x14..0x17 = DTLS record
      ip port PR-FIND -> idx
      idx 0< 0= IF                                           \ existing peer for this address?
         RXBIG len CLIENTHELLO?  idx PR-STATE ST-UP = AND IF
            idx PR-SSL SSL-FREE  ST-FREE idx PR-STATE!  -1 -> idx   \ fresh ClientHello to a live peer -> reconnect
         THEN
      THEN
      idx 0< IF                                              \ no peer for this source address:
         RXBIG len CLIENTHELLO?  HS-COUNT HS-MAX < AND IF    \ ONLY a real ClientHello, and only if we have room,
            ip port TRUE PR-NEW -> idx                       \ allocates accept-side state (drop stray/flood records)
         THEN
      THEN
      idx 0< 0= IF idx RXBIG len PR-DELIVER THEN
      EXIT
   THEN ;                                                    \ else (uTP/junk): ignore

\ ---- per-tick timers: DTLS retransmit + NAT-keepalive ping ----
: PR-PING-CHECK { idx -- }
   NOW-MS  idx PR-PING@  U< 0= IF                            \ NOW-MS >= next-ping deadline
      idx PR-IP idx PR-PORT  PING-MSG  DHT-SOCK @ UDP-SEND   \ a DHT ping keeps the NAT 4-tuple open
      NOW-MS PING-INTERVAL + idx PR-PING!
      ." (NAT keepalive ping -> " idx PR-IP idx PR-PORT .IPPORT ." )" CR
   THEN ;
: PR-TICK ( -- )
   MAXPEERS 0 ?DO
      I PR-STATE ST-FREE <> IF
         I PR-STATE ST-HS =  NOW-MS I PR-DL@ U>  AND IF        \ still handshaking past its deadline
            I S" handshake timeout (no valid DTLS response)" NCACHE-SLOW-TTL PR-FAIL
         ELSE I PR-STATE ST-UP =  NOW-MS I PR-RX@ -  PEER-IDLE U>  AND IF   \ established but silent -> reclaim
            ." --- peer idle, dropping " I PR-IP I PR-PORT .IPPORT CR       \ (frees the slot; NAT rebind/dead)
            I PR-SSL SSL-FREE  ST-FREE I PR-STATE!
         ELSE
            I PR-SSL DTLS-TIMEOUT DROP     \ retransmit a lost flight if its timer is due
            I PR-PUMP-OUT
            I PR-STATE ST-UP = IF I PR-PING-CHECK THEN
         THEN THEN
      THEN
   LOOP ;

\ ---- the multiplexed serve loop (DHT + DTLS + timers) on the one socket ----
: SWARM-DTLS-SERVE { secs \ deadline len ip port -- }
   NOW-MS secs 1000 * + -> deadline
   BEGIN NOW-MS deadline U< WHILE
      RXBIG /RXBIG DHT-SOCK @ UDP-RECV  -> port -> ip -> len
      len IF len ip port SWARM-RX THEN
      PR-TICK
      ANN-TICK                       \ non-blocking re-announce round management
   REPEAT ;

\ ---- stitch discovery -> DTLS auth: take the peers SWARM-FIND collected and verify each one ----
: SWARM-CONNECT-CANDIDATES { expect-a \ e ip port -- }
   ." swarm: " PEERS-N @ .  ." candidates from discovery; connecting + verifying..." CR
   PEERS-N @ 0 ?DO
      PEERS I 6 * + -> e
      e C-IP -> ip   e 4 + C-PORT -> port
      ip MY-EXT-IP @ = port MY-PORT @ = AND IF
         ." swarm:   skip self       " ip port .IPPORT CR
      ELSE ip port PR-FIND 0< 0= IF
         ." swarm:   skip known peer  " ip port .IPPORT CR
      ELSE ip port NCACHE-HAS? IF
         ." swarm:   skip cached-bad  " ip port .IPPORT CR
      ELSE
         ." swarm:   dial candidate   " ip port .IPPORT CR
         ip port expect-a SWARM-DTLS-CONNECT DROP
      THEN THEN THEN
   LOOP ;
: SWARM-JOIN { ih-a expect-a -- }                 \ discover peers for ih, then DTLS-verify each candidate
   ih-a SWARM-FIND                                \ fills PEERS/PEERS-N (retried + deduped)
   expect-a SWARM-CONNECT-CANDIDATES ;            \ handshakes complete/reject in the following SWARM-DTLS-SERVE

\ Dial+verify the accumulated fleet peers at each round's end.  With a PERSISTENT PEERS set most entries
\ are already known/connected, so we only LOG genuinely new dials and summarise the rest (no per-peer
\ "skip known" spam).  Un-connected, non-cached peers are re-dialed every round = NAT-punch retry.
: SWARM-DISCOVER-DIAL { \ e ip port dialed known bad self -- }
   0 -> dialed  0 -> known  0 -> bad  0 -> self
   PEERS-N @ 0 ?DO
      PEERS I 6 * + -> e   e C-IP -> ip   e 4 + C-PORT -> port
      ip MY-EXT-IP @ = port MY-PORT @ = AND IF self 1+ -> self
      ELSE ip port PR-FIND 0< 0= IF known 1+ -> known
      ELSE ip port NCACHE-HAS? IF bad 1+ -> bad
      ELSE ." swarm:   dial new peer " ip port .IPPORT CR
           ip port 0 SWARM-DTLS-CONNECT DROP  dialed 1+ -> dialed
      THEN THEN THEN
   LOOP
   ." swarm: discovery: PEERS=" PEERS-N @ .  ." (" dialed .  ." new, " known .  ." known, "
   bad .  ." bad, " self .  ." self)  corr-hit=" OQ-HIT @ .  ." miss=" OQ-MISS @ . CR ;
' SWARM-DISCOVER-DIAL TO ROUND-END-XT
