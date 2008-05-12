\ $Id$

REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f

TRUE VALUE ok

: check
  ." Checking " 2DUP TYPE CR
  FileLines=>
  DUP STR@ +ModuleDirName FILE-EXIST IF EXIT THEN
  DUP STR@ +LibraryDirName FILE-EXIST IF EXIT THEN
  FALSE TO ok
  DUP STR@ ." Not found : " TYPE CR ;

: check: 
  PARSE-NAME check 
  ok IF ." All ok" ELSE ." Errors" THEN CR ;
