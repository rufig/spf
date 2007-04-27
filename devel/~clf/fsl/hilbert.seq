\ HILBERT      Hilbert matrix routines

\ Forth Scientific Library Algorithm #25

\ HILBERT      Generates a finite segment of a Hilbert Matrix
\ HILBERT-INV  generates the inverse of a finite segment of a Hilbert
\              Matrix (ACM #50)
\ HILBERT-DET  calculates the determinant for a Hilbert matrix of a given order


\ These matrices provide severe test cases for matrix inverters and determinant
\ calculation routines.  They become numerically ill-conditioned even for
\ moderate sizes of 'n'.

\ This is an ANS Forth program requiring:
\      1. The Floating-Point word set (and a separate float stack)
\      2. The word 'S>F' to convert an integer to a float
\      3. The word '}}' to dereference a two-dimensional array.
\      4. The test code Uses '}}malloc' and '}}free' to allocate and
\         release memory for dynamic matrices ( 'DMATRIX' ).
\      5. The compilation of the test code is controlled by the VALUE TEST-CODE?
\         and the conditional compilation words in the Programming-Tools wordset


\ Collected Algorithms from ACM, Volume 1 Algorithms 1-220,
\ 1980; Association for Computing Machinery Inc., New York,
\ ISBN 0-89791-017-6


\  (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\  author to use this software for any application provided this
\  copyright notice is preserved.


CR .( HILBERT           V1.1           13 October 1994   EFC )


: HILBERT ( &h n -- )             \ stores in array with address &h

     DUP 0 DO
            DUP 0 DO
                    1.0E0 I J + 1+ S>F F/
                    OVER I J }} F!
            LOOP

     LOOP

     2DROP
;


: HILBERT-INV ( &s n -- )       \ stores inverse in array with address &s

      DUP S>F FDUP F* FDUP
      OVER 0 0 }} F!
      
      DUP 1 ?DO                \ do diagonals
                DUP I +
                OVER I - *   S>F
                I DUP *      S>F F/
                FDUP F* F*
                
                FDUP OVER I I }} F!
                
            LOOP

      FDROP


      DUP 1- 0 ?DO                \ do off-diagonals
                 DUP I 1+ DO
                            DUP  I +
                            OVER I - * S>F
                            I DUP * S>F F/
                            FNEGATE
                            OVER J I 1- }} F@ F*
                            OVER J I }} F!                      
                 LOOP
               LOOP


      1 ?DO                         \ normalize
           I 1+ 0 DO
                    I J + 1+ S>F
                    DUP I J }} DUP F@ FSWAP F/
                    FDUP F!
                    DUP J I }} F!
           LOOP
           
      LOOP

      DROP
;

: HILBERT-DET ( n -- ) ( F: -- det )      \ calculates determinant of n order matrix
                                          \ the actual matrix is implicit

       1.0E0  1.0E0
               DUP 0 DO

                      DUP 0 DO
                              I J < IF   \ numerator accumulation
                                        I J - S>F FDUP F* FROT F* FSWAP
                                    THEN

                              I J + 1+ S>F F*            \ denominator accumulation

                      LOOP

                 LOOP
       DROP

       F/
;


TEST-CODE? [IF]   \ test code ==============================================


FLOAT DMATRIX s{{

: invresults-for-4 ( -- )

       CR
       ." For n = 4, the inverse is: " CR
       ."   16  -120   240  -140 " CR
       ." -120  1200 -2700  1680 " CR
       ."  240 -2700  6480 -4200 " CR
       ." -140  1680 -4200  2800 " CR
;

: results-for-4 ( -- )

       CR
       ." For n = 4, the matrix is: " CR
       ."  1      0.5      0.333333 0.25 " CR
       ."  0.5    0.333333 0.25     0.2 " CR
       ."  0.333333 0.25   0.2      0.166667 " CR
       ."  0.25   0.2      0.166667 0.142857 " CR

;

: hilbert-test ( n -- )

         CR

         & s{{ OVER DUP }}malloc

         malloc-fail? ABORT" malloc failure "
         
         s{{ OVER HILBERT

         ." The Hilbert Matrix: " CR
         DUP DUP s{{ }}fprint

         DUP 4 = IF results-for-4 THEN


         CR
         ." The INVERSE Hilbert Matrix: " CR
         s{{ OVER HILBERT-INV

         DUP DUP s{{ }}fprint

         DUP 4 = IF invresults-for-4 THEN

         & s{{ }}free

         HILBERT-DET         
         CR ." The determinant: " F. CR

;


\ 2 HILBERT-DET f.         0.0833333
\ 3 HILBERT-DET f.         0.000462963
\ 4 HILBERT-DET f.         1.65344e-7
\ 5 HILBERT-DET f.         3.7493E-12


[THEN]

