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
1024 CONSTANT /BE-BUF
CREATE BE-BUF /BE-BUF ALLOT
VARIABLE BE-PTR

: BE-RESET ( -- )        BE-BUF BE-PTR ! ;
: BE-LEN   ( -- u )      BE-PTR @ BE-BUF - ;
: BE-C,    ( c -- )      BE-PTR @ C!  1 BE-PTR +! ;
: BE-A,    ( a u -- )    BE-PTR @ SWAP DUP >R MOVE  R> BE-PTR +! ;   \ append u raw bytes
: BE-#     ( n -- )      \ append a signed integer as ASCII decimal (bencode is always base-10)
   BASE @ >R DECIMAL   DUP >R ABS 0 <# #S R> SIGN #> BE-A,  R> BASE ! ;
: BE-STR   ( a u -- )    DUP BE-#  [CHAR] : BE-C,  BE-A, ;      \ <len>:<bytes>
: BE-KEY   ( a u -- )    BE-STR ;                               \ a dict key is just a bstring
: BE-INT   ( n -- )      [CHAR] i BE-C,  BE-#  [CHAR] e BE-C, ; \ i<n>e
: BE-D{    ( -- )        [CHAR] d BE-C, ;                       \ open a dict  (keys MUST be emitted sorted)
: BE-L[    ( -- )        [CHAR] l BE-C, ;                       \ open a list
: BE-}     ( -- )        [CHAR] e BE-C, ;                       \ close a dict or list

\ ===== decoder (zero-copy walk) =============================================================
\ Each B-*@ word takes the address of a bencoded value and returns the address just past it.
: DIGIT? ( c -- f )   [CHAR] 0 [CHAR] 9 1+ WITHIN ;

: B-NUM ( a -- a' n )                        \ parse [-]<digits>; a' points at the first non-digit
   DUP C@ [CHAR] - = >R
   R@ IF 1+ THEN   0                         ( a acc )
   BEGIN OVER C@ DIGIT? WHILE
      10 *  OVER C@ [CHAR] 0 - +  SWAP 1+ SWAP
   REPEAT
   R> IF NEGATE THEN ;

: B-INT@ ( a -- a' n )                       \ a at 'i' : i<n>e  -> value, past the 'e'
   1+ B-NUM  SWAP 1+ SWAP ;

: B-STR@ ( a -- a' s-a s-u )                 \ a at a length digit : <len>:<bytes> -> bytes span, past them
   B-NUM  SWAP 1+  SWAP  2DUP + -ROT ;

: B-SKIP ( a -- a' )                         \ skip one whole value of any type (self-recursive)
   DUP C@ [CHAR] i = IF B-INT@ DROP EXIT THEN
   DUP C@ [CHAR] l = IF 1+ BEGIN DUP C@ [CHAR] e <> WHILE RECURSE         REPEAT 1+ EXIT THEN
   DUP C@ [CHAR] d = IF 1+ BEGIN DUP C@ [CHAR] e <> WHILE RECURSE RECURSE REPEAT 1+ EXIT THEN
   B-STR@ 2DROP ;                            \ else a string: keep a', drop the span

: STR= { a1 u1 a2 u2 -- f }
   u1 u2 <> IF FALSE EXIT THEN
   u1 0 DO  a1 I + C@ a2 I + C@ <> IF FALSE UNLOOP EXIT THEN  LOOP  TRUE ;

: B-DFIND ( dict-a key-a key-u -- val-a true | false )   \ find a key in a dict, return its value addr
   2>R  1+                                   ( p ; R: key-a key-u )
   BEGIN DUP C@ [CHAR] e <> WHILE
      B-STR@                                 ( p' k-a k-u )
      2R@ STR= IF  2R> 2DROP  TRUE EXIT  THEN
      B-SKIP                                 ( p'' )
   REPEAT
   DROP 2R> 2DROP FALSE ;

: B-LIST ( list-a xt -- )                    \ call xt ( elem-a -- ) for each element (xt must be stack-neutral)
   SWAP 1+ SWAP                              ( p xt )
   BEGIN OVER C@ [CHAR] e <> WHILE
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
