\ telescope1        Telescoping of a polynomial (ACM #37)

\ Forth Scientific Library Algorithm #31

\ Takes an Nth degree polynomial,  \Sum_{k = 0}^N c_k x^k
\ approximation to a function which is valid to within eps ( >= 0 ) over
\ the interval (0,L) and reduces it if possible to a polynomial
\ of lower degree valid to within limit (>0).
\ Returns the degree of the new polynomial in the return stack
\ and the new error bound on the floating point stack

\ Collected Algorithms from ACM, Volume 1 Algorithms 1-220,
\ 1980; Association for Computing Machinery Inc., New York,
\ ISBN 0-89791-017-6

\ This is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. The word '}' to dereference a one-dimensional array.
\      3. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control visibility of internal code
\      4. Uses '}malloc' and '}free' to allocate and release memory
\         for dynamic arrays ( 'DArray' ).
\      5. The compilation of the test code is controlled by the VALUE TEST-CODE?
\         and the conditional compilation words in the Programming-Tools wordset

\      The test code requires:
\      1. The immediate word '%' which takes the next token
\         and converts it to a floating-point literal
\      2. The word 'FACTORIAL' is needed for the test code.
\      3. The word '}fprint' is needed to print a one dimensional
\         floating point array in the test code.

\     (c) Copyright 1994  Everett F. Carter.     Permission is granted
\     by the author to use this software for any application provided
\     the copyright notice is preserved.


CR .( TELESCOPE1        V1.4           20 August 1994   EFC )

Private:


FLOAT DArray c1{
FLOAT DArray d1{

: make_coefs1 ( n -- n ) ( f: L -- L )
         DUP 1 < IF EXIT THEN

         c1{ OVER } F@ -1.0E0 F* d1{ OVER } F!

         1 OVER DO
                   FDUP FNEGATE
                   d1{ I } F@ F*
                   I S>F     F*
                   I S>F 0.5E0 F- F*
                   DUP I + 1- S>F F/
                   DUP I - 1+ S>F F/
                   d1{ I 1- } F!
          -1 +LOOP

;

: t1_cleanup ( -- ) ( f: L eps limit -- eps )

        \ drop limit and L from fstack
        FDROP FSWAP FDROP

        \ release dynamically allocated space
        & d1{ }free
;

Public:

: telescope1 ( 'c n1 -- n2 ) ( f: L eps limit -- eps )

      SWAP
      & c1{ &!

      & d1{ OVER 1+ }malloc           \ allocate scratch array d1{

      BEGIN
        FROT          \ move eps and limit out of the way
        make_coefs1
        FROT FROT          \ move eps and limit back
        FOVER d1{ 0 } F@ FABS F+

        FOVER F<
      WHILE

        FSWAP
        d1{ 0 } F@ FABS F+ FSWAP   \ compute new eps

        0 OVER DO d1{ I } F@       \ update new set of coefficients
                  c1{ I } DUP F@ F+ F!
               -1 +LOOP

        1-

        DUP 1 < IF t1_cleanup EXIT THEN

      REPEAT

      t1_cleanup

;

Reset_Search_Order

TEST-CODE? [IF]     \ test code =============================================

\ test code telescopes the 10th order polynomial fit of exp(-x)
\ to a smaller polynomial

12 FLOAT Array C{                 \ the polynomial coefficients


: fill_test_array1 ( n -- )   \ put Taylor series coefs of exp(-x) into C

        \ first fill C array
         0 DO 1.0E0
                I factorial D>F F/ c{ i } F!
                I 2 MOD IF -1.0E0 c{ I } F@ F* c{ I } F! THEN
             LOOP
;

: test_telescope1 ( -- )

       11 fill_test_array1

       CR ." The original array: "
        
       11 c{ }fprint CR
       

       c{ 10 % 1.0 % 5.0e-5 % 1.0e-3 telescope1

       ." Eps: "  F.
       ." N: " DUP . CR

        ." The new array: " 1+ c{ }fprint CR

        ." The new array should be 4 elements (approximately): " CR
        ."  0.99978965 -0.99307236 0.46364955 -0.10267767" CR

;


[THEN]




