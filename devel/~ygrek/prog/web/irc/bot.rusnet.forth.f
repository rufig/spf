S" ~ygrek/prog/web/irc/bot.f" INCLUDED

\ HERE S" quotes.txt" S", COUNT 2TO quotes-file
: aaa S" quotes.txt" ; aaa 2TO quotes-file

SocketsStartup THROW
load-quotes

" exsample" TO nickname
S" irc.run.net:6669" server!
CONNECT

/JOIN #forth
" #forth" current!
