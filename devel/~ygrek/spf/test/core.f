\ $Id$

REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE NOT ~profit/lib/logic.f

TESTCASES FILL

100000 VALUE #buf

0 VALUE buf 
#buf CHARS ALLOCATE THROW TO buf

: check ( a u char -- ? )
   -ROT
   CHARS OVER + SWAP ?DO DUP I C@ = NOT IF DROP UNLOOP FALSE EXIT THEN /CHAR +LOOP 
   DROP TRUE ;

buf #buf CHAR a FILL
\ buf #buf 100 CHARS MIN DUMP

(( buf #buf CHAR a check -> TRUE ))

buf FREE THROW

END-TESTCASES

