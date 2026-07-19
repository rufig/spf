\ ~ac/lib/net/swarm.f -- Eserv/acWEB64 fleet self-discovery over the DHT: derive the fleet keys from
\ the certs (PEM or DER), open the DHT socket, announce, and run retried+deduplicated get_peers lookups.
\ Identity of a server = SHA1(SubjectPublicKeyInfo) of its X.509 cert -- i.e. a hash of the PUBLIC
\ KEY, not of the whole .cer file, so renewing the cert (new validity/serial, same key) does NOT
\ change the identity.  Two DHT keys are announced:
\   IH-SELF  = SHA1(SPKI of own cert)  -> lets someone who knows this hash (from the signing
\                                         registry) find THIS specific server.
\   IH-GROUP = SHA1(SPKI of CA cert)   -> every fleet member announces the issuer key, so
\                                         get_peers(IH-GROUP) enumerates the whole fleet.
\ The DHT returns only UNTRUSTED ip:port hints -- authenticate after discovery via TLS/cert against
\ the CA (that layer is out of scope here).  Node id is random (NOT derived from the key): discovery
\ is via announce_peer, not node position, and a key-derived id would only break BEP 42.  Windows +
\ Linux (POSIX transport).  CRLF.
REQUIRE .TORRENT-PEERS ~ac/lib/net/torrent.f     \ SLURP (read file) + SHA1 + .HASH
REQUIRE WATCH-INFOHASH ~ac/lib/net/dht-serve.f   \ announce machinery (DO-ANNOUNCE, BIND-PORT, ...)
DECIMAL

\ ===== minimal DER/ASN.1 walk (single-byte tags; enough for the X.509 cert path) ===========
: DER@ { a \ lp b n -- val-a val-len next-a }     \ parse one TLV at a; content span + addr past it
   a 1+ -> lp                                      \ length field
   lp C@ -> b
   b 128 < IF
      lp 1+  b                                     \ short form: content at lp+1, length b
   ELSE
      b 127 AND -> n                               \ long form: n length octets follow
      lp 1+ -> lp
      0  n 0 DO 8 LSHIFT lp C@ + lp 1+ -> lp LOOP  \ big-endian length
      lp SWAP
   THEN
   2DUP + ;
: DER-INTO ( a -- content-a )  DER@ 2DROP ;        \ descend into a constructed TLV
: DER-NEXT ( a -- next-a )      DER@ NIP NIP ;      \ advance past a TLV

: CERT-SPKI { ca -- spki-a spki-len }              \ locate SubjectPublicKeyInfo TLV in a DER cert
   ca DER-INTO                                      \ Certificate SEQUENCE -> tbsCertificate TLV
   DER-INTO                                         \ tbsCertificate SEQUENCE -> its first field
   DUP C@ 160 = IF DER-NEXT THEN                    \ skip [0] EXPLICIT version (0xA0) if present
   5 0 DO DER-NEXT LOOP                             \ skip serial, sigAlg, issuer, validity, subject
   DUP DER-NEXT OVER - ;                            \ next field = SubjectPublicKeyInfo; return its TLV

\ PEM tolerance: cert files may be DER (.cer, starts 0x30) OR PEM (.crt, "-----BEGIN...", base64).
\ CERT-SPKI walks DER, so a PEM body must be base64-decoded first -- else it yields a SILENTLY WRONG
\ hash (no error) and fleet members that used .cer vs .crt would compute different keys and never meet.
: B64V ( c -- v )                                   \ base64 char -> 6-bit value, or -1 to skip (ws/pad/=)
   DUP [CHAR] A [CHAR] Z 1+ WITHIN IF [CHAR] A - EXIT THEN
   DUP [CHAR] a [CHAR] z 1+ WITHIN IF [CHAR] a - 26 + EXIT THEN
   DUP [CHAR] 0 [CHAR] 9 1+ WITHIN IF [CHAR] 0 - 52 + EXIT THEN
   DUP [CHAR] + = IF DROP 62 EXIT THEN
   [CHAR] / = IF 63 ELSE -1 THEN ;
: PEM>DER { buf u \ ip end op acc nb c v -- der-a der-len }   \ decode the first PEM block IN PLACE
   buf -> ip   buf u + -> end   buf -> op   0 -> acc   0 -> nb
   BEGIN ip end U< IF ip C@ 10 <> ELSE FALSE THEN WHILE ip 1+ -> ip REPEAT   \ skip header line
   ip end U< IF ip 1+ -> ip THEN                                            \ step past its LF
   BEGIN ip end U< IF ip C@ DUP -> c [CHAR] - <> ELSE FALSE THEN WHILE       \ stop at "-----END"
      c B64V -> v
      v 0< 0= IF                                                            \ a real base64 char
         acc 6 LSHIFT v OR -> acc   nb 6 + -> nb
         nb 7 > IF nb 8 - -> nb   acc nb RSHIFT 255 AND op C!  op 1+ -> op THEN
      THEN
      ip 1+ -> ip
   REPEAT
   buf  op buf - ;
