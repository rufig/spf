\ ~ygrek/lib/debug/include.f
REQUIRE LINUX-CONSTANTS lib/posix/const.f
REQUIRE module-((-fix ~ygrek/lib/linux/ffi.f

S" bot.rusnet.forth.lock" W/O CREATE-FILE DROP VALUE lock
:NONAME (( lock F_TLOCK 0 )) lockf IF BYE THEN ; EXECUTE

\ REQUIRE RTRACE ~ygrek/lib/debug/rtrace.f
\ : THROW DUP 0 <> IF RTRACE THEN THROW ;
\ lib/ext/disasm.f
S" ~ygrek/prog/web/irc/bot.f" INCLUDED

REQUIRE DateTime>Num ~ygrek/lib/spec/unixdate.f

\ Global logger configuration
{{ logger
:NONAME ( a u -- )
  TIME&DATE DateTime>PAD TYPE
\  (( 0 )) times .
  DEPTH "  | DEPTH={n} " STYPE
  level " [{s}] " STYPE
  gettid " {n} " STYPE
  ." | "
  TYPE CR ; TO LOG-TYPE
}}

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
\ ['] CONNECT CATCH IF S" CONNECT FAILED" log::error EXIT THEN
CONNECT
S" #forth" S-JOIN
BEGIN 10000 PAUSE AGAIN
;

: save
['] start MAINX !
S" exsample" SAVE ;

\ S" exsample.exe" SAVE BYE

