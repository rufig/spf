REQUIRE StartSQL   ~yz/lib/odbc.f
REQUIRE small-hash ~yz/lib/hash.f
REQUIRE >>         ~yz/lib/data.f

MODULE: ODBC

USER bound-hash
USER counter

WINAPI: SQLBindParameter ODBC32.DLL

: bind-parameter { adr type num -- }
\ type=0 число, <>0 asciiz-строка
  0  type IF adr @ ZLEN ELSE 4 THEN  
  type IF adr @ ELSE adr THEN
  0  type IF adr @ ZLEN ELSE 4 THEN  
  type IF W: sql_char ELSE W: sql_integer THEN
  type IF W: sql_c_char ELSE W: sql_c_slong THEN
  W: sql_param_input num last-stat @
  SQLBindParameter DROP ;

: ins-param-markers ( n -- )
  1 ?DO " ?," z>> LOOP ;

: (insert-rec) ( rec -- )
  DUP :hashkey @ COUNT S>> c: , C>>
  DUP :hashvalue SWAP :hashfree C@ counter @ bind-parameter
  counter 1+! ;

EXPORT

: insert-hash { table hash fodbc \ [ 1000 ] buf -- ? }
  fodbc prepare-handles 0= IF W: sql_invalid_handle EXIT THEN
  push->>
  buf init->>
  " INSERT INTO " z>>  table z>>  "  (" z>>
  1 counter !
  ['] (insert-rec) hash all-hash-records
  ptr 1-! " ) VALUES(" z>>
  counter @ ins-param-markers
  ptr 1-! " )" Z>>
  buf last-odbc @ ExecuteSQL
  free-laststat
  SWAP pop->>
;

\ --------------------------------------------------

: BIND-HASH { hash \ len [ 50 ] name [ 50 ] lenname -- }
  hash bound-hash !
  hash clear-hash
  last-odbc @ ColCount 1+ 1 ?DO
    name I last-odbc @ ColName
    name lenname ZMOVE
    lenname " #" ZAPPEND
    I last-odbc @ ColDisplaySize 1+ TO len
    4 lenname ASCIIZ> hash HASH!R ( actuallen)
    len  DUP name ASCIIZ> hash HASH!R
    W: sql_char I last-stat @ SQLBindCol DROP
  LOOP ;

: UNBIND-HASH ( -- ) 
  free-laststat ;

;MODULE

\EOF

0 VALUE database
0 VALUE h

small-hash TO h
StartSQL . TO database
S" реклама" 0 0 0 0 database ConnectSQL SQL_OK? .
\ " SELECT * from firms" database ExecuteSQL ?sql-error
\ h BIND-HASH
\ database NextRow DROP
\ S" contact" h HASH@Z 10 DUMP
\ S" contact#" h HASH@ .
\ UNBIND-HASH
\ -----------------
S" number" 1010 h HASH!N
" Максимиллиан" S" surname" h HASH!Z
S" vm" 1 h HASH!N
" 543.56" S" sum" h HASH!Z
" Это просто примечание" S" note" h HASH!Z
" ticket" h database insert-hash SQL_OK? .
BYE
