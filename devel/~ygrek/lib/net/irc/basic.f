REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE ToRead ~ac/lib/win/winsock/psocket.f
REQUIRE STR@ ~ac/lib/str4.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE /STRING lib/include/string.f
REQUIRE /GIVE ~ygrek/lib/parse.f
REQUIRE ENUM ~ygrek/lib/enum.f
REQUIRE split ~profit/lib/bac4th-str.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f
REQUIRE ConnectHostViaSocks5 ~ygrek/lib/net/socks/v5.f
REQUIRE 2VALUE ~ygrek/lib/2value.f
REQUIRE domain:port ~ygrek/lib/net/domain.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f

CREATE IRC-BASIC

\ MODULE: IRC

\ default values for user tweakable parameters
" irc.run.net" VALUE server
6669 VALUE port
" spf" VALUE username
" ~ygrek/lib/net/irc/basic.f" VALUE realname
" spf" VALUE nickname
"" VALUE password
" #forth" VALUE _current \ активный канал
"" VALUE proxy \ SOCKS5 proxy " domain:port"
0 VALUE proxy-port

: server! ( a u -- )
  server STRFREE
  domain:port TO port
  " {s}" TO server ;

: proxy! ( a u -- )
  proxy STRFREE
  domain:port TO proxy-port
  " {s}" TO proxy ;

\ --------------------------------------------------------

0 VALUE lsocket \ соединение с IRC сервером

TRUE VALUE ?LOGSEND
TRUE VALUE ?LOGSAY
TRUE VALUE ?LOGMSG

\ --------------------------------------------------------

: ECHO ( a u -- ) TYPE CR ;

: S= COMPARE 0= ;
: S<> COMPARE ;
: US= COMPARE-U 0= ;
: US<> COMPARE-U ;

VECT DO-CMD

: SIMPLE-DO-CMD lsocket WriteSocketLine IF S" WriteSocket failed" ECHO -1 THROW THEN ;

' SIMPLE-DO-CMD TO DO-CMD

: CMD ( a u -- )
  ?LOGSEND IF 2DUP ." > " ECHO THEN
  DO-CMD ;

: sCMD ( s -- ) STR@ CMD ;

: SocketStatus ( s -- ) 
    ToRead IF DROP S" Error." EXIT THEN
    " Ready. {n} bytes" STR@ ;

: DataPending ( -- u ) lsocket ToRead IF S" ToRead failed!" ECHO -1 THROW THEN ;

: .S ." DEPTH = " DEPTH . DEPTH 100 > IF EXIT THEN .S ;

: ReceiveData ( -- a u )
    DataPending
    DUP ALLOCATE THROW >R
    R@ SWAP lsocket ReadSocket THROW
    R> SWAP ;

VECT ON-RECEIVE ( a u -- )
' 2DROP TO ON-RECEIVE

WINAPI: GetTickCount KERNEL32.DLL

: RECEIVED ( a u -- )
    byRows split notEmpty 
    DUP STR@ 
    ON-RECEIVE ;

