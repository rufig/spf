REQUIRE PARSE-IRC-MSG ~ygrek/lib/net/irc/basic.f
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
REQUIRE RTRACE ~ygrek/lib/debug/rtrace.f

\ MODULE: IRC-CONN

WINAPI: GetTickCount KERNEL32.DLL

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

: current! ( s -- ) TO _current ;
: current-channel _current STR@ ;

\ --------------------------------------------------------

0 VALUE socketline \ соединение с IRC сервером

: lsock socketline sl_socket @ ;

TRUE VALUE ?LOGSEND
FALSE VALUE ?LOGSAY
TRUE VALUE ?LOGMSG

\ --------------------------------------------------------

: ECHO ( a u -- ) TYPE CR ;

: BAD CR TYPE RTRACE ABORT ;
: (BAD) ROT IF BAD ELSE 2DROP THEN ;
: BAD" [CHAR] " PARSE POSTPONE SLITERAL POSTPONE (BAD) ; IMMEDIATE

: CMD ( a u -- )
  ?LOGSEND IF 2DUP ." > " ECHO THEN
  lsock WriteSocketLine BAD" WriteSocket failed" ;

: SCMD ( s -- ) DUP STR@ CMD STRFREE ;
: DataPending ( sock -- u ) ToRead BAD" ToRead failed!" ;

VECT ON-RECEIVE ( a u -- )
' 2DROP TO ON-RECEIVE

: (RECEIVE) ( -- )
   BEGIN
    lsock DataPending
    10 PAUSE
   UNTIL
   socketline fgets { s }
   \ CR ." RECEIVED : " s STR@ TYPE
   s STR@ ['] ON-RECEIVE CATCH IF 2DROP " Received data processing failed!" ECHO ABORT THEN
   s STRFREE ;


:NONAME ( x -- )
  DROP
  BEGIN
   ['] (RECEIVE) CATCH IF CR ." ERROR IN RECEIVE. EXITING..." BYE THEN
  AGAIN
  ; TASK: SimpleReceiveTask

: AT-LOGIN ... ;

: LOGIN
  password STR@ NIP IF " PASS {password STR@}" SCMD THEN
  " NICK {nickname STR@}" SCMD
  " USER {username STR@} 8 * : {realname STR@}" SCMD
  AT-LOGIN ;

: AT-CONNECT ... ;

: CONNECT
  server STR@ " {s}" current!
  server STR@ port
  proxy STR@ proxy-port
  ConnectHostViaSocks5 THROW SocketLine TO socketline

  AT-CONNECT ;

: SAY-MSG ( a u a1 u1 a2 u2 -- )
   ?LOGSAY IF 2>R 2OVER 2OVER nickname STR@ " {s} ({s}): {s}" DUP STR@ ECHO STRFREE 2R> THEN
   " {s} {s} :{s}" SCMD ;

: S-SAY-TO S" PRIVMSG" SAY-MSG ;
: S-NOTICE-TO ( text-a u1 target-a u2 -- ) S" NOTICE" SAY-MSG ;
: S-SAY ( a u -- ) current-channel S-SAY-TO ;
\ ответить в контекст общения
: S-REPLY ( a u -- ) message-target S-SAY-TO ;
\ ответить в контекст общения нотисом
: S-NOTICE-REPLY ( a u -- ) message-target S-NOTICE-TO ;

: S-JOIN ( a u -- ) 2DUP " {s}" current! " JOIN {s}" SCMD ;
: S-QUIT ( a u -- ) " QUIT :{s}" SCMD ;

: COMMAND: ( "name" -- )
   PARSE-NAME 2DUP " : /{s} -1 PARSE S-{s} ;" DUP STR@ EVALUATE STRFREE ;

' COMMAND: ENUM: JOIN SAY QUIT ;

: PONG ( a u -- ) " PONG {s}" SCMD ;

: SHOW-MSG message-text message-sender " {s}: {s}" DUP STR@ ECHO STRFREE ;

: AT-CLOSE ... ;

: CLOSE ( -- )
    S" Need hot code reload." S-QUIT
    lsock CloseSocket THROW

    AT-CLOSE ;

\ -----------------------------------------------------------------------

MODULE: VOC-IRC-COMMAND

: PRIVMSG SHOW-MSG ;
: PING message-text ( servername ) PONG ;
: 353 S" NAMREPLY" EVALUATE ;
: 366 S" ENDOFNAMES" EVALUATE ;

;MODULE

MODULE: VOC-IRC-COMMAND-NOTFOUND

: NOTFOUND 2DROP -1 THROW ;

;MODULE

\ -----------------------------------------------------------------------

: AT-RECEIVE ( a u -- a u ) ... ;

: DEFAULT-ON-RECEIVE ( a u -- )
   2DUP PARSE-IRC-MSG 0= IF CR ." BAD MESSAGE : " TYPE EXIT THEN
   ( a u ) AT-RECEIVE ( a u )
   2DROP

   GET-ORDER
   ONLY VOC-IRC-COMMAND
   ALSO VOC-IRC-COMMAND-NOTFOUND
   IRC::command ['] EVALUATE CATCH IF 2DROP THEN
   SET-ORDER ;

' DEFAULT-ON-RECEIVE TO ON-RECEIVE

\ -----------------------------------------------------------------------

\ ;MODULE

/TEST

SocketsStartup THROW

: test
\ StartTrace
  " spfirc" TO nickname
  S" irc.run.net:6669" server!
  S" localhost:9050" proxy!
  CONNECT
  0 SimpleReceiveTask START DROP
  LOGIN

  S" #spf" S-JOIN
 ;
