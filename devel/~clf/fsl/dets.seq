\ Dets      Determinant of a matrix in LU form

\ Forth Scientific Library Algorithm #34

\ det       The determinant of a matrix in LU form
\ det-i     The determinant of a matrix in LU form, result returned as
\           as a factor and a power of 10 (useful for very large and
\           very small determinants).

\ Presumes that the matrix has been converted in LU form (using LUFACT)
\ before being called.

\ This code is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      3. Uses the words 'FLOAT' and 'DARRAY' to create floating point arrays
\         plus 'INTEGER' to create integer arrays.
\      4. The word '}' to dereference a one-dimensional array, and '}}' to
\         dereference two dimensional arrays.
\      5. Uses the words 'DARRAY' and '&!' to set array pointers.
\      6. The compilation of the test code is controlled by the VALUE TEST-CODE?
\         and the conditional compilation words in the Programming-Tools wordset
\      7. The test code uses 'HILBERT' and 'HILBERT-DET' for generating the testt

\ see,
\ Baker, L., 1989; C Tools for Scientists and Engineers,
\ McGraw-Hill, New York, 324 pages,   ISBN 0-07-003355-2


\  (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\  author to use this software for any application provided this
\  copyright notice is preserved.


CR .( DETS              V1.0           13 October 1994   EFC )


Private:


FLOAT  DMATRIX a{{            \ pointer to users matrix
INTEGER DARRAY pivot{          \ pointer to users array of LU pivots

: ?ODD ( n -- t/f )

     DUP 2/ 2* -
;

: large-det ( exp s -- exp' s ) ( F: det -- det' )

                  BEGIN
                    % 0.10 F*
                    SWAP 1+ SWAP

                    % 10.0 FOVER FABS F< 0=
                  UNTIL

;

: small-det ( exp s -- exp' s ) ( F: det -- det' )

                  BEGIN
                    % 10.0 F*
                    SWAP 1- SWAP

                    FDUP FABS % 0.10 F< 0=
                  UNTIL

;

Public:

: det ( &dlu -- ) ( F: -- det )

      2DUP ->MATRIX{{ & a{{ &!
      2DUP ->PIVOT{   & pivot{ &!
      
      1.0E0
      ->N @ 0 SWAP 0 DO
                  a{{ I I }} F@ F*
                  pivot{ I } @ I = 0= IF 1+ THEN
               LOOP

      ?ODD IF FNEGATE THEN
               
;

: deti ( &dlu -- exp ) ( F: -- det )     \ det = x * 10^exp

      2DUP ->MATRIX{{ & a{{ &!
      2DUP ->PIVOT{   & pivot{ &!

      1.0E0
      ->N @
      0 0 ROT 0 DO
                  a{{ I I }} F@ F*
                  pivot{ I } @ I = 0= IF 1+ THEN

                  % 10.0 FOVER FABS F< IF
                                            large-det
                                       ELSE
                                            FDUP FABS % 0.10 F< IF
                                                                   small-det
                                                                THEN
                                       THEN


               LOOP

      ?ODD IF FNEGATE THEN
               
;

Reset_Search_Order

TEST-CODE? [IF]   \ test code ==============================================

\ test code, creates a finite segment of a Hilbert matrix of the specified
\ size and gets its determinant.  Uses the known form for the determinant
\ of these matrices to calculate the comparison value.

\ Dynamically allocated array space
FLOAT DMATRIX mat{{

LUMATRIX lmat


: det-test ( n -- )

         & mat{{ OVER DUP }}malloc
         malloc-fail? ABORT" malloc failure (1) "

        mat{{ OVER HILBERT
        
        CR ." A: " CR
        DUP DUP mat{{ }}fprint

        lmat 2 PICK LU-MALLOC

        mat{{ lmat lufact

        lmat det

        CR ." DET(A): " F.
        
        lmat deti

        F. ." X 10^ " . CR

       \ now calculate the determinant directly, since it is a Hilbert matrix

       HILBERT-DET

       CR ." DET-Hilbert: " F. CR

         & mat{{ }}free
         lmat LU-FREE
         
;

[THEN]

