REQUIRE CHAR-UPPERCASE ~ac/lib/string/uppercase.f
\ REQUIRE /TEST ~profit/lib/testing.f

\ TRUE - strings are equal ignoring case
: CEQUAL-U ( a1 u1 a2 u2 -- ? )
  SWAP >R >R
  R@ <> IF DROP 2R> 2DROP FALSE EXIT THEN
  R> R> SWAP 0
  ?DO 2DUP I + C@ CHAR-UPPERCASE SWAP I + C@ CHAR-UPPERCASE <> IF 2DROP UNLOOP FALSE EXIT THEN 
  LOOP 2DROP TRUE ;

\ /TEST
\ 
\ REQUIRE TESTCASES ~ygrek/lib/testcase.f
\ 
\ TESTCASES CEQUAL-U
\ 
\ (( S" 2DROP" S" RDROP" CEQUAL-U -> FALSE ))
\ (( S" rDROP" S" RDROP" CEQUAL-U -> TRUE ))
\ (( S" " S" " CEQUAL-U -> TRUE ))
\ (( S" 2DROP" S" 2DRO" CEQUAL-U -> FALSE ))
\ (( S" SeArCh-woRDLiSt" S" SEARCH-WORDLIST" CEQUAL-U -> TRUE ))
\ 
\ END-TESTCASES

: [else]   \ 94 TOOLS EXT
    1
    BEGIN
      PARSE-NAME DUP
      IF  
         2DUP S" [if]"   CEQUAL-U  IF 2DROP 1+                 ELSE 
         2DUP S" [else]" CEQUAL-U  IF 2DROP 1- DUP  IF 1+ THEN ELSE 
              S" [then]" CEQUAL-U  IF       1-                 THEN
                                    THEN  THEN   
      ELSE 2DROP REFILL  AND \   SOURCE TYPE
      THEN DUP 0=
    UNTIL  DROP 
;  IMMEDIATE

: [if] \ 94 TOOLS EXT
  0= IF POSTPONE [else] THEN
; IMMEDIATE
