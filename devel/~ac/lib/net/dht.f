\ ~ac/lib/net/dht.f -- the client core of a minimal BitTorrent Mainline DHT node (BEP 5): find peers
\ for an infohash without a tracker (ping + get_peers), keeping a CONVERGING shortlist of the nodes
\ closest to the target (XOR distance; the farthest is evicted when full, and it can be re-queried).
\ The responder side (answering queries) and announce_peer live one layer up in dht-serve.f.  No
\ crypto: node ids and transaction ids are random (xorshift), infohashes are given.  Built on the spf4
\ UDP idiom (SOCKNAME.F WriteTo/ReadFrom = sendto/recvfrom), like ntp.f and the Eserv DNS servers.
\ TODO: BEP 42 secure node id; BEP 32 IPv6 (nodes6); persist the shortlist across restarts (SQLite).
\
\ Public API:
\   DHT-INIT ( -- )              open the UDP socket, seed the PRNG, pick a random node id
\   DHT-DONE ( -- )              close the socket
\   FIND-PEERS ( infohash-a -- ) run a get_peers lookup for the 20-byte infohash, print the peers
\   FIND-PEERS-HEX ( a u -- )    same, from a 40-char hex infohash string
\   DHT-PING ( ip port -- f )    true if ip:port answered a ping
\   .PEERS ( -- )                print the peers collected by the last FIND-PEERS
\   PEERS ( -- a )  PEERS-N ( -- a )   raw result buffer: PEERS-N @ compact 6-byte (ip4+port) entries
\
\ NB: the encoder/shortlist/result buffers are single global instances -> one lookup at a time.
\ Runs on BOTH spf4 (Win32) and spf64 (all Win targets); POSIX transport is still a TODO.  CRLF.
REQUIRE [IF] lib/include/tools.f          \ spf4: [DEFINED]/[IF]/[ELSE]/[THEN] (already resident on spf64)
REQUIRE {    ~ac/lib/locals.f             \ define { } early so the POSIX sockets.f REQUIRE { skips
DECIMAL

\ ===== per-OS UDP + name-resolution backend ================================================
\ Windows (spf4 OR spf64): spf4 winsock (SOCKETS.F + SOCKNAME.F -> WriteTo/ReadFrom = sendto/recvfrom).
\ On spf64 recvfrom/sendto/getsockname need explicit Win64 arg counts BEFORE SOCKNAME.F's bare WINAPI:
\ borrows them (the sock-pre.f pattern); on spf4 WINAPI: is count-less, so SOCKNAME.F declares its own.
[DEFINED] WINAPI: [IF]                                    \ ===== Windows =====
   [DEFINED] WINAPI64: [IF]                               \ ---- spf64 (Win64): predeclare arg counts ----
      6 WINAPI64: recvfrom     WSOCK32.DLL
      6 WINAPI64: sendto       WSOCK32.DLL
      3 WINAPI64: getsockname  WSOCK32.DLL
      0 WINAPI64: GetTickCount KERNEL32.DLL
   [ELSE]                                                 \ ---- spf4 (Win32) ----
      WINAPI: GetTickCount KERNEL32.DLL
   [THEN]
   REQUIRE ReadFrom ~ac/lib/win/winsock/SOCKNAME.F        \ pulls SOCKETS.F (CreateUdpSocket/GetHostIP/...)
   2000 VALUE UDP-TIMEOUT-MS
   : SOCK-START ( -- )       SocketsStartup DROP ;
   : UDP-OPEN ( -- sock )    CreateUdpSocket THROW  DUP UDP-TIMEOUT-MS SWAP SetUdpSocketTimeout THROW ;
   : UDP-CLOSE ( sock -- )   CloseSocket DROP ;
   : UDP-SEND ( ip port a u sock -- )  ['] WriteTo CATCH IF 2DROP 2DROP DROP THEN ;   \ ignore send errors
   : UDP-RECV ( a u sock -- len ip port )
      ['] ReadFrom CATCH IF  DROP 2DROP  0 0 0  THEN ;    \ timeout/error -> len 0
   : NAME>IP ( a u -- ip ior )  GetHostIP ;
   : NOW-MS ( -- u )  GetTickCount ;
[ELSE]                                                    \ ===== POSIX (Linux/macOS) =====
   \ UDP via libc recvfrom/sendto (the ~ac/lib/lin/net/sockets.f SO idiom: aN..a1 N name, args reversed).
   REQUIRE CreateSocket ~ac/lib/lin/net/sockets.f         \ sock_addr/(sockaddr!)/getaddrinfo machinery + NS-ON
   NS-ON  ALSO SO NEW: libc.so.6
   : (u-socket)     ( proto type domain -- fd )                 3 socket ;
   : (u-setsockopt) ( optlen optval optname level fd -- r )     5 setsockopt ;
   : (u-sendto)     ( tolen toaddr flags len buf fd -- n )      6 sendto ;
   : (u-recvfrom)   ( fromlenaddr fromaddr flags len buf fd -- n )  6 recvfrom ;
   : (u-gettime)    ( tz tv -- r )                              2 gettimeofday ;
   PREVIOUS
   CREATE U-TV  16 ALLOT   2 U-TV !  0 U-TV 8 + !               \ recv timeout {tv_sec=2, tv_usec=0}
   CREATE U-FROM 16 ALLOT   CREATE U-FROMLEN 8 ALLOT            \ recvfrom sender sockaddr + addrlen
   CREATE U-GTV 16 ALLOT
   : NOW-MS ( -- u )  0 U-GTV (u-gettime) DROP  U-GTV @ 1000 *  U-GTV 8 + @ 1000 / + ;
   : SOCK-START ( -- ) ;
   : UDP-OPEN ( -- sock )                                       \ socket(AF_INET,SOCK_DGRAM,0) + 2s recv timeout
      0 2 2 (u-socket) SX  DUP 0< IF (errno) THROW THEN
      DUP >R  16 U-TV 20 1 R@ (u-setsockopt) DROP  R> ;         \ SO_RCVTIMEO=20, SOL_SOCKET=1
   : UDP-CLOSE ( sock -- )  CloseSocket DROP ;
   : UDP-SEND { ip port a u sock -- }                           \ sendto(sock,a,u,0,&sock_addr,16)
      ip port (sockaddr!)  16 sock_addr 0 u a sock (u-sendto) DROP ;
   : UDP-RECV { a u sock -- len ip port }                       \ recvfrom(sock,a,u,0,&from,&fromlen)
      16 U-FROMLEN !
      U-FROMLEN U-FROM 0 u a sock (u-recvfrom) SX
      DUP 0< IF DROP 0 0 0 EXIT THEN                            \ EAGAIN (timeout) / error -> len 0
      U-FROM 4 + @ [ HEX ] FFFFFFFF [ DECIMAL ] AND             \ sin_addr (offset 4)
      U-FROM 2 + C@ 8 LSHIFT U-FROM 3 + C@ + ;                  \ sin_port big-endian (offset 2)
   : NAME>IP { a u -- ip ior }                                  \ getaddrinfo -> first sin_addr
      a hostz u 255 MIN MOVE  0 hostz u 255 MIN + C!
      gai-res gai-hints 0 hostz (getai) ?DUP IF 0 SWAP EXIT THEN
      gai-res @ AI-ADDR-OFF + @ 4 + @ [ HEX ] FFFFFFFF [ DECIMAL ] AND
      gai-res @ (freeai)  0 ;
[THEN]

REQUIRE BE-RESET ~ac/lib/net/bencode.f

[DEFINED] >= [IF] [ELSE] : >= ( a b -- f )  < 0= ; [THEN]   \ resident on spf4, not on spf64

20 CONSTANT IDLEN                        \ node id / infohash length
26 CONSTANT NODELEN                      \ compact node info: 20 id + 4 ip + 2 port  (BEP 5)
64 CONSTANT SL-MAX                       \ shortlist capacity
256 CONSTANT PEERS-MAX                   \ collected peers cap
40 CONSTANT MAX-QUERIES                  \ max nodes queried per lookup (termination bound)

CREATE MY-ID   IDLEN ALLOT               \ our (random) node id
CREATE TARGET  IDLEN ALLOT               \ current lookup target (= the infohash) for XOR distance
VARIABLE CUR-IH                          \ addr of the 20-byte infohash we are looking up
VARIABLE DHT-SOCK
CREATE RX-BUF  2048 ALLOT                \ received datagram

\ ===== xorshift64 PRNG (node id + transaction ids; not cryptographic) =======================
VARIABLE RNGSTATE
: RNG-SEED ( -- )  NOW-MS  HERE XOR  1 OR  RNGSTATE ! ;
: RND ( -- x )
   RNGSTATE @  DUP 13 LSHIFT XOR  DUP 7 RSHIFT XOR  DUP 17 LSHIFT XOR
   DUP RNGSTATE ! ;
: RAND-BYTES ( dest u -- )  0 DO  RND 255 AND  OVER I + C!  LOOP DROP ;

\ ===== BEP 42 secure node id: derive MY-ID from our external IP so strict nodes accept us ========
\ id[0..2] top 21 bits = crc32c( ip masked per-byte, with (r&7)<<5 in byte0 ); id[19]=r; rest random.
HEX
CREATE CRCBUF 4 ALLOT
: CRC32C { a u \ crc -- crc }            \ CRC-32C (Castagnoli), reflected poly 82F63B78
   FFFFFFFF -> crc
   u 0 DO
      crc  a I + C@ XOR -> crc
      8 0 DO  crc 1 AND IF crc 1 RSHIFT 82F63B78 XOR ELSE crc 1 RSHIFT THEN -> crc  LOOP
   LOOP
   crc FFFFFFFF XOR ;
: BEP42-CRC { ip r -- crc }              \ crc32c of the masked 4 bytes (ip = C-IP little-endian int)
   ip          03 AND  r 7 AND 5 LSHIFT OR   CRCBUF    C!    \ byte0: ip[0]&0x03 | (r&7)<<5
   ip  8 RSHIFT 0F AND                        CRCBUF 1+ C!   \ byte1: ip[1]&0x0f
   ip 10 RSHIFT 3F AND                        CRCBUF 2 + C!  \ byte2: ip[2]&0x3f
   ip 18 RSHIFT FF AND                        CRCBUF 3 + C!  \ byte3: ip[3]
   CRCBUF 4 CRC32C ;
: BEP42-ID> { ip dest \ r crc -- }       \ fill dest(20) per BEP 42 from an external ip
   RND 7 AND -> r
   ip r BEP42-CRC -> crc
   crc 18 RSHIFT FF AND                dest    C!            \ id[0] = crc>>24
   crc 10 RSHIFT FF AND                dest 1+ C!            \ id[1] = crc>>16
   crc  8 RSHIFT F8 AND  RND 7 AND OR  dest 2 + C!           \ id[2] = ((crc>>8)&0xf8) | (rand&7)
   dest 3 + 10 RAND-BYTES                                    \ id[3..18] random
   r                                   dest 13 + C! ;        \ id[19] = r
: BEP42-NODE-ID ( ip -- )   MY-ID BEP42-ID> ;                \ the identity we sign our queries with
VARIABLE CUR-ID   MY-ID CUR-ID !
   \ The identity the message being built is signed with.  BEP 42 ties an id to the ADDRESS the packet
   \ leaves from, and the route -- hence the address -- is chosen per DESTINATION.  So the id is a
   \ property of who we are talking TO, like picking the right interface's MAC.  SIGN-FOR sets it.
DECIMAL

\ ===== transaction id (2 bytes, big-endian counter) =========================================
VARIABLE TXN
CREATE TXBUF 2 ALLOT
: NEW-TXN ( -- a u )
   TXN @  DUP 8 RSHIFT TXBUF C!  255 AND TXBUF 1+ C!
   TXN @ 1+ TXN !  TXBUF 2 ;

\ ===== KRPC message builders ================================================================
\ Dict keys are emitted in ascending byte order, as bencode requires.
CREATE V-STR  65 C, 67 C, 0 C, 7 C,      \ BEP 20 client id: "AC" + version 0x0007 -> peers log us as "AC.7"
FALSE VALUE DHT-SEND-V?                   \ emit our 'v' client-version key?  DEFAULT OFF -- some nodes deprioritise
: BE-V ( -- )  DHT-SEND-V? IF  S" v" BE-KEY  V-STR 4 BE-STR  THEN ;   \ unknown clients; `TRUE TO DHT-SEND-V?` to send it
: PING-MSG ( -- a u )
   BE-RESET  BE-D{
      S" a" BE-KEY  BE-D{  S" id" BE-KEY  CUR-ID @ IDLEN BE-STR  BE-}
      S" q" BE-KEY  S" ping" BE-STR
      S" t" BE-KEY  NEW-TXN BE-STR
      BE-V
      S" y" BE-KEY  S" q" BE-STR
   BE-}  BE-BUF BE-LEN ;

: GETPEERS-MSG ( -- a u )                \ info_hash = CUR-IH @
   BE-RESET  BE-D{
      S" a" BE-KEY  BE-D{
         S" id" BE-KEY         CUR-ID @ IDLEN BE-STR   \ per-destination identity (SIGN-FOR), like ping/announce
         S" info_hash" BE-KEY  CUR-IH @ IDLEN BE-STR
      BE-}
      S" q" BE-KEY  S" get_peers" BE-STR
      S" t" BE-KEY  NEW-TXN BE-STR
      BE-V
      S" y" BE-KEY  S" q" BE-STR
   BE-}  BE-BUF BE-LEN ;

\ ===== compact-node / compact-peer field extraction =========================================
\ ip: 4 network-order bytes read as an LE integer == the sin_addr layout WriteTo/ConnectSocket want.
\ port: 2 big-endian bytes as a host integer == what WriteTo htons()es.
: C-IP ( a -- ip )
   DUP C@  OVER 1+ C@ 8 LSHIFT OR  OVER 2 + C@ 16 LSHIFT OR  SWAP 3 + C@ 24 LSHIFT OR ;
: C-PORT ( a -- port )  DUP C@ 8 LSHIFT SWAP 1+ C@ + ;
: NODE-IP   ( node-a -- ip )    20 + C-IP ;
: NODE-PORT ( node-a -- port )  24 + C-PORT ;

\ ===== shortlist (candidate nodes) + XOR distance to TARGET ==================================
CREATE SL    SL-MAX NODELEN * ALLOT
CREATE SL-Q  SL-MAX ALLOT                \ per-slot queried flag
VARIABLE SL-N
: SL-RESET ( -- )  0 SL-N ! ;
: SL-NODE ( idx -- a )  NODELEN * SL + ;

: DBYTE ( id-a i -- b )  DUP >R + C@  TARGET R> + C@ XOR ;     \ (id[i] XOR target[i])
: CLOSER? ( ida idb -- f )               \ true if ida is strictly closer to TARGET than idb
   IDLEN 0 DO
      OVER I DBYTE  OVER I DBYTE         ( ida idb da db )
      2DUP = IF 2DROP ELSE  < >R 2DROP R> UNLOOP EXIT  THEN
   LOOP  2DROP FALSE ;

: ID= { a b -- f }
   IDLEN 0 DO  a I + C@ b I + C@ <> IF FALSE UNLOOP EXIT THEN  LOOP  TRUE ;
: SL-DUP? { na -- f }
   SL-N @ 0 ?DO  na I SL-NODE ID= IF TRUE UNLOOP EXIT THEN  LOOP  FALSE ;
: SL-FARTHEST ( -- idx )                  \ slot farthest from TARGET (the one to evict when full)
   0  SL-N @ 1 ?DO
      DUP SL-NODE  I SL-NODE CLOSER? IF DROP I THEN   \ current closer than I -> I is farther -> keep I
   LOOP ;
: SL-ADD { na -- }                       \ keep the SL-MAX nodes CLOSEST to TARGET (evict the farthest)
   na SL-DUP? IF EXIT THEN
   SL-N @ SL-MAX < IF                     \ room: append
      na  SL-N @ SL-NODE  NODELEN MOVE
      0 SL-N @ SL-Q + C!   1 SL-N +!  EXIT THEN
   SL-FARTHEST >R                         \ full: replace the farthest IFF na is closer than it
   na  R@ SL-NODE  CLOSER? IF
      na  R@ SL-NODE  NODELEN MOVE   0 R@ SL-Q + C!   \ overwrite + mark un-queried so we probe it
   THEN  R> DROP ;
: SL-REQUERY ( -- )  SL-Q  SL-N @  ERASE ;   \ clear all queried flags: a new round re-probes known nodes
: SL-PICK ( -- idx | -1 )                \ closest un-queried node, or -1 when none remain
   -1  SL-N @ 0 ?DO
      I SL-Q + C@ 0= IF
         DUP 0< IF DROP I
         ELSE  I SL-NODE OVER SL-NODE CLOSER? IF DROP I THEN  THEN
      THEN
   LOOP ;

\ ===== collected peers ======================================================================
CREATE PEERS  PEERS-MAX 6 * ALLOT
VARIABLE PEERS-N
: PEERS-RESET ( -- )  0 PEERS-N ! ;
: MEM= { a b u -- f }  u 0 DO a I + C@ b I + C@ <> IF FALSE UNLOOP EXIT THEN LOOP TRUE ;
: PEER-DUP? { pa -- f }                   \ is this 6-byte compact peer already collected?
   PEERS-N @ 0 ?DO  pa  PEERS I 6 * +  6 MEM= IF TRUE UNLOOP EXIT THEN  LOOP  FALSE ;
: STORE-PEER { pa -- }
   pa PEER-DUP? IF EXIT THEN
   PEERS-N @ PEERS-MAX >= IF EXIT THEN
   pa  PEERS-N @ 6 * PEERS +  6 MOVE
   1 PEERS-N +! ;

\ ===== routing table: keep good contacts + answer find_node/get_peers with the closest we know =====
\ Without a routing table we return empty `nodes`, so other nodes drop us and never query us (no DHT
\ presence -- the "no incoming" diagnostic).  A flat table of compact nodes (id+ip+port) with last-seen;
\ populated from replies AND from the nodes that query us; when full, the stalest entry is evicted.
160 CONSTANT RTAB-MAX
8   CONSTANT RT-K
CREATE RTAB       RTAB-MAX NODELEN * ALLOT
CREATE RTAB-SEEN  RTAB-MAX CELLS   ALLOT
CREATE RT-PICK    RTAB-MAX         ALLOT
CREATE RT-OUT     RT-K NODELEN *   ALLOT
VARIABLE RTAB-N   0 RTAB-N !
: RT-NODE ( idx -- a )  NODELEN * RTAB + ;
: RT-SEEN ( idx -- a )  CELLS RTAB-SEEN + ;
: XOR-CLOSER? { ida idb tgt \ da db -- f }         \ ida strictly closer to tgt than idb (XOR distance)?
   IDLEN 0 DO
      ida I + C@ tgt I + C@ XOR -> da
      idb I + C@ tgt I + C@ XOR -> db
      da db <> IF da db < UNLOOP EXIT THEN
   LOOP FALSE ;
: RT-ID= { a b -- f }  IDLEN 0 DO a I + C@ b I + C@ <> IF FALSE UNLOOP EXIT THEN LOOP TRUE ;
: RT-FIND-ID { na -- idx }  RTAB-N @ 0 ?DO na I RT-NODE RT-ID= IF I UNLOOP EXIT THEN LOOP -1 ;
: RT-STALEST ( -- idx )
   0  RTAB-N @ 1 ?DO  DUP RT-SEEN @  I RT-SEEN @  U> IF DROP I THEN  LOOP ;
: RT-ADD { na \ idx -- }                           \ add/refresh a compact node (skip garbage: 0 ip)
   na NODE-IP 0= IF EXIT THEN
   na RT-FIND-ID -> idx
   idx 0< IF
      RTAB-N @ RTAB-MAX < IF RTAB-N @ -> idx  1 RTAB-N +!  ELSE RT-STALEST -> idx THEN
      na idx RT-NODE NODELEN MOVE
   THEN
   NOW-MS idx RT-SEEN ! ;
: RT-CLOSEST-NODES { tgt \ out n best -- a u }      \ compact string of the K closest table nodes to tgt
   RTAB-N @ 0 ?DO 0 I RT-PICK + C! LOOP
   RT-OUT -> out  0 -> n
   RT-K 0 DO
      -1 -> best
      RTAB-N @ 0 ?DO
         I RT-PICK + C@ 0= IF
            best 0< IF I -> best
            ELSE I RT-NODE best RT-NODE tgt XOR-CLOSER? IF I -> best THEN THEN
         THEN
      LOOP
      best 0< IF LEAVE THEN
      1 best RT-PICK + C!
      best RT-NODE out NODELEN MOVE  out NODELEN + -> out  n 1+ -> n
   LOOP
   RT-OUT  n NODELEN * ;

: SEED-FROM-RTAB ( -- )                   \ inject the routing table into the lookup shortlist (TARGET set)
   \ Warm start: without this, loaded nodes sit in RTAB (used only to ANSWER others) and never seed OUR
   \ lookups -- which start empty and depend on the bootstrap routers/DNS.  Feeding RTAB to SL-ADD (which
   \ keeps the SL-MAX closest to TARGET) makes a restarted node query its persisted peers directly, so
   \ the mesh can come up even with the bootstrap domains unreachable.  Harmless in steady state: SL-ADD
   \ dedups and keeps the closest, so nodes already there via replies are not disturbed.
   RTAB-N @ 0 ?DO  I RT-NODE SL-ADD  LOOP ;

\ ===== response parsing =====================================================================
: ADD-PEER ( elem-a -- )                 \ a values[] element: a bencoded 6-byte compact peer
   B-STR@ { a1 pa pu }  pu 6 >= IF pa STORE-PEER THEN ;
: ADD-NODES { sa su -- }                 \ the nodes string: su/26 compact nodes -> shortlist AND routing table
   su 26 / 0 ?DO  sa I NODELEN * +  DUP SL-ADD  RT-ADD  LOOP ;
: HARVEST { r -- }                       \ r = the 'r' response dict: pull values[] and nodes
   r S" values" B-DFIND IF  ['] ADD-PEER B-LIST  THEN
   r S" nodes"  B-DFIND IF
      B-STR@ >R >R DROP R> R>            \ ( a' s-a s-u ) -> ( s-a s-u )
      ADD-NODES
   THEN ;
: PARSE-RESP ( rlen -- )
   DUP 0= IF DROP EXIT THEN
   RX-BUF SWAP BE-SETEND DROP                    \ bound the parser to the received reply
   RX-BUF C@ [CHAR] d <> IF EXIT THEN
   RX-BUF S" r" B-DFIND IF HARVEST THEN ;

\ ===== transport: one request/response ======================================================
: DHT-QUERY ( ip port a u -- rlen )      \ send to ip:port, receive one reply into RX-BUF
   DHT-SOCK @ UDP-SEND
   RX-BUF 2048 DHT-SOCK @ UDP-RECV       ( len rip rport )
   2DROP ;                               \ (sender ip/port ignored)

\ ===== lookup ===============================================================================
: SEED ( ip port -- )                    \ query a bootstrap ip:port directly; its nodes seed the shortlist
   GETPEERS-MSG DHT-QUERY PARSE-RESP ;
: TRY-SEED ( a u port -- )               \ resolve a hostname and SEED it; skip on resolve failure
   >R NAME>IP IF DROP R> DROP EXIT THEN  R> SEED ;
: SEED-ROUND ( -- )
   S" router.bittorrent.com"  6881 TRY-SEED
   S" dht.transmissionbt.com" 6881 TRY-SEED
   S" router.utorrent.com"    6881 TRY-SEED
   S" dht.libtorrent.org"     25401 TRY-SEED ;
: SEED-BOOTSTRAP ( -- )                  \ retry the routers until the shortlist is non-empty (rate-limited)
   3 0 DO  SEED-ROUND  SL-N @ IF LEAVE THEN  LOOP ;

: LOOKUP-ROUND ( -- f )                  \ query the closest un-queried node; f = did we query one?
   SL-PICK DUP 0< IF DROP FALSE EXIT THEN
   DUP  1 SWAP SL-Q + C!                 \ mark queried
   SL-NODE                               ( node-a )
   DUP NODE-IP  OVER NODE-PORT           ( node-a ip port )
   ROT DROP                              ( ip port )
   GETPEERS-MSG DHT-QUERY PARSE-RESP
   TRUE ;

\ ===== public API ===========================================================================
: DHT-INIT ( -- )
   SOCK-START
   RNG-SEED  MY-ID IDLEN RAND-BYTES
   0 TXN !
   UDP-OPEN DHT-SOCK ! ;
: DHT-DONE ( -- )  DHT-SOCK @ UDP-CLOSE ;

: DHT-PING ( ip port -- f )              \ true if ip:port answered
   PING-MSG DHT-QUERY  0= 0= ;

: .# ( u -- )  0 <# #S #> TYPE ;         \ unsigned decimal, no surrounding spaces
: .PEER { p -- }
   BASE @ >R DECIMAL
   p C@ .# ." ." p 1+ C@ .# ." ." p 2 + C@ .# ." ." p 3 + C@ .#
   ." :"  p 4 + C@ 8 LSHIFT p 5 + C@ +  .#  CR
   R> BASE ! ;
: .PEERS ( -- )
   PEERS-N @ 0= IF ." (no peers found)" CR EXIT THEN
   ." Peers found: " PEERS-N @ . CR
   PEERS-N @ 0 DO  PEERS I 6 * +  .PEER  LOOP ;

: FIND-PEERS ( infohash-a -- )           \ run a get_peers lookup and print the peers
   DUP TARGET IDLEN MOVE
   CUR-IH !
   SL-RESET  PEERS-RESET
   SEED-BOOTSTRAP
   MAX-QUERIES 0 DO  LOOKUP-ROUND 0= IF LEAVE THEN  LOOP
   .PEERS ;

: HEXDIG ( c -- n )
   DUP [CHAR] 0 [CHAR] 9 1+ WITHIN IF [CHAR] 0 - EXIT THEN
   32 OR [CHAR] a - 10 + ;               \ accept A-F or a-f
: HEX>ID { a u dest -- }                 \ 40 hex chars -> 20 bytes
   20 0 DO
      a I 2* + C@ HEXDIG 16 *  a I 2* 1+ + C@ HEXDIG +  dest I + C!
   LOOP ;
CREATE IH-BUF IDLEN ALLOT
: FIND-PEERS-HEX ( a u -- )              \ a u = 40-char hex infohash
   IH-BUF HEX>ID  IH-BUF FIND-PEERS ;

\EOF
\ ================================ live demo / smoke test ====================================
\ Comment the "\EOF" line just above (turn it into "\ \EOF") and reload this file to run a real
\ lookup against the public DHT.  Needs internet + Windows (spf4 or spf64).  Example:
\    spf4.exe  ~ac/lib/net/dht.f          spf64.exe ~ac/lib/net/dht.f
DECIMAL
: .MYID ( -- )
   ." my node id (hex): "  BASE @ >R HEX
   MY-ID IDLEN 0 DO  MY-ID I + C@ 0 <# # # #> TYPE  LOOP  R> BASE ! CR ;
: DHT-DEMO ( -- )
   DHT-INIT  .MYID
   S" 2aa4f5a7e209e54b32803d43670971c4c8caaa05"    \ ubuntu-24.04.1-desktop-amd64.iso
   ." looking up infohash: " 2DUP TYPE CR
   FIND-PEERS-HEX
   DHT-DONE  ." === DHT DEMO DONE ===" CR ;
DHT-DEMO
