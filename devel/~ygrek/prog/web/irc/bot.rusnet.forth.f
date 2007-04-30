S" spf.runet.forth.log" W/O CREATE-FILE-SHARED THROW TO H-STDLOG

S" ~ygrek/prog/web/irc/bot.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/rss.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/quotes.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/spf.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/bar.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/weather.f" INCLUDED

" exsample" TO nickname
S" irc.run.net:6669" server!
S" localhost:9050" proxy!
CONNECT

/JOIN #forth
" #forth" current!
