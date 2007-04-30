\ $Id$
\ погода от http://www.gismeteo.ru

REQUIRE XSLT ~ac/lib/lin/xml/xslt.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f 
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f
REQUIRE /STRING lib/include/string.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f
REQUIRE HASH! ~pinka/lib/hash-table.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE FINE-HEAD ~pinka/samples/2005/lib/split-white.f
REQUIRE UPPERCASE ~ac/lib/string/uppercase.f
REQUIRE %( ~ygrek/lib/list/all.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f

( testing
: S-REPLY DUMP ;
: message-sender S" dsds" ;
: ECHO CR TYPE ;
: AT-CONNECT ... ;
\ )

0 VALUE h

MODULE: BOT-COMMANDS-HELP

: !weather S" Usage: !weather <город> - погода от http://www.gismeteo.ru/" S-REPLY ;

;MODULE

: SKIP-NAME PARSE-NAME 2DROP ;

: parse-city-code-name ( a u a1 u1 a2 u2 -- )
   [CHAR] ; PARSE
   [CHAR] ; PARSE
   [CHAR] ; PARSE
   -1 PARSE 2DROP ;

: load-city-codes ( a u -- )
   FileLines=> DUP STR@ 
    LAMBDA{ 
     parse-city-code-name ( a u a u a u )
     2DUP UPPERCASE
     2>R 2OVER 2R> h HASH!
     2DUP UPPERCASE h HASH!
    } EVALUATE-WITH ;

: load-gismeteo-city-codes
   S" plugins/gismeteo.txt" 
   2DUP FILE-EXIST 0= IF 
    S" http://bar.gismeteo.ru/gmbartlistfull.txt"
    GET-FILE DUP STR@ S" plugins/gismeteo.txt" OCCUPY STRFREE 
   THEN
   load-city-codes ;

: find-city-code ( a u -- a u ) " {s}" DUP STR@ UPPERCASE DUP STR@ h HASH@ ROT STRFREE ;

%( 
  %( " мск" %s " Москва" %s )% %l 
  %( " спб" %s " С.-Петербург" %s )% %l 
  %( " нск" %s " Новосибирск" %s )% %l 
)% VALUE short-cities

: short-city ( a u -- a1 u1 )
   LAMBDA{ car STR@ 2OVER COMPARE 0= } short-cities list-scan
   IF car cdar STR@ 2SWAP 2DROP THEN ;

MODULE: BOT-COMMANDS

: !weather 
    PARSE-NAME short-city
    2DUP find-city-code 
    DUP 0= IF 2DROP 2DROP message-sender " {s}: Нет такого города!" DUP STR@ S-REPLY STRFREE EXIT THEN
    " http://informer.gismeteo.ru/xml/{s}_1.xml" >R 
    R@ STR@ S" plugins/frc3.xsl" XSLT ( a u )
    R> STRFREE
    FINE-HEAD
    2SWAP
    message-sender " {s}: погода в городе {s} {s}" DUP STR@ S-REPLY STRFREE
    S" BUG: MEMORY LEAK - NEED XSLT FREE" ECHO
;
: !п !weather ;
: !w !weather ;
: !погода !weather ;

;MODULE

..: AT-CONNECT large-hash TO h load-gismeteo-city-codes ;..

$Revision$ " -- gismeteo weather plugin {s} loaded." DUP STR@ ECHO STRFREE

\EOF \ testing

AT-CONNECT
S" хельсинки" find-city-code CR TYPE
BOT-COMMANDS::!weather киев
S" нск" short-city find-city-code CR TYPE
