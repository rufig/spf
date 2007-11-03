\ $Id$
\ Test vectors for DES from NBS and cryptonessie
\ Download test data :
\ http://forth.org.ru/~ygrek/files/data/nbs.test
\ http://forth.org.ru/~ygrek/files/data/nessie.test

REQUIRE BIT@ ~ygrek/lib/bit.f
REQUIRE NUMBER ~ygrek/lib/parse.f
REQUIRE ACCERT-LEVEL lib/ext/debug/accert.f
REQUIRE DES-BLOCK-ENCRYPT des.f
REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f

VARIABLE total
VARIABLE succeeded

CREATE key 64 bits, 
CREATE data 64 bits, 
CREATE plain 64 bits, 
CREATE cipher 64 bits, 

: hex-byte
   DUP 2 <> ABORT" not a byte"
   BASE @ >R
   HEX 
   NUMBER 0= ABORT" not a hex"
   R> BASE ! 
   0
   8 0 DO \ invert the byte
    1 LSHIFT
    OVER 1 AND IF 1 OR THEN
    SWAP 1 RSHIFT SWAP
   LOOP
   NIP ;

: set-hex ( a u addr -- )
   SWAP 16 <> ABORT" bad key"
   { a addr }
   8 0 DO 
     a 2 hex-byte addr I + B!
     a 2 + -> a
   LOOP ;

: set-key-hex key set-hex ;
: set-plain-hex plain set-hex ;
: set-cipher-hex cipher set-hex ;

: do-test
   plain data 8 MOVE
   key data DES-BLOCK-ENCRYPT
   data cipher 64 BITS-EQUAL?

   cipher data 8 MOVE
   key data DES-BLOCK-DECRYPT
   data plain 64 BITS-EQUAL? 

   AND ;

: tester
   total 1+!
   PARSE-NAME set-key-hex
   PARSE-NAME set-plain-hex
   PARSE-NAME set-cipher-hex
   do-test 
   IF succeeded 1+! THEN ;

: test-line 
   DUP 1 < IF 2DROP EXIT THEN
   OVER C@ [CHAR] # = IF 2DROP EXIT THEN
   ['] tester EVALUATE-WITH ;

: results CR " {succeeded @} of {total @} tests passed" STYPE ;
: passed/total succeeded @ total @ ;
: reset total 0! succeeded 0! ;

: test-file ( a u -- )
    2DUP CR TYPE
    reset
    START{ FileLines=> DUP STR@ test-line }EMERGE 
    results ;

TESTCASES some test vectors

reset
S" 0000000000000000 0000000000000000 8CA64DE9C1B123A7" test-line
S" 8001010101010101 0000000000000000 95A8D72813DAA94D" test-line
S" 133457799BBCDFF1 0123456789ABCDEF 85E813540F0AB405" test-line
S" 3B3898371520F75E 7177657274797569 08502C1F62774453" test-line
(( passed/total -> 4 4 ))

END-TESTCASES

:NONAME S" nbs.test" FILE-EXIST S" nessie.test" FILE-EXIST AND 0 = IF CR CR ." Download test data!" CR CR THEN ; EXECUTE

TESTCASES NBS and cryptonessie test vectors

S" nbs.test" test-file 
(( passed/total -> 324 324 ))
S" nessie.test" test-file 
(( passed/total -> 385 385 ))

END-TESTCASES


