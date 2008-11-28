S" spf.runet.forth.log" W/O CREATE-FILE-SHARED THROW TO H-STDLOG

S" ~ygrek/prog/web/irc/bot.f" INCLUDED
\ S" ~ygrek/prog/web/irc/plugins/rss.f" INCLUDED
\ S" ~ygrek/prog/web/irc/plugins/quotes.f" INCLUDED
\ S" ~ygrek/prog/web/irc/plugins/spf.f" INCLUDED
\ S" ~ygrek/prog/web/irc/plugins/bar.f" INCLUDED
\ S" ~ygrek/prog/web/irc/plugins/weather.f" INCLUDED
\ S" ~ygrek/prog/web/irc/plugins/httpreport.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/history.f" INCLUDED
\ S" ~ygrek/prog/web/irc/plugins/title.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/msg.f" INCLUDED

" exsample_" TO nickname
S" irc.run.net:6669" server!
S" localhost:9050" proxy!
\ S" " proxy!
CONNECT
/JOIN #forth
