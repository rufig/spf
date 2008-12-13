\ $Id$
\ Список собеседников в канале

REQUIRE list-make ~ygrek/lib/list/make.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE list-ext ~ygrek/lib/list/ext.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f

0 [IF] \ mock-up
: AT-CONNECT ... ;
: current-channel S" ds" ;
: irc-str-send STYPE SPACE TYPE CR ;
: current-msg-text S" text" ;
: minutes 60 60 * * ;
[THEN]

MODULE: bot_plugin_names

list::nil VALUE names-list

: break-string-to-list ( a u -- list ) %[ LAMBDA{ BEGIN PARSE-NAME DUP WHILE >STR % REPEAT 2DROP } EVALUATE-WITH ]% ;
: MEMORIZE-NAMES ( a u -- ) break-string-to-list names-list list::concat TO names-list ;

:NONAME { pause }
  BEGIN
   pause PAUSE
   current-channel " NAMES {s}" irc-str-send
  AGAIN
; TASK: reporter

EXPORT

: AT-NAMES-UPDATED ( l -- l ) ... ;

\ -----------------------------------------------------------------------

MODULE: VOC-IRC-COMMAND

: NAMREPLY current-msg-text MEMORIZE-NAMES ;
: ENDOFNAMES names-list AT-NAMES-UPDATED DROP names-list ['] STRFREE list::free-with list::nil TO names-list ;
: 353 NAMREPLY ;
: 366 ENDOFNAMES ;

;MODULE

\ -----------------------------------------------------------------------

..: AT-CONNECT 4 minutes reporter START DROP ;..

;MODULE

$Revision$ " -- names-list plugin {s} loaded." STYPE CR

\ -----------------------------------------------------------------------

\EOF
