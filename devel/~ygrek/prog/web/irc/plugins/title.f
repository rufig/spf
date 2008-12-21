\ $Id$
\ Обьявление <title> тега ссылок

REQUIRE $Revision: ~ygrek/lib/fun/kkv.f
REQUIRE GET-FILE ~ac/lib/lin/curl/curl.f
\ REQUIRE xml.load=> ~ygrek/lib/spec/rss.f
REQUIRE re_match? ~ygrek/lib/re/re.f
REQUIRE logger ~ygrek/lib/log.f
REQUIRE CURLOPT! ~ac/lib/lin/curl/curlopt.f
REQUIRE mtq ~ygrek/lib/multi/queue.f

0 [IF] \ mockup
: STR-REPLY STYPE CR ;
: STR-SAY-TO TYPE SPACE STYPE CR ;
: PRIVMSG ;
: current-msg-text S" text" ;
: current-msg-target S" target" ;
: AT-CONNECT ... ;
[THEN]

MODULE: bot_plugin_title

0 VALUE q

: GET-FILE-AU ( a u -- s ) " {s}" DUP STR@ GET-FILE SWAP STRFREE ;

: GET-AND-REPLY-TITLE { to-a to-u a u -- }
   a u " GET-AND-REPLY-TITLE {s}" slog::trace
   a u RE" .*(((http://|www\.)(\w+\.)+\w+)(/\S*)*).*" re_match? 0= IF S" Not an url. Finish." log::trace EXIT THEN
   1 get-group 
   \ 5 get-group NIP 0= IF " {s}/" STR@ THEN
   2DUP " HTTP GET {s}" slog::trace
   60 CURLOPT_TIMEOUT CURLOPT! \ timeout
   TRUE CURLOPT_FOLLOWLOCATION CURLOPT!
   2 CURLOPT_MAXREDIRS CURLOPT!
   10 1024 * TO CURL-MAX-SIZE \ maximum download 10K
   GET-FILE-AU
   DUP STR@ RE" .*<[tT][iI][tT][lL][eE]>(.*)</[tT][iI][tT][lL][eE]>.*" re_match? 
   IF
      \1 " Title: {s}" to-a to-u STR-SAY-TO
   THEN 

   ( 
   DUP STR@ NIP 0= IF ." No reply" CR STRFREE EXIT THEN
   DUP STR@
   START{
       xml.load=> DUP
       XML_DOC_ROOT ?DUP ONTRUE \ корень html
       DUP x.name @ ASCIIZ> S" html" COMPARE 0= ONTRUE
       S" head" ROT node@ ?DUP ONTRUE \ head
       ." IN H" DUP XML_NLIST 
       S" title" ROT node@ ?DUP ONTRUE \ title
       ." IN T"
       text@ " Title: {s}" DUP STR@ TYPE CR STRFREE
   }EMERGE)
   STRFREE
;

:NONAME ( x -- )
  S" title-worker" log_thread
  DROP
  { | msg }
  BEGIN
   q mtq::get -> msg
   S" work thread received str" log::trace
   msg list::cdar STR@ msg list::car STR@ GET-AND-REPLY-TITLE
   S" GET-AND-REPLY TITLE done" log::trace
   msg ['] STRFREE list::free-with
   S" work thread is waiting for another message" log::trace
  AGAIN ; TASK: work-thread

EXPORT

MODULE: VOC-IRC-COMMAND

: PRIVMSG
   S" PRIVMSG of bot_plugin_title" log::trace
   PRIVMSG
   %[ current-msg-text >STR % current-msg-target >STR % ]% q mtq::put
   S" PRIVMSG of bot_plugin_title done" log::trace ;

;MODULE

..: AT-CONNECT mtq::new TO q 0 work-thread START DROP ;..
\ ..: AT-CLOSE q mtq::del 0 TO q ;..

;MODULE

0 [IF]
ALSO bot_plugin_title

mtq::new TO q 0 work-thread START .

: a %[ >STR % " dsds" % ]% q mtq::put ;
 S" dsdsds www.forth.org.ru/~ygrek quququq" a
 S" dsds http://ygrek.org.ua ??" a
 S" dsds http://www.debian.org quq?" a
[THEN]

$Revision$ " -- HTML title plugin {s} loaded." STYPE CR
