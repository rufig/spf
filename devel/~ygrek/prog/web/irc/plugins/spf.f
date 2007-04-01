REQUIRE get-info ~ygrek/prog/web/irc/xmlhelpdb.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f

MODULE: BOT-COMMANDS

: !spf
    SkipDelimiters
    PARSE-NAME DUP 0= IF 2DROP S" Try !info !spf" S-REPLY EXIT THEN
    get-info 
    DUP STR@ DUP 0= IF 2DROP S" no result" THEN S-REPLY STRFREE
    TRUE TO ?check ;

;MODULE

MODULE: BOT-COMMANDS-HELP
: !spf S" usage: !spf <word> - find the word definition in SPF source" S-REPLY ;
;MODULE

$Revision$ " -- SPF help plugin {s} loaded." DUP STR@ ECHO STRFREE

\ EOF