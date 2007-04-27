\ telescope2        Telescoping of a polynomial (ACM #38)

\ Forth Scientific Library Algorithm #32

\ Takes an Nth degree polynomial,  \Sum_{k = 0}^N c_k x^k
\ approximation to a function which is valid to within eps ( >= 0 ) over
\ the interval (-L,L) and reduces it if possible to a polynomial
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
\      1. The word 'FACTORIAL' is needed for the test code.
\      2. The immediate word '%' which takes the next token
\         and converts it to a floating-point literal
\      3. The word '}fprint' is needed to print a one dimensional
\         floating point array in the test code.

\     (c) Copyright 1994  Everett F. Carter.     Permission is granted
\     by the author to use this software for any application provided
\     the copyright notice is preserved.


CR .( TELESCOPE2        V1.4           20 August 1994   EFC )

Private:

FLOAT DArray c2{
FLOAT DArray d2{

: make_coefs2 ( n -- n ) ( f: L -- L )
         DUP 2 < IF EXIT THEN

         c2{ OVER } F@ -1.0E0 F* d2{ OVER } F!

         2 OVER DO
                   FDUP FDUP F* FNEGATE
                   d2{ I } F@ F*
                   I S>F     F*
                   I S>F 1.0E0 F- F*
                   DUP I + 2 - S>F F/
                   DUP I - 2 + S>F F/
                   d2{ I 2 - } F!
          -2 +LOOP

;

: t2_cleanup ( -- ) ( F: L eps limit -- eps )

        \ drop limit and L from fstack
        FDROP FSWAP FDROP

       \ release dynamically allocated space
       & d2{ }free
;

Public:

: telescope2 ( 'c n1 -- n2 ) ( f: L eps limit -- eps )

      SWAP
      & c2{ &!

      & d2{ OVER 1+ }malloc          \ allocate scratch array d2{
      
      BEGIN
        FROT          \ move eps and limit out of the way
        make_coefs2
        FROT FROT     \ move eps and limit back

        FOVER          \ put an extra copy of eps on top of the fstack
        
        DUP 2 MOD  IF d2{ 1 } F@ DUP S>F F/
                   ELSE d2{ 0 } F@ THEN
        FABS F+
        FOVER F<
      WHILE

        FSWAP
        DUP 2 MOD IF d2{ 1 } F@ DUP S>F F/         \ compute new eps
                  ELSE d2{ 0 } F@ THEN
        FABS F+ FSWAP

        0 OVER DO d2{ I } F@       \ update new set of coefficients
                  c2{ I } DUP F@ F+  F!
               -2 +LOOP

        1-

        DUP 2 < IF t2_cleanup EXIT THEN

      REPEAT

      t2_cleanup
;

Reset_Search_Order

TEST-CODE? [IF]     \ test code =============================================

\ test code telescopes the 10th order polynomial fit of exp(+x)
\ to a smaller polynomial

12 FLOAT Array C{                 \ the polynomial coefficients


: fill_test_array2 ( n -- )   \ put Taylor series coefs of exp(+x) into C

        \ first fill C array
         0 DO 1.0E0
                I factorial D>F F/ c{ I } F!
         LOOP
;

: test_telescope2 ( -- )

       11 fill_test_array2

       CR ." The original array: "
        
       11 c{ }fprint CR
       

       c{ 10 % 1.0 % 1.0e-5 % 1.0e-3 telescope2

       ." Eps: "  F.
       ." N: " DUP . CR

        ." The new array: " 1+ c{ }fprint CR

        ." The new array should be 5 elements (approximately): " CR
        ."  1.0000447 0.99730758 0.49919675 0.17734729 0.043793910" CR 
        
        
;

[THEN]