: CERT>KEY { a u dest \ buf len -- }                \ cert file (a,u) -> SHA1(SPKI) into dest (20 bytes)
   a u SLURP                                        ( buf len ior )
   DUP IF ." swarm: cannot open " a u TYPE CR  -1005 THROW THEN DROP
   -> len -> buf
   buf C@ [CHAR] - = IF buf len PEM>DER -> len -> buf THEN   \ PEM? decode to DER first
   buf CERT-SPKI                                    ( spki-a spki-len )
   dest SHA1
   buf FREE THROW ;

\ ===== the two fleet keys ===================================================================
CREATE IH-SELF  20 ALLOT                            \ SHA1(SPKI of own cert)
CREATE IH-GROUP 20 ALLOT                            \ SHA1(SPKI of CA cert)

\ ===== DHT session + announce ===============================================================
: SWARM-OPEN ( -- )                                \ open the UDP socket + pick a node id, bind a port
   SOCK-START  RNG-SEED
   MY-EXT-IP @ ?DUP IF BEP42-NODE-ID ." swarm: node id via BEP42 (external IP)" CR
              ELSE MY-ID IDLEN RAND-BYTES ." swarm: node id RANDOM (no external IP set)" CR THEN
   0 TXN !
   RND SECRET !
   UDP-OPEN DHT-SOCK !
   DHT-SOCK @ BIND-PORT DUP MY-PORT !
   ?DUP IF ." swarm: bound UDP port " . CR
   ELSE                                            \ NEVER run on an OS-assigned ephemeral port: we would
      ." swarm: FATAL -- could not bind 6881..6890" CR   \ announce ourselves at an address nobody can
      -3300 THROW                                  \ reach, and that stale entry then haunts the DHT for
   THEN ;                                          \ its whole TTL.  Fail loudly; the supervisor retries.

: ANNOUNCE-KEY ( ih-a -- )                         \ locate nodes near ih, then announce ourselves for it
   DUP TARGET IDLEN MOVE  CUR-IH !
   SL-RESET  SEED-BOOTSTRAP
   MAX-QUERIES 0 DO LOOKUP-ROUND 0= IF LEAVE THEN LOOP
   DO-ANNOUNCE ;

: SWARM-KEYS { sc scu cac cacu -- }                \ compute IH-SELF / IH-GROUP from the two cert files
   sc scu   IH-SELF  CERT>KEY
   cac cacu IH-GROUP CERT>KEY
   ." IH-SELF  (this server) = " IH-SELF  .HASH CR
   ." IH-GROUP (CA / fleet)   = " IH-GROUP .HASH CR ;

: SWARM-ANNOUNCE ( sc scu cac cacu -- )            \ compute keys, open DHT, announce both once
   SWARM-KEYS
   SWARM-OPEN
   IH-SELF  ANNOUNCE-KEY  ." announced IH-SELF  (this server)" CR
   IH-GROUP ANNOUNCE-KEY  ." announced IH-GROUP (fleet)" CR ;

\ ===== discovery: retried + deduplicated lookup ============================================
\ A single announcer lands on only ~5-8 nodes, and two independent lookups converge on
\ overlapping-but-different subsets, so ONE get_peers round is flaky.  SWARM-FIND runs several full
\ lookups and accumulates the DEDUPLICATED union (STORE-PEER now drops duplicates).  Results are left
\ in PEERS / PEERS-N for the caller (the auth layer then TLS-verifies each candidate against the CA).
4 VALUE FIND-RETRIES
CREATE FIND-IH 20 ALLOT                             \ scratch infohash for the *-HEX helper
: SWARM-FIND ( ih-a -- )                            \ needs an open DHT socket (SWARM-OPEN/DHT-INIT); silent
   DUP TARGET IDLEN MOVE  CUR-IH !
   PEERS-RESET
   FIND-RETRIES 0 DO
      SL-RESET  SEED-BOOTSTRAP
      MAX-QUERIES 0 DO LOOKUP-ROUND 0= IF LEAVE THEN LOOP
   LOOP ;
: SWARM-LOOKUP ( ih-a -- )                          \ one-shot: open DHT, retried find, print, close
   >R SWARM-OPEN R> SWARM-FIND .PEERS DHT-DONE ;
: SWARM-FIND-HEX ( a u -- )                          \ 40-char hex infohash -> one-shot lookup
   FIND-IH HEX>ID  FIND-IH SWARM-LOOKUP ;

600 VALUE REANNOUNCE-SECS                           \ re-announce interval (announce TTL is ~15-30 min)
: SWARM-DAEMON ( sc scu cac cacu -- )              \ announce forever; serve (answer queries) between rounds
   SWARM-KEYS  SWARM-OPEN
   BEGIN
      IH-SELF  ANNOUNCE-KEY
      IH-GROUP ANNOUNCE-KEY
      ." swarm: (re)announced both keys; serving " REANNOUNCE-SECS . ." s" CR
      REANNOUNCE-SECS DHT-SERVE
   AGAIN ;
