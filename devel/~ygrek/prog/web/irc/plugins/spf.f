REQUIRE get-info ~ygrek/prog/web/irc/xmlhelpdb.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f

MODULE: BOT-COMMANDS

: !spf
    SkipDelimiters
    -1 PARSE DUP 0= IF 2DROP S" Try !help !spf" determine-sender S-SAY-TO EXIT THEN
    get-info 
    DUP STR@ DUP 0= IF 2DROP S" no result from !spf" ECHO ELSE S-REPLY THEN STRFREE
    TRUE TO ?check ;

;MODULE

MODULE: BOT-COMMANDS-HELP
: !spf S" !spf <word> - search the word in the database" S-REPLY ;
;MODULE

$Revision$ " -- SPF help plugin {s} loaded." DUP STR@ ECHO STRFREE

\ EOF