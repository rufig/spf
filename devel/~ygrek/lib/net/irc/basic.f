\ $Id$
\ IRC messages parsing
\ See RFC-1459

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE BOUNDS ~ygrek/lib/string.f
REQUIRE /STRING lib/include/string.f
REQUIRE /GIVE ~ygrek/lib/parse.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f
REQUIRE 2VALUE ~ygrek/lib/2value.f
REQUIRE re_match? ~ygrek/lib/re/re.f
REQUIRE FINE-HEAD ~pinka/samples/2005/lib/split-white.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: IRC

0 0 2VALUE prefix
0 0 2VALUE command
0 0 2VALUE params
0 0 2VALUE trailing

: message-debug
   prefix CR ." - " TYPE
   command CR ." - " TYPE
   params CR ." - " TYPE
   trailing CR ." - " TYPE ;

\ -----------------------------------------------------------------------

EXPORT

: PARSE-IRC-MSG ( a u -- ? )
   RE" (:(\S+)\x20+)?(\S+)((\x20+[^: ][^ ]*)+)?(\x20+:(.*))?" re_match?
   2 get-group 2TO prefix
   3 get-group 2TO command
   5 get-group FINE-HEAD 2TO params
   7 get-group 2TO trailing ;

\ выделить ник из IRC контакта
: ClientName>Nick ( a u -- a1 u1 ) LAMBDA{ [CHAR] ! PARSE } EVALUATE-WITH ;

\ определить отправителя сообщения
: message-sender ( -- a u ) prefix ClientName>Nick ;

: message-text ( -- a u ) trailing ;

: irc-action? ( a u -- a u ? ) 
   RE" \x01ACTION\s(.*)\x01" re_match? IF 1 get-group TRUE ELSE 0 get-group FALSE THEN ;

\ получить контекст общения
\ если сообщение было направлено в канал - вернуть имя канала
\ если же соощение было направлено лично нам - вернуть имя отправителя
: message-target ( -- a u )
   params 1 MIN S" #" COMPARE 0= IF
    params
   ELSE \ private message
    message-sender
   THEN ;

;MODULE

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES basic IRC parsing

(( S" :irc.run.net 353 exsample = #forth :exsample mak4444 ygrek @TiReX" PARSE-IRC-MSG -> TRUE ))
(( S" :somebody!~user@example.com PRIVMSG exsample :!spf DROP" PARSE-IRC-MSG -> TRUE ))
(( :NONAME S" :somebody!~user@example.com JOIN :#forth" ; EXECUTE PARSE-IRC-MSG -> TRUE ))
message-sender S" somebody" TEST-ARRAY
IRC::command S" JOIN" TEST-ARRAY 
(( S" :ChanServ!service@RusNet MODE #forth +o ЗверюгА" PARSE-IRC-MSG -> TRUE ))
(( S" :irc.run.net PING" PARSE-IRC-MSG -> TRUE ))
(( S" PING" PARSE-IRC-MSG -> TRUE ))
(( S" PING :irc.run.net" PARSE-IRC-MSG -> TRUE ))

END-TESTCASES
