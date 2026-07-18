\ ~ac/lib/net/torrent.f -- look up DHT peers for a .torrent file given its filename.
\ The BitTorrent infohash is SHA-1 of the RAW bytes of the bencoded "info" dictionary inside the
\ .torrent (NOT of the whole file).  We slurp the file, locate the info dict's byte span with the
\ bencode walker (B-DFIND finds the value, B-SKIP gives its end), SHA-1 it, and hand the 20-byte
\ infohash to FIND-PEERS.  The SHA-1 core is ported verbatim from acWEB64's WS-SHA1
\ (src/proto/http/websocket.f), with ACTCP-PALLOC/PFREE swapped for portable ALLOCATE/FREE so it
\ runs standalone under spf4 and spf64.  When wired into acWEB64, call WS-SHA1 directly instead.
\ Windows only (transport lives in dht.f).  CRLF.
REQUIRE FIND-PEERS      ~ac/lib/net/dht.f
REQUIRE WATCH-INFOHASH  ~ac/lib/net/dht-serve.f    \ announce + server (for WATCH-TORRENT)

\ ===== SHA-1 (ported from acWEB64 WS-SHA1) ==================================================
HEX
5A827999 CONSTANT SH-K0   6ED9EBA1 CONSTANT SH-K1   8F1BBCDC CONSTANT SH-K2   CA62C1D6 CONSTANT SH-K3
67452301 CONSTANT SH-H0   EFCDAB89 CONSTANT SH-H1   98BADCFE CONSTANT SH-H2
10325476 CONSTANT SH-H3   C3D2E1F0 CONSTANT SH-H4
FFFFFFFF CONSTANT SH-MASK
DECIMAL
: SH-U32 ( n -- n )  SH-MASK AND ;
: SH-ROL { x n -- y }  x n LSHIFT  x 32 n - RSHIFT OR  SH-U32 ;
: SH-BE@ { a -- u }  a C@ 24 LSHIFT  a 1+ C@ 16 LSHIFT OR  a 2 + C@ 8 LSHIFT OR  a 3 + C@ OR  SH-U32 ;
: SH-BE! { u a -- }
   u 24 RSHIFT 255 AND a C!  u 16 RSHIFT 255 AND a 1+ C!
   u 8 RSHIFT 255 AND a 2 + C!  u 255 AND a 3 + C! ;
CREATE SH-H 5 CELLS ALLOT                 \ running hash state (single-threaded)
CREATE SH-W 80 CELLS ALLOT                \ message schedule

: SH-BLOCK { block \ a b c d e f k temp -- }
   16 0 DO  block I 4 * + SH-BE@  SH-W I CELLS + !  LOOP
   80 16 DO
      SH-W I 3 - CELLS + @  SH-W I 8 - CELLS + @ XOR  SH-W I 14 - CELLS + @ XOR  SH-W I 16 - CELLS + @ XOR
      1 SH-ROL  SH-W I CELLS + !
   LOOP
   SH-H 0 CELLS + @ -> a  SH-H 1 CELLS + @ -> b  SH-H 2 CELLS + @ -> c
   SH-H 3 CELLS + @ -> d  SH-H 4 CELLS + @ -> e
   80 0 DO
      I 20 < IF  b c AND  b INVERT SH-U32 d AND  OR -> f  SH-K0 -> k
      ELSE I 40 < IF  b c XOR d XOR -> f  SH-K1 -> k
      ELSE I 60 < IF  b c AND  b d AND OR  c d AND OR -> f  SH-K2 -> k
      ELSE  b c XOR d XOR -> f  SH-K3 -> k  THEN THEN THEN
      a 5 SH-ROL f + e + k + SH-W I CELLS + @ + SH-U32 -> temp
      d -> e  c -> d  b 30 SH-ROL -> c  a -> b  temp -> a
   LOOP
   SH-H 0 CELLS + @ a + SH-U32 SH-H 0 CELLS + !
   SH-H 1 CELLS + @ b + SH-U32 SH-H 1 CELLS + !
   SH-H 2 CELLS + @ c + SH-U32 SH-H 2 CELLS + !
   SH-H 3 CELLS + @ d + SH-U32 SH-H 3 CELLS + !
   SH-H 4 CELLS + @ e + SH-U32 SH-H 4 CELLS + ! ;

