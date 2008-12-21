\ $Id$
\ Отчёт о количестве собеседников на канале

REQUIRE CURLOPT! ~ac/lib/lin/curl/curlopt.f
REQUIRE AT-NAMES-UPDATED ~ygrek/prog/web/irc/plugins/names.f

MODULE: bot_plugin_httpreport

: report-url ( nu tt -- s ) " http://fforum.winglion.ru/irc_out.php?tt={n}&nu={n}" ;

TIME&DATE DateTime>Num VALUE last-message-stamp

: sHTTP-REQUEST-DROP ( s -- )
   DUP STR@ " HTTP GET {s}" slog::trace
   30 CURLOPT_TIMEOUT CURLOPT!
   DUP STR@ GET-FILE STRFREE
       STRFREE ;

: REPORT-NAMES1 ( n -- )
   last-message-stamp TIME&DATE DateTime>Num - ABS report-url sHTTP-REQUEST-DROP ;

: REPORT-NAMES ( l -- )
    list::length ['] REPORT-NAMES1 CATCH IF S" REPORT-NAMES ERROR" log::warn DROP THEN ;

EXPORT

..: AT-NAMES-UPDATED DUP REPORT-NAMES ;..

\ -----------------------------------------------------------------------

MODULE: VOC-IRC-COMMAND

: PRIVMSG
   PRIVMSG
   TIME&DATE DateTime>Num TO last-message-stamp ;

;MODULE

\ -----------------------------------------------------------------------

..: AT-CLOSE -1 -1 report-url sHTTP-REQUEST-DROP ;..

;MODULE

$Revision$ " -- HTTP-report plugin {s} loaded." STYPE CR

\ -----------------------------------------------------------------------

\EOF
