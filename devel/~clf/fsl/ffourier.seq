\ FFourier                      Fast Fourier Transforms

\ Forth Scientific Library Algorithm #38

\ Perform the Fast Fourier Transform on an array using various algorithms
\ based upon the Cooley-Tukey Decimation-in-Frequency technique.
\ FFT2-1   -- basic radix-2 one butterfly Cooley-Tukey FFT
\ FFT2-1T  -- Radix-2 one butterfly FFT with table look-up
\ FFT2-1TF -- Radix-2 one butterfly FFT with twiddle factor update
\ FFT2-2T  -- Radix-2 two butterfly FFT with table look-up
\ FFT2-3T  -- Radix-2 three butterfly FFT with table look-up

\ expects input data to be of length n = 2^m
\ (i.e. n is a power of 2 and m is that power)

\ Note for the table look-up forms:
\       If several transforms of the same length are to be performed,
\       it would be more efficient to allocate and create the table
\       ONCE outside the routine.  The routine would also NOT free
\       the table in this case.

\ This code is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      3. Uses the words 'FLOAT' and 'DARRAY' to create floating point arrays
\      4. The FCONSTANT PI (3.1415926536...)
\      5. The immediate word '&' to get word addresses and '&!' to alias
\         arrays to 'DARRAY'.
\      6. The test code uses the word 'zpow' to raise a complex number
\         to a real power, 'Z/' to divide one complex number by another,
\         'Z*' to multiply two complex numbers, and Z% to indicate complex
\         literals (See FSL files COMPLEX and CMATH)
\      7. The compilation of the test code is controlled by VALUE TEST-CODE?
\         and the conditional compilation words in the Programming-Tools
\         wordset

\ see:
\ Burrus, C.S. and T.W. Parks, 1985; DFT/FFT and Convolution
\ Algorithms, Theory and Implementation, John Wiley and Sons, New York,
\ 233 pages, ISBN 0-471-81932-8

