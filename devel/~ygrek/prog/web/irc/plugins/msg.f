\ $Id$
\ оффлайновые сообщения 

REQUIRE NOT ~profit/lib/logic.f
REQUIRE ENSURE ~ygrek/lib/debug/ensure.f
REQUIRE CEQUAL ~pinka/spf/string-equal.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f
REQUIRE DateTime>PAD ~ygrek/lib/spec/unixdate.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f
REQUIRE list-ext ~ygrek/lib/list/ext.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f

REQUIRE AT-NAMES-UPDATED ~ygrek/prog/web/irc/plugins/names.f

0 [IF] \ mock-up
: current-msg-sender S" sender" ;
: S-REPLY S" REPLY: " TYPE TYPE CR ;
: STR-REPLY DUP STR@ S-REPLY STRFREE ;
: S-NOTICE-TO TYPE SPACE TYPE CR ;
: AT-CONNECT ... ;
[THEN]

MODULE: bot_plugin_msg

: msgs-store S" msgs.lst" ;

list::nil VALUE all

{{ list
: u>name car ;
: u>msg cdr car ;
: u-free ['] STRFREE free-with ;
}}

: make-msg ( "target msg" -- u )
  %[
  PARSE-NAME >STR %
  -1 PARSE >STR % ]% ;

: get-messages ( a u -- l ) all LAMBDA{ u>name STR@ 2OVER CEQUAL } list::partition 2SWAP 2DROP TO all ;

: save-message { u -- } u u>msg STR@ u u>name STR@ " {s} {s}" DUP STR@ msgs-store ATTACH-LINE-CATCH DROP STRFREE ;
: save-messages ( l -- ) msgs-store EMPTY ['] save-message list::iter ; 
: load-messages% msgs-store FileLines=> DUP STR@ ['] make-msg EVALUATE-WITH % ;
: load-messages ( -- l ) %[ load-messages% ]% ;

: u-send { u -- } u u>msg STR@ u u>name STR@ S-NOTICE-TO ;

: send-user-msgs ( s -- )
   STR@ get-messages LAMBDA{ DUP u-send u-free } list::free-with \ possible problems on Win32 due to another thread heap
   all save-messages ;

..: AT-NAMES-UPDATED ( l -- l ) DUP ['] send-user-msgs list::iter ;..

MODULE: VOC-IRC-COMMAND
: JOIN 
  -1 PARSE 2DROP
  current-msg-sender >STR DUP send-user-msgs STRFREE ;
;MODULE

MODULE: BOT-COMMANDS
: !msg 
    make-msg { msg }
    TIME&DATE DateTime>PAD current-msg-sender "  ({s} at {s})" msg u>msg S+
    msg all list::cons TO all
    msg u>name STR@ current-msg-sender " {s}: message for {s} was recorded." STR-REPLY
    all save-messages ;
;MODULE

MODULE: BOT-COMMANDS-HELP
: !msg S" !msg <nick> message - bot will send message to <nick> when <nick> will join this channel" S-REPLY ;
;MODULE

..: AT-CONNECT load-messages TO all ;..

;MODULE

$Revision$ " -- Msg plugin {s} loaded" STYPE CR

0 [IF]
ALSO bot_plugin_msg
ALSO BOT-COMMANDS
[THEN]

