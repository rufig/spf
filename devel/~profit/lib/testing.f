VARIABLE TESTING
: /TEST TESTING @ 0= IF \EOF THEN ;
TESTING 0!

\EOF
VOCABULARY tests:
           ALSO tests DEFINITIONS
: ;test PREVIOUS ;
: NOTFOUND 2DROP ;
 PREVIOUS DEFINITIONS

\EOF
REQUIRE (: ~yz/lib/inline.f

: r
&INTERPRET @
(:
BEGIN \ интерпретировать входной поток со знаками препинания
NextWord DUP         WHILE 
S" bla" COMPARE 0= WHILE
?STACK               REPEAT THEN ;)
 &INTERPRET !
2DROP ;