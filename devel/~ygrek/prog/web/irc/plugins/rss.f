\ retrieve RSS feeds and announce new items
\ FIXME leaks memory

REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE rss.items-new=> ~ygrek/lib/spec/rss.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f
REQUIRE [IF] lib/include/tools.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f
REQUIRE UTF8> ~ac/lib/lin/iconv/iconv.f
\ REQUIRE UTF>WIN ~ygrek/lib/iconv.f
REQUIRE mtq ~ygrek/lib/multi/queue.f
REQUIRE logger ~ygrek/lib/log.f
REQUIRE list-make ~ygrek/lib/list/make.f
REQUIRE list-ext ~ygrek/lib/list/ext.f

\ local.f

\ ALSO libxml2.dll
\ ALSO libxml2.so.2
\ : nodeText-s ( a u node -- s ) node@ ?DUP IF 1 xmlNodeGetContent ASCIIZ> UTF8> 2DUP >STR NIP SWAP FREE THROW ELSE "" THEN ;
\ PREVIOUS
\ PREVIOUS

MODULE: bot_plugin_rss

: read-number ( a u -- stamp )
   R/O OPEN-FILE IF DROP 0 EXIT THEN
   >R
   PAD 100 R@ READ-FILE DROP
   PAD SWAP NUMBER 0= IF 0 THEN
   R> CLOSE-FILE DROP ;

: timestamp>pad Num>DateTime DateTime>PAD ;

: write-number ( stamp a u -- ) 2>R S>D <# #S #> 2R> OCCUPY ;

\ remove double-slashes - (not a) bug in fforum rss
: normalize-link ( s -- s )
   DUP " //" " /" replace-str-
   DUP " http:/" " http://" replace-str- ;

\ for manual debugging
\ [UNDEFINED] ON-CONNECT [IF]
\ : S-SAY CR TYPE ; : ECHO S-SAY ; : ON-CONNECT ... ;
\ [THEN]

: +TZ ( stamp -- stamp+tz ) TZ @ 60 * + ;

\ sorry for ugly code
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

: reply-rss { node | title author -- }
   node rss.item.title >STR -> title
   node rss.item.author >STR hide-email -> author
   node rss.item.timestamp my-date
   " [{s}] {$author} -- {$title}" STR-SAY
   author STRFREE
   title STRFREE
   node rss.item.link >STR STR-SAY ;

: process-and-stamp-rss=> ( stamp-a stamp-u data-a data-u -- node )
    S" Checking xml..." log::trace
    2SWAP 2DUP read-number >R
    2OVER rss.items-newest DUP IF -ROT write-number ELSE DROP 2DROP THEN
    R>
    \ CR ." Newest : "
    \ 2DUP rss.items-newest Num>DateTime DateTime>PAD TYPE
    \ 2SWAP read-number
    \ CR ." Stamp : "
    \ DUP Num>DateTime DateTime>PAD TYPE
    PRO
     START{
      rss.items-new=> DUP rss.item.timestamp ONTRUE \ не обяз. т.к. если stamp=0 то new не пропустит!
       CONT
     }EMERGE
    S" xml checked" log::trace
    ;

: print-rss { node -- }
   CR ." title=" node rss.item.title TYPE
   CR ." author=" node rss.item.author TYPE
   CR ." date=" node rss.item.timestamp my-date TYPE
   CR ." link=" S" link" node nodeText TYPE 
   CR ." description=" S" description" node nodeText TYPE 
   ;

EXPORT
: debug-rss ( a u -- ) 
   rss.items=> DUP print-rss ;
DEFINITIONS   

: process-rss-forum
   process-and-stamp-rss=> DUP reply-rss ;

: seconds 1000 * ;
: minutes 60 * seconds ;

: url-to-filename ( s -- s )
    DUP " /" " _" replace-str-
    DUP " :" " _" replace-str-
    DUP " ?" " _" replace-str-
    DUP " &" " _" replace-str- ;

0 VALUE rss-checker-q

: rss-getter-get ( a u -- )
     2DUP " rss get {s}" slog::trace
     2DUP >STR url-to-filename { filename }
     ( a u ) >STR >R R@ STR@ GET-FILE R> STRFREE \ DUP STR@ S" qua" TO-FILE
     \ 2DROP S" 3.xml" FILE " {s}"
     ( s ) %[ % filename % ]% rss-checker-q mtq::put
     S" rss-getter done" log::trace
     ;

0 VALUE getter-q

:NONAME
 S" rss-getter" log_thread
 DROP
 BEGIN
   getter-q mtq::get
   DUP STR@ rss-getter-get
       STRFREE
 AGAIN ; TASK: rss-getter

:NONAME { x | url pause }
  S" rss-submitter" log_thread
  1 minutes PAUSE
  x list::car TO url
  x list::cdar TO pause   
  BEGIN
   url STR@ >STR getter-q mtq::put
   pause PAUSE
  AGAIN
  ; TASK: submitter

:NONAME
  S" rss-checker" log_thread
  DROP
  BEGIN
     rss-checker-q mtq::get
     >R
       \ R@ msg.type 1 = IF
       S" rss-checker awaken" log::trace
       R@ list::cdar STR@ R@ list::car STR@ process-rss-forum
       \ THEN
       \ R@ msg.type 0 = IF R@ msg.data msg-lt-rss> process-rss-general THEN
     R> ['] STRFREE list::free-with
  AGAIN
; TASK: rss-checker

: fforum-url S" http://fforum.winglion.ru/rss.php?c=10" ;
: wiki-url S" http://wiki.forth.org.ru/RecentChanges?format=rss" ;
: sf.net-url S" http://sourceforge.net/export/rss2_projnews.php?group_id=17919" ;
: blog-url S" http://my.opera.com/forth/xml/rss/blog" ;

EXPORT

\ -----------------------------------------------------------------------

..: AT-CONNECT
  mtq::new TO rss-checker-q
  mtq::new TO getter-q

  0 rss-getter START DROP
  0 rss-checker START DROP

  \ ограничим сообщения с форума только на время онлайна бота
  TIME&DATE DateTime>Num fforum-url >STR url-to-filename STR@ write-number

  %[ fforum-url >STR % 5 minutes % ]% submitter START DROP
  %[ sf.net-url >STR % 6 60 * minutes % ]% submitter START DROP
  %[ wiki-url >STR % 60 minutes % ]% submitter START DROP
  %[ blog-url >STR % 30 minutes % ]% submitter START DROP

;..

;MODULE

$Revision$ " -- RSS plugin {s} loaded." STYPE CR

\ -----------------------------------------------------------------------

/TEST

ALSO bot_plugin_rss

: q GET-FILE STR@ rss.items=> DUP reply-rss ;

\EOF

\ testing
STARTLOG
ON-CONNECT
