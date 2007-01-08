REQUIRE IRC-BASIC ~ygrek/lib/net/irc/basic.f

SocketsStartup THROW

" somebody" TO nickname
\ S" irc.run.net:6669" server!
S" irc.freenode.net:6667" server!
CONNECT

/JOIN #forth
" #forth" current!
