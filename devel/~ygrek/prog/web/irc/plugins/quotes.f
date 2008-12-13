REQUIRE quotes ~ygrek/prog/web/irc/quotes.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f

MODULE: BOT-COMMANDS

: !q
    SkipDelimiters
    -1 PARSE DUP 0= IF
     2DROP random-quote
    ELSE
     2DUP NUMBER IF >R 2DROP R> quote[] ELSE search-quote THEN
    THEN
    STR@ S-REPLY
    TRUE TO ?check ;

: !aq
    SkipDelimiters
    -1 PARSE DUP 0= IF 2DROP S" Try !info !aq" S-REPLY EXIT THEN
    2DUP current-msg-sender " Adding quote from {s}: {s}" slog::trace
    ( a u ) current-msg-sender register-quote
    quotes-total 1- current-msg-sender " {s}: Quote {n} added. Thanks." DUP STR@ S-REPLY STRFREE
    TRUE TO ?check ;

;MODULE

MODULE: BOT-COMMANDS-HELP
: !q S" usage: !q - random quote. !q <keyword> - quote with keyword. !q <number> - quote by number." S-REPLY ;
: !aq S" usage: !aq <quote> - add quote to the database" S-REPLY ;
;MODULE

..: AT-CONNECT load-quotes ;..

$Revision$ " -- Quotes plugin {s} loaded." STYPE CR

\ -----------------------------------------------------------------------

\EOF
