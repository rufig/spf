\ REQUIRE get-info ~ygrek/prog/web/irc/xmlhelpdb.f
REQUIRE words-load ~ygrek/prog/web/help.cgi/load.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f

MODULE: bot_plugin_spf

{{ list
() VALUE words

: word_desc { w -- s } w cddar STR@ w cdar STR@ w car STR@ " {s} {s} \ {s}" ;
: words_desc { l | s -- s } 
  "" -> s 
  10 0 DO 
  l empty? IF LEAVE THEN 
  l car car STR@ s STR+ 
  S"  " s STR+ 
  l cdr -> l 
  LOOP
  s ;
}}

EXPORT

{{ list
: get_spf_word ( a u -- s ) 
   words words-find list::concat { l }
   l length 0 = IF " no result" EXIT THEN
   l length 1 = IF l car word_desc ELSE l words_desc THEN
   l free ; \ not words-free !
}}

: load_spf_words ( a u -- ) words-load TO words ;

;MODULE

\ ALSO bot_plugin_spf
\ list ALSO!
\ S" words" load_spf_words

MODULE: BOT-COMMANDS

: !spf
    SkipDelimiters
    PARSE-NAME DUP 0= IF 2DROP S" Try !info !spf" S-REPLY EXIT THEN
    2DUP " search spf word : {s}" slog::trace
    get_spf_word STR-REPLY
    TRUE TO ?check ;

;MODULE

MODULE: BOT-COMMANDS-HELP
: !spf S" usage: !spf <word> - find the word definition in SPF source, lib or devel" S-REPLY ;
;MODULE

..: AT-CONNECT S" words" load_spf_words ;..

$Revision$ " -- SPF help plugin {s} loaded." STYPE CR

\ -----------------------------------------------------------------------

