\ FDivDiffs   BDivDiffs          Forward and Backward divided differences

\ Forth Scientific Library Algorithm #12

\ Caluclates forward or backward divided differences from a set of n floating
\ point values x{} and y{}, the results are returned in difs{}, the original
\ data is preserved.

\ This code conforms with ANS requiring:
\      1. The Floating-Point word set
\      2. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      3. Uses the words 'DARRAY' and '&!' to alias arrays.
\      4. The immediate word '&' to get the address of an array
\         at either compile or run time.

\ see, e.g.
\ Conte, S.D. and C. deBoor, 1972; Elementary Numerical Analysis, an algorithmic
\ approach, McGraw-Hill, New York, 396 pages


\ (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.

CR .( DivDiffs          V1.3           31 October 1994   EFC )

Private:

FLOAT DARRAY x{                   \ array pointers
FLOAT DARRAY y{

: }fcopy ( n &src &dest -- )

    ROT 0 DO
                OVER I } F@
                DUP  I } F!
          LOOP

          2DROP
;

Public:

: forward_div_difs ( &x &yin &y n -- )
       >R
       & y{ &!
       SWAP & x{ &!
       R>

       DUP ROT y{ }fcopy

       1-

       DUP 0 DO
                DUP I - 0 DO
                             y{ I 1+ } F@ y{ I } F@ F-
                             x{ I J + 1+ } F@ x{ I } F@ F-
                             F/
                             y{ I } F!
                           LOOP
             LOOP
       DROP
;

: backward_div_difs ( &x &yin &y n -- )
       >R
       & y{ &!
       SWAP & x{ &!
       R>

       DUP ROT y{ }fcopy
       
       1- DUP 0 DO
                  I 1+ OVER DO
                             y{ I } F@ y{ I 1-  } F@ F-
                             x{ I } F@ x{ I J - 1- } F@ F-
                             F/
                             y{ I } F!
                        -1 +LOOP
             LOOP
       DROP
;

Reset_Search_Order


