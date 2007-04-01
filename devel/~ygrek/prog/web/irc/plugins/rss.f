REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE rss.items-new=> ~ygrek/lib/spec/rss.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f
REQUIRE [IF] lib/include/tools.f
REQUIRE ltcreate ~ygrek/lib/multi/msg.f
REQUIRE GET-TIME-ZONE ~ac/lib/win/date/timezone.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f

GET-TIME-ZONE

: read-number ( a u -- stamp )
   R/O OPEN-FILE IF DROP 0 EXIT THEN
   >R
   PAD 100 R@ READ-FILE DROP
   PAD SWAP NUMBER 0= IF 0 THEN 
   R> CLOSE-FILE DROP ;

: timestamp>pad Num>DateTime DateTime>PAD ;

: write-number ( stamp a u -- )
    2>R S>D <# #S #> 2R> OCCUPY ;

\ remove double-slashes - bug in fforum
: normalize-link ( s -- s )
   DUP " //" " /" replace-str-
   DUP " http:/" " http://" replace-str- ;

\ for manual debugging
\ [UNDEFINED] ON-CONNECT [IF]
\ : S-SAY CR TYPE ; : ECHO S-SAY ; : ON-CONNECT ... ;
\ [THEN]

: +TZ ( stamp -- stamp+tz ) TZ Bias @ 60 * + ;

\ sorry fr ugly code
: my-date ( stamp -- a u )
    DUP TIME&DATE DateTime>Num +TZ - ABS 6 60 * < 
    IF 
     DROP
     S" Только что"
     EXIT 
    THEN

    DUP Num>DateTime DateTime>Days TIME&DATE DateTime>Days -
    DUP 
    0 = 
    IF 
     DROP
     Num>Time ROT DROP SWAP ( hh mm)
     <# S"  GMT" HOLDS S>D # # 2DROP [CHAR] : HOLD S>D # # 2DROP S" Сегодня " HOLDS 0 0 #>
     EXIT
    THEN

    -1 = 
    IF 
    Num>Time ROT DROP SWAP ( hh mm)
     <# S"  GMT" HOLDS S>D # # 2DROP [CHAR] : HOLD S>D # # 2DROP S" Вчера " HOLDS 0 0 #>
    ELSE
     timestamp>pad
    THEN ;

\ lame :)
: hide-email DUP " @" "  at " replace-str- ;

: reply-rss { node | str1 -- }
   node rss.item.title
   node rss.item.author " {s}" TO str1
   str1 hide-email STR@
   node rss.item.timestamp my-date
   " [{s}] {s} -- {s}" DUP STR@ S-SAY STRFREE
   str1 STRFREE
   S" link" node nodeText " {s}" DUP STR@ S-SAY STRFREE ;

: process-and-stamp-rss=> ( stamp-a stamp-u data-a data-u -- node )
    \ S" Checking forum..." ECHO
    2SWAP 2DUP read-number >R
    2OVER rss.items-newest DUP IF -ROT write-number ELSE DROP 2DROP THEN
    R>
    PRO
     START{
      rss.items-new=> DUP rss.item.timestamp ONTRUE \ не обяз. т.к. если stamp=0 то new не пропустит!
       CONT
     }EMERGE
    \ S" Forum checked" ECHO 
    ;

: process-rss-forum
   process-and-stamp-rss=> DUP reply-rss ;

: process-rss-general ( a u a1 u1 -- ) 2DROP 2DROP CR ." !WEDSRESD" ;

: seconds 1000 * ;
: minutes 60 * seconds ;

: FREE-FILE IF FREE THROW ELSE DROP THEN ;

0 VALUE rss-checker-lt
0 VALUE rss-getter-lt

: new-pack ( -- pack ) "" ;
: pack-n ( n pack -- ) >R SP@ CELL " {s}" R> S+ DROP ;
: pack-au ( a u pack -- ) >R SP@ CELL " {s}{s}" R> S+ ;

