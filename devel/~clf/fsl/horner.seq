\ Horner          Evaluation of a polynomial by the Horner method

\ Forth Scientific Library Algorithm #3

\ This routine evaluates an Nth order polynomial Y(X) at point X
\ Y(X) = \sum_i=0^N a[i] x^i                  (NOTE: N+1 COEFFICIENTS)
\ by the Horner scheme.  This algorithm minimizes the number of multiplications
\ required to evaluate the polynomial.
\ The implementation demonstrates the use of array aliasing.

\ This code conforms with ANS requiring:
\      1. The Floating-Point word set
\      2. The immediate word '%' which takes the next token
\         and converts it to a floating-point literal
\      3. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      4. The immediate word '&' to get the address of an array
\         function at either compile or run time.
\      5. Uses the words 'DArray' and '&!' to alias arrays.
\      6. Test code uses 'ExpInt' for real exponential integrals

\  (code for the dependencies , 3, 4, and 5 above are in the file 'fsl_util' )

\ This algorithm is described in many places, e.g.,
\ Conte, S.D. and C. deBoor, 1972; Elementary Numerical Analysis, an algorithmic
\ approach, McGraw-Hill, New York, 396 pages

\ (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.

CR .( HORNER            V1.5           31 October 1994   EFC )


Private:

FLOAT DARRAY ha{

Public:

: }Horner ( &a n -- , f: x -- y[x] )

        SWAP & ha{ &!

        % 0.0

        0 SWAP DO
                     FOVER F*
                     ha{ I } F@ F+
              
        -1 +LOOP

         FSWAP FDROP
;


Reset_Search_Order

TEST-CODE? [IF]     \ test code =============================================

6 FLOAT ARRAY ArrayZ{
5 FLOAT ARRAY ArrayY{
5 FLOAT ARRAY ArrayW{

\ initialize with data for real exponential integral
: horner_test_init ( -- )

     %   0.00107857  ArrayZ{ 5 } F!
     %  -0.00976004  ArrayZ{ 4 } F!
     %   0.05519968  ArrayZ{ 3 } F!
     %  -0.24991055  ArrayZ{ 2 } F!
     %   0.99999193  ArrayZ{ 1 } F!
     %  -0.57721566  ArrayZ{ 0 } F!

     %   1.0          ArrayY{ 4 } F!
     %   8.5733287401 ArrayY{ 3 } F!
     %  18.059016973  ArrayY{ 2 } F!
     %   8.6347608925 ArrayY{ 1 } F!
     %   0.2677737343 ArrayY{ 0 } F!

     %   1.0          ArrayW{ 4 } F!
     %   9.5733223454 ArrayW{ 3 } F!
     %  25.6329561486 ArrayW{ 2 } F!
     %  21.0996530827 ArrayW{ 1 } F!
     %   3.9584969228 ArrayW{ 0 } F!

;

: local_exp ( -- , f: x -- expint[x] )

        FDUP
        f1.0 F< IF
                    FDUP ArrayZ{  5 }Horner
                    FSWAP FLN F-
                ELSE
                    FDUP  ArrayY{ 4 }Horner
                    FOVER ArrayW{ 4 }Horner
                    F/
                    FOVER F/
                    FSWAP % -1.0 F* FEXP F*
                THEN
;

: do_both ( -- , f: x -- )

   FDUP FDUP
   ." X = " F.
   ." Horner: " local_exp F.
   ." ExpInt: " expint    F.
   CR
;

\ compare ExpInt as coded in V1.0 against the general purpose
\ Horner routine

: horner_test ( -- )

    horner_test_init

    CR
    %  0.2 do_both
    %  0.5 do_both
    %  1.0 do_both
    %  2.0 do_both
    %  5.0 do_both
    % 10.0 do_both
    
;

[THEN]




