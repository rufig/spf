\ BNewt FNewt     Newton Interpolation           ACM Algorithm #168 and #169

\ Forth Scientific Library Algorithm #13

\ BNewt   Newton Interpolation with backward differences   ACM Algorithm #168
\ FNewt   Newton Interpolation with forward  differences   ACM Algorithm #169

\ These routines use the Newton interpolation scheme to interpolate
\ within N data points (X).  The interpolated data (dif) has to be passed
\ as either backward divided differences or forward divided differences
\ depending upon which routine is used.  The interpolation point (z) is expected
\ on the float stack.

\ The routine returns 3 floating point values, the interpolated value (p),
\ the estimate of the first derivative (d), and an estimated error bound (e).
\ In practice the error bound estimate does not seem very accurate.

\ This is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      3. Uses the words 'DARRAY' and '&!' to alias arrays.
\      4. The immediate word '&' to get the address of an array
\         at either compile or run time.
\      5. Uses Divided Differences words, 'forward_div_difs' and
\         'backward_div_difs'
\      6. The compilation of the test code is controlled by the VALUE TEST-CODE?
\         and the conditional compilation words in the Programming-Tools wordset.
\      7. The test code uses the immediate word '%' which takes the next token
\         and converts it to a floating-point literal
\      8. The second test uses 'logistic' for the logistic equation.
\

\ Collected Algorithms from ACM, Volume 1 Algorithms 1-220,
\ 1980; Association for Computing Machinery Inc., New York,
\ ISBN 0-89791-017-6

\ (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.

CR .( Newton            V1.4           31 October 1994   EFC )

Private:

FLOAT DARRAY xn{
FLOAT DARRAY dif{

FVARIABLE z

: z1 ( i -- ) ( f: -- z1 )
      z F@
      xn{ SWAP } F@ F-
;

: Newton ( i -- ) ( f: e d p -- e d p )

             \ calculate new D
             DUP z1
             FROT F* FOVER F+

             \ calculate new P
             FSWAP
             DUP z1
             F* dif{ OVER } F@ F+

             \ calculate new E
             FROT
             z1 FABS
             F*
             FOVER FABS F+

             \ restore stack order
             FROT FROT

;

: scale_error ( -- ) ( f: e d p -- e d p )
          FROT
          1.5e0 F*
          FOVER FABS F-
          1.0e-5 F*
          FROT FROT
;


Public:

: FNewt ( &xn &dif n -- ) ( f: z -- e d p)
        >R
        & dif{ &!
        & xn{  &!
        R>

        z F!        
        0.0e0  0.0e0 0.0e0

        \ this loop direction is opposite what is in the original
        \ publication, but apparently the original pub is wrong here.
        0 DO
             I Newton
          LOOP

          \ scale error estimate
          scale_error
;

: BNewt ( &xn &dif n -- ) ( f: z -- e d p )
        >R
        & dif{ &!
        & xn{  &!
        R>

        z F!        
        0.0e0  0.0e0 0.0e0
        
        \ this loop direction is opposite what is in the original
        \ publication, but apparently the original pub is wrong here.
        1- 0 SWAP DO
                    I Newton
                   -1 +LOOP

          \ scale error estimate
          scale_error
;


Reset_Search_Order


TEST-CODE? [IF]     \ test code =============================================


9 FLOAT ARRAY x{
9 FLOAT ARRAY y{
9 FLOAT ARRAY dif{

: test_coords1 ( n -- )

     0 DO I S>F % 0.25 F*
          FDUP x{ I } F!
          FSIN y{ I } F!
     LOOP

;

: test_coords2 ( n -- )

      0 DO I 2* S>F % -4.0 F+
           FDUP x{ I } F!
           % 1.0 % 1.0 logistic  y{ I } F!
      LOOP
;

\ forward differences tests

: fnewt-test1 ( -- ) ( f: u -- )   \ u can be in the range 0..2 for this test

           9 test_coords1

           \ convert y{} to forward divided differences
           x{ y{ dif{ 9 forward_div_difs

           FDUP FDUP CR ." Interpolation point: " F. CR

           FSIN FSWAP             \ get exact value for later
           FDUP FCOS FSWAP

           x{ dif{ 9 FNewt

          ."      interpolated value, deriv, err: " F. F. F. CR
          ."      exact value: " FSWAP F. F. CR


;


: fnewt-test2 ( -- ) ( f: u -- )   \ u is in the range -4..4 for this test

           5 test_coords2

           \ convert y{} to forward divided differences
           x{  y{ dif{ 5 forward_div_difs

           FDUP FDUP CR ." Interpolation point: " F. CR

           % 1.0 % 1.0 logistic FSWAP             \ get exact value for later
           FDUP % 1.0 % 1.0 d_logistic FSWAP

           x{ dif{ 5 FNewt

          ."      interpolated value, deriv, err: " F. F. F. CR
          ."      exact value: " FSWAP F. F. CR


;


\ backwards differences tests

: bnewt-test1 ( -- , f: u -- )   \ u can be in the range 0..2 for this test

           9 test_coords1

           \ convert y{} to backward divided differences
           x{  y{ dif{ 9 backward_div_difs

           FDUP FDUP CR ." Interpolation point: " F. CR

           FSIN FSWAP             \ get exact value for later
           FDUP FCOS FSWAP

           x{  dif{ 9 BNewt

          ."      interpolated value, deriv, err: " F. F. F. CR
          ."      exact value: " FSWAP F. F. CR


;

: bnewt-test2 ( -- , f: u -- )   \ u is in the range -4..4 for this test

           5 test_coords2

           \ convert y{} to backward divided differences
           x{  y{ dif{ 5 backward_div_difs

           FDUP FDUP CR ." Interpolation point: " F. CR

           % 1.0 % 1.0 logistic FSWAP             \ get exact value for later
           FDUP % 1.0 % 1.0 d_logistic FSWAP

           x{  dif{ 5 BNewt

          ."      interpolated value, deriv, err: " F. F. F. CR
          ."      exact value: " FSWAP F. F. CR


;


[THEN]


