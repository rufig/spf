\ $Id$
\
\ bac4th итераторы для SQLite

REQUIRE db3_open ~ac/lib/lin/sql/sqlite3.f
REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE STATIC ~profit/lib/static.f
REQUIRE /TEST ~profit/lib/testing.f

\ обёртка над db3_enum
: sql.enum { a u xt db | rrr }
   \ xt: i par ppStmt -- ? \ ? - флаг продолжения
   a u rrr xt db db3_enum ; 
   \ ['] CATCH ?DUP IF ." !!!" S" sql.enum" db db3_error? 2DROP 2DROP DROP THEN

\ перебор sql-rows
\ с верхнего уровня должен приходить флаг продолжения
: sql.enum=> ( a u db --> i par pp \ <-- ? ) R> SWAP sql.enum ;

\ сброс на стек всех полей записи pp (каждое поле как строка a u)
: pp.data { pp -- i*x }
   pp db3_cols 0 DO
    pp db3_cols 1- I - pp db3_col 
   LOOP ;

\ итератор по полям записи
: pp.data=> ( pp --> a u \ <-- a u )
   PRO
   STATIC pp
   pp !
   pp @ db3_cols 0 DO
    I pp @ db3_col CONT 2DROP
   LOOP ;

\ выдача всех pp по sql запросу, более удобный аналог sql.enum=>
: sql.pp=> ( sql-a sql-u db --> pp \ <-- pp )
  PRO
   sql.enum=>
   NIP NIP
   ( pp ) CONT ( pp )
   DROP
   TRUE ;

\ Открыть файл базы a u
\ При откате - закрыть
: db.open=> ( a u --> db \ <-- db )
   PRO db3_open CONT db3_close ;

/TEST

: create-tables 
  S" CREATE TABLE IF NOT EXISTS TEST1 (ID INTEGER PRIMARY KEY AUTOINCREMENT,str TEXT);begin;commit;" 
  ROT
  db3_exec_ ;

: test
   S" test1.db3" db.open=> DUP 
   >R
   R@ create-tables 
   S" INSERT INTO TEST1 (str) VALUES ('hello1')" R@ db3_exec_
   S" INSERT INTO TEST1 (str) VALUES ('hello2')" R@ db3_exec_
   S" SELECT * FROM TEST1" R@ START{ sql.pp=> DUP pp.data CR TYPE 2 SPACES TYPE }EMERGE
   RDROP
   ;
   