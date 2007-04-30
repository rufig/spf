REQUIRE IRC-BASIC ~ygrek/lib/net/irc/basic.f
REQUIRE NFA=> ~ygrek/lib/wid.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE ATTACH ~pinka/samples/2005/lib/append-file.f
REQUIRE TIME&DATE lib/include/facil.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f
REQUIRE ltcreate ~ygrek/lib/multi/msg.f
REQUIRE #N## ~ac/lib/win/date/date-int.f

' ACCEPT1 TO ACCEPT \ disables autocompletion if present ;)

' ANSI>OEM TO ANSI><OEM \ cp1251

: CVS-DATE $Date$ SLITERAL ;
: CVS-REVISION $Revision$ SLITERAL ;

FALSE TO ?LOGSEND
TRUE TO ?LOGSAY
TRUE TO ?LOGMSG

\ : TALK-LOG-FILE TIME&DATE 2>R NIP NIP NIP 2R> " talk.{n}{n}{n}.log" ;
\ : STR=> PRO CONT STRFREE ;

: CURRENT-DATE ( -- d m y ) TIME&DATE 2>R NIP NIP NIP 2R> ;
: CURRENT-TIME ( -- m h ) TIME&DATE DROP DROP DROP ROT DROP ;

: CURRENT-LOG-FILE 
    CURRENT-DATE { d m y }
    <# S" .log" HOLDS d #N## m #N## y #N [CHAR] . HOLD current-channel HOLDS 0 0 #> ;

: (DO-LOG-TO-FILE) ( a u -- ) CURRENT-LOG-FILE ATTACH-LINE-CATCH DROP ;

: RAW-LOG ( a u -- )
   CURRENT-TIME { m h }
   <# m #N## [CHAR] : HOLD h #N## 0 0 #>
   " {s}|{s}" DUP STR@ (DO-LOG-TO-FILE) STRFREE ;

: S-LOG ( s -- ) DUP STR@ RAW-LOG STRFREE ;

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

: HelpWords=> PRO [WID] BOT-COMMANDS-HELP NFA=> DUP COUNT CONT ;
: AllHelpWords ( -- s ) LAMBDA{ HelpWords=> TYPE SPACE } TYPE>STR ;

0 [IF]
() VALUE all-info-commands
: add-info-command vnode as-str all-commands cons TO all-commands ;

\ добавить s1 в конец строки s НЕ удаляя s1
: +S ( s1 s -- ) SWAP STR@ ROT STR+ ;

: collect-all-info-commands ( -- s )
   "" LAMBDA{ OVER +S } all-info-commands mapcar ;
" !version" add-info-command
" !info" add-info-command
[THEN]

MODULE: BOT-COMMANDS

: !help
    TRUE TO ?check

    -1 PARSE -TRAILING
    DUP IF

      2>R

      GET-ORDER
      ONLY BOT-COMMANDS-HELP
      ALSO BOT-COMMANDS-NOTFOUND
      2R> ['] EVALUATE CATCH IF 2DROP S" Sorry, no info." S-REPLY THEN
      SET-ORDER

    ELSE

    2DROP

    AllHelpWords >R
    R@ STR@ " Available commands : {s} (Use '!info !<command>' for more info)." DUP STR@ S-REPLY STRFREE
    R> STRFREE
    THEN ;

: !info !help ;

: !version
    CVS-DATE
    CVS-REVISION
    " IRC bot in SP-Forth (http://spf.sf.net). Rev. {s} ({s})" DUP STR@ S-REPLY STRFREE
     ;

;MODULE

MODULE: BOT-COMMANDS-HELP

: !info S" If you want to understand recusion you should understand recursion first!" S-REPLY ;
: !version S" It is self-descriptive, man!" S-REPLY ;

;MODULE

MODULE: BOT-COMMANDS-NOTFOUND
 : NOTFOUND 
    nickname STR@ COMPARE-U 0= IF EXIT THEN \ игнорируем упоминания нашего никнейма
    -1 THROW ; \ иначе завершаем разбор строки
;MODULE

: CHECK-MSG-ME ( -- ? )
  trailing nickname STR@ SEARCH NIP NIP 0= IF FALSE EXIT THEN
  S" Hello. I am a bot. Try !info. You can chat to me privately." S-REPLY
  TRUE EXIT ;

: CHECK-MSG-IGNORE ( -- ? ) message-sender S" TiReX" US= ;

0 [IF]
: CHECK-MSG-SPECIAL
   trailing S" .." COMPARE 0= IF 
      message-sender " {s}, dont be so boring! Lets talk." DUP STR@ S-REPLY STRFREE
      TRUE EXIT 
   THEN
   FALSE ;
[THEN]

: CHECK-MSG ( -- ? )
   FALSE TO ?check

   CHECK-MSG-IGNORE IF TRUE EXIT THEN

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

: BOT-ON-RECEIVE ( a u -- )
   \ S" HERE : " TYPE HERE . CR
   2DUP PARSE-IRC-LINE
   2DUP RAW-LOG
   LAMBDA{
    ?LOGMSG IF 2DUP ECHO THEN
    PING-COMMAND? IF PONG EXIT THEN
    PRIVMSG-COMMAND? IF CHECK-MSG DROP EXIT THEN
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