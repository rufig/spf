DIS-OPT

REQUIRE IRC-BASIC ~ygrek/lib/net/irc/basic.f
REQUIRE NFA=> ~ygrek/lib/wid.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE ATTACH ~pinka/samples/2005/lib/append-file.f
REQUIRE TIME&DATE lib/include/facil.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f
REQUIRE ltcreate ~ygrek/lib/multi/msg.f

' ACCEPT1 TO ACCEPT \ disables autocompletion if present ;)

' ANSI>OEM TO ANSI><OEM \ cp1251

$Date$ 2VALUE CVS-DATE
$Revision$ 2VALUE CVS-REVISION

FALSE TO ?LOGSEND
TRUE TO ?LOGSAY
TRUE TO ?LOGMSG

\ : TALK-LOG-FILE TIME&DATE 2>R NIP NIP NIP 2R> " talk.{n}{n}{n}.log" ;
\ : STR=> PRO CONT STRFREE ;

: CURRENT-DATE TIME&DATE 2>R NIP NIP NIP 2R> ;

: TALK-LOG-FILE CURRENT-DATE
    SWAP ROT
    <# S" .log" HOLDS S>D # # 2DROP S>D # # 2DROP S>D #S 2DROP S" talk." HOLDS 0 0 #> ;

: DO-LOG-TALK TALK-LOG-FILE ATTACH-LINE-CATCH DROP ;

:NONAME { | last -- }
  DROP
  BEGIN
   1000 PAUSE
   ltreceive >R
    \ TIME&DATE DateTime>Num TO last
    R@ msg.data SIMPLE-DO-CMD
   R> FREE-MSG
  AGAIN
; VALUE <irc-bot-sender>

FALSE VALUE ?check

VOCABULARY BOT-COMMANDS
VOCABULARY BOT-COMMANDS-HELP
VOCABULARY BOT-COMMANDS-NOTFOUND

: HelpWords=> PRO [WID] BOT-COMMANDS NFA=> DUP COUNT CONT ;
: AllHelpWords ( -- s ) LAMBDA{ HelpWords=> TYPE SPACE } TYPE>STR ;

MODULE: BOT-COMMANDS

: !bar 
   S" Just for testing" determine-sender S-NOTICE-TO
   TRUE TO ?check
;

: !help
    TRUE TO ?check

    -1 PARSE -TRAILING
    DUP IF

      2>R

      GET-ORDER
      ONLY BOT-COMMANDS-HELP
      ALSO BOT-COMMANDS-NOTFOUND
      2R> ['] EVALUATE CATCH IF 2DROP THEN
      SET-ORDER

    ELSE

    2DROP

    AllHelpWords DUP >R STR@
    " Available commands : {s} (Use '!info !<command>' for more info)." DUP STR@ S-REPLY STRFREE
    R> STRFREE
    THEN ;

: !info !help ;

: !version
    CVS-DATE
    CVS-REVISION
    " IRC bot in SP-Forth (http://spf.sf.net). Rev. {s} ({s})" DUP STR@ S-REPLY STRFREE
     ;

;MODULE

MODULE: BOT-COMMANDS-NOTFOUND
 : NOTFOUND -1 THROW ;
;MODULE

: CHECK-MSG-ME ( -- ? )
  trailing nickname STR@ SEARCH NIP NIP 0= IF FALSE EXIT THEN
  S" Hello. I am a bot. Try !info. You can chat to me privately." S-REPLY
  TRUE EXIT ;

0 [IF]
: CHECK-MSG-SPECIAL
   trailing S" .." COMPARE 0= IF 
      determine-sender " {s}, dont be so boring! Lets talk." DUP STR@ S-REPLY STRFREE
      TRUE EXIT 
   THEN
   FALSE ;
[THEN]

: CHECK-MSG ( -- ? )
   FALSE TO ?check

   GET-ORDER
   ONLY BOT-COMMANDS
   ALSO BOT-COMMANDS-NOTFOUND
   \ ORDER
   trailing ['] EVALUATE CATCH IF 2DROP THEN \ тут отваливание - нормальная ситуация
   SET-ORDER

   ?check IF TRUE EXIT THEN

   CHECK-MSG-ME IF TRUE EXIT THEN

   \ CHECK-MSG-SPECIAL IF TRUE EXIT THEN

   FALSE
;

: LOG-TALK
   ?PRIVMSG 0= 
   \ command S" notice"
   IF EXIT THEN
   trailing
   determine-sender 
   params nickname STR@ US= 
   IF 
    " notice {s} : {s}"
   ELSE
    " {s} : {s}"
   THEN
   DUP
   STR@ DO-LOG-TALK
   STRFREE ;


: BOT-ON-RECEIVE ( a u -- )
   \ S" HERE : " TYPE HERE . CR
   2DUP 
   PARSE-REPLY
   LAMBDA{
    LOG-TALK
    ?LOGMSG IF 2DUP ECHO THEN
    ?PING IF PONG EXIT THEN
    ?PRIVMSG IF CHECK-MSG DROP EXIT THEN
    ?LOGMSG 0= IF 2DUP ECHO THEN
   }
   EXECUTE
   2DROP ;

' BOT-ON-RECEIVE TO ON-RECEIVE

\ ------------------------------------------------------

0 VALUE bot-watcher

:NONAME ( x -- )
  DROP
  BEGIN 
   ['] (RECEIVE) CATCH IF BYE THEN 
  AGAIN 
  ; TASK: BotReceiveTask

: CONNECT CONNECT 0 BotReceiveTask START DROP LOGIN ;

SocketsStartup THROW
\ 0 <irc-bot-sender> ltcreate VALUE irc-bot-sender
\ : IRC-BOT-DO-CMD ( a u -- ) 0 irc-bot-sender ltsend ;
\ ' IRC-BOT-DO-CMD TO DO-CMD

\ 0 <bot-watcher> ltcreate TO bot-watcher

\ EOF