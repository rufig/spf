REQUIRE /STRING lib/include/string.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE STR{ ~ygrek/lib/strtype.f
REQUIRE AddNode ~ac/lib/list/str_list.f

"" VALUE test-s
TEMP-WORDLIST VALUE test-wl
VARIABLE test-list
0 VALUE test-depth
0 VALUE test-count
0 VALUE test-fail

: REGISTER-TEST test-s test-list AddNode ;

: SET-INTERPRET &INTERPRET ! ;

: TO-STR ( -> ) \ интерпретировать входной поток
  BEGIN
    PARSE-NAME DUP
  WHILE
    S" }test" COMPARE 0=          
    IF 
     ['] INTERPRET_ SET-INTERPRET 
     SOURCE DROP >IN @ 5 - test-s STR+ 
     REGISTER-TEST
     "" TO test-s
     EXIT  THEN
  REPEAT
  2DROP
  SOURCE test-s STR+ 
  test-s STR{ CR }STR TO test-s
  ;

: ? 0= IF ABORT" ds" THEN ;

: test{
   SOURCE >IN @ /STRING SOURCE!
   ['] TO-STR SET-INTERPRET
   TO-STR ;

: RUN-TEST ( a u -- ? )
   DEPTH 2 - TO test-depth
   ['] EVALUATE CATCH ?DUP IF CR . 2DROP TRUE EXIT THEN
   DEPTH test-depth <> IF 
     CR
     ." DEPTH after = " DEPTH . ." DEPTH before = " test-depth . 
     DEPTH test-depth ?DO DROP LOOP
     TRUE EXIT 
   THEN 
   FALSE ;

\   lib/include/tools.f
: node-run 
   NodeValue TO test-s
   test-s STR@ RUN-TEST
   IF 
     CR ." Test failed:"
     test-s STR@ CR TYPE 
     CR
     test-fail 1+ TO test-fail
     EXIT
   THEN 
   test-count 1+ TO test-count 
   ;

: test 
   0 TO test-count 
   0 TO test-fail
   ['] node-run test-list DoList 
   test-fail ?DUP IF CR . ." test FAILED!" THEN 
   test-count CR . ." tests passed!" ;

\EOF test whether test works 8-)

test{  fff
dsa
as
qwe
dsd }test

test{ 2 2 + 4 = ? }test

test{ 2 3 3 4 }test


