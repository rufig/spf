\ $Id$
\ оффлайновые сообщения 

REQUIRE new-hash ~pinka/lib/hash-table.f
REQUIRE NOT ~profit/lib/logic.f
REQUIRE print-list ~ygrek/lib/list/all.f
REQUIRE ENSURE ~ygrek/lib/debug/ensure.f
REQUIRE CEQUAL ~pinka/spf/string-equal.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f
REQUIRE DateTime>PAD ~ygrek/lib/spec/unixdate.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f
\ REQUIRE split-patch ~profit/lib/bac4th-str.f

REQUIRE AT-NAMES-UPDATED ~ygrek/prog/web/irc/plugins/names.f

0 [IF]
: message-sender S" sender" ;
: S-REPLY S" REPLY: " TYPE TYPE CR ;
: S-NOTICE-TO TYPE SPACE TYPE CR ;
() VALUE names-list
: AT-CONNECT ... ;
[THEN]

MODULE: bot_plugin_msg

: msgs-store S" msgs.lst" ;

() VALUE all

0 VALUE current-user-name

: u>name car ;
: u>msgs cdr car ;
: u-addmsg car >R R@ u>msgs cons R> cdr setcar ;

: current-user? ( node -- ? ) car u>name STR@ current-user-name STR@ CEQUAL ;

: find-current-user ( -- l ? ) ['] current-user? all scan-list ;
: del-current-user ( -- ) LAMBDA{ current-user? NOT } all filter-this TO all ;

: save-all-msgs all ['] print-list TYPE>STR DUP STR@ msgs-store OCCUPY STRFREE ;
: (load-all-msgs) msgs-store FILE 2>R 2R@ ['] EVALUATE CATCH IF () THEN 2R> DROP FILEFREE ;
: load-all-msgs DEPTH >R (load-all-msgs) DEPTH R> - 0 = IF () THEN TO all ;

: send-user-msgs ( s -- )
   TO current-user-name
   find-current-user
   IF 
     car u>msgs LAMBDA{ STR@ current-user-name STR@ S-NOTICE-TO } SWAP mapcar 
     all write-list
     del-current-user
     all write-list
     save-all-msgs
   ELSE 
    DROP 
   THEN ;
   
..: AT-NAMES-UPDATED ( l -- l ) ['] send-user-msgs OVER mapcar ;..

: make-msg ( "msg" -- s )
  -1 PARSE >STR >R 
  TIME&DATE DateTime>PAD current-msg-sender "  ({s} at {s})" R@ S+
  R> ;

MODULE: VOC-IRC-COMMAND
: JOIN 
  -1 PARSE 2DROP
  current-msg-sender >STR DUP send-user-msgs STRFREE ;
;MODULE

MODULE: BOT-COMMANDS
: !msg 
    PARSE-NAME >STR TO current-user-name
    find-current-user NIP NOT IF %[ current-user-name STR@ >STR %s () %l ]% vnode as-list all cons TO all THEN \ add empty entry
    find-current-user IF
      make-msg vnode as-str SWAP u-addmsg 
      current-user-name STR@ current-msg-sender " {s}: message for {s} was recorded." DUP STR@ S-REPLY STRFREE 
     ELSE DROP CR ." STRANGE!!!" THEN
    save-all-msgs ;
;MODULE

MODULE: BOT-COMMANDS-HELP
: !msg S" !msg <nick> message - bot will send message to <nick> when <nick> will join this channel" S-REPLY ;
;MODULE

..: AT-CONNECT load-all-msgs ;..

;MODULE

$Revision$ " -- Msg plugin {s} loaded" STYPE CR

0 [IF]
ALSO bot_plugin_msg
ALSO BOT-COMMANDS
[THEN]