: unpack-n ( addr -- addr' n )
  DUP CELL+ SWAP @ ;

: unpack-au ( addr -- addr' a u )
   unpack-n 2DUP + -ROT ;

: >msg-lt-rss ( a1 u1 a u -- s )
   new-pack >R
   R@ pack-au
   R@ pack-au
   R> ;

: msg-lt-rss> ( a u -- a u a1 u1 )
   DROP
   unpack-au ROT
   unpack-au ROT DROP ;

: url-to-filename ( s -- s )
    DUP " /" " _" replace-str-
    DUP " :" " _" replace-str-
    DUP " ?" " _" replace-str-
    DUP " &" " _" replace-str- ;

: rss-getter-get { msg | pack typ filename }
     \ S" rss get" ECHO
     msg msg.data DROP TO pack
     pack 
     unpack-au 2DUP ECHO 2DUP " {s}" url-to-filename TO filename
     ROT unpack-n NIP TO typ
     ( a u ) " {s}" >R R@ STR@ GET-FILE R> STRFREE \ DUP STR@ S" qua" TO-FILE
     \ 2DROP S" 3.xml" FILE " {s}"
     DUP STR@ filename STR@ >msg-lt-rss STR@ typ rss-checker-lt ltsend
         STRFREE
     \ S" rss-getter done" ECHO 
     ;
 
:NONAME
 DROP
 BEGIN
   ltreceive 
   DUP ['] rss-getter-get CATCH ?DUP IF . S" rss-getter failed !" ECHO DROP THEN
   FREE-MSG
 AGAIN
 ; VALUE rss-getter

:NONAME { | url typ pause pack }
  DROP
  1 minutes PAUSE
  ltreceive 
  msg.data DROP 
  unpack-au " {s}" TO url
  unpack-n TO typ
  unpack-n TO pause
  DROP
  BEGIN
   new-pack TO pack
   url STR@ pack pack-au
   typ pack pack-n
   pack STR@ 0 rss-getter-lt ltsend
   pack STRFREE
   pause PAUSE
  AGAIN 
  ; VALUE submitter

:NONAME
  DROP
  BEGIN
   LAMBDA{
     \ my-msgbox-size CR ." My msgbox size : " .
     ltreceive 
     >R
       \ R@ msg.type 1 = IF 
       R@ msg.data msg-lt-rss> process-rss-forum 
       \ THEN
       \ R@ msg.type 0 = IF R@ msg.data msg-lt-rss> process-rss-general THEN
     R>
     FREE-MSG
   } 
   CATCH ?DUP IF . S" rss-checker failed !" ECHO BYE THEN
  AGAIN
; VALUE rss-checker

0 VALUE lt
0 VALUE pack

: fforum-url S" http://fforum.winglion.ru/rss.php?c=10" ;

..: AT-CONNECT 
  0 rss-checker ltcreate TO rss-checker-lt
  0 rss-getter ltcreate TO rss-getter-lt 

\ ограничим сообщения с форума только на время онлайна бота
TIME&DATE DateTime>Num fforum-url " {s}" url-to-filename STR@ write-number

0 submitter ltcreate TO lt
new-pack TO pack 
fforum-url pack pack-au
1 pack pack-n
5 minutes pack pack-n
pack STR@ 0 lt ltsend

0 submitter ltcreate TO lt
new-pack TO pack 
S" http://sourceforge.net/export/rss2_projnews.php?group_id=17919" pack pack-au
1 pack pack-n
6 60 * minutes pack pack-n
pack STR@ 0 lt ltsend

0 submitter ltcreate TO lt
new-pack TO pack 
S" http://wiki.forth.org.ru/RecentChanges?format=rss" pack pack-au
1 pack pack-n
45 minutes pack pack-n
pack STR@ 0 lt ltsend

0 submitter ltcreate TO lt
new-pack TO pack 
S" http://my.opera.com/forth/xml/rss/blog" pack pack-au
1 pack pack-n
30 minutes pack pack-n
pack STR@ 0 lt ltsend
  ;..

$Revision$ " -- RSS plugin {s} loaded." DUP STR@ ECHO STRFREE

\EOF

\ testing
STARTLOG
ON-CONNECT