: (RECEIVE) ( -- )
    BEGIN 
     10 PAUSE
     DataPending
    UNTIL
    ReceiveData
  
    \ 2DUP GetTickCount " {n}.dat" STR@ OCCUPY LSTRFREE

    2DUP ['] RECEIVED CATCH IF 2DROP CR S" Received data processing failed!" ECHO THEN

    DROP FREE IF S" FREE Failed" ECHO THEN
   ;

: S-JOIN ( a u -- ) " JOIN {s}" DUP sCMD STRFREE ; 
: S-QUIT ( a u -- ) " QUIT :{s}" DUP sCMD STRFREE ;

:NONAME ( x -- )
  DROP
  BEGIN 
   ['] (RECEIVE) IF EXIT THEN 
  AGAIN 
  ; TASK: SimpleReceiveTask

: AT-LOGIN ... ;

: LOGIN
  password STR@ NIP IF " PASS {password STR@}" DUP sCMD STRFREE THEN
  " NICK {nickname STR@}" DUP sCMD STRFREE
  " USER {username STR@} 8 * : {realname STR@}" DUP sCMD STRFREE 
  AT-LOGIN ;

: AT-CONNECT ... ;

: CONNECT
  server STR@ port
  proxy STR@ proxy-port
  ConnectHostViaSocks5 THROW TO lsocket

  AT-CONNECT ;

: CLOSE ( -- )
    S" Need hot code reload." S-QUIT
    lsocket CloseSocket THROW ;

: current! ( s -- ) TO _current ;
: current-channel _current STR@ ;

: S-SAY-TO ( a u a1 u1 -- ) 
   ?LOGSAY IF 2OVER 2OVER nickname STR@ " {s} ({s}): {s}" DUP STR@ ECHO STRFREE THEN
   " PRIVMSG {s} :{s}" DUP sCMD STRFREE ;
: S-SAY ( a u -- ) current-channel S-SAY-TO ;

: S-NOTICE-TO ( text-au targer-au -- )
   ?LOGSAY IF 2OVER 2OVER nickname STR@ " {s} ({s}): {s}" DUP STR@ ECHO STRFREE THEN
   " NOTICE {s} :{s}" DUP sCMD STRFREE ;

\ -----------------------------------------------------------------------

\ parsing replies

0 0 2VALUE prefix
0 0 2VALUE command
0 VALUE #command
0 0 2VALUE params
0 0 2VALUE trailing

: params-trailing ( a u -- a1 u1 a2 u2 )
   LAMBDA{
    BEGIN
     SkipDelimiters 
     PeekChar [CHAR] : = IF SOURCE >IN @ /GIVE -TRAILING 2SWAP 1 /STRING EXIT THEN
     PARSE-NAME NIP 0=
    UNTIL
    SOURCE 0 0
   } EVALUATE-WITH ;

: (PARSE-IRC-LINE) ( -- prefix-au command-au #command params-au trailing-au )
   PeekChar [CHAR] : = IF PARSE-NAME 1 /STRING ELSE 0 0 THEN

   PARSE-NAME
   2DUP NUMBER IF ( n ) ELSE 0 THEN

   SkipDelimiters
   -1 PARSE 
   params-trailing ;

: PARSE-IRC-LINE ( a u -- )
   ['] (PARSE-IRC-LINE) EVALUATE-WITH
   2TO trailing
   2TO params
   TO #command
   2TO command
   2TO prefix ;

: msginfo
   CR 
   ." prefix - " prefix ECHO
   ." command ( " #command . ." ) - " command ECHO
   ." params - " params ECHO
   ." trailing - " trailing ECHO ;

\ выделить ник из IRC контакта
: ClientName>Nick ( a u -- a1 u1 ) LAMBDA{ [CHAR] ! PARSE } EVALUATE-WITH ;

\ определить отправителя сообщения
: message-sender ( -- a u ) prefix ClientName>Nick ;

: message-text ( -- a u ) trailing ;

\ получить контекст общения 
\ если сообщение было направлено в канал - вернуть имя канала
\ если же соощение было направлено лично нам - вернуть имя отправителя
: message-target ( -- a u )
   params nickname STR@ US= IF \ private message
     message-sender
   ELSE
     params
   THEN ;

\ ответить в контекст общения
: S-REPLY ( a u -- ) message-target S-SAY-TO ;

\ ответить в контекст общения нотисом
: S-NOTICE-REPLY ( a u -- ) message-target S-NOTICE-TO ;

: COMMAND? ( a u -- ? ) command US= ;

: PING-COMMAND? ( -- ? ) S" PING" COMMAND? ;
: PRIVMSG-COMMAND? ( -- ? ) S" PRIVMSG" COMMAND? ;

: PONG trailing " PONG {s}" sCMD ;

: SHOW-MSG trailing prefix " {s}: {s}" STR@ ECHO ;

: DEFAULT-ON-RECEIVE ( a u -- )
   2DUP 
   PARSE-IRC-LINE
   LAMBDA{
    ?LOGMSG IF 2DUP ECHO THEN
    PING-COMMAND? IF PONG EXIT THEN
    PRIVMSG-COMMAND? IF SHOW-MSG EXIT THEN
    ?LOGMSG 0= IF 2DUP ECHO THEN
   }
   EXECUTE
   2DROP ;

' DEFAULT-ON-RECEIVE TO ON-RECEIVE

: COMMAND: ( "name" -- )
   PARSE-NAME 2DUP " : /{s} -1 PARSE S-{s} ;" STR@ EVALUATE LSTRFREE ;

' COMMAND: ENUM COMMANDS:

COMMANDS: JOIN SAY QUIT ;

\ ;MODULE

/TEST

SocketsStartup THROW

: test
  " test" TO nickname
  S" irc.freenode.net:6667" server!
  CONNECT
  0 SimpleReceiveTask START DROP
  LOGIN
  
  S" #spf" S-JOIN
  " #spf" current! ;
