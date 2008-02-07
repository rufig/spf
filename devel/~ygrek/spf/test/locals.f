\ $Id$

REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE { lib/ext/locals.f

\ Этот тест проходят как "старые" локалсы, так и "продвинутые"
TESTCASES locals.f

: TEST1 { a b c d \ e f -- } a b c  b c + -> e   e  f ^ a @ ;
: TEST2 { a b -- } a b 5 0 DO I a b LOOP ;
: TEST3 { a b } a b ;
: TEST4 { a b \ c } a b c ;
: TEST5 { a b -- } a b ;
: TEST6 { a b \ c -- d } a b c ;
: TEST7 { \ a b } a b  1 -> a  2 -> b  a b ;
: TEST4a { a b | c } a b c ;
: TEST6a { a b | c -- d } a b c ;
: TEST7a { | a b } a b  1 -> a  2 -> b  a b ;
: TEST8 { | [ 120 CHARS ] a [ 10 CHARS ] b f[ 20 CHARS ] }
   a 120 2 FILL
   b 10 3 FILL
   f[ 20 4 FILL
   a C@
   a 119 CHARS + C@
   b C@
   b 9 CHARS + C@
   f[ C@
   f[ 19 CHARS + C@ ;

(( 1 2 3 4 TEST1 -> 1 2 3 5 0 1 ))
(( 12 34 TEST2 -> 12 34 0 12 34 1 12 34 2 12 34 3 12 34 4 12 34 ))
(( 1 2 TEST3 -> 1 2 ))
(( 1 2 TEST4 -> 1 2 0 ))
(( 1 2 TEST5 -> 1 2 ))
(( 1 2 TEST6 -> 1 2 0 ))
(( TEST7 -> 0 0 1 2 ))
(( 1 2 TEST4a -> 1 2 0 ))
(( 1 2 TEST6a -> 1 2 0 ))
(( TEST7a -> 0 0 1 2 ))
(( TEST8 -> 2 2 3 3 4 4 ))

END-TESTCASES

\ эти тесты проходят только "продвинутые" локалсы
TESTCASES More strict locals

: TEST1b { a -b |c \d \ --e f -- } a -b |c  -b |c + -> --e   --e  f ^ a @ ;
: TEST2b { [a] -b -- } [a] -b 5 0 DO I [a] -b LOOP ;
: TEST3b { }a b } }a b ;
: TEST4b { \a v | c } \a v c ;
: TEST5b { --a b -- } --a b ;
: TEST6b { |a |b | }c -- d } |a |b }c ;
: TEST7b { | a[] \b } a[] \b  1 -> a[]  2 -> \b  a[] \b ;

(( 1 2 3 4 TEST1b -> 1 2 3 5 0 1 ))
(( 12 34 TEST2b -> 12 34 0 12 34 1 12 34 2 12 34 3 12 34 4 12 34 ))
(( 1 2 TEST3b -> 1 2 ))
(( 1 2 TEST4b -> 1 2 0 ))
(( 1 2 TEST5b -> 1 2 ))
(( 1 2 TEST6b -> 1 2 0 ))
(( TEST7b -> 0 0 1 2 ))

END-TESTCASES

