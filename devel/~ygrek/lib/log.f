\ $Id$
\ Simple logger

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: logger

: lvl_num @ ;
: lvl_name CELL+ COUNT ;

: create1 ( xt fxt lvl -- ) DUP lvl_name SHEADER LIT, COMPILE, COMPILE, RET, ;

\ Available message levels (priority and name)
CREATE l_error 50 , S" error" S",
CREATE l_warn  40 , S" warn"  S",
CREATE l_info  30 , S" info"  S",
CREATE l_debug 20 , S" debug" S",
CREATE l_trace 10 , S" trace" S",

\ Create actual logging words, which will supply actual message and invoke xt
\ xt: ( a u lvl -- )
: create { xt | fxt -- } 
   S" facility" SFIND 0= ABORT" no facility specified" -> fxt
   xt fxt l_error create1
   xt fxt l_warn  create1
   xt fxt l_info  create1
   xt fxt l_debug create1
   xt fxt l_trace create1 ;

USER-VALUE f-a
USER-VALUE f-u
USER-VALUE level

: facil f-a f-u ;

VECT FILTER ( -- ? ) \ use facil and level
VECT LOG-WRITE ( a u -- )

\ default
: LOG-WRITE1 level lvl_name TYPE SPACE facil TYPE ."  : " TYPE CR ;

' LOG-WRITE1 TO LOG-WRITE
' TRUE TO FILTER

: LOG ( `msg lvl `facil -- )
   TO f-u TO f-a
   TO level
   FILTER IF ( a u ) LOG-WRITE ELSE 2DROP THEN ;

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

\ Define custom facility
MODULE: my
: facility S" my" ;
' (log-str) logger::create
;MODULE

\ Example logger configuration
MODULE: logger
\ Print messages with timestamps to stdout
:NONAME ( a u -- ) TIME&DATE DateTime>PAD TYPE ."  | " level lvl_name TYPE ."  | " TYPE CR ; TO LOG-WRITE
\ Print only error and warn messages
:NONAME ( -- ? ) 
  level lvl_num l_info lvl_num > 
  facil S" my" CEQUAL
  AND ; TO FILTER
;MODULE

10 " value={n}" slog::info
" Alarm! Error" my::error
" comment" my::debug
S" Reached point 1" log::trace
" Alarm! Warning" my::warn

