REQUIRE MAKE-IRC-MSG ~ygrek/lib/net/irc/basic.f
REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE /STRING lib/include/string.f
REQUIRE /GIVE ~ygrek/lib/parse.f
REQUIRE ENUM ~ygrek/lib/enum.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f
REQUIRE domain:port ~ygrek/lib/net/domain.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE OCCUPY ~pinka/samples/2005/lib/append-file.f
REQUIRE RTRACE ~ygrek/lib/debug/rtrace.f
REQUIRE logger ~ygrek/lib/log.f
REQUIRE WITH-CRIT ~ygrek/lib/sys/critical.f
REQUIRE AsQName ~pinka/samples/2006/syntax/qname.f 
REQUIRE ConnectHost ~ygrek/lib/net/sockets.f
REQUIRE fsock ~ac/lib/win/winsock/PSOCKET.F
REQUIRE ConnectHostViaSocks5 ~ygrek/lib/net/socks/v5.f

[UNDEFINED] WINAPI: [IF]
REQUIRE TIMEZONE ~ygrek/lib/linux/timezone.f
[THEN]

\ MODULE: IRC-CONN

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
  \ server STRFREE
  domain:port TO port
  >STR TO server ;

: proxy! ( a u -- )
  \ proxy STRFREE
  domain:port TO proxy-port
  >STR TO proxy ;

: current! ( s -- ) TO _current ;
: current-channel _current STR@ ;

TRUE VALUE ?LOGSEND
FALSE VALUE ?LOGSAY
TRUE VALUE ?LOGMSG

: ?IOR ( ior -- ) ?DUP IF ." ior = " . CR RTRACE THEN ;

\ --------------------------------------------------------

MODULE: IRC-CONN

0 VALUE socketline \ соединение с IRC сервером
CREATE-CRIT lock

\ : BAD CR TYPE RTRACE ABORT ;
\ : (BAD) ROT IF BAD ELSE 2DROP THEN ;
\ : BAD" [CHAR] " PARSE POSTPONE SLITERAL POSTPONE (BAD) ; IMMEDIATE

EXPORT

: irc-send ( a u -- )
   ?LOGSEND IF 2DUP " irc-send : {s}" slog::trace THEN
   LAMBDA{ socketline fsock WriteSocketLine THROW } lock WITH-CRIT-CATCH ?IOR ;

: irc-str-send ( s -- ) DUP STR@ irc-send STRFREE ;

;MODULE

VECT ON-RECEIVE ( a u -- )
' 2DROP TO ON-RECEIVE