: SHA1 { addr u dest \ total msg -- }             \ 20-byte SHA-1 digest of (addr,u) -> dest
   u 9 + 63 + 64 / 64 *  -> total                 \ padded length (multiple of 64)
   total ALLOCATE THROW  -> msg
   msg total ERASE
   addr msg u MOVE
   128 msg u + C!                                  \ 0x80 terminator bit
   0 msg total + 8 - SH-BE!                        \ high 32 bits of the bit-length (0 for our sizes)
   u 8 *  msg total + 4 - SH-BE!                   \ low 32 bits of the bit-length
   SH-H0 SH-H 0 CELLS + !  SH-H1 SH-H 1 CELLS + !  SH-H2 SH-H 2 CELLS + !
   SH-H3 SH-H 3 CELLS + !  SH-H4 SH-H 4 CELLS + !
   total 64 / 0 ?DO  msg I 64 * +  SH-BLOCK  LOOP
   SH-H 0 CELLS + @ dest 0 +  SH-BE!
   SH-H 1 CELLS + @ dest 4 +  SH-BE!
   SH-H 2 CELLS + @ dest 8 +  SH-BE!
   SH-H 3 CELLS + @ dest 12 + SH-BE!
   SH-H 4 CELLS + @ dest 16 + SH-BE!
   msg FREE THROW ;

\ ===== .torrent -> infohash -> peers ========================================================
: SLURP { a u \ fid sz buf n ior -- buf len ior }   \ read a whole file; buf via ALLOCATE (caller FREEs)
   a u R/O OPEN-FILE -> ior -> fid
   ior IF 0 0 ior EXIT THEN
   fid FILE-SIZE THROW DROP -> sz
   sz ALLOCATE THROW -> buf
   buf sz fid READ-FILE THROW -> n
   fid CLOSE-FILE THROW
   buf n 0 ;

CREATE IH20 20 ALLOT                                \ the extracted infohash

: TORRENT-INFOHASH { buf len dest -- ior }          \ SHA-1 of the info dict -> dest(20); 0 = ok
   buf S" info" B-DFIND 0= IF -1 EXIT THEN           ( info-a = the value addr, at its 'd' )
   DUP B-SKIP OVER -                                 ( info-a span )
   dest SHA1  0 ;

: .HASH ( a -- )  BASE @ >R HEX  20 0 DO DUP I + C@ 0 <# # # #> TYPE LOOP DROP  R> BASE ! ;

: .TORRENT-PEERS { a u \ buf len ior -- }           \ filename -> init DHT, look up, print peers
   ." torrent: " a u TYPE CR
   a u SLURP  -> ior -> len -> buf
   ior IF ." cannot open file (ior=" ior . ." )" CR EXIT THEN
   buf len IH20 TORRENT-INFOHASH
   IF ." not a valid .torrent (no 'info' dictionary)" CR  buf FREE THROW EXIT THEN
   ." infohash: " IH20 .HASH CR
   DHT-INIT  IH20 FIND-PEERS  DHT-DONE
   buf FREE THROW ;

: WATCH-TORRENT { a u secs \ buf len ior -- }       \ announce for the file + watch incoming DHT queries
   ." torrent: " a u TYPE CR
   a u SLURP  -> ior -> len -> buf
   ior IF ." cannot open file (ior=" ior . ." )" CR EXIT THEN
   buf len IH20 TORRENT-INFOHASH
   IF ." not a valid .torrent (no 'info' dictionary)" CR  buf FREE THROW EXIT THEN
   ." infohash: " IH20 .HASH CR
   IH20 secs WATCH-INFOHASH
   buf FREE THROW ;

\EOF
\ ================================ demo ======================================================
\ Comment the "\EOF" line above (-> "\ \EOF") and reload to run.  Needs internet + Windows.
\    spf4.exe ~ac/lib/net/torrent.f          spf64.exe ~ac/lib/net/torrent.f
\ Edit the path below to a .torrent you have on disk.
S" D:\DL\sample.torrent" .TORRENT-PEERS
\ Announce ourselves for the file and watch 60 s for incoming get_peers/announce_peer naming it:
\ S" D:\DL\sample.torrent" 60 WATCH-TORRENT
