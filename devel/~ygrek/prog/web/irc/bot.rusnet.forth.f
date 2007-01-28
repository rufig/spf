S" spf.runet.log" W/O CREATE-FILE-SHARED THROW TO H-STDLOG

S" ~ygrek/prog/web/irc/bot.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/rss.f" INCLUDED
S" ~ygrek/prog/web/irc/plugins/quotes.f" INCLUDED

\ HERE S" quotes.txt" S", COUNT 2TO quotes-file
\ : aaa S" quotes.txt" ; aaa 2TO quotes-file

" exsample" TO nickname
S" irc.run.net:6669" server!
CONNECT

/JOIN #forth
" #forth" current!
