REQUIRE 2CONSTANT lib/include/double.f
REQUIRE TESTCASES ~ygrek/lib/testcase.f

\ Тест на глюк N 1778916: 16-битность SEARCH ?..
\ http://sourceforge.net/tracker/index.php?func=detail&aid=1778916&group_id=17919&atid=117919

TESTCASES SEARCH test

HERE
0x80 C, 0x80 C, 0x1 C, 0x80 C,
HERE OVER - ( addr u )
2CONSTANT toFind

: fillOut ( n -- ) 0 DO 0x80 C, LOOP ;

HERE
66000 fillOut
toFind S,
HERE OVER - ( addr u )
2CONSTANT buf

(( buf toFind SEARCH NIP NIP -> TRUE ))
END-TESTCASES