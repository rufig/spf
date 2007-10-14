\ $Id$
\ Обьявление <title> тега ссылок

REQUIRE $Revision: ~ygrek/lib/fun/kkv.f
REQUIRE GET-FILE ~ac/lib/lin/curl/curl.f
REQUIRE xml.load=> ~ygrek/lib/spec/rss.f
REQUIRE re_match? ~ygrek/lib/re/re.f
REQUIRE ltreceive ~ygrek/lib/multi/msg.f

MODULE: bot_plugin_title

0 VALUE work-thread-lt

: GET-FILE-AU ( a u -- s ) " {s}" DUP STR@ GET-FILE SWAP STRFREE ;

: GET-AND-REPLY-TITLE ( a u -- ) 
   ACCERT( ." try it" CR )
   RE" .*(((http://|www\.)(\w+\.)+\w+)(/\S*)*).*" re_match? 0= IF ACCERT( ." no url" CR ) EXIT THEN
   1 get-group 
   \ 5 get-group NIP 0= IF " {s}/" STR@ THEN
   2DUP ." Getting url " TYPE CR
   30 CURLOPT_TIMEOUT CURLOPT! \ timeout
   TRUE CURLOPT_FOLLOWLOCATION CURLOPT!
   2 CURLOPT_MAXREDIRS CURLOPT!
   10 1024 * TO CURL-MAX-SIZE \ maximum download 10K
   GET-FILE-AU
   DUP STR@ RE" .*<title>(.*)</title>.*" re_match? 
   IF
    1 get-group " Title: {s}" DUP STR@ S-REPLY STRFREE 
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
  DROP
  BEGIN
   ltreceive
   ACCERT( ." ltrecved" CR )
   DUP msg.data GET-AND-REPLY-TITLE
   ACCERT( ." free-msg goes" CR )
       FREE-MSG
       ACCERT( ." free-msg done" CR )
  AGAIN ; VALUE work-thread     

EXPORT

MODULE: VOC-IRC-COMMAND

: PRIVMSG
   ACCERT( ." i am here 1" CR )
   PRIVMSG
   ACCERT( ." i am there 2" CR )
   message-text 0 work-thread-lt ltsend ACCERT( ." i am tututu" CR ) ;

;MODULE

..: AT-CONNECT 0 work-thread ltcreate TO work-thread-lt ;..

;MODULE

\ : a ." !" 0 bot_plugin_title::work-thread-lt ltsend ;
\ S" dsdsds www.forth.org.ru/~ygrek quququq" a
\ S" dsds http://ygrek.org.ua ??" a
\ S" dsds http://www.debian.org quq?" a

$Revision$ " -- HTML title plugin {s} loaded." STYPE CR
