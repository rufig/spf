\ $Id$
\
\ Dump .const file contents (see lib/ext/const.f)

REQUIRE STR@ ~ac/lib/str5.f

: DUMP-CONST-FILE ( a u -- )
  FILE DROP { a }
  a 4 S" CONS" COMPARE 0 <> IF ." Not a const file" CR a FREE THROW EXIT THEN
  a 2 CELLS + @ 0 ?DO
   a 3 I + CELLS + @ a + DUP @ . SPACE ." CONSTANT " CELL+ COUNT TYPE CR
  LOOP
  a FREE THROW ;

\ S" lib/win/winconst/windows.const" +ModuleDirName DUMP-CONST-FILE
\ S" devel/~yz/cons/windows.const" +ModuleDirName DUMP-CONST-FILE
\ S" devel/~ygrek/lib/data/curl.const" +ModuleDirName DUMP-CONST-FILE
