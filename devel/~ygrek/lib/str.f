\ $Id$
\
\ Useful extensions to ~ac/lib/str.f

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE list ~ygrek/lib/list/core.f
REQUIRE /TEST ~profit/lib/testing.f

\ append s1 to s
: STRAPPEND ( s s1 -- s' ) OVER S+ ;

\ : str-concat ( l -- s ) "" OVER LAMBDA{ OVER SWAP STR@ ROT STR+ } list::iter SWAP ['] STRFREE list::free-with ;

\ Concatenate the list of strings l, inserting separator a u between each
\ l is destroyed
: str-concat-with { l a u \ r l1 -- s }
  "" -> r
  l -> l1
  {{ list
  l empty? IF r EXIT THEN
  BEGIN
   l cdr empty? IF l car r S+ l1 list::free r EXIT THEN
   l car r S+
   a u r STR+
   l cdr -> l
  AGAIN
  }} ;

\ Concatenate the list of strings l, inserting separator s between each
: str-concat-with-s ( l s -- s ) >R R@ STR@ str-concat-with R> STRFREE ;

/TEST

REQUIRE list-make ~ygrek/lib/list/make.f

%[ " oh" % " I" % " believe" % " in" % " yesterday" % ]% S" ," str-concat-with STYPE CR
%[ " oh" % " I" % " believe" % " in" % " yesterday" % ]% "  " str-concat-with-s STYPE CR

