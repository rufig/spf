DIS-OPT

REQUIRE IRC-BASIC ~ygrek/lib/net/irc/basic.f
REQUIRE quotes ~ygrek/prog/web/irc/quotes.f
REQUIRE NFA=> ~ygrek/lib/wid.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f

' ACCEPT1 TO ACCEPT \ disables autocompletion if present ;)

' ANSI>OEM TO ANSI><OEM \ cp1251

: kkv-save [CHAR] $ PARSE -TRAILING S", ;
: kkv-extract HERE >R kkv-save R> COUNT ;
: $Date: kkv-extract ;
: $Revision: kkv-extract ;

$Date$ 2VALUE CVS-DATE
$Revision$ 2VALUE CVS-REVISION

TRUE TO ?LOGSEND
TRUE TO ?LOGSAY
TRUE TO ?LOGMSG

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
    " Available commands : {s} (Use '!help !<command>' for more info)." DUP STR@ S-REPLY STRFREE
    R> STRFREE
    THEN ;

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
  S" Hello. I am a bot. Try !help. You can chat to me privately." S-REPLY
  TRUE EXIT ;

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

   FALSE
;

: BOT-ON-RECEIVE ( a u -- )
   2DUP 
   PARSE-REPLY
   LAMBDA{
    ?LOGMSG IF 2DUP ECHO THEN
    ?PING IF PONG EXIT THEN
    ?PRIVMSG IF CHECK-MSG DROP EXIT THEN
    ?LOGMSG 0= IF 2DUP ECHO THEN
   }
   EXECUTE
   2DROP ;

' BOT-ON-RECEIVE TO ON-RECEIVE





\ EOF