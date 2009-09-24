
\ Convert given char to uppercase. 
\ Behaviour for values above 128 is implementation-defined.
: CHAR-UPPERCASE ( c -- c1 )
  DUP [CHAR] a [CHAR] z 1+ WITHIN IF 32 - EXIT THEN
  DUP [CHAR] à [CHAR] ÿ 1+ WITHIN IF 32 - THEN
;

\ Convert (addr u) to uppercase
: UPPERCASE ( addr u -- )
  OVER + SWAP ?DO
    I C@ CHAR-UPPERCASE I C!
  LOOP ;

\ TRUE - strings are equal ignoring case
: CEQUAL-U ( a1 u1 a2 u2 -- flag )
  ROT TUCK <> IF DROP 2DROP FALSE EXIT THEN
  0 ?DO ( a1i a2i ) 2DUP
  C@ CHAR-UPPERCASE SWAP C@ CHAR-UPPERCASE <> IF 2DROP UNLOOP FALSE EXIT THEN
  SWAP CHAR+ SWAP CHAR+
  LOOP 2DROP TRUE
;

\EOF

REQUIRE /TEST ~profit/lib/testing.f

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES CEQUAL-U

(( S" 2DROP" S" RDROP" CEQUAL-U -> FALSE ))
(( S" rDROP" S" RDROP" CEQUAL-U -> TRUE ))
(( S" " S" " CEQUAL-U -> TRUE ))
(( S" 2DROP" S" 2DRO" CEQUAL-U -> FALSE ))
(( S" SeArCh-woRDLiSt" S" SEARCH-WORDLIST" CEQUAL-U -> TRUE ))

END-TESTCASES

