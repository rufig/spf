\ $Id$
\ Распечатка списка

REQUIRE ?value ~ygrek/lib/list/ext.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE /TEST ~profit/lib/testing.f

: (.) ( n -- ) S>D (D.) TYPE ;
: print-quoted-str [CHAR] " EMIT SPACE STR@ TYPE [CHAR] " EMIT SPACE ;
: print-quoted-str-cut ( s -- ) [CHAR] " EMIT STR@ DUP 20 > IF DROP 17 TYPE ." ..." ELSE TYPE THEN [CHAR] " EMIT ;

\ -----------------------------------------------------------------------

VECT (write-list)

: write-node ( node -- )
   DUP ?list IF car (write-list) EXIT THEN
   DUP ?str IF car print-quoted-str-cut SPACE EXIT THEN
   DUP ?value IF car . EXIT THEN
   ." ?" car . ;

\ Распечатать список, удобный для интерактива вариант, длинные сроки затроеточиваются
: write-list ( node -- )
   ." ( "
   BEGIN
    DUP ?empty 0=
   WHILE
    DUP write-node
    cdr
   REPEAT 
   DROP ." ) " ;

' write-list TO (write-list)

\ -----------------------------------------------------------------------

VECT (print-list)

: print-node ( node -- )
   DUP ?list IF car (print-list) ." %l " EXIT THEN
   DUP ?str IF car print-quoted-str ." %s " EXIT THEN
   DUP ?value IF car . ." % " EXIT THEN
   ABORT" ??? Bad list" ;

\ Распечатать список, строковое представление пригодное для EVALUATE
\ BUG: строки содержащие кавычку не квотятся!
: print-list ( node -- )
   ." lst( "
   BEGIN
    DUP ?empty 0=
   WHILE
    DUP print-node
    cdr
   REPEAT 
   DROP ." )lst " ;

' print-list TO (print-list)

\ -----------------------------------------------------------------------

: dump-node ( node -- )
   DUP ?empty IF DROP ." ()" EXIT THEN
   DUP ?list IF ." (l " THEN
   DUP ?str IF ." (s " THEN
   DUP ?value IF ." (v " THEN
   DUP car . ." . "
       cdr (.) ." )" ;

\ Распечатать список, без лишней обработки - просто адреса
: dump-list ( node -- )
   DUP dump-node 
   DUP ?empty IF DROP EXIT THEN 
   ."  -> "
   cdr RECURSE ;

\ -----------------------------------------------------------------------

/TEST

lst( 1 %n " qu qu" %s 2 %n " long string for demonstration" %s 
     3 %n lst( -1 %n -2 %n -3 %n )lst %l 5 %n )lst VALUE l1

CR l1 write-list
CR l1 print-list
CR l1 dump-list
