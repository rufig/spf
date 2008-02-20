\ $Id$

REQUIRE >FLOAT lib/include/float2.f
REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES floats
(( 0.99e 1.00e F< -> TRUE ))
(( 1.00e 1.00e F< -> FALSE ))
(( 1.01e 1.00e F< -> FALSE ))
(( 12.3e FLOAT>DATA DEPTH NIP NIP FDEPTH -> 2 0 ))
(( 12.3e FLOAT>DATA32 DEPTH NIP FDEPTH -> 1 0 ))
END-TESTCASES

