REQUIRE IRC-BASIC ~ygrek/lib/net/irc/basic.f
REQUIRE quotes ~ygrek/prog/web/irc/quotes.f

' ACCEPT1 TO ACCEPT \ disables autocompletion if present ;)

' ANSI>OEM TO ANSI><OEM \ cp1251

\ STARTLOG

DIS-OPT

: kkv-extract [CHAR] $ PARSE HERE >R S", R> COUNT ;
: $Date: kkv-extract ;
: $Revision: kkv-extract ;

$Date$ 2VALUE CVS-DATE
$Revision$ 2VALUE CVS-REVISION

TRUE TO ?LOGSEND
TRUE TO ?LOGSAY
TRUE TO ?LOGMSG

FALSE VALUE ?check

MODULE: BOT-COMMANDS

: !q
    SkipDelimiters
    -1 PARSE DUP 0= IF 
     2DROP random-quote 
    ELSE
     2DUP NUMBER IF >R 2DROP R> quote[] ELSE search-quote THEN
    THEN
    STR@ S-REPLY
    TRUE TO ?check ;

: !Q !q ;

: !aq
    SkipDelimiters
    -1 PARSE DUP 0= IF 2DROP S" Try !help !aq" determine-sender S-SAY-TO EXIT THEN
    2DUP determine-sender " Adding quote from {s}: {s}" DUP STR@ ECHO STRFREE
    ( a u ) determine-sender register-quote
    quotes-total 1- determine-sender " {s}: Quote {n} added. Thanks." DUP STR@ S-REPLY STRFREE
    TRUE TO ?check ;

: !help
    TRUE TO ?check

    PARSE-NAME 

    2DUP S" !q" US= 
    IF 
     2DROP
     S" !q - random quote. !q keyword - quote with keyword. !q number - quote by number." S-REPLY
     EXIT
    THEN

    2DUP S" !aq" US= 
    IF 
     2DROP
     S" !aq quote - add quote" S-REPLY
     EXIT
    THEN

    2DROP

    CVS-DATE
    CVS-REVISION
    " IRC bot written in SP-Forth (http://spf.sf.net). alpha. rev. {s} {s}" DUP STR@ S-REPLY STRFREE
    S" Available commands - !q, !aq, !help. (Use '!help !cmd' for more info)." S-REPLY
 ;

: NOTFOUND 2DROP ;

;MODULE

: CHECK-MSG-ME ( -- ? )
  trailing nickname STR@ SEARCH NIP NIP 0= IF FALSE EXIT THEN
  S" Hello. I am a bot. Try !help." S-REPLY
  TRUE EXIT ;

: CHECK-MSG ( -- ? )
   FALSE TO ?check

   GET-ORDER
   BOT-COMMANDS
   trailing EVALUATE
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