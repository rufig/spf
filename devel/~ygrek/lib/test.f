REQUIRE /STRING lib/include/string.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE AddNode ~ac/lib/list/str_list.f

"" VALUE test-s
"" VALUE test-name
TEMP-WORDLIST VALUE test-wl
VARIABLE test-list
0 VALUE test-depth
0 VALUE test-count
0 VALUE test-fail

0
CELL -- .test-s
CELL -- .test-name
CONSTANT /full-test

: new-test ( s name -- addr )
   /full-test ALLOCATE THROW >R
   R@ .test-name !
   R@ .test-s ! 
   R> ;

: REGISTER-TEST test-s test-name new-test test-list AddNode ;

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
  ['] CR TYPE>STR test-s S+
  ;

: ? 0= IF ABORT" ds" THEN ;

: define-test ( a u -- )
   " {s}" TO test-name
   SOURCE >IN @ /STRING SOURCE!
   ['] TO-STR SET-INTERPRET
   TO-STR ;

: test{ S" unnamed" define-test ;
: test: PARSE-NAME define-test ;

: RUN-TEST ( a u -- ? )
   DEPTH 2 - TO test-depth
   ['] EVALUATE CATCH ?DUP IF CR ." Exception : " . 2DROP TRUE EXIT THEN
   DEPTH test-depth <> IF 
     CR
     ." DEPTH after = " DEPTH . ." DEPTH before = " test-depth . 
     DEPTH test-depth ?DO DROP LOOP
     TRUE EXIT 
   THEN 
   FALSE ;

\   lib/include/tools.f
: node-run 
   NodeValue >R
   R@ .test-s @ TO test-s
   CR ." ======================="
   R> .test-name @ CR ." Running test: " STYPE
   CR
   test-s STR@ RUN-TEST
   IF 
     CR ." Test failed:"
     test-s STR@ CR TYPE 
     test-fail 1+ TO test-fail
     EXIT
   ELSE
     CR ." Ok"
   THEN 
   test-count 1+ TO test-count 
   ;

: test 
   0 TO test-count 
   0 TO test-fail
   ['] node-run test-list DoList 
   test-fail ?DUP IF CR . ." tests FAILED!" THEN 
   test-count CR . ." tests passed!" ;

\ EOF test whether test works 8-)

test: test.f-1-fail  fff
dsa
as
qwe
dsd }test

test: 2+2=4 2 2 + 4 = ? }test

test: test.f-2-fail 2 3 3 4 }test
