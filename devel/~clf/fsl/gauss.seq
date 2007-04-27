\ Gauss       The Gaussian (Normal) probablity function   ACM Algorithm #209
\ Calulates, z = 1/sqrt( 2 pi ) \int_-\infty^x exp( - 0.5 u^2 ) du
\ by means of polynomial approximations.   Accurate to 6 places.

\ Forth Scientific Library Algorithm #42

\ This is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      3. Uses the words 'FLOAT' and ARRAY to create floating point arrays.
\      4. The word '}' to dereference a one-dimensional array.
\      5. Uses the FSL word '}Horner' for fast polynomial evaluation.
\      6. The compilation of the test code is controlled by VALUE TEST-CODE?
\         and the conditional compilation words in the
\         Programming-Tools wordset.

\ Collected Algorithms from ACM, Volume 1 Algorithms 1-220,
\ 1980; Association for Computing Machinery Inc., New York,
\ ISBN 0-89791-017-6

\ (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.


CR .( GAUSS             V1.0            2 November 1994   EFC )

Private:

15 FLOAT ARRAY big{
 9 FLOAT ARRAY small{

: init-gauss-arrays
       0.999936657524E0 big{ 0 } F!        0.000535310849E0 big{ 1 } F!
      -0.002141268741E0 big{ 2 } F!        0.005353579108E0 big{ 3 } F!
      -0.009279453341E0 big{ 4 } F!        0.011630447319E0 big{ 5 } F!
      -0.010557625006E0 big{ 6 } F!        0.006549791214E0 big{ 7 } F!
      -0.002034254874E0 big{ 8 } F!       -0.000794620820E0 big{ 9 } F!
       0.001390604284E0 big{ 10 } F!      -0.000676904986E0 big{ 11 } F!
      -0.000019538132E0 big{ 12 } F!       0.000152529290E0 big{ 13 } F!
      -0.000045255659E0 big{ 14 } F!

       0.797884560593E0 small{ 0 } F!     -0.531923007300E0 small{ 1 } F!
       0.319152932694E0 small{ 2 } F!     -0.151968751364E0 small{ 3 } F!
       0.059054035624E0 small{ 4 } F!     -0.019198292004E0 small{ 5 } F!
       0.005198775019E0 small{ 6 } F!     -0.001075204047E0 small{ 7 } F!
       0.000124818987E0 small{ 8 } F!
;

init-gauss-arrays

: gauss-small-y ( -- ) ( F: y -- z )

       FDUP FDUP F*
       small{ 8 }Horner
       F* 2.0E0 F*
;

: gauss-mid-y ( -- ) ( F: y -- z )
      2.0E0 F-
      big{ 14 }Horner
;

Public:


: gauss ( -- ) ( f: x -- gauss{x} )

        FDUP F0= IF
                    F0< 0.0E0
                 ELSE

                    FDUP F0<            \ push flag for sign of x
                    FABS 2.0E0 F/

                    FDUP 1.0E0 F<  IF
                                      gauss-small-y
                                   ELSE
                                      FDUP 4.85E0 F< IF
                                                      gauss-mid-y
                                                     ELSE
                                                      FDROP 1.0E0
                                                     THEN
                                   THEN
                                   
                 THEN


      IF ( x < 0 )    FNEGATE THEN

      1.0E0 F+ 2.0E0 F/

;

Reset_Search_Order

TEST-CODE? [IF]   \ test code ========================================

: gauss-test ( -- )

      CR
      
      ." gauss(  5.0 ) = "  5.0E0 gauss F.    ." (should be 1.0) " CR
      ." gauss( -1.5 ) = " -1.5E0 gauss F.    ." (should be 0.0668072) " CR
      ." gauss( -0.5 ) = " -0.5E0 gauss F.    ." (should be 0.308538) " CR
      ." gauss(  0.5 ) = "  0.5E0 gauss F.    ." (should be 0.691462) " CR
         
      CR


;

[THEN]






