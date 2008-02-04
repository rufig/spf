\ $Id$
\ 30.Dec.2006 taken from forthgui by ~day

( testcase.f day )

MODULE: testcase

: TO-CONTEXT ( wl -- )
    >R
    GET-ORDER 1+
    R> SWAP
    SET-ORDER
;

EXPORT

\ From original well-known tester.f

VARIABLE VERBOSE
   TRUE VERBOSE !
VARIABLE USE-TESTS
   TRUE USE-TESTS !

DEFINITIONS

VARIABLE PREVIOUS-CURRENT

VARIABLE TESTING-DEPTH

: EMPTY-STACK   \ ( ... -- ) EMPTY STACK.
   DEPTH ?DUP IF 0 DO DROP LOOP THEN ;

VARIABLE ACTUAL-DEPTH                   \ STACK RECORD
VARIABLE PRE-DEPTH
CREATE ACTUAL-RESULTS 20 CELLS ALLOT

: ERROR         \ ( C-ADDR U -- ) DISPLAY AN ERROR MESSAGE FOLLOWED BY
                \ THE LINE THAT HAD THE ERROR.
   TYPE SOURCE TYPE CR                  \ DISPLAY LINE CORRESPONDING TO ERROR

    ACTUAL-DEPTH @ . ." :"
    ACTUAL-DEPTH @ 0 > IF
        0 ACTUAL-DEPTH @ 1- DO
            I CELLS ACTUAL-RESULTS + @ .
        -1 +LOOP
    THEN
    CR

   EMPTY-STACK                          \ THROW AWAY EVERY THING ELSE
   -1 ABORT" test failed"
;

EXPORT

: ((             \ ( -- )
   DEPTH PRE-DEPTH !
;

: ->            \ ( ... -- ) RECORD DEPTH AND CONTENT OF STACK.
   DEPTH PRE-DEPTH @ - DUP ACTUAL-DEPTH !             \ RECORD DEPTH
   ?DUP IF                              \ IF THERE IS SOMETHING ON STACK
      0 DO ACTUAL-RESULTS I CELLS + ! LOOP \ SAVE THEM
   THEN ;

: ))             \ ( ... -- ) COMPARE STACK (EXPECTED) CONTENTS WITH SAVED
                \ (ACTUAL) CONTENTS.
   DEPTH PRE-DEPTH @ - ACTUAL-DEPTH @ = IF            \ IF DEPTHS MATCH
      DEPTH PRE-DEPTH @ - ?DUP IF                     \ IF THERE IS SOMETHING ON THE STACK
         0 DO                           \ FOR EACH STACK ITEM
            ACTUAL-RESULTS I CELLS + @  \ COMPARE ACTUAL WITH EXPECTED
            <> IF S" INCORRECT RESULT: " ERROR LEAVE THEN
         LOOP
      THEN
   ELSE                                 \ DEPTH MISMATCH
      S" WRONG NUMBER OF RESULTS: " ERROR
   THEN ;

: TESTING       \ ( -- ) TALKING COMMENT.
   SOURCE VERBOSE @
   IF DUP >R TYPE CR R> >IN !
   ELSE >IN ! DROP
   THEN ;

\ comparing arrays
: TEST-ARRAY ( addr u addr1 u1 )
   >R OVER R@ = R> SWAP
   INVERT
   IF
      S" DIFFERENT LENGTH: " ERROR
   ELSE
     COMPARE
     IF
        S" ARRAYS DIFFERS BY CONTENT: " ERROR
     THEN
   THEN
;

: TESTCASES
    DEPTH TESTING-DEPTH !

    GET-CURRENT PREVIOUS-CURRENT !
    USE-TESTS @ INVERT
    IF
      [COMPILE] \EOF
    ELSE
      WORDLIST TO-CONTEXT DEFINITIONS
      CR ." TESTING: "
      SOURCE >IN @ DUP >R - SWAP R> CHARS + SWAP TYPE
      SOURCE NIP >IN !
    THEN
;

: END-TESTCASES
    PREVIOUS
    PREVIOUS-CURRENT @ SET-CURRENT
    DEPTH TESTING-DEPTH @ = 0= ABORT" wrong depth after tests"
    CR ." TEST PASSED"
;

;MODULE

\EOF \ Пример использования

TESTCASES testcase.f

\ examples

: test 1 1 ;
: stest S" abc" ;

(( test -> 1 1 )) \ good
\ (( test -> 1 0 )) \ wrong

stest S" abc" TEST-ARRAY \ good
\ stest S" abd" TEST-ARRAY \ wrong

END-TESTCASES
