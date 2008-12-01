\ $Id$
\ IRC messages parsing
\ See RFC-1459

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE /STRING lib/include/string.f
REQUIRE /GIVE ~ygrek/lib/parse.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f
REQUIRE re_match? ~ygrek/lib/re/re.f
REQUIRE FINE-HEAD ~pinka/samples/2005/lib/split-white.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE ALLOCATED ~pinka/lib/ext/basics.f

MODULE: IRC

0
CELL -- .prefix
CELL -- .cmd
CELL -- .params
CELL -- .trail
CONSTANT /MSG

: :prefix ( msg -- a u ) .prefix @ STR@ ;
: :cmd ( msg -- a u ) .cmd @ STR@ ;
: :params ( msg -- a u ) .params @ STR@ ;
: :trail ( msg -- a u ) .trail @ STR@ ;

: message-debug { msg -- }
   msg :prefix CR ." - " TYPE
   msg :cmd CR ." - " TYPE
   msg :params CR ." - " TYPE
   msg :trail CR ." - " TYPE ;

\ -----------------------------------------------------------------------

EXPORT

: MAKE-IRC-MSG ( a u -- msg ? )
   RE" (:(\S+)\x20+)?(\S+)((\x20+[^: ][^ ]*)+)?(\x20+:(.*))?" re_match?
   /MSG ALLOCATED DROP >R
   2 get-group >STR R@ .prefix !
   3 get-group >STR R@ .cmd !
   5 get-group FINE-HEAD >STR R@ .params !
   7 get-group >STR R@ .trail ! 
   R> SWAP ;

: FREE-IRC-MSG { msg -- }
  msg .prefix @ STRFREE
  msg .cmd @ STRFREE
  msg .params @ STRFREE
  msg .trail @ STRFREE
  msg FREE THROW ;   

\ выделить ник из IRC контакта
: ClientName>Nick ( a u -- a1 u1 ) LAMBDA{ [CHAR] ! PARSE } EVALUATE-WITH ;

\ определить отправителя сообщения
: irc-msg-sender ( msg -- a u ) :prefix ClientName>Nick ;
: irc-msg-text ( msg -- a u ) :trail ;
: irc-msg-cmd ( nsg -- a u ) :cmd ;

: irc-action? ( a u -- a u ? ) 
   RE" \x01ACTION\s(.*)\x01" re_match? IF 1 get-group TRUE ELSE 0 get-group FALSE THEN ;

\ получить контекст общения
\ если сообщение было направлено в канал - вернуть имя канала
\ если же соощение было направлено лично нам - вернуть имя отправителя
: irc-msg-target { msg -- a u }
   msg :params 1 MIN S" #" COMPARE 0= IF
    msg :params
   ELSE \ private message
    msg irc-msg-sender
   THEN ;

;MODULE

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES basic IRC parsing

: PARSE-IRC-MSG MAKE-IRC-MSG SWAP FREE-IRC-MSG ;

0 VALUE msg

(( S" :irc.run.net 353 exsample = #forth :exsample mak4444 ygrek @TiReX" MAKE-IRC-MSG 
   SWAP TO msg -> TRUE ))
msg irc-msg-sender S" irc.run.net" TEST-ARRAY
msg FREE-IRC-MSG
(( S" :somebody!~user@example.com PRIVMSG exsample :!spf DROP" PARSE-IRC-MSG -> TRUE ))
(( S" :somebody!~user@example.com JOIN :#forth" MAKE-IRC-MSG SWAP TO msg -> TRUE ))
msg irc-msg-sender S" somebody" TEST-ARRAY
msg irc-msg-cmd S" JOIN" TEST-ARRAY
msg FREE-IRC-MSG
(( S" :ChanServ!service@RusNet MODE #forth +o ЗверюгА" PARSE-IRC-MSG -> TRUE ))
(( S" :irc.run.net PING" PARSE-IRC-MSG -> TRUE ))
(( S" PING" PARSE-IRC-MSG -> TRUE ))
(( S" PING :irc.run.net" PARSE-IRC-MSG -> TRUE ))

END-TESTCASES
