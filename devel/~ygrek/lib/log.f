\ $Id$
\ Simple logger that suits my needs

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE WITH-CRIT ~ygrek/lib/sys/critical.f
REQUIRE CEQUAL ~pinka/spf/string-equal.f
REQUIRE NOT ~profit/lib/logic.f
REQUIRE SPLIT ~pinka/samples/2005/lib/split.f

MODULE: logger

: lvl_num @ ;
: lvl_name CELL+ COUNT ;

: create1 ( xt fxt lvl -- ) DUP lvl_name SHEADER LIT, COMPILE, COMPILE, RET, ;

\ Available message levels (priority and name)
CREATE l:error 50 , S" error" S",
CREATE l:warn  40 , S" warn"  S",
CREATE l:info  30 , S" info"  S",
CREATE l:debug 20 , S" debug" S",
CREATE l:trace 10 , S" trace" S",

\ speed doesn't matter here, it is used in compile-time only
: what ( a u -- n )
  2DUP S" error" CEQUAL IF 2DROP l:error lvl_num EXIT THEN
  2DUP S" warn"  CEQUAL IF 2DROP l:warn  lvl_num EXIT THEN
  2DUP S" info"  CEQUAL IF 2DROP l:info  lvl_num EXIT THEN
  2DUP S" debug" CEQUAL IF 2DROP l:debug lvl_num EXIT THEN
  2DUP S" trace" CEQUAL IF 2DROP l:trace lvl_num EXIT THEN
  2DROP 0 ;

\ Create logging words, which will supply actual message and invoke xt
\ xt: ( a u lvl -- )
: create { xt | fxt -- }
   S" facility" SFIND 0= ABORT" no facility specified" -> fxt
   xt fxt l:error create1
   xt fxt l:warn  create1
   xt fxt l:info  create1
   xt fxt l:debug create1
   xt fxt l:trace create1 ;

USER-VALUE f-a
USER-VALUE f-u
USER-VALUE lvl

: level lvl lvl_name ;
: facil f-a f-u ;

: parse: ( "facil.level" -- `f l ) PARSE-NAME S" ." SPLIT NOT IF 0 ELSE what THEN ;
: check-level ( l -- ? ) lvl lvl_num <= ;
: check ( l `f -- ? ) facil CEQUAL IF check-level EXIT ELSE DROP FALSE EXIT THEN ;
: parse-check parse: LIT, 2DUP S" *" CEQUAL IF 2DROP POSTPONE check-level ELSE SLIT, POSTPONE check THEN ;
: and: ( ? "name" -- ) POSTPONE IF POSTPONE TRUE POSTPONE ELSE parse-check POSTPONE THEN ; IMMEDIATE
: only: POSTPONE DROP ( discard previous checks ) parse-check ; IMMEDIATE

VECT FILTER ( -- ? ) \ use facil and level
VECT LOG-TYPE ( a u -- )

\ default
: LOG-TYPE1 level TYPE SPACE facil TYPE ."  : " TYPE CR ;
: AT-FILTER ... ;
: FILTER1 TRUE AT-FILTER ;

' LOG-TYPE1 TO LOG-TYPE
' FILTER1 TO FILTER

CREATE-CRIT LOGGER-LOCK

: LOG ( `msg lvl `facil -- )
   TO f-u TO f-a
   TO lvl
   FILTER IF ( a u ) ['] LOG-TYPE LOGGER-LOCK WITH-CRIT ELSE 2DROP THEN ;

;MODULE

: (log-plain) ( a u lvl f-a f-u -- ) logger::LOG ;
: (log-str) { s lvl f-a f-u -- } s STR@ lvl f-a f-u logger::LOG s STRFREE ;

\ create facility-specific logger module
\ This is "general"
MODULE: log
: facility S" general" ;
' (log-plain) logger::create
;MODULE

MODULE: slog
: facility S" general" ;
' (log-str) logger::create
;MODULE

/TEST

REQUIRE DateTime>Num ~ygrek/lib/spec/unixdate.f
REQUIRE CEQUAL ~pinka/spf/string-equal.f

\ Define custom logging facility
MODULE: my
: facility S" my" ;
' (log-plain) logger::create
;MODULE

\ "program"
: run
10 " value={n}" slog::info
S" Alarm! Error" my::error
S" comment" my::debug
S" Reached point 1" log::trace
S" Alarm! Warning" my::warn
S" test" my::debug
S" aaaaa" log::error
S" nope" log::warn
S" go go go" my::info
;

\ Example logger configuration
{{ logger

\ Print messages with timestamps to stdout
:NONAME ( a u -- ) TIME&DATE DateTime>PAD TYPE ."  | " facil TYPE ." (" level TYPE ." ) | " TYPE CR ; TO LOG-TYPE

.( print only messages from "my" with level "info" or higher) CR
..: AT-FILTER only: my.info ;..
}}

run CR

{{ logger
.( and "general" errors) CR
..: AT-FILTER and: general.error ;..
}}

run CR

{{ logger
.( only warnings and errors from everyone) CR
..: AT-FILTER only: *.warn ;..
}}

run CR

