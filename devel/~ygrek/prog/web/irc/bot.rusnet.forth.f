\ ~ygrek/lib/debug/include.f
\ REQUIRE RTRACE ~ygrek/lib/debug/rtrace.f
\ : THROW DUP 0 <> IF RTRACE THEN THROW ;
\ lib/ext/disasm.f
S" ~ygrek/prog/web/irc/bot.f" INCLUDED

REQUIRE DateTime>Num ~ygrek/lib/spec/unixdate.f

\ Global logger configuration
MODULE: logger
:NONAME ( -- ? ) TRUE ; TO FILTER
:NONAME ( a u -- ) 
\  TIME&DATE DateTime>PAD TYPE 
  (( 0 )) times .
  DEPTH "  | DEPTH={n} " STYPE 
  level lvl_name " [{s}] " STYPE 
  gettid " {n} " STYPE
  ." | "
  TYPE CR ; TO LOG-WRITE
;MODULE

S" ~ygrek/prog/web/irc/plugins/rss.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/quotes.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/spf.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/bar.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/weather.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/httpreport.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/history.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/title.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/msg.f" INCLUDED

: start
\ SocketsStartup THROW
S" spf.runet.forth.log" W/O CREATE-FILE-SHARED THROW TO H-STDLOG
" exsample" TO nickname
"" TO password
" spf" TO username
" spf" TO realname
S" irc.run.net:6669" server!
\ S" localhost:9050" proxy!
S" " proxy!
['] CONNECT CATCH IF S" CONNECT FAILED" log::error EXIT THEN
S" #forth" S-JOIN 
\ BEGIN 10000 PAUSE AGAIN 
;

: save
['] start MAINX !
S" exsample" SAVE ;

\ S" exsample.exe" SAVE BYE

