\ DFourier                      Direct Fourier Transforms

\ Forth Scientific Library Algorithm #37

\ Perform the Direct Fourier Transform on an array using various algorithms.
\ DFT-T   -- uses table lookup
\ DFT-1   -- uses modified first-order Goertzel with reverse order input
\ DFT-2   -- uses modified second-order Goertzel with reverse order input
\ DFT-2F  -- uses second-order Goertzel with forward order input

\ This code conforms with ANS requiring:
\      1. The Floating-Point word set
\      2. The immediate word '%' which takes the next token
\         and converts it to a floating-point literal (for the test code).
\      3. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      4. The test code uses the word 'zpow' to raise a complex number
\         to a real power, 'Z/' to divide one complex number by another
\         and 'Z*' to multiply two complex numbers.

\ see:
\ Burrus, C.S. and T.W. Parks, 1985; DFT/FFT and Convolution
\ Algorithms, Theory and Implementation, John Wiley and Sons, New York,
\ 233 pages, ISBN 0-471-81932-8

\  (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\  author to use this software for any application provided this
\  copyright notice is preserved.

CR .( DFourier          V1.2            8 September 1994   EFC )

\ Private:

FLOAT DARRAY fx{
FLOAT DARRAY fy{
FLOAT DARRAY a{
FLOAT DARRAY b{

FLOAT DARRAY c{
FLOAT DARRAY s{

FVARIABLE cosine                \ scratch variables used by all but DFT-T
FVARIABLE sine

FVARIABLE cos2                   \ scratch variables used by DFT-2 and DFT-2F
FVARIABLE a2
FVARIABLE b2

1 VALUE dir                    \  1 for forward transform, -1 for inverse


: dft1-table-init ( n -- )                 \ build the DFT look-up table
        2.0E0 PI F* DUP S>F F/

        0 DO
            I dir * S>F FOVER F* FDUP
            FCOS c{ I } F!
            FSIN s{ I } F!
       LOOP

       FDROP
;

Public:

: DFT-T ( &x &y &a &b n di -- )            \ Direct Fourier Transform with
     TO dir                                \ table look-up
     >R
     &  b{ &!     &  a{ &!
     & fy{ &!     & fx{ &!
     R>


     & c{ OVER }malloc
     & s{ OVER }malloc

     DUP dft1-table-init

     DUP 0 DO
             0 fx{ OVER } F@    fy{ SWAP } F@

             0
             OVER 1 DO
                      J +
                      OVER 1- OVER < IF OVER - THEN

                      c{ OVER } F@ fy{ I } F@ F*
                      s{ OVER } F@ fx{ I } F@ F* F-  F+
                      FSWAP
                      c{ OVER } F@ fx{ I } F@ F*
                      s{ OVER } F@ fy{ I } F@ F* F+  F+
                      FSWAP
             LOOP

             DROP
             b{ I } F!
             a{ I } F!    
     LOOP

     DROP

     & c{ }free
     & s{ }free
     
;

: DFT-1 ( &x &y &a &b n di -- )             \ Direct Fourier Transform using
     TO dir                                 \ Goertzel's first order algorithm
     >R
     &  b{ &!     &  a{ &!
     & fy{ &!     & fx{ &!
     R>

     2.0E0 PI F* DUP S>F F/

     DUP 1- SWAP 0 DO
                      FDUP I dir * S>F F* FDUP FCOS  cosine F!
                                         FSIN  sine   F!
                                       
                      DUP  fx{ OVER } F@    fy{ SWAP } F@

                      DUP 1-  0 DO
                                 FOVER FOVER
                                 sine F@ F* FSWAP
                                 cosine F@ F* F+
                                 fx{ OVER I - 1- } F@ F+
                                 FROT FROT
                                 cosine F@ F*
                                 FSWAP  sine F@ F* F-
                                 fy{ OVER I - 1- } F@ F+
                     LOOP
                     
                     FOVER FOVER
                     sine F@ F* FSWAP
                     cosine F@ F* F+
                     fx{ 0 } F@ F+     a{ I } F!

                     cosine F@ F* FSWAP
                     sine F@ F* F-
                     fy{ 0 } F@ F+     b{ I } F!                     
     LOOP

     DROP
     FDROP
     
;

: DFT-2 ( &x &y &a &b n di -- )             \ Direct Fourier Transform using
     TO dir                                 \ Goertzel's second order algorithm,
     >R                                     \ with reverse order input
     &  b{ &!     &  a{ &!
     & fy{ &!     & fx{ &!
     R>

     2.0E0 PI F* DUP S>F F/

     DUP 1- SWAP 0 DO
                      FDUP I dir * S>F F* FDUP FCOS  FDUP cosine F!
                      2.0E0 F* cos2 F!
                                         FSIN  sine   F!
                                       
                      DUP  fy{ OVER } F@    fx{ SWAP } F@
                      0.0E0 a2 F!    0.0E0 b2 F!
                      
                      DUP 1-  0 DO
                                 FDUP cos2 F@ F* a2 F@ F-
                                 fx{ OVER I - 1- } F@ F+
                                 FSWAP a2 F!
                                 FSWAP
                                 FDUP cos2 F@ F* b2 F@ F-
                                 fy{ OVER I - 1- } F@ F+
                                 FSWAP b2 F!
                                 FSWAP
                     LOOP
                     
                     FOVER FOVER
                     cosine F@ F* a2 F@ F-
                     FSWAP
                     sine F@ F* F+
                     fx{ 0 } F@ F+     a{ I } F!

                     sine F@ F* FSWAP
                     cosine F@ F* b2 F@ F- FSWAP
                     F-
                     fy{ 0 } F@ F+     b{ I } F!                     
     LOOP

     DROP
     FDROP
     
;

: DFT-2F ( &x &y &a &b n di -- )            \ Direct Fourier Transform using
     TO dir                                 \ Goertzel's second order algorithm,
     >R                                     \ with forward order input
     &  b{ &!     &  a{ &!
     & fy{ &!     & fx{ &!
     R>

     2.0E0 PI F* DUP S>F F/

     DUP  0 DO
                      FDUP I dir * S>F F* FDUP FCOS  FDUP cosine F!
                      2.0E0 F* cos2 F!
                                         FSIN  sine   F!
                                       
                      0  fy{ OVER } F@    fx{ SWAP } F@
                      0.0E0 a2 F!    0.0E0 b2 F!
                      
                      DUP  1 DO
                                 FDUP cos2 F@ F* a2 F@ F-
                                 fx{ I } F@ F+
                                 FSWAP a2 F!
                                 FSWAP
                                 FDUP cos2 F@ F* b2 F@ F-
                                 fy{ I } F@ F+
                                 FSWAP b2 F!
                                 FSWAP
                     LOOP
                     
                     FOVER FOVER
                     cosine F@ F* a2 F@ F-
                     FSWAP
                     sine F@ F* F-
                     a{ I } F!

                     sine F@ F* FSWAP
                     cosine F@ F* F+ b2 F@ F- 
                     b{ I } F!                     
     LOOP

     DROP
     FDROP
     
;


Reset_Search_Order

TEST-CODE? [IF]     \ test code =============================================


19 FLOAT ARRAY xx{
19 FLOAT ARRAY yy{
19 FLOAT ARRAY aa{
19 FLOAT ARRAY bb{

: dftest1-init ( n -- )
       2.0E0 PI F*   DUP S>F F/
       0 DO
             I S>F FOVER F* FDUP
             3.0E0 F* FCOS   xx{ i } F!
             FSIN 0.4E0 F*   yy{ i } F!

       LOOP

       FDROP
;

: dftest2-init ( n -- )       \ a chirp signal test
       0 DO
             0.9E0 0.3E0 R,I->Z I S>F  zpow  Z->R,I
             yy{ I } F!
             xx{ I } F!
       LOOP

;


ZVARIABLE w
ZVARIABLE dc

: chirp-actual-ft ( n -- )

       2.0E0 PI F*
       DUP S>F F/
       FDUP FCOS FSWAP FSIN FNEGATE  R,I->Z  w Z!

       Z% 0.9 0.3 DUP S>F      zpow
       1+0i ZSWAP Z-
       dc Z!
       
       0 DO

             \ stack numerator for later division
             dc Z@

             \ calculate the denominator
             w Z@ I S>F ZPOW
             Z% 0.9 0.3  Z*
             1+0i ZSWAP  Z-

             Z/  Z->R,I

             yy{ I } F!
             xx{ I } F!
         LOOP
;


: dfourier-test1 ( -- )

    CR
    19 dftest1-init
    ." Initial array: " CR 19 xx{ }fprint CR
                           19 yy{ }fprint CR
                        
    xx{ yy{ aa{ bb{ 19 1 DFT-T

    ." Transformed array (table method) : " CR 19 aa{ }fprint CR
                                               19 bb{ }fprint CR
    xx{ yy{ aa{ bb{ 19 1 DFT-1

     ." transformed array (1st order method): " CR
     19 aa{ }fprint CR
     19 bb{ }fprint CR

    xx{ yy{ aa{ bb{ 19 1 DFT-2

     ." transformed array (2nd order method): " CR
     19 aa{ }fprint CR
     19 bb{ }fprint CR

    xx{ yy{ aa{ bb{ 19 1 DFT-2F

     ." transformed array (2nd order forward method): " CR
     19 aa{ }fprint CR
     19 bb{ }fprint CR

;

v: DFT                          \ execution vector for DFT
& DFT-T defines DFT             \ initialize to use DFT-T
                                \ also try DFT-1, DFT-2, and DFT-2F

: dfourier-test2 ( -- )

        CR
        19 dftest2-init
        xx{  yy{ aa{ bb{ 19 1 DFT

        ." Transformed array: " CR 19 aa{ }fprint CR
                                   19 bb{ }fprint CR
        19 chirp-actual-ft

        ." Analytic value : "   CR 19 xx{ }fprint CR
                                   19 yy{ }fprint CR

;


[THEN]





