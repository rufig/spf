\ Hermite             Hermite Interpolation        ACM Algorithm #211

\ Forth Scientific Library Algorithm #10

\ Evaluates the (2N-1)th degree Hermite Polynomial, given N data coordinates
\ plus the first derivatives and the value where interpolation is desired.
\
\ This is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. The immediate word '%' which takes the next token
\         and converts it to a floating-point literal
\      3. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      4. Uses the words 'DARRAY' and '&!' to alias arrays.
\      5. The immediate word '&' to get the address of an array
\         at either compile or run time.
\      6. The compilation of the test code is controlled by the VALUE TEST-CODE?
\         and the conditional compilation words in the Programming-Tools wordset
\      7. The second test uses 'Logistic' and 'D_Logistic' for the
\         logistic equation and its first derivative

\ Collected Algorithms from ACM, Volume 1 Algorithms 1-220,
\ 1980; Association for Computing Machinery Inc., New York,
\ ISBN 0-89791-017-6

\ (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.

CR .( HERMITE           V1.2           20 August 1994   EFC )

Private:

FLOAT DARRAY x{                   \ array pointers
FLOAT DARRAY y{
FLOAT DARRAY y1{

Public:

: Hermite ( &x &y & y1 n -- ) ( f: u -- ans )
        >R
        & y1{ &!
        & y{  &!
        & x{  &!
        R>
        
        % 0.0 FSWAP
        DUP 0 DO
                    % 1.0   % 0.0         ( n -- n , f: ans u -- ans u h a )
                    DUP 0 DO
                          I J = 0= IF
                                       \ update value of a
                                       % 1.0
                                       x{ J } F@ x{ I } F@ F- F/ F+

                                       \ now update h
                                       FROT FROT
                                       FOVER
                                       x{ I } F@ F- FDUP F*
                                       x{ J } F@ x{ I } F@ F- FDUP F*
                                       F/ F*

                                       FROT
                                       
                                     THEN
                     LOOP

                    % 2.0 F* y{ I } F@ F* y1{ I } F@ F-
                    FROT x{ I } F@ FOVER F-
                    FROT F*  y{ I } F@ F+
                    FROT F*

                    FROT F+ FSWAP
             LOOP

         DROP FDROP
;


Reset_Search_Order

TEST-CODE? [IF]   \ test code ==============================================


9 FLOAT ARRAY x{
9 FLOAT ARRAY y{
9 FLOAT ARRAY y1{

: H_coords1 ( -- )

     9 0 DO I S>F % 0.25 F*
          FDUP x{ I } F!
          FDUP FSIN y{ I } F!
          FCOS y1{ I } F!
     LOOP

;

: hermite_test1 ( -- ) ( f: u -- )    \ u can be in the range 0..2 for this test

           H_coords1

           FDUP FDUP CR ." Interpolation point: " F. CR

           FSIN FSWAP             \ get exact value for later

           x{  y{  y1{ 9 Hermite

          ."      interpolated value: " F.
          ."   exact value: " F. CR


;

: H_coords2 ( -- )

     5 0 DO I 2* S>F % -4.0 F+
            FDUP x{ I } F!
            FDUP % 1.0 % 1.0 logistic y{ I } F!
            % 1.0 % 1.0 d_logistic y1{ I } F!
     LOOP
;

: hermite_test2 ( -- ) ( f: u -- )    \ u can be in the range -4..4 for this test

           H_coords2

           FDUP FDUP CR ." Interpolation point: " F. CR

           % 1.0 % 1.0 logistic FSWAP             \ get exact value for later

           x{  y{  y1{ 5 Hermite

          ."      interpolated value: " F.
          ."   exact value: " F. CR


;


[THEN]
