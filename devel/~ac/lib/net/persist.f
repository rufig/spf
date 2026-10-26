\ ~ac/lib/net/persist.f -- warm-start persistence for a swarm node, via SQLite (~ac/lib/lin/sql).
\ Two things survive a restart so the node need not rediscover everything from the bootstrap routers:
\   * dht_nodes -- the DHT routing table.  Reseeding it on boot lets the first lookups query known-good
\     nodes instead of only the public routers, so the mesh can even come up with the bootstrap DNS down.
\   * members  -- the last address each verified fleet member was reached at; dialed directly on boot.
\ Schema is EXPLICIT COLUMNS, not a dump of the in-memory node struct: id/hash as hex TEXT, ip as a
\ dotted-quad TEXT string, port/seen as INTEGER.  That decouples the on-disk format from NODELEN / the
\ compact-node byte layout (a source change can't silently misread old rows), keeps both tables shaped
\ the same, and pins the ip's byte order to the codebase's canonical C-IP/.IP4 form instead of a column
\ word size.  Uses sqlite3.f plus bounded SQLite calls below (sqlite3.f is cp1251).
\ dht.f is REQUIREd first so `{` (~ac/lib/locals.f) is resident before sqlite3.f pulls in str5.f.  CRLF.
REQUIRE RT-ADD   ~ac/lib/net/dht.f
REQUIRE db3_open ~ac/lib/lin/sql/sqlite3.f
DECIMAL

[DEFINED] WINAPI: [DEFINED] WINAPI64: OR [IF]
  ALSO SO NEW: sqlite3.dll
[ELSE]
  [DEFINED] DLFN: [IF]
    ALSO SO NEW: libsqlite3.dylib
  [ELSE]
    [DEFINED] ?BIONIC [IF]
      ALSO SO NEW: libsqlite3_acweb.so
    [ELSE]
      ALSO SO NEW: libsqlite3.so.0
    [THEN]
  [THEN]
[THEN]
: PERSIST-SQL-EXEC ( errmsg data callback sql db -- rc ) 5 sqlite3_exec ;
: PERSIST-SQL-PREPARE ( tail stmt u a db -- rc ) 5 sqlite3_prepare_v2 ;
: PERSIST-SQL-STEP ( stmt -- rc ) 1 sqlite3_step ;
: PERSIST-SQL-FINALIZE ( stmt -- rc ) 1 sqlite3_finalize ;
: PERSIST-SQL-TIMEOUT ( ms db -- rc ) 2 sqlite3_busy_timeout ;
PREVIOUS

VARIABLE SWARM-DB   0 SWARM-DB !
: DB?  ( -- f )    SWARM-DB @ 0<> ;
: DBX { a u \ sql rc -- }
   a u >STR -> sql
   0 0 0 sql STR@ DROP SWARM-DB @ PERSIST-SQL-EXEC -> rc
   sql STRFREE rc THROW ;

\ ---- a tiny SQL string builder (NUL-terminated, as db3_exec expects) ----
512 CONSTANT /SQLBUF   CREATE SQLBUF /SQLBUF ALLOT   VARIABLE SQLP
: SQL{  ( -- )     SQLBUF SQLP ! ;
: SQLC  { c -- }   SQLP @ SQLBUF - /SQLBUF 1- < IF c SQLP @ C!  1 SQLP +! THEN ;   \ one byte, bounded
: SQL+  { a u -- } u 0 ?DO  a I + C@ SQLC  LOOP ;
: SQL#  { n -- }   n 0 <# #S #> SQL+ ;                    \ unsigned decimal
: HEXNIB ( n -- c )  15 AND DUP 9 > IF 55 + ELSE 48 + THEN ;   \ 0..15 -> '0'..'9','A'..'F'
: SQLB  { a u -- } u 0 ?DO  a I + C@  DUP 4 RSHIFT HEXNIB SQLC  HEXNIB SQLC  LOOP ;   \ bytes as hex
: SQL$  ( -- a u )  0 SQLP @ C!  SQLBUF  SQLP @ SQLBUF - ;   \ terminate, return the counted string

\ ip <-> dotted-quad TEXT.  Byte order matches C-IP / .IP4 (byte0 = low byte of the ip integer), so the
\ text form is canonical and unambiguous -- no dependence on a column's width or sign.  Portable (no
\ winsock inet_addr/inet_ntoa, which are Windows-only and would break the Linux/mac fleet nodes).
: IP>SQL { ip -- }
   ip        255 AND SQL#  [CHAR] . SQLC
   ip  8 RSHIFT 255 AND SQL#  [CHAR] . SQLC
   ip 16 RSHIFT 255 AND SQL#  [CHAR] . SQLC
   ip 24 RSHIFT 255 AND SQL# ;
: DQ>IP { a u \ ip byte sh -- ip }                       \ "45.149.114.218" -> ip integer
   0 -> ip  0 -> byte  0 -> sh
   u 0 ?DO
      a I + C@ DUP [CHAR] . = IF  DROP  byte sh LSHIFT ip OR -> ip  sh 8 + -> sh  0 -> byte
      ELSE  [CHAR] 0 -  byte 10 * +  -> byte  THEN
   LOOP
   byte sh LSHIFT ip OR ;                                \ fold in the last octet

: PERSIST-IP? { a u \ octets digits byte c -- flag }
   1 -> octets 0 -> digits 0 -> byte
   u 7 16 WITHIN 0= IF FALSE EXIT THEN
   u 0 DO a I + C@ -> c c [CHAR] . = IF
      digits 0= IF FALSE UNLOOP EXIT THEN
      octets 1+ -> octets 0 -> digits 0 -> byte
   ELSE
      c [CHAR] 0 [CHAR] 9 1+ WITHIN 0= IF FALSE UNLOOP EXIT THEN
      byte 10 * c [CHAR] 0 - + -> byte digits 1+ -> digits
      byte 255 > digits 3 > OR IF FALSE UNLOOP EXIT THEN
   THEN LOOP octets 4 = digits 0<> AND ;
: PERSIST-HEX? { a u -- flag }
   u 40 <> IF FALSE EXIT THEN
   u 0 DO a I + C@ DUP [CHAR] 0 [CHAR] 9 1+ WITHIN
      SWAP 32 OR [CHAR] a [CHAR] f 1+ WITHIN OR 0= IF FALSE UNLOOP EXIT THEN
   LOOP TRUE ;
VARIABLE persist-stmt
: PERSIST-FINALIZE ( -- )
   persist-stmt @ ?DUP IF PERSIST-SQL-FINALIZE DROP 0 persist-stmt ! THEN ;
: PERSIST-PREPARE { a u \ rc tail -- }
   0 persist-stmt ! ^ tail persist-stmt u a SWARM-DB @ PERSIST-SQL-PREPARE -> rc
   rc IF PERSIST-FINALIZE rc THROW THEN ;
: PERSIST-STEP ( -- flag )
   persist-stmt @ PERSIST-SQL-STEP DUP 100 = IF DROP TRUE EXIT THEN
   DUP 101 = IF DROP FALSE EXIT THEN THROW FALSE ;
: PERSIST-WITH { a u xt \ ior -- }
   a u PERSIST-PREPARE xt CATCH -> ior PERSIST-FINALIZE ior THROW ;

: SWARM-DB-OPEN { a u -- f }                             \ open/create the DB + schema; f = opened
   a u db3_open  DUP SWARM-DB !  0= IF FALSE EXIT THEN
   100 SWARM-DB @ PERSIST-SQL-TIMEOUT DROP
   S" CREATE TABLE IF NOT EXISTS dht_nodes(id TEXT PRIMARY KEY, ip TEXT, port INTEGER, seen INTEGER)" DBX
   S" CREATE TABLE IF NOT EXISTS members(hash TEXT PRIMARY KEY, ip TEXT, port INTEGER, seen INTEGER)" DBX
   TRUE ;
: SWARM-DB-CLOSE ( -- )
   PERSIST-FINALIZE DB? IF SWARM-DB @ db3_close 0 SWARM-DB ! THEN ;

\ ---- routing table <-> dht_nodes ----
: SAVE-ONE-NODE { na -- }                                \ id hex, ip dotted-quad, port int -- columns
   SQL{ S" INSERT OR REPLACE INTO dht_nodes(id,ip,port,seen) VALUES('" SQL+
        na IDLEN SQLB  S" ','" SQL+  na NODE-IP IP>SQL  S" '," SQL+  na NODE-PORT SQL#
        S" ,strftime('%s','now'))" SQL+  SQL$ DBX ;
: (SWARM-DB-SAVE-NODES) ( -- )
   S" DELETE FROM dht_nodes" DBX
   RTAB-N @ 0 ?DO I RT-NODE SAVE-ONE-NODE LOOP
   S" DELETE FROM members WHERE seen < strftime('%s','now')-2592000 OR hash NOT IN (SELECT hash FROM members ORDER BY seen DESC LIMIT 256)" DBX
   S" COMMIT" DBX ;
: SWARM-DB-SAVE-NODES { \ ior -- }
   DB? 0= IF EXIT THEN S" BEGIN IMMEDIATE" DBX
   ['] (SWARM-DB-SAVE-NODES) CATCH -> ior
   ior IF S" ROLLBACK" ['] DBX CATCH IF 2DROP THEN ior THROW THEN ;
: HEXV  ( c -- n ) DUP 57 > IF 32 OR 87 - ELSE 48 - THEN ;
CREATE NDBUF 26 ALLOT
: BUILD-NODE { ida ip port -- }                          \ id hex + ip int + port -> compact node -> RT-ADD
   NDBUF 26 ERASE
   IDLEN 0 DO  ida I 2* + C@ HEXV 4 LSHIFT  ida I 2* + 1+ C@ HEXV OR  NDBUF I + C!  LOOP
   ip        255 AND NDBUF 20 + C!   ip  8 RSHIFT 255 AND NDBUF 21 + C!    \ C-IP layout (byte0 = low)
   ip 16 RSHIFT 255 AND NDBUF 22 + C!  ip 24 RSHIFT 255 AND NDBUF 23 + C!
   port 8 RSHIFT 255 AND NDBUF 24 + C!  port 255 AND NDBUF 25 + C!         \ C-PORT layout (big-endian)
   NDBUF RT-ADD ;
VARIABLE persist-count
: PERSIST-ROW? ( -- flag )
   0 persist-stmt @ db3_col PERSIST-HEX?
   1 persist-stmt @ db3_col PERSIST-IP? AND
   2 persist-stmt @ db3_coli 1 65536 WITHIN AND ;
: (SWARM-DB-LOAD-NODES) ( -- )
   BEGIN PERSIST-STEP WHILE PERSIST-ROW? IF
      0 persist-stmt @ db3_col DROP
      1 persist-stmt @ db3_col DQ>IP 2 persist-stmt @ db3_coli BUILD-NODE
      1 persist-count +!
   THEN REPEAT ;
: SWARM-DB-LOAD-NODES ( -- n )
   DB? 0= IF 0 EXIT THEN 0 persist-count !
   S" SELECT id,ip,port FROM dht_nodes WHERE seen>=strftime('%s','now')-604800 ORDER BY seen DESC LIMIT 160"
   ['] (SWARM-DB-LOAD-NODES) PERSIST-WITH persist-count @ ;

\ ---- verified fleet members (same shape: hash hex, ip dotted-quad, port) ----
: SWARM-DB-SAVE-MEMBER { hash-a ip port -- }            \ remember where a member was last verified
   DB? 0= IF EXIT THEN
   SQL{ S" INSERT OR REPLACE INTO members(hash,ip,port,seen) VALUES('" SQL+
        hash-a IDLEN SQLB  S" ','" SQL+  ip IP>SQL  S" '," SQL+  port SQL#
        S" ,strftime('%s','now'))" SQL+  SQL$ DBX ;
[DEFINED] MEMBER-UP-XT [IF]                              \ when loaded over dtls-net.f, persist every
   ' SWARM-DB-SAVE-MEMBER TO MEMBER-UP-XT                \ MEMBER-verified event; loadable standalone too
[THEN]
VARIABLE persist-member-xt
CREATE persist-member-key 20 ALLOT
: (SWARM-DB-LOAD-MEMBERS) ( -- )
   BEGIN PERSIST-STEP WHILE PERSIST-ROW? IF
      0 persist-stmt @ db3_col persist-member-key HEX>ID
      1 persist-stmt @ db3_col DQ>IP 2 persist-stmt @ db3_coli
      persist-member-key persist-member-xt @ EXECUTE 1 persist-count +!
   THEN REPEAT ;
: SWARM-DB-LOAD-MEMBERS-KEY ( xt -- n ) \ xt: ( ip port key-a -- ); key borrowed during callback
   DB? 0= IF DROP 0 EXIT THEN persist-member-xt ! 0 persist-count !
   S" SELECT hash,ip,port FROM members WHERE seen>=strftime('%s','now')-2592000 ORDER BY seen DESC LIMIT 256"
   ['] (SWARM-DB-LOAD-MEMBERS) PERSIST-WITH persist-count @ ;
VARIABLE persist-legacy-xt
: PERSIST-LEGACY-MEMBER ( ip port key -- ) DROP persist-legacy-xt @ EXECUTE ;
: SWARM-DB-LOAD-MEMBERS ( xt -- n ) \ compatibility: callback takes ( ip port -- )
   persist-legacy-xt ! ['] PERSIST-LEGACY-MEMBER SWARM-DB-LOAD-MEMBERS-KEY ;

\ ---- keep reconnecting to saved members (not just once at boot) ----
\ Warm-start dials each saved member ONCE.  If that dial missed (a transient timeout, or the member came
\ up after us) the node never retries it, and if discovery is starved it can stay disconnected until a
\ restart.  Wired into the DTLS layer's per-round hook, this re-dials saved members that are not currently
\ connected -- guarded by SELF-EP?/PR-FIND/NCACHE so a live or backed-off member is left alone.
[DEFINED] MEMBER-REDIAL-XT [IF]                         \ only when loaded over dtls-net.f
: (REDIAL-ONE) { ip port -- }
   ip port SELF-EP? IF EXIT THEN                        \ never dial ourselves
   ip port PR-FIND 0< 0= IF EXIT THEN                   \ already connecting or connected
   ip port NCACHE-HAS? IF EXIT THEN                     \ rejected/backed-off: respect the NCACHE window
   ip port 0 SWARM-DTLS-CONNECT DROP ;
: SWARM-REDIAL-MEMBERS ( -- )  ['] (REDIAL-ONE) SWARM-DB-LOAD-MEMBERS DROP ;
' SWARM-REDIAL-MEMBERS TO MEMBER-REDIAL-XT
[THEN]
