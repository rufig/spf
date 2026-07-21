\ ~ac/lib/net/bencode-test.f -- strict-parser regression for bencode.f (reviews P0.2 / 3rd-round P1).
\ TRACKED next to the source (like asn1/der-test.f) so it travels with commits -- NOT under the
\ gitignored tests/.  The invariant under test: on ANY malformed input every decoder word sets BE-BAD
\ and returns a cursor within [BE-START, BE-END] -- never BE-END+1.  Bounds are checked against BE-END,
\ not the scratch buffer, so an off-by-one past the message is caught.
\ Run from D:\PRO\spf :   spf64 devel\~ac\lib\net\bencode-test.f
REQUIRE B-STR@ ~ac/lib/net/bencode.f
DECIMAL
VARIABLE #F  0 #F !
: CK ( f a u -- ) ROT IF ." ok   " TYPE ELSE ." FAIL " TYPE 1 #F +! THEN CR ;

CREATE BUF 128 ALLOT
: LOAD ( a u -- start )   DUP >R  BUF SWAP MOVE  BUF R> BE-SETEND ;
: CURSOR-OK? ( a' -- f )  DUP BE-START @ U< 0=  SWAP BE-END @ U> 0= AND ;   \ BE-START <= a' <= BE-END

\ ---- well-formed ----
: T-GOOD-STR
   S" 3:abc" LOAD  B-STR@  ( a' s-a s-u )
   3 =  SWAP BUF 2 + = AND  SWAP BE-END @ = AND   S" 3:abc -> len 3, cursor at BE-END" CK
   BE-OK?                                          S" 3:abc BE-OK?" CK ;
: T-GOOD-INT
   S" i42e"  LOAD  B-INT@  ( a' n )   42 =  SWAP BE-END @ = AND  S" i42e -> 42, cursor at BE-END" CK  BE-OK? S" i42e BE-OK?" CK
   S" i-7e"  LOAD  B-INT@  NIP  -7 =  BE-OK? AND                 S" i-7e -> -7, BE-OK" CK ;

\ ---- string-length failures: each MUST set BE-BAD and keep the cursor in bounds ----
: BAD-STR { a u aa uu -- }   \ load, B-STR@, assert cursor in bounds AND BE-BAD, label = (aa uu)
   a u LOAD  B-STR@  2DROP        ( a' )
   CURSOR-OK?  BE-OK? 0= AND  aa uu CK ;
: T-STR-FAILS
   S" 1"                       S" bare length '1' (no colon): flagged, cursor <= BE-END" BAD-STR
   S" -5:abcde"                S" negative length: flagged, in bounds" BAD-STR
   S" :abc"                    S" no-digit length: flagged" BAD-STR
   S" 5abcd"                   S" missing ':' : flagged" BAD-STR
   S" 99:ab"                   S" over-long length: flagged, clamped" BAD-STR
   S" 18446744073709551616:x"  S" length 2^64 (wraps to 0): flagged, NOT accepted" BAD-STR ;

\ ---- integer failures ----
: BAD-INT { a u aa uu -- }   a u LOAD  B-INT@  DROP ( a' ) CURSOR-OK?  BE-OK? 0= AND  aa uu CK ;
: T-INT-FAILS
   S" i1"                      S" i1 (no closing e): flagged, cursor <= BE-END" BAD-INT
   S" ix"                      S" ix (no digit): flagged" BAD-INT
   S" ie"                      S" ie (empty int): flagged" BAD-INT
   S" i99999999999999999999e"  S" integer overflow: flagged" BAD-INT ;

\ ---- structural: unterminated list/dict must be flagged, cursor bounded ----
: BAD-SKIP { a u aa uu -- }   a u LOAD  B-SKIP ( a' ) CURSOR-OK?  BE-OK? 0= AND  aa uu CK ;
: T-STRUCT-FAILS
   S" l3:abc"                  S" unterminated list: flagged, in bounds" BAD-SKIP
   S" d1:a1:b"                 S" unterminated dict: flagged, in bounds" BAD-SKIP ;
: T-DEEP
   34 0 DO  [CHAR] l BUF I + C!  LOOP   BUF 34 BE-SETEND  B-SKIP
   CURSOR-OK?  BE-OK? 0= AND            S" nesting past BE-MAXDEPTH: flagged, no runaway" CK ;
: T-DFIND-HOSTILE
   S" d2:id-9:XXXXXe" LOAD  S" xx" B-DFIND DROP
   BE-OK? 0=                            S" B-DFIND survives a hostile value length" CK ;

: MAIN
   T-GOOD-STR T-GOOD-INT T-STR-FAILS T-INT-FAILS T-STRUCT-FAILS T-DEEP T-DFIND-HOSTILE
   #F @ IF ." FAILURES " #F @ . ELSE ." strict bencode: bounds + grammar hold against hostile input" THEN CR ;
MAIN
BYE
