\ $Id$
\ Dynamic strings and bac4th

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE PRO ~profit/lib/bac4th.f

\ STRFREE at backtracking
: BACKSTRFREE ( s --> s \ <-- ) PRO BACK STRFREE TRACKING RESTB CONT ;
: BACKSTR@ ( s --> a u \ <-- ) PRO BACKSTRFREE STR@ CONT ;

\ EVALUATE s and STRFREE
: STREVALUATE ( s -- i*x ) BACKSTR@ EVALUATE ;

