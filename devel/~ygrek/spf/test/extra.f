\ $Id$

REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE ANSI-FILE lib/include/ansi-file.f

TESTCASES FILE-EXIST
(( ModuleDirName FILE-EXIST -> TRUE ))
(( ModuleName FILE-EXIST -> TRUE ))
(( S" ?*?" FILE-EXIST -> FALSE ))
END-TESTCASES

TESTCASES FILE-EXISTS
(( ModuleDirName FILE-EXISTS -> FALSE ))
(( ModuleName FILE-EXISTS -> TRUE ))
(( S" ?*?" FILE-EXISTS -> FALSE ))
END-TESTCASES
