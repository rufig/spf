REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE ToRead ~ac/lib/win/winsock/psocket.f
REQUIRE STR@ ~ac/lib/str4.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE /STRING lib/include/string.f
REQUIRE /GIVE ~ygrek/lib/parse.f
\ REQUIRE EVALUATE, ~profit/lib/evaluated.f
REQUIRE ENUM ~ygrek/lib/enum.f
REQUIRE split ~profit/lib/bac4th-str.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f
REQUIRE ConnectHostViaProxy ~ygrek/lib/net/socks/v5.f
REQUIRE 2VALUE ~ygrek/lib/2value.f
REQUIRE domain:port ~ygrek/lib/net/domain.f

' ACCEPT1 TO ACCEPT \ disable autocompletion - hacky

' ANSI>OEM TO ANSI><OEM \ cp1251

\ STARTLOG

CREATE IRC-BASIC

\ MODULE: IRC

THREAD-HEAP @ VALUE PROCESS-HEAP \ dont bother with thread memory, use global, i.e. this heap

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

: server! 
  server STRFREE
  domain:port TO port
  " {s}" TO server ;

: proxy!
  proxy STRFREE
  domain:port TO proxy-port
  " {s}" TO proxy ;

\ --------------------------------------------------------

0 VALUE lsocket \ socket for IRC comms
0 VALUE hReceiveTask \ хэндл потока приёма

TRUE VALUE ?LOGSEND
TRUE VALUE ?LOGSAY
TRUE VALUE ?LOGMSG

\ --------------------------------------------------------

: ECHO ( a u -- ) TYPE CR ;

: S= COMPARE 0= ;
: S<> COMPARE ;
: US= COMPARE-U 0= ;
: US<> COMPARE-U ;

: CMD ( a u -- )
  ?LOGSEND IF 2DUP ." > " ECHO THEN
  lsocket WriteSocketLine IF S" WriteSocket failed" ECHO ABORT THEN ;

: sCMD ( s -- ) STR@ CMD ;

: SocketStatus ( s -- ) 
    ToRead IF DROP S" Error." EXIT THEN
    " Ready. {n} bytes" STR@ ;

: DataPending ( -- u ) lsocket ToRead IF S" ToRead failed!" ECHO ABORT THEN ;

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

:NONAME ( x -- )
  DROP
  PROCESS-HEAP THREAD-HEAP !

  BEGIN

  LAMBDA{
    BEGIN 
     10 PAUSE
     DataPending
    UNTIL
    ReceiveData } CATCH IF CR CR S" Receive failed!" ECHO TERMINATE EXIT THEN
  
   (
   CR
   GetTickCount .
   ."  RCV "
   2DUP SWAP . .
   CR)

   \ 2DUP GetTickCount " {n}.dat" STR@ ATTACH-CATCH DROP LSTRFREE

   2DUP ['] RECEIVED CATCH IF 2DROP CR S" Received data processing failed!" ECHO THEN

   DROP FREE IF S" FREE Failed" ECHO THEN

   AGAIN ; TASK: ReceiveTask

: S-JOIN ( a u -- ) " JOIN {s}" DUP sCMD STRFREE ; 
: S-QUIT ( a u -- ) " QUIT :{s}" DUP sCMD STRFREE ;

: ON-CONNECT ... ;

: CONNECT

  SocketsStartup THROW

  server STR@ port
  proxy STR@ proxy-port
  SOCKS5::ConnectHostViaProxy THROW TO lsocket

  0 ReceiveTask START TO hReceiveTask

  password STR@ NIP IF " PASS {password STR@}" DUP sCMD STRFREE THEN
  " NICK {nickname STR@}" DUP sCMD STRFREE
  " USER {username STR@} 8 * : {realname STR@}" DUP sCMD STRFREE 
  ON-CONNECT ;

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
   } EVALUATE-WITH
;

: (PARSE-REPLY) ( -- prefix-au command-au #command params-au trailing-au )
   PeekChar [CHAR] : = IF PARSE-NAME 1 /STRING ELSE 0 0 THEN

   PARSE-NAME
   2DUP NUMBER IF ( n ) ELSE 0 THEN

   SkipDelimiters
   -1 PARSE 
   params-trailing ;

: PARSE-REPLY ( a u -- )
   ['] (PARSE-REPLY) EVALUATE-WITH 
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

: ClientName>Nick ( a u -- a1 u1 ) LAMBDA{ [CHAR] ! PARSE } EVALUATE-WITH ;
: determine-sender prefix ClientName>Nick ;

: determine-target ( -- a u )
   params nickname STR@ US= IF \ private message
     determine-sender
   ELSE
     params
   THEN ;

: S-REPLY ( a u -- ) determine-target S-SAY-TO ;

: ?PING command S" PING" US= ;
: ?PRIVMSG command S" PRIVMSG" US= ;

: PONG trailing " PONG {s}" sCMD ;

: SHOW-MSG trailing prefix " {s}: {s}" STR@ ECHO ;

: DEFAULT-ON-RECEIVE ( a u -- )
   2DUP 
   PARSE-REPLY
   LAMBDA{
    ?LOGMSG IF 2DUP ECHO THEN
    ?PING IF PONG EXIT THEN
    ?PRIVMSG IF SHOW-MSG EXIT THEN
    ?LOGMSG 0= IF 2DUP ECHO THEN
   }
   EXECUTE
   2DROP ;

' DEFAULT-ON-RECEIVE TO ON-RECEIVE

: COMMAND: 
   NextWord 
   2DUP " : /{s} -1 PARSE S-{s} ;" STR@ EVALUATE LSTRFREE ;

' COMMAND: ENUM COMMANDS:

COMMANDS: JOIN SAY QUIT ;

\ ;MODULE

\ SocketsStartup THROW
