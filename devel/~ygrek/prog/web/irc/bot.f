REQUIRE ACCERT( lib/ext/debug/accert.f
0 ACCERT-LEVEL ! \ не компилировать ACCERT'ы

REQUIRE VOC-IRC-COMMAND ~ygrek/lib/net/irc/conn.f
REQUIRE NFA=> ~ygrek/lib/wid.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE ATTACH ~pinka/samples/2005/lib/append-file.f
REQUIRE TIME&DATE lib/include/facil.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f
REQUIRE ltcreate ~ygrek/lib/multi/msg.f
REQUIRE #N## ~ac/lib/win/date/date-int.f
REQUIRE %[ ~ygrek/lib/list/all.f
REQUIRE DateTime>Num ~ygrek/lib/spec/unixdate.f
REQUIRE GET-FILE ~ac/lib/lin/curl/curl.f

' ACCEPT1 TO ACCEPT \ disables autocompletion if present ;)

' ANSI>OEM TO ANSI><OEM \ cp1251 in console

: CVS-DATE $Date$ SLITERAL ;
: CVS-REVISION $Revision$ SLITERAL ;

: CURRENT-DATE ( -- d m y ) TIME&DATE 2>R NIP NIP NIP 2R> ;
: CURRENT-TIME ( -- m h ) TIME&DATE DROP DROP DROP ROT DROP ;

: CURRENT-LOG-FILE
    CURRENT-DATE { d m y }
    <# S" .log" HOLDS d #N## m #N## y #N [CHAR] . HOLD current-channel HOLDS 0 0 #> ;

: (DO-LOG-TO-FILE) ( a u -- ) CURRENT-LOG-FILE ATTACH-LINE-CATCH DROP ;

: AS-LOG-STR ( a u -- s )
   CURRENT-TIME { m h }
   <# m #N## [CHAR] : HOLD h #N## 0 0 #>
   " {s}|{s}" ;
   
: RAW-LOG AS-LOG-STR { s } s STR@ ECHO s STR@ (DO-LOG-TO-FILE) s STRFREE ;

FALSE VALUE ?check

VOCABULARY BOT-COMMANDS
VOCABULARY BOT-COMMANDS-HELP
VOCABULARY BOT-COMMANDS-NOTFOUND

: HelpWords=> PRO [WID] BOT-COMMANDS-HELP NFA=> DUP COUNT CONT ;
: AllHelpWords ( -- s ) LAMBDA{ HelpWords=> TYPE SPACE } TYPE>STR ;

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
  message-text nickname STR@ SEARCH NIP NIP 0= IF FALSE EXIT THEN
  S" Hello. I am a bot. Try !info. You can chat to me privately." S-REPLY
  TRUE EXIT ;

: CHECK-MSG-IGNORE ( -- ? ) message-sender S" TiReX" COMPARE-U 0= ;

: CHECK-MSG-SPECIAL
   message-text S" .." COMPARE 0= IF
      message-sender " {s}, dont be so boring! Lets talk." DUP STR@ S-REPLY STRFREE
      TRUE EXIT
   THEN
   FALSE ;

\ : cons: PARSE-NAME 2DUP " {s} cons TO {s}" DUP STR@ EVALUATE STRFREE ; IMMEDIATE
\ : vcons: POSTPONE vnode POSTPONE cons: ; IMMEDIATE

: CHECK-MSG ( -- ? )
   FALSE TO ?check

   ACCERT( ." CHECK-MSG" CR )

   GET-ORDER
   ONLY BOT-COMMANDS
   ALSO BOT-COMMANDS-NOTFOUND
   \ ORDER
   message-text ['] EVALUATE CATCH IF 2DROP THEN \ тут отваливание - нормальная ситуация
   SET-ORDER

   ?check ;

() VALUE xt-on-privmsg
\ xt: ( -- ? )
\ ? - xt обработал сообщение, остановить обработку

%[
' CHECK-MSG-IGNORE %
' CHECK-MSG %
\ ' CHECK-MSG-SPECIAL %
' CHECK-MSG-ME %
]% TO xt-on-privmsg

: seconds 1000 * ;
: minutes 60 * seconds ;

\ -----------------------------------------------------------------------

MODULE: VOC-IRC-COMMAND

: PRIVMSG 
   ACCERT( ." PRIVMSG of bot" CR )
   ['] EXECUTE xt-on-privmsg list-find 
   ACCERT( ." PRIVMSG of bot almost done" CR )
   2DROP ;

: 433 BYE ; \ nickname already in use
: ERROR BYE ; \

;MODULE

\ -----------------------------------------------------------------------

..: AT-RECEIVE ( a u -- a u ) 2DUP RAW-LOG ;..
..: AT-CONNECT 0 SimpleReceiveTask START DROP LOGIN ;..

\ -----------------------------------------------------------------------

SocketsStartup THROW

\EOF
