REQUIRE xml.children=> ~ygrek/lib/spec/rss.f
REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE ITERATE-FILES ~profit/lib/iterate-files.f
REQUIRE LIKE ~pinka/lib/like.f
REQUIRE sql.pp=> ~ygrek/lib/db/sqlite3.f
REQUIRE load-file ~profit/lib/bac4th-str.f
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f
REQUIRE seq{ ~profit/lib/bac4th-sequence.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f

: files=> ( a u depth --> a u )
  PRO
  ITERATE-FILES 
  ( addr u data flag --> \ <-- )
  NIP
  IF 2DROP EXIT THEN
  CONT 
  2DROP ;

: create-tables ( db -- )
  S" CREATE TABLE IF NOT EXISTS DEVEL (ID INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT, params TEXT, file TEXT);begin;commit;" 
  ROT db3_exec_ ;

: all-xml=> ( a u -- a u )
  PRO
  100 files=> 2DUP S" *.xml" LIKE ONTRUE CONT ;

: DB_NAME S" spf.db3" ;

: print ( a u db -- ) sql.pp=> CR DUP pp.data=> 2DUP TYPE 2 SPACES ;

: value-quote DUP " '" " ''" replace-str- ;

: find-name=> ( a u db -- )
   PRO
   STATIC db db !
   S>STR2 value-quote STR@ 
   " SELECT word, params, file FROM DEVEL WHERE word LIKE '{s}' LIMIT 1"
   DUP
   STR@ db @ START{ sql.pp=> CONT }EMERGE
   STRFREE ;

: print-name ( a u -- )
   BACK db3_close TRACKING
   DB_NAME db3_open RESTB
   find-name=>
   DUP pp.data
   TYPE SPACE TYPE ."   \  defined in " TYPE ;

: get-info ( a u -- s )
   ['] print-name TYPE>STR-CATCH IF NIP NIP THEN ;

: sql 
   BACK db3_close TRACKING
   DB_NAME db3_open RESTB
   sql.pp=> CR DUP pp.data=> 2DUP SPACE TYPE ;

: what-modules? S" SELECT DISTINCT file FROM DEVEL" sql ;

: full-index
   STATIC db
   STATIC colon
   STATIC module 
   STATIC cnt

   DB_NAME R/W CREATE-FILE THROW CLOSE-FILE THROW
   DB_NAME db.open=> DUP db !

   db @ create-tables 

   S" devel/~ygrek/doc/docbook/source" +ModuleDirName all-xml=>
   2DUP load-file
   2DUP xml.load=>
   DUP XML_DOC_ROOT
   xml.children=>
   S" module" //name=
   DUP module !
   0 cnt !
   START{ 
    DUP xml.children=> S" colon" //name=
    DUP colon !
    cnt 1+!
    S" name" module @ attr@ xml.text  " {s}" value-quote STR@ 
    S" params" colon @ attr@ xml.text " {s}" value-quote STR@
    S" name" colon @ attr@ xml.text   " {s}" value-quote STR@
    " INSERT INTO DEVEL (word,params,file) VALUES ('{s}','{s}','{s}')" 
    DUP STR@ ( 2DUP CR TYPE) db @ db3_exec_ STRFREE
   }EMERGE
   CR cnt @ . ." names from " S" name" module @ attr@ xml.text TYPE ;
