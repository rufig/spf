\ ~ac/lib/net/persist.f -- warm-start persistence for a swarm node, via SQLite (~ac/lib/lin/sql).
\ Two things survive a restart so the node need not rediscover everything from the bootstrap routers:
\   * dht_nodes -- the DHT routing table (compact 26-byte nodes).  Reseeding the table on boot means the
\     first lookups query known-good nodes instead of only the public routers, converging in seconds.
\   * members  -- the last address each verified fleet member was reached at.  On boot we dial those
\     directly (accepting any CA-signed member -- addresses drift, so the hash is stored for logging,
\     not as a hard expectation) and often re-form the mesh before a single DHT round completes.
\ Uses ONLY the stock sqlite3.f words -- that library is cp1251 and must not be edited by ASCII tools.
\ Binary keys travel as hex TEXT built into the SQL, and integers are formatted in; no bind API needed.
\ Loaded/saved explicitly by the boot script and a periodic save -- nothing here touches the hot RX path.
\ dht.f is REQUIREd first so `{` (~ac/lib/locals.f) is resident before sqlite3.f pulls in str5.f.  CRLF.
REQUIRE RT-ADD   ~ac/lib/net/dht.f
REQUIRE db3_open ~ac/lib/lin/sql/sqlite3.f
DECIMAL

VARIABLE SWARM-DB   0 SWARM-DB !
4294967295 CONSTANT 32MASK   \ column_int is 32-bit SIGNED: an ip with the top bit set (e.g. 0xDA727295)
                             \ comes back sign-extended.  Mask it to recover the unsigned 32-bit address.
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

: SWARM-DB-OPEN { a u -- f }                             \ open/create the DB + schema; f = opened
   a u db3_open  DUP SWARM-DB !  0= IF FALSE EXIT THEN
   S" CREATE TABLE IF NOT EXISTS dht_nodes(node TEXT PRIMARY KEY)" DBX
   S" CREATE TABLE IF NOT EXISTS members(hash TEXT PRIMARY KEY, ip INTEGER, port INTEGER, seen INTEGER)" DBX
   TRUE ;
: SWARM-DB-CLOSE ( -- )   DB? IF SWARM-DB @ db3_close  0 SWARM-DB ! THEN ;

\ ---- routing table <-> dht_nodes ----
: SAVE-ONE-NODE { na -- }
   SQL{ S" INSERT OR IGNORE INTO dht_nodes(node) VALUES('" SQL+  na NODELEN SQLB  S" ')" SQL+  SQL$ DBX ;
: SWARM-DB-SAVE-NODES ( -- )                            \ replace the stored table with the live one
   DB? 0= IF EXIT THEN
   S" BEGIN"                DBX
   S" DELETE FROM dht_nodes" DBX
   RTAB-N @ 0 ?DO I RT-NODE SAVE-ONE-NODE LOOP
   S" COMMIT" DBX ;
: HEXV  ( c -- n )  DUP 57 > IF 55 - ELSE 48 - THEN ;   \ '0'..'9','A'..'F' -> 0..15
CREATE NDBUF 26 ALLOT
: DECODE-NODE { a u -- }                                \ 52 hex chars -> NDBUF (26 bytes) -> RT-ADD
   u NODELEN 2* <> IF EXIT THEN
   NODELEN 0 DO  a I 2* + C@ HEXV 4 LSHIFT  a I 2* + 1+ C@ HEXV OR  NDBUF I + C!  LOOP
   NDBUF RT-ADD ;
: SWARM-DB-LOAD-NODES { \ ppStmt n -- n }               \ seed RTAB from storage; returns rows added
   DB? 0= IF 0 EXIT THEN  0 -> n
   S" SELECT node FROM dht_nodes" SWARM-DB @ db3_car -> ppStmt
   BEGIN ppStmt WHILE
      0 ppStmt db3_col DECODE-NODE  n 1+ -> n
      ppStmt db3_cdr -> ppStmt
   REPEAT  n ;

\ ---- verified fleet members ----
: SWARM-DB-SAVE-MEMBER { hash-a ip port -- }            \ remember where a member was last verified
   DB? 0= IF EXIT THEN
   SQL{ S" INSERT OR REPLACE INTO members(hash,ip,port,seen) VALUES('" SQL+
        hash-a IDLEN SQLB  S" '," SQL+  ip SQL#  S" ," SQL+  port SQL#
        S" ,strftime('%s','now'))" SQL+  SQL$ DBX ;
[DEFINED] MEMBER-UP-XT [IF]                              \ when loaded over dtls-net.f, persist every
   ' SWARM-DB-SAVE-MEMBER TO MEMBER-UP-XT                \ MEMBER-verified event; loadable standalone too
[THEN]
: SWARM-DB-LOAD-MEMBERS { xt \ ppStmt n -- n }          \ xt: ( ip port -- ) -- caller dials each; count
   DB? 0= IF 0 EXIT THEN  0 -> n
   S" SELECT ip,port FROM members ORDER BY seen DESC" SWARM-DB @ db3_car -> ppStmt
   BEGIN ppStmt WHILE
      0 ppStmt db3_coli 32MASK AND  1 ppStmt db3_coli  xt EXECUTE  n 1+ -> n
      ppStmt db3_cdr -> ppStmt
   REPEAT  n ;
