\ ~ac/lib/net/persist.f -- warm-start persistence for a swarm node, via SQLite (~ac/lib/lin/sql).
\ Two things survive a restart so the node need not rediscover everything from the bootstrap routers:
\   * dht_nodes -- the DHT routing table.  Reseeding it on boot lets the first lookups query known-good
\     nodes instead of only the public routers, so the mesh can even come up with the bootstrap DNS down.
\   * members  -- the last address each verified fleet member was reached at; dialed directly on boot.
\ Schema is EXPLICIT COLUMNS, not a dump of the in-memory node struct: id/hash as hex TEXT, ip as a
\ dotted-quad TEXT string, port/seen as INTEGER.  That decouples the on-disk format from NODELEN / the
\ compact-node byte layout (a source change can't silently misread old rows), keeps both tables shaped
\ the same, and pins the ip's byte order to the codebase's canonical C-IP/.IP4 form instead of a column
\ word size.  Uses ONLY stock sqlite3.f words (that library is cp1251 -- never edit it with ASCII tools).
\ dht.f is REQUIREd first so `{` (~ac/lib/locals.f) is resident before sqlite3.f pulls in str5.f.  CRLF.
REQUIRE RT-ADD   ~ac/lib/net/dht.f
REQUIRE db3_open ~ac/lib/lin/sql/sqlite3.f
DECIMAL

VARIABLE SWARM-DB   0 SWARM-DB !
: DB?  ( -- f )    SWARM-DB @ 0<> ;
: DBX  ( a u -- )  SWARM-DB @ db3_exec_ ;                 \ run a no-result statement on the open DB

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

: SWARM-DB-OPEN { a u -- f }                             \ open/create the DB + schema; f = opened
   a u db3_open  DUP SWARM-DB !  0= IF FALSE EXIT THEN
   S" CREATE TABLE IF NOT EXISTS dht_nodes(id TEXT PRIMARY KEY, ip TEXT, port INTEGER, seen INTEGER)" DBX
   S" CREATE TABLE IF NOT EXISTS members(hash TEXT PRIMARY KEY, ip TEXT, port INTEGER, seen INTEGER)" DBX
   TRUE ;
: SWARM-DB-CLOSE ( -- )   DB? IF SWARM-DB @ db3_close  0 SWARM-DB ! THEN ;

\ ---- routing table <-> dht_nodes ----
: SAVE-ONE-NODE { na -- }                                \ id hex, ip dotted-quad, port int -- columns
   SQL{ S" INSERT OR REPLACE INTO dht_nodes(id,ip,port,seen) VALUES('" SQL+
        na IDLEN SQLB  S" ','" SQL+  na NODE-IP IP>SQL  S" '," SQL+  na NODE-PORT SQL#
        S" ,strftime('%s','now'))" SQL+  SQL$ DBX ;
: SWARM-DB-SAVE-NODES ( -- )                            \ replace the stored table with the live one
   DB? 0= IF EXIT THEN
   S" BEGIN"                DBX
   S" DELETE FROM dht_nodes" DBX
   RTAB-N @ 0 ?DO I RT-NODE SAVE-ONE-NODE LOOP
   S" COMMIT" DBX ;
: HEXV  ( c -- n )  DUP 57 > IF 55 - ELSE 48 - THEN ;   \ '0'..'9','A'..'F' -> 0..15
CREATE NDBUF 26 ALLOT
: BUILD-NODE { ida ip port -- }                          \ id hex + ip int + port -> compact node -> RT-ADD
   NDBUF 26 ERASE
   IDLEN 0 DO  ida I 2* + C@ HEXV 4 LSHIFT  ida I 2* + 1+ C@ HEXV OR  NDBUF I + C!  LOOP
   ip        255 AND NDBUF 20 + C!   ip  8 RSHIFT 255 AND NDBUF 21 + C!    \ C-IP layout (byte0 = low)
   ip 16 RSHIFT 255 AND NDBUF 22 + C!  ip 24 RSHIFT 255 AND NDBUF 23 + C!
   port 8 RSHIFT 255 AND NDBUF 24 + C!  port 255 AND NDBUF 25 + C!         \ C-PORT layout (big-endian)
   NDBUF RT-ADD ;
: SWARM-DB-LOAD-NODES { \ ppStmt n ida ip port -- n }   \ seed RTAB from storage; returns rows added
   DB? 0= IF 0 EXIT THEN  0 -> n
   S" SELECT id,ip,port FROM dht_nodes" SWARM-DB @ db3_car -> ppStmt
   BEGIN ppStmt WHILE
      0 ppStmt db3_col DROP -> ida                        \ id hex (col0 text ptr stays valid across cols)
      1 ppStmt db3_col DQ>IP -> ip                        \ ip dotted-quad -> integer
      2 ppStmt db3_coli -> port
      ida ip port BUILD-NODE  n 1+ -> n
      ppStmt db3_cdr -> ppStmt
   REPEAT  n ;

\ ---- verified fleet members (same shape: hash hex, ip dotted-quad, port) ----
: SWARM-DB-SAVE-MEMBER { hash-a ip port -- }            \ remember where a member was last verified
   DB? 0= IF EXIT THEN
   SQL{ S" INSERT OR REPLACE INTO members(hash,ip,port,seen) VALUES('" SQL+
        hash-a IDLEN SQLB  S" ','" SQL+  ip IP>SQL  S" '," SQL+  port SQL#
        S" ,strftime('%s','now'))" SQL+  SQL$ DBX ;
[DEFINED] MEMBER-UP-XT [IF]                              \ when loaded over dtls-net.f, persist every
   ' SWARM-DB-SAVE-MEMBER TO MEMBER-UP-XT                \ MEMBER-verified event; loadable standalone too
[THEN]
: SWARM-DB-LOAD-MEMBERS { xt \ ppStmt n -- n }          \ xt: ( ip port -- ) -- caller dials each; count
   DB? 0= IF 0 EXIT THEN  0 -> n
   S" SELECT ip,port FROM members ORDER BY seen DESC" SWARM-DB @ db3_car -> ppStmt
   BEGIN ppStmt WHILE
      0 ppStmt db3_col DQ>IP  1 ppStmt db3_coli  xt EXECUTE  n 1+ -> n
      ppStmt db3_cdr -> ppStmt
   REPEAT  n ;
