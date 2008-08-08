\ $Id$
\ 
\ Dump .const file contents (see lib/ext/const.f)

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f

\ Execute xt for each constant in file a u
\ NB no bounds checking
: DUMP-CONST-FILE-WITH-XT ( a u xt -- ) \ xt ( value name-a name-u -- )
  { xt | a }
  FILE DROP -> a
  a 4 S" CONS" COMPARE 0 <> IF ." Not a const file" CR a FREE THROW EXIT THEN
  a 2 CELLS + @ 0 ?DO
   a 3 I + CELLS + @ a + DUP @ SWAP CELL+ COUNT xt EXECUTE
  LOOP
  a FREE THROW ;

: DUMP-CONST-FILE=> ( a u <--> value name-a name-u ) R> DUMP-CONST-FILE-WITH-XT ;

: DUMP-CONST-FILE ( a u -- ) LAMBDA{ ROT . ." CONSTANT " TYPE CR } DUMP-CONST-FILE-WITH-XT ;

\ S" lib/win/winconst/windows.const" +ModuleDirName DUMP-CONST-FILE
\ S" devel/~yz/cons/windows.const" +ModuleDirName :NONAME DUMP-CONST-FILE=> TYPE ."  = " . CR ; EXECUTE

\ S" devel/~ygrek/lib/data/curl.const" +ModuleDirName 
\ :NONAME " int {s} = {n};{EOLN}" STYPE ; DUMP-CONST-FILE-WITH-XT
