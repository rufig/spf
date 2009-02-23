\ $Id$
\ macroopt test cases

REQUIRE TESTCASES ~ygrek/lib/testcase.f

\ Message-ID: <49A1AEA6.6010100@ngs.ru>
\ From: Oda <oda_tmp1@ngs.ru>
\ Date: Mon, 23 Feb 2009 01:59:34 +0600

\ rule 282

: TEST 255 >R R> 1+ >R R> ;

DIS-OPT
: TEST2 255 >R R> 1+ >R R> ;
SET-OPT

TESTCASES macroopt
(( TEST -> 256 ))
(( TEST2 -> 256 ))
END-TESTCASES