: fgets-catch ( sl -- s -1 | 0 ) ['] fgets CATCH IF DROP FALSE ELSE TRUE THEN ;

: AT-RECEIVE ... ;

\ FALSE - connection failed
: (RECEIVE) ( -- ? )
   S" (RECEIVE)" log::trace
   IRC-CONN::socketline fgets-catch 0= IF FALSE EXIT THEN 
   { s }
   s STR@ AT-RECEIVE 2DROP
   s STR@ " (RECEIVE) : {s}" slog::trace
   s STR@ ['] ON-RECEIVE CATCH IF 2DROP S" Received data processing failed!" log::warn THEN
   S" (RECEIVE) done" log::trace
   s STRFREE 
   TRUE ;

:NONAME ( x -- )
  DROP
  BEGIN
   (RECEIVE) FALSE = IF S" CONNECTION FAILED. EXITING..." log::info BYE THEN
  AGAIN
  ; TASK: SimpleReceiveTask

: AT-LOGIN ... ;

: LOGIN
  password STRLEN IF password STR@ " PASS {s}" irc-str-send THEN
  nickname STR@ " NICK {s}" irc-str-send
  " USER {username STR@} 8 * : {realname STR@}" irc-str-send
  AT-LOGIN ;

: AT-CONNECT ... ;

: CONNECT
  server STR@ " {s}" current!
  server STR@ port
  proxy STR@ proxy-port
  ConnectHostViaSocks5 THROW SocketLine IRC-CONN::TO socketline

  AT-CONNECT ;

: SAY-MSG ( a u a1 u1 a2 u2 -- )
   ?LOGSAY IF 2>R 2OVER 2OVER nickname STR@ " {s} ({s}): {s}" slog::trace 2R> THEN
   " {s} {s} :{s}" irc-str-send ;

0 VALUE current-msg

: current-msg-text current-msg irc-msg-text ;
: current-msg-sender current-msg irc-msg-sender ;
: current-msg-target current-msg irc-msg-target ;

: S-SAY-TO ( a u target u2 -- ) `PRIVMSG SAY-MSG ;
: S-NOTICE-TO ( text-a u1 target-a u2 -- ) `NOTICE SAY-MSG ;
: S-SAY ( a u -- ) current-channel S-SAY-TO ;
\ ответить в контекст общения
: S-REPLY ( a u -- ) current-msg-target S-SAY-TO ;
\ ответить в контекст общения нотисом
: S-NOTICE-REPLY ( a u -- ) current-msg-target S-NOTICE-TO ;

: STR-SAY DUP STR@ S-SAY STRFREE ;
: STR-REPLY DUP STR@ S-REPLY STRFREE ;
: STR-SAY-TO { s a u -- } s STR@ a u S-SAY-TO s STRFREE ;

: S-JOIN ( a u -- ) 2DUP >STR current! " JOIN {s}" irc-str-send ;
: S-QUIT ( a u -- ) " QUIT :{s}" irc-str-send ;

: COMMAND: ( "name" -- )
   PARSE-NAME 2DUP " : /{s} -1 PARSE S-{s} ;" DUP STR@ EVALUATE STRFREE ;

COMMAND: JOIN 
COMMAND: SAY 
COMMAND: QUIT

: PONG ( a u -- ) " PONG {s}" irc-str-send ;

: SHOW-MSG current-msg-text current-msg-sender " {s}: {s}" STYPE CR ;

: AT-CLOSE ... ;

: CLOSE ( -- )
    S" CLOSE" log::trace
    S" Need hot code reload." S-QUIT
    IRC-CONN::socketline fclose

    AT-CLOSE
    S" CLOSE DONE" log::trace ;

\ -----------------------------------------------------------------------

MODULE: VOC-IRC-COMMAND

: PRIVMSG SHOW-MSG ;
: PING current-msg-text ( servername ) PONG ;

;MODULE

MODULE: VOC-IRC-COMMAND-NOTFOUND

: NOTFOUND ( a u -- )
  " VOC-IRC-COMMAND-NOTFOUND {s}" slog::trace
  -1 THROW ;

;MODULE

\ -----------------------------------------------------------------------

\ ..: AT-RECEIVE 2DUP TYPE ;..

: DEFAULT-ON-RECEIVE ( a u -- )
   S" DEFAULT-ON-RECEIVE" log::trace
   MAKE-IRC-MSG 0= IF FREE-IRC-MSG " BAD MESSAGE : {s}" slog::warn EXIT THEN
   { msg }

   msg TO current-msg
   GET-ORDER
   ONLY VOC-IRC-COMMAND
   ALSO VOC-IRC-COMMAND-NOTFOUND
   msg irc-msg-cmd
   2DUP " EVALUATE goes : {s}" slog::trace
   ( a u ) ['] EVALUATE CATCH IF 2DROP THEN
   S" EVALUATE done" log::trace
   SET-ORDER
   0 TO current-msg
   msg FREE-IRC-MSG 
   S" DEFAULT-ON-RECEIVE done" log::trace ;

' DEFAULT-ON-RECEIVE TO ON-RECEIVE

\ -----------------------------------------------------------------------

\ ;MODULE

/TEST

SocketsStartup THROW

: test
\ StartTrace
  " spfirc" TO nickname
  S" irc.run.net:6669" server!
\  S" localhost:9050" proxy!
S" " proxy!
  CONNECT
  0 SimpleReceiveTask START DROP
  LOGIN

  S" #spf" S-JOIN
 ;
