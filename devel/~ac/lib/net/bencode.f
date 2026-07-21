\ ~ac/lib/net/bencode.f -- Bencode encode/decode (BEP 3), the wire format of BitTorrent + the KRPC
\ DHT protocol.  Portable: needs only the core + locals ({ }), no OS/sockets -- so it loads and unit-
\ tests on every spf64 target.  Encoding builds into a single reusable buffer BE-BUF; decoding is a
\ zero-copy walk over an in-memory bencoded message (parse words take a byte address, return the
\ address just past the value they consumed).  All strings are BINARY (a DHT node id is 20 raw bytes),
\ so every string is length-prefixed -- never NUL-terminated.  Single-buffer encoder = one message in
\ flight at a time (fine for a sequential client; make BE-BUF a USER buffer to go per-thread).  CRLF.
REQUIRE { ~ac/lib/locals.f
DECIMAL

\ ===== encoder ==============================================================================
\ BE-C,/BE-A, are BOUNDED: they never write past BE-BUF.  On overflow they drop the excess and set
\ BE-OVER, so a too-large message is truncated (and detectable) instead of corrupting the dictionary
\ (BE-PTR sits right after BE-BUF).  Producers of variable-length messages must ALSO cap their content
\ up front (e.g. the values[] list in a get_peers reply) so the wire message stays well-formed.
1024 CONSTANT /BE-BUF
CREATE BE-BUF /BE-BUF ALLOT
BE-BUF /BE-BUF + CONSTANT BE-BUF-END          \ one past the encode buffer
VARIABLE BE-PTR
VARIABLE BE-OVER                              \ TRUE if an encode hit the buffer limit (message truncated)

: BE-RESET ( -- )        BE-BUF BE-PTR !  FALSE BE-OVER ! ;
: BE-LEN   ( -- u )      BE-PTR @ BE-BUF - ;
: BE-C,    ( c -- )                           \ append one byte, bounded
   BE-PTR @ DUP BE-BUF-END U< IF C! 1 BE-PTR +! ELSE 2DROP TRUE BE-OVER ! THEN ;
: BE-A,    ( a u -- )                         \ append u raw bytes, clamped to the space left
   BE-BUF-END BE-PTR @ -  0 MAX               ( a u room )
   2DUP > IF TRUE BE-OVER ! THEN              ( a u room )   \ u > room -> overflow, clamp below
   MIN                                        ( a u' )
   BE-PTR @ SWAP DUP >R MOVE  R> BE-PTR +! ;
: BE-#     ( n -- )      \ append a signed integer as ASCII decimal (bencode is always base-10)
   BASE @ >R DECIMAL   DUP >R ABS 0 <# #S R> SIGN #> BE-A,  R> BASE ! ;
: BE-STR   ( a u -- )    DUP BE-#  [CHAR] : BE-C,  BE-A, ;      \ <len>:<bytes>
: BE-KEY   ( a u -- )    BE-STR ;                               \ a dict key is just a bstring
: BE-INT   ( n -- )      [CHAR] i BE-C,  BE-#  [CHAR] e BE-C, ; \ i<n>e
: BE-D{    ( -- )        [CHAR] d BE-C, ;                       \ open a dict  (keys MUST be emitted sorted)
: BE-L[    ( -- )        [CHAR] l BE-C, ;                       \ open a list
: BE-}     ( -- )        [CHAR] e BE-C, ;                       \ close a dict or list

\ ===== decoder (BOUNDED zero-copy walk) =====================================================
\ Each B-*@ word takes the address of a bencoded value and returns the address just past it.  Every
\ read is confined to [start, BE-END): arm it with BE-SETEND ( a u -- a ) once per received message.
\ A read past the end, an over-long string length, or nesting deeper than BE-MAXDEPTH sets BE-BAD and
\ the walk unwinds safely -- cursors clamp to BE-END so loops terminate and nothing reads outside the
\ datagram.  Trusting callers still get their value; network-facing callers should honour BE-OK?.
VARIABLE BE-END                              \ one past the last byte of the message being parsed
VARIABLE BE-START                            \ first byte of the message: the LOWER bound (a bad length
                                             \ could otherwise drive a cursor before the buffer -- P0.2)
VARIABLE BE-BAD                              \ TRUE after any out-of-bounds / over-long / too-deep event
32 CONSTANT BE-MAXDEPTH
: BE-SETEND ( a u -- a )   OVER BE-START !  OVER + BE-END !  FALSE BE-BAD !  ;   \ arm for [a, a+u); return a
: BE-OK?    ( -- f )       BE-BAD @ 0= ;
: IN?       ( a -- f )     DUP BE-START @ U< IF DROP FALSE EXIT THEN  BE-END @ U< ;   \ BE-START <= a < BE-END
: @IN       ( a -- c )     DUP IN? IF C@ ELSE DROP TRUE BE-BAD ! 0 THEN ;   \ bounded read (0 outside)

: DIGIT? ( c -- f )   [CHAR] 0 [CHAR] 9 1+ WITHIN ;

: BE-CLAMP  ( a -- a' )    BE-END @ MIN ;     \ a returned cursor NEVER points past the message end

\ A bencoded string length: UNSIGNED, >= 1 digit.  Overflow is impossible by construction -- the value is
\ capped to the message size the moment it would exceed it (a length longer than the whole datagram is
\ malformed anyway), so acc*10 can never wrap a cell.  This replaces the earlier `acc 0<` overflow test,
\ which missed 2^64 wrapping cleanly to 0.
: B-ULEN { a \ acc nd cap -- a' n }
   0 -> acc  0 -> nd   BE-END @ BE-START @ - -> cap
   BEGIN a IN? IF a C@ DIGIT? ELSE FALSE THEN WHILE
      acc 10 *  a C@ [CHAR] 0 - +  -> acc
      acc cap U> IF cap -> acc  TRUE BE-BAD ! THEN   \ longer than the whole message -> malformed, clamp
      a 1+ -> a   nd 1+ -> nd
   REPEAT
   nd 0= IF TRUE BE-BAD ! THEN                       \ at least one digit required
   a acc ;
: B-STR@ ( a -- a' s-a s-u )                 \ <len>:<bytes>; ':' required, span AND cursor bounded to BE-END
   B-ULEN                                     ( c-a n )
   OVER @IN [CHAR] : <> IF TRUE BE-BAD ! THEN \ the length must be followed by a colon
   SWAP 1+  SWAP                              ( s-a s-u )         \ s-a just past the ':'
   OVER BE-END @ SWAP -  0 MAX                ( s-a s-u avail )   \ bytes from s-a to BE-END (>= 0)
   2DUP SWAP < IF TRUE BE-BAD ! THEN          ( s-a s-u avail )   \ declared len > avail -> malformed
   MIN                                        ( s-a s-u' )        \ clamp the span
   2DUP + BE-CLAMP  -ROT ;                    ( a' s-a s-u' )     \ and clamp the cursor (never BE-END+1)

18 CONSTANT B-INT-MAXDIG                      \ 10^18 < 2^63; more digits than this is treated as overflow
: B-INT@ { a \ n neg nd -- a' n }            \ i<digits>e ; require 'i', >=1 digit (opt '-'), and 'e'
   a @IN [CHAR] i <> IF TRUE BE-BAD !  BE-END @ 0 EXIT THEN
   a 1+ -> a
   a @IN [CHAR] - = -> neg   neg IF a 1+ -> a THEN
   0 -> n  0 -> nd
   BEGIN a IN? IF a C@ DIGIT? ELSE FALSE THEN WHILE
      nd B-INT-MAXDIG < IF  n 10 *  a C@ [CHAR] 0 - +  -> n  ELSE TRUE BE-BAD ! THEN   \ overflow guard
      a 1+ -> a   nd 1+ -> nd
   REPEAT
   nd 0= IF TRUE BE-BAD ! THEN                \ at least one digit
   a @IN [CHAR] e <> IF TRUE BE-BAD ! THEN    \ closing 'e' required
   a 1+ BE-CLAMP -> a
   neg IF n NEGATE -> n THEN
   a n ;

: STR= { a1 u1 a2 u2 -- f }
   u1 u2 <> IF FALSE EXIT THEN
   u1 0 DO  a1 I + C@ a2 I + C@ <> IF FALSE UNLOOP EXIT THEN  LOOP  TRUE ;

: (B-SKIP) { a depth -- a' }                 \ skip one value; recursion depth-bounded
   depth BE-MAXDEPTH > IF TRUE BE-BAD !  BE-END @ EXIT THEN   \ too deep: jump to end so every loop unwinds
   a @IN [CHAR] i = IF a B-INT@ DROP EXIT THEN
   a @IN [CHAR] l = IF  a 1+ -> a
      BEGIN a IN? IF a @IN [CHAR] e <> ELSE FALSE THEN WHILE  a depth 1+ RECURSE -> a  REPEAT
      a IN? IF a 1+ BE-CLAMP ELSE TRUE BE-BAD !  BE-END @ THEN  EXIT THEN   \ ran off end w/o 'e' -> malformed
   a @IN [CHAR] d = IF  a 1+ -> a
      BEGIN a IN? IF a @IN [CHAR] e <> ELSE FALSE THEN WHILE
         a depth 1+ RECURSE -> a   a depth 1+ RECURSE -> a
      REPEAT
      a IN? IF a 1+ BE-CLAMP ELSE TRUE BE-BAD !  BE-END @ THEN  EXIT THEN   \ unterminated dict -> malformed
   a @IN DIGIT? 0= IF TRUE BE-BAD !  BE-END @ EXIT THEN   \ not i/l/d and not a string length -> malformed
   a B-STR@ 2DROP ;                           \ else a string -> a' past its bytes
: B-SKIP ( a -- a' )   0 (B-SKIP) ;

: B-DFIND ( dict-a key-a key-u -- val-a true | false )   \ find a key in a dict, return its value addr
   2>R  1+                                   ( p ; R: key-a key-u )
   BEGIN DUP IN? IF DUP @IN [CHAR] e <> ELSE FALSE THEN WHILE
      B-STR@                                 ( p' k-a k-u )
      2R@ STR= IF  2R> 2DROP  TRUE EXIT  THEN
      B-SKIP                                 ( p'' )
   REPEAT
   DROP 2R> 2DROP FALSE ;

: B-LIST ( list-a xt -- )                    \ call xt ( elem-a -- ) for each element (xt must be stack-neutral)
   SWAP 1+ SWAP                              ( p xt )
   BEGIN OVER IN? IF OVER @IN [CHAR] e <> ELSE FALSE THEN WHILE
      2DUP EXECUTE  SWAP B-SKIP SWAP
   REPEAT 2DROP ;

\EOF
\ ================================ self-test ================================================
\ Comment the "\EOF" line just above (turn it into "\ \EOF") and reload this file to run.
\ Works on spf4 and spf64, no network.  Example:  spf4.exe ~ac/lib/net/bencode.f
DECIMAL
VARIABLE #FAIL   0 #FAIL !
VARIABLE LSUM
: CK  ( f a u -- )   ROT IF 2DROP ELSE ." FAIL: " TYPE CR 1 #FAIL +! THEN ;
: ONE ( elem-a -- )  B-INT@ NIP LSUM +! ;    \ sum ints in a list
: SELFTEST ( -- )
   BE-RESET  42 BE-INT   BE-BUF BE-LEN  S" i42e"      STR=  S" enc i42e"      CK
   BE-RESET  -7 BE-INT   BE-BUF BE-LEN  S" i-7e"      STR=  S" enc i-7e"      CK
   BE-RESET  S" spam" BE-STR   BE-BUF BE-LEN  S" 4:spam"  STR=  S" enc 4:spam"   CK
   BE-RESET  BE-D{ S" bar" BE-KEY S" foo" BE-STR BE-}
             BE-BUF BE-LEN  S" d3:bar3:fooe"  STR=  S" enc dict"       CK
   S" i123e"  DROP  B-INT@ NIP  123 =                    S" dec i123e"      CK
   S" 4:spam" DROP  B-STR@ >R >R DROP R> R>  S" spam" STR=  S" dec 4:spam"   CK
   S" d3:cow3:moo4:spam4:eggse" DROP  S" spam" B-DFIND
      IF  B-STR@ >R >R DROP R> R>  S" eggs" STR=  ELSE  FALSE  THEN  S" dfind spam"  CK
   S" d3:cow3:mooe" DROP  S" pig" B-DFIND  0=            S" dfind absent"   CK
   0 LSUM !  S" li1ei2ei3ee" DROP  ['] ONE B-LIST  LSUM @ 6 =  S" list sum"  CK
   CR #FAIL @ IF ." BENCODE SELFTEST FAILED: " #FAIL @ . CR
            ELSE ." === BENCODE SELFTEST OK ===" CR THEN ;
SELFTEST
