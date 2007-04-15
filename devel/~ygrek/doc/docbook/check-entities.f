\ проверяет docbook на предмет использования каждого описанного entity ровно один раз.

REQUIRE cons ~ygrek/lib/list/all.f
REQUIRE children=> ~ygrek/lib/spec/rss.f
REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE ITERATE-FILES ~profit/lib/iterate-files.f
REQUIRE LIKE ~pinka/lib/like.f
REQUIRE sql.pp=> ~ygrek/lib/db/sqlite3.f
REQUIRE load-file ~profit/lib/bac4th-str.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f

() VALUE entities-list

: collect-entities% ( a u -- )
   BEGIN
    S" <!ENTITY " SEARCH 0= IF 2DROP EXIT THEN
    S" <!ENTITY " NIP /STRING
    2DUP ['] PARSE-NAME EVALUATE-WITH 2DUP " &{s};" %s
    NIP /STRING
   AGAIN
  ;

: SEARCHN { a u a1 u1 | cnt -- cnt } 
    a u
    0 -> cnt 
    BEGIN 
     a1 u1 SEARCH 0= IF 2DROP cnt EXIT THEN
     u1 /STRING
     cnt 1+ TO cnt
    AGAIN ;

FALSE VALUE bad

: str. car STR@ TYPE ;

: check-entities ( a u lst -- ? )
    FALSE TO bad
    >R
    BEGIN
     R@ () = IF RDROP 2DROP EXIT THEN
     2DUP
     R@ car STR@ SEARCHN 
     DUP 0 = IF CR ." Entity missing : " R@ str. TRUE TO bad THEN
         1 > IF CR ." Entity used more than once : " R@ str. TRUE TO bad THEN
     R> cdr >R 
    AGAIN ;

S" devel.docbook" FILE 2DUP lst( collect-entities% )lst check-entities
:NONAME CR bad IF ." ERROR" ELSE ." ALL OK" THEN ; EXECUTE
