\ $Id$
\ IRC bot
\ Требуемые библиотеки :
\ sqlite3.dll - http://sqlite.org/download.html
\ libexslt.dll libxslt.dll libxml2.dll iconv.dll zlib1.dll - http://zlatkovic.com/pub/libxml/
\ libcurl.dll - http://curl.haxx.se/latest.cgi?curl=win32-devel-ssl
\ zlibwapi.dll - http://www.winimage.com/zLibDll/
\ libeay32.dll libssl32.dll - http://www.slproweb.com/products/Win32OpenSSL.html

REQUIRE VOC-IRC-COMMAND ~ygrek/lib/net/irc/conn.f
REQUIRE NFA=> ~ygrek/lib/wid.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE ATTACH ~pinka/samples/2005/lib/append-file.f
REQUIRE TIME&DATE lib/include/facil.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f
REQUIRE scan-list ~ygrek/lib/list/all.f
REQUIRE DateTime>Num ~ygrek/lib/spec/unixdate.f
REQUIRE #N## ~ac/lib/win/date/date-int.f
REQUIRE logger ~ygrek/lib/log.f
REQUIRE OSNAME-STR ~ygrek/lib/sys/osname.f
REQUIRE str-concat-with ~ygrek/lib/str.f

REQUIRE RAW-LOG-FILE ~ygrek/prog/web/irc/common.f
REQUIRE log2html ~ygrek/prog/web/irc/log2html.f

[DEFINED] WINAPI: [IF]
' ANSI>OEM TO ANSI><OEM \ cp1251 in console
[THEN]

gmtime CONSTANT start-time

: CVS-DATE $Date$ SLITERAL ;
: CVS-REVISION $Revision$ SLITERAL ;

: CURRENT-DATE ( -- d m y ) TIME&DATE 2>R NIP NIP NIP 2R> ;
: CURRENT-TIME ( -- s m h ) TIME&DATE DROP DROP DROP ;

: (DO-LOG-TO-FILE) ( a u -- ) CURRENT-DATE RAW-LOG-FILE FORCE-PATH ATTACH-LINE-CATCH DROP ;

: AS-LOG-STR ( a u -- s )
   CURRENT-TIME { s m h }
   <# s #N## [CHAR] : HOLD m #N## [CHAR] : HOLD h #N## 0 0 #>
   " {s}|{s}" ;

0 VALUE last-convert
: minutes ( n -- secs ) 60 * ;
: hours ( n -- secs ) 60 minutes * ;
: days ( n -- secs ) 24 hours * ;

: CONVERT-LOGS ( -- )
    TIME&DATE DateTime>Num
    DUP last-convert - 2 hours < IF DROP EXIT THEN \ every two hours
    TO last-convert
    { | d m y }
    S" CONVERT-LOGS" log::info
    last-convert 1 days - Num>Date log2html
    last-convert Num>Date log2html
    30 2 DO
      last-convert I days - Num>Date -> y -> m -> d
      d m y RAW-LOG-FILE FILE-EXISTS IF
      d m y HTML-LOG-FILE FILE-EXISTS NOT IF
      y m d " will convert {n}/{n}/{n}" slog::info
      d m y log2html
      THEN
      THEN
    LOOP ;

: RAW-LOG CONVERT-LOGS AS-LOG-STR { s } s STR@ (DO-LOG-TO-FILE) s STRFREE ;

FALSE VALUE ?check

VOCABULARY BOT-COMMANDS
VOCABULARY BOT-COMMANDS-HELP
VOCABULARY BOT-COMMANDS-NOTFOUND

: HelpWords=> PRO [WID] BOT-COMMANDS-HELP NFA=> DUP COUNT CONT ;
: AllHelpWords ( -- s ) %[ START{ HelpWords=> >STR % }EMERGE ]% S"  " str-concat-with ;

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
    R@ STR@ " Available commands : {s} (Use '!info !<command>' for more info)." STR-REPLY
    R> STRFREE
    THEN ;

: !info !help ;

: !uptime gmtime start-time - Num>Time 24 /MOD " {n} days {n} hours {n} minutes {n} seconds" STR-REPLY ;

: !version
    OSNAME-STR { s }
    s STR@
    CVS-DATE
    CVS-REVISION
    " IRC bot in SP-Forth (http://spf.sf.net). Rev. {s} ({s}). OS: {s}" STR-REPLY
    s STRFREE
     ;

;MODULE

MODULE: BOT-COMMANDS-HELP

: !info S" If you want to understand recursion you should understand recursion first!" S-REPLY ;
: !version S" It is self-descriptive, man!" S-REPLY ;
: !uptime S" Bot uptime" S-REPLY ;

;MODULE

MODULE: BOT-COMMANDS-NOTFOUND
 : NOTFOUND
    nickname STR@ COMPARE-U 0= IF EXIT THEN \ игнорируем упоминания нашего никнейма
    -1 THROW ; \ иначе завершаем разбор строки
;MODULE

: CHECK-MSG-ME ( -- ? )
  current-msg-text nickname STR@ SEARCH NIP NIP 0= IF FALSE EXIT THEN
  S" Hello. I am a bot. Try !info. You can chat to me privately." S-REPLY
  TRUE ;

: CHECK-MSG-IGNORE ( -- ? ) current-msg-sender S" TiReX" COMPARE-U 0= ;

: CHECK-MSG-SPECIAL
   current-msg-text S" .." COMPARE 0= IF
      current-msg-sender " {s}, dont be so boring! Lets talk." STR-REPLY
      TRUE EXIT
   THEN
   FALSE ;

: CHECK-MSG ( -- ? )
   FALSE TO ?check

   `CHECK-MSG log::trace

   GET-ORDER
   ONLY BOT-COMMANDS
   ALSO BOT-COMMANDS-NOTFOUND
   current-msg-text " current msg : {s}" slog::trace
   current-msg-text ['] EVALUATE CATCH IF S" current msg failed (it is ok)" log::trace 2DROP THEN \ тут отваливание - нормальная ситуация
   SET-ORDER

   ?check ;

list::nil VALUE xt-on-privmsg
\ xt: ( -- ? )
\ ? - xt обработал сообщение, остановить обработку

: seconds 1000 * ;
: minutes 60 * seconds ;

\ -----------------------------------------------------------------------

MODULE: VOC-IRC-COMMAND

: PRIVMSG 
   S" PRIVMSG of bot" log::trace
   LAMBDA{
     CHECK-MSG-IGNORE IF EXIT THEN
     CHECK-MSG IF EXIT THEN
     CHECK-MSG-ME IF EXIT THEN
   } EXECUTE
   S" PRIVMSG of bot almost done" log::trace
;

: 433 BYE ; \ nickname already in use
: ERROR BYE ; \

;MODULE

\ -----------------------------------------------------------------------

..: AT-RECEIVE ( a u -- a u ) 2DUP RAW-LOG ;..
..: AT-CONNECT 0 SimpleReceiveTask START DROP LOGIN ;..

\ -----------------------------------------------------------------------