\  (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\  author to use this software for any application provided this
\  copyright notice is preserved.

CR .( FFourier          V1.2           15 September 1994   EFC )

Private:

FLOAT DARRAY fx{
FLOAT DARRAY fy{

FLOAT DARRAY wr{              \ for tabular version (FFT2-1T)
FLOAT DARRAY wi{

FVARIABLE cosine                \ scratch variables used by all
FVARIABLE sine

FVARIABLE c1                    \ scratch variables used by FFT2-1TF
FVARIABLE s1

VARIABLE ia                    \ scratch variables used by table forms
VARIABLE ie                    \ (FFT2-1T, FFT2-2T, FFT2-3T)

1 VALUE dir                    \  1 for forward transform, -1 for inverse

: digit-reverse1 ( n -- )

         DUP 1- 0 SWAP 0 DO
                           I OVER < IF
                                      fx{ OVER } F@
                                      fx{ I } F@ fx{ OVER } F!
                                      fx{ I } F!

                                      fy{ OVER } F@
                                      fy{ I } F@ fy{ OVER } F!
                                      fy{ I } F!
                                    THEN

                                    OVER
                                    BEGIN
                                       2/
                                      OVER OVER SWAP > 0=
                                    WHILE
                                      SWAP OVER -
                                      SWAP
                                    REPEAT

                                    +
                         LOOP

         DROP DROP
;

: fft1-table-init ( n -- )                 \ build the FFT look-up table

        2.0E0 PI F* DUP S>F F/

        0 DO
            I dir * S>F FOVER F* FDUP
            FCOS           wr{ I } F!
            FSIN           wi{ I } F!     \ note sign difference from
       LOOP                               \ Burrus and Parks

       FDROP

;

: Main-Butterfly ( n n2 n1 start -- n n2 n1 )
           3 PICK SWAP DO
                        OVER I +
                        fx{ I } F@ fx{ OVER } F@ F-
                        fx{ I } F@ fx{ OVER } F@ F+
                        fx{ I } F!
                                       
                        fy{ I } F@ fy{ OVER } F@ F-
                        fy{ I } F@ fy{ OVER } F@ F+
                        fy{ I } F!
                                       
                        FOVER FOVER
                        sine F@ F* FSWAP cosine F@ F* F+
                        fx{ OVER } F!
                        cosine F@ F* FSWAP sine F@ F* F-
                        fy{ SWAP } F!
                DUP +LOOP
;

: First-Butterfly ( n n2 n1 -- n n2 n1 )
            2 PICK 0 DO
                       OVER I +
                       fx{ I } F@ fx{ OVER } F@ F-
                       fx{ I } F@ fx{ OVER } F@ F+
                       fx{ I } F!
                       fx{ OVER } F!
                              
                       fy{ I } F@ fy{ OVER } F@ F-
                       fy{ I } F@ fy{ OVER } F@ F+
                       fy{ I } F!
                       fy{ SWAP } F!
            DUP +LOOP
;

: Third-Butterfly ( n n2 n1 start -- n n2 n1 )
            3 PICK SWAP DO
                          OVER I +
                          fx{ OVER } F@ fx{ I } F@ F-
                          fx{ I } F@ fx{ OVER } F@ F+
                          fx{ I } F!
                                          
                          fy{ I } F@ fy{ OVER } F@ F-
                          fy{ I } F@ fy{ OVER } F@ F+
                          fy{ I } F!

                          fx{ OVER } F!
                          fy{ SWAP } F!
            DUP +LOOP
;


Public:

: FFT2-1 ( &x &y n m di -- )                 \ One-butterfly Fast Fourier
     TO dir                                  \ Transform, radix-2
     ROT  & fy{ &!
     ROT  & fx{ &!


     OVER SWAP 0 DO
                   DUP 2/ SWAP
                   2.0E0 PI F* DUP S>F F/
                   0.0E0
                   OVER 0 DO
                            FDUP FCOS cosine F!
                            FSIN sine   F!
                            FDUP I 1+ dir * S>F F*

                            I Main-Butterfly

                   LOOP

                 DROP FDROP FDROP
              LOOP

              DROP
              digit-reverse1
;

: FFT2-1T ( &x &y n m di -- )              \ One-butterfly Fast Fourier
     TO dir                                \ Transform, radix-2 w table look-up
     ROT  & fy{ &!
     ROT  & fx{ &!


     OVER & wr{ OVER }malloc
     DUP  & wi{ OVER }malloc

     fft1-table-init


     SWAP 0 DO
                   DUP 2/ SWAP
                   2 PICK OVER /
                   0
                   3 PICK 0 DO
                            DUP wr{ OVER } F@  cosine F!
                                wi{ SWAP } F@  sine   F!
                            OVER +

                            ia ! ie !
                            I Main-Butterfly
                            ie @ ia @
                   LOOP

                   DROP 2DROP
              LOOP

              DROP
              digit-reverse1

              & wr{ }free
              & wi{ }free
;

: FFT2-1TF ( &x &y n m di -- )            \ One-butterfly Fast Fourier
     TO dir                               \ Transform, radix-2, with
     ROT  & fy{ &!                        \ twiddle factor update
     ROT  & fx{ &!


     OVER SWAP 0 DO
                   DUP 2/ SWAP
                   2.0E0 PI F* dir S>F F* DUP S>F F/
                   FDUP FCOS   c1 F!
                        FSIN   s1 F!
                   1.0E0  cosine F!   0.0E0  sine F!
                   OVER 0 DO
                            I Main-Butterfly
                            cosine F@
                            FDUP c1 F@ F*   sine F@ s1 F@ F* F-
                            cosine F!
                            s1 F@ F*        sine F@ c1 F@ F* F+
                            sine F!                                 
                   LOOP

                 DROP
              LOOP

              DROP
              digit-reverse1
;


: FFT2-2T ( &x &y n m di -- )          \ Two-butterfly Fast Fourier
     TO dir                            \ Transform, radix-2 w table look-up
     ROT  & fy{ &!
     ROT  & fx{ &!


     OVER & wr{ OVER }malloc
     DUP  & wi{ OVER }malloc

     fft1-table-init


     SWAP 1- 0 DO
                   DUP 2/ SWAP
                   First-Butterfly

                   2 PICK OVER /
                   0
                   3 PICK 1 DO
                            OVER +
                            wr{ OVER } F@  cosine F!
                            wi{ OVER } F@  sine   F!
                            
                            ia ! ie !
                            I Main-Butterfly
                            ie @ ia @
                   LOOP

                   DROP 2DROP
              LOOP

         DUP 2/ SWAP
         First-Butterfly

         2DROP
                            
         digit-reverse1

         & wr{ }free
         & wi{ }free
;

: FFT2-3T ( &x &y n m di -- )         \ Three-butterfly Fast Fourier
     TO dir                           \ Transform, radix-2 w table look-up
     ROT  & fy{ &!
     ROT  & fx{ &!

     OVER & wr{ OVER }malloc
     DUP  & wi{ OVER }malloc

     fft1-table-init


     SWAP 1- 0 DO
                   DUP 2/ SWAP
                   First-Butterfly

                   2 PICK OVER /
                   0
                   
                   3 PICK 1 DO
                            OVER + ia ! ie !
                            OVER I = IF
                                        I Third-Butterfly
                                     ELSE
                                          ia @
                                          wr{ OVER } F@  cosine F!
                                          wi{ SWAP } F@  sine   F!
                            
                                          I Main-Butterfly
                                     THEN
                           ie @ ia @
                   LOOP

                   DROP DROP DROP
              LOOP

         DUP 2/ SWAP
         First-Butterfly

         2DROP
                            
         digit-reverse1

         & wr{ }free
         & wi{ }free
;


: }FFT-Normalize ( &x n -- )
   DUP 0 DO OVER I } DUP F@ OVER S>F F/ F! LOOP
   2DROP
;

Reset_Search_Order


TEST-CODE? [IF]     \ test code =============================================

16 FLOAT ARRAY xx{
16 FLOAT ARRAY yy{

: fftest1-init ( n -- )
       2.0E0 PI F*   DUP S>F F/
       0 DO
             I S>F FOVER F* FDUP
             3.0E0 F* FCOS   xx{ I } F!
             FSIN 0.4E0 F*   yy{ I } F!

       LOOP

       FDROP
;

: fftest2-init ( n -- )       \ a chirp signal test
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


v: fft                           \ execution vector for FFT
& FFT2-1 defines fft             \ initialize to use FFT2-1
                                 \ also try FFT2-1T, FFT2-1TF,
                                 \ FFT2-2T, FFT2-3T



: ffourier-test1 ( -- )

    CR
    16 fftest1-init
    ." Initial array: " CR 16 xx{ }fprint CR
                           16 yy{ }fprint CR
                        
    xx{ yy{ 16 4 1 fft

    ." Transformed array : "  CR      16 xx{ }fprint CR
                                      16 yy{ }fprint CR

   xx{ 16 }FFT-Normalize      yy{ 16 }FFT-Normalize

   xx{ yy{ 16 4 -1 fft
   ." Inverse transformed array: "  CR        16 xx{ }fprint CR
                                              16 yy{ }fprint CR

;

: ffourier-test2 ( -- )

        CR
        16 fftest2-init
        xx{ yy{ 16 4 1 fft

        ." Transformed array: " CR 16 xx{ }fprint CR
                                   16 yy{ }fprint CR
        16 chirp-actual-ft

        ." Analytic value : "   CR 16 xx{ }fprint CR
                                   16 yy{ }fprint CR

;


[THEN]







