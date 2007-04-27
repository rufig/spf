\ gauleg     Gauss-Legendre Integration

\ Forth Scientific Library Algorithm #27

\ Given lower and upper limits of integration X1 and X2
\ the routine gauleg returns the abscissas and weights of the Gauss-Legendre
\ N-point quadrature formula.

\ The integral of f(x) is then calculated numerically as:
\ z = \int_x1^x2 f(x) dx = \sum_i=0^n-1 w[i] f( x[i] )
\ the routine )gl-integrate is provided to do this calculation using the
\ previously calculated values of x and w.


\ This is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. The FCONSTANT PI (3.1415926536...)
\      3. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      4. Uses the words 'FLOAT' and 'ARRAY' to create floating point arrays.
\      5. The word '}' to dereference a one-dimensional array.
\      6. Uses the words 'DARRAY' and '&!' to set array pointers.
\      7. The test code uses '}malloc' and '}free' to allocate and release
\         memory for dynamic arrays ( 'DARRAY' ) (from the file DYNMEM).
\      8. The compilation of the test code is controlled by the VALUE
\         TEST-CODE? and the conditional compilation words in the
\         Programming-Tools wordset

\      requirements 2 through 6 are provided in the file FSL-UTIL


\ This program implements the function GAULEG as described in 
\ Press, W.H., B.P. Flannery, S.A. Teukolsky, and W.T. Vetterling, 1986;
\ Numerical Recipes, The Art of Scientific Computing, Cambridge University
\ Press, 818 pages,   ISBN 0-521-30811-9


\  (c) Copyright 1995 Everett F. Carter.  Permission is granted by the
\  author to use this software for any application provided this
\  copyright notice is preserved.


CR .( GAULEG            V1.1            9 Februrary 1995   EFC )


Private:

3.0E-6 FCONSTANT eps

FVARIABLE xm       \ scratch variables
FVARIABLE xl
FVARIABLE z
FVARIABLE p1
FVARIABLE pp

FLOAT DARRAY x{    \ aliases to user arrays
FLOAT DARRAY w{

v: f(x)            \ pointer to user function with diagram ( F: x -- f[x] )

: calc-pp ( n -- n ) ( F: -- )           \ NOTE: changes Z


       BEGIN
         1.0E0 p1 F!    0.0E0 pp F!

         DUP 1+ 1 DO
                     pp F@
                     p1 F@    FDUP pp F!

                     I 2* 1- S>F F*
                     z F@ F*

                     FSWAP I 1- NEGATE S>F F* F+
                     I S>F F/

                     p1 F!

         LOOP         

         z F@ p1 F@ F* pp F@ F- DUP S>F F*
         z F@ FDUP F* 1.0E0 F- F/       pp F!

         p1 F@ pp F@ F/ FNEGATE

         z F@ FDUP FROT F+ FDUP z F!
         

         F- FABS eps F<
       UNTIL

       pp F@ FDUP F*
;

Public:

: gauleg ( &x &w n -- ) ( F: x1 x2 -- )

         \ validate the parameter N
         DUP 1 < ABORT" bad value of N (must be > 0) for gauleg "
         
         FOVER FOVER F+ 0.5E0 F* xm F!
         FSWAP F- 0.5E0 F* xl F!


         SWAP & w{ &!     SWAP & x{ &!

         DUP 1+ 2/

         0 DO
              PI DUP S>F 0.5E0 F+ F/
              I S>F 0.75E0 F+ F*     FCOS z F!

              calc-pp

              z F@ FDUP F* FNEGATE 1.0E0 F+ F*
              2.0E0 xl F@ F* FSWAP F/
              FDUP w{ I } F!     w{ OVER 1- I - } F!      

              xl F@ z F@ F* FDUP FNEGATE xm F@ F+   x{ I } F!
              xm F@ F+     x{ OVER 1- I - } F!


           LOOP

         DROP
;


\ do the integration
: )gl-integrate ( func &x &w n -- ) ( F: -- z )

         \ validate the parameter N
         DUP 1 < ABORT" bad value of N (must be > 0) for )gl-integrate "

         >R
         & w{ &!     & x{ &!      defines f(x)
         R>
                  
         0.0E0
         0 DO
               x{ I } F@ f(x)
               w{ I } F@ F*
               F+
           LOOP
;

Reset_Search_Order

TEST-CODE? [IF]   \ test code ==============================================

\ test code
\ This test code demonstrates the ability to use Dynamic Arrays in the
\ place of static arrays without code changes.


FLOAT DARRAY x{
FLOAT DARRAY wgt{

: func ( -- ) ( F: x -- f[x] )         \ function to integrate

        FDUP 0.2E0 F+ F*
;

: ifunc ( -- ) ( F: x -- I[x] )        \ its (indefinite) integral

       FDUP  3.0E0 F/ 0.10E0 F+
       FOVER F* F*
;

: values-for-8 ( -- )

    CR
    ." The values for n = 8 are: " CR
    ." X: -0.96029   -0.796667   -0.525532   -0.183435 " CR
    ."     0.183435   0.525532   0.796667   0.96029 " CR


    ." W: 0.101228   0.222381   0.313706   0.362684 " CR
    ."    0.362684   0.313706   0.222381   0.101228 " CR

;

: gauleg-test ( n -- )         \ if n = 8, comparison values are also given

       & x{ OVER }malloc
       & wgt{ OVER }malloc


      CR

      DUP

      x{ wgt{ ROT -1.0E0  1.0E0 gauleg

      ." X: " DUP x{ }fprint

      CR
      ." W: " DUP wgt{ }fprint


      DUP 8 = IF values-for-8 THEN

      >R
      
      use( func x{ wgt{ R> )gl-integrate

      CR ." The integral from -1.0 to 1.0 is: "  F.
         ."   (the actual value is: "
         1.0E0 ifunc -1.0E0 ifunc F- F.
         ." ) " CR
         

      & x{ }free
      & wgt{ }free


;

[THEN]

