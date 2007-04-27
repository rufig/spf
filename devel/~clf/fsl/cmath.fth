\ CMATH      Complex Math operations    ZEXP ZLN Z** ZPOW
\                                       ZSIN ZCOS ZSINH ZCOSH 1/Z
\                                       >POLAR POLAR>

\ Complex Math functions.
\ Note on the stack diagrams, the symbol Zn on the float stack denotes
\ a complex number.

\ TO BE ADDED WHEN I GET A CHANCE:  ZSQRT, ZTAN, ZASIN, ZACOS, ZATAN

\ ZARG    The angle of a complex number as seen as a phasor

\ ZEXP    The exponential of a complex number         ACM Algorithm #46

\ ZLN     The (natural) logarithm of a complex number ACM Algorithm #48


\ ZPOW     Complex number to a Real Power            ACM Algorithm #106
\ Evaluates the quantity a + ib = (x+iy)^w
\ Note that if w = -1, then this routine will return ONLY ONE of the n-th
\ roots of (x+iy)

\ Z**     Complex power                               ACM Algorithm #190
\ Raises a complex number (x1, y1) to a complex power (x2, y2).
\ The integer value n, determines which principal value to take.
\ If n = 0 and y2 = 0, the result is the same as ACM Algorithm #106.

\ ZSIN        The sine of a complex number
\ ZCOS        The cosine of a complex number
\ ZSINH       The hyperbolic sine of a complex number
\ ZCOSH       The hyperbolic cosine of a complex number
\ 1/Z         The complex reciprocal of a complex number
\ >POLAR      Convert to polar form
\ POLAR>      Convert to cartesian form from polar form


\ Collected Algorithms from ACM, Volume 1 Algorithms 1-220,
\ 1980; Association for Computing Machinery Inc., New York.
\ ISBN 0-89791-017-6


\ This is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. The Forth Scientific library COMPLEX word set
\      3. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      4. The FCONSTANT PI (3.1415926536...)
\      5. Uses a local variable mechanism implemented in 'fsl_util.seq'
\      6. The compilation of the test code is controlled by the VALUE ?TEST-CODE
\         and the conditional compilation words in the Programming-Tools wordset



\  (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\  author to use this software for any application provided this
\  copyright notice is preserved.
 

CR .( CMATH             V1.4           10 January 1995   EFC )

Private:

ZVARIABLE z-temp
FVARIABLE w


: zln-imaginary-part  ( -- ) ( f: x y -- zln-imag )

       \ note: does not deal with x = 0, y = 0 case because that is already
       \       eliminated as a possiblity by the time this word is invoked.

       FSWAP FDUP
       0.0E0 F> IF    ( real part is positive )
                      F/ FATAN
                ELSE  ( real part is negative or zero )

                      FDUP F0< IF   ( real part is negative )
                                    FOVER FSWAP F/ FATAN FSWAP
                                    F0< IF   PI F- 
                                        ELSE PI F+ THEN
                                         
                                ELSE  ( real part is zero )
                                      FDROP
                                      F0< IF  ( imag part is negative )
                                                PI -2.0E0 F/
                                          ELSE
                                                PI 2.0E0 F/
                                          THEN

                                THEN
                THEN
;

: get-principal-value ( n -- t/f ) ( f: a b -- p )

          FOVER F0= IF  ( real part is zero )

                        FDUP F0= IF ( imag part is zero )
                                    DROP 0 FDROP
                                 ELSE
                                    FSWAP FDROP
                                    4 *
                                    F< IF    ( imag part is negative )
                                          1-
                                       ELSE  ( imag part is positive )
                                          1+
                                       THEN
                                    S>F [ PI F2/ ] FLITERAL F*
                                    1
                                 THEN

                    ELSE   ( real part is nonzero )
                         F2DUP FSWAP F/ FATAN
                         2* S>F PI F* F+
                         FROT F0< FSWAP IF
                                          F0< IF PI F- ELSE PI F+ THEN
                                        ELSE
                                          FDROP
                                        THEN
                                               
                        1
                    THEN

;

Public:

: ZARG ( -- ) ( F: z1 -- theta )
        Z->I,R
        FATAN2
;

: ZPOW ( -- ) ( f: z1 w -- z2 )
         w F!   Z->R,I


         FOVER F0< IF    \ re < 0

                          F2DUP R,I->Z ZARG FOVER
                          F0< IF [ PI FNEGATE ] FLITERAL ELSE PI THEN
                          F+
                          
                     ELSE
                             FOVER F0= IF       \ re = 0


                                          FDUP F0= IF
                                                      FDROP FDROP
                                                      0+0i
                                                      EXIT
                                                    THEN

                                           FDUP F0< IF [ PI -0.5e0 F* ] FLITERAL
                                                    ELSE [ PI 0.5e0 F* ] FLITERAL
                                                    THEN

                                       ELSE   \ re > 0


                                          F2DUP R,I->Z ZARG
                                          
                                       THEN
                                                                     
                       THEN

        FSWAP FDUP  F*
        FROT  FDUP  F* F+ FSQRT
        FLN w F@ F* FEXP
        FSWAP w F@ F*
        FSINCOS
        FROT FDUP w F!
        F*
        FSWAP W F@ F*

        R,I->Z
;


: ZEXP ( -- ) ( f: z1 -- z2 )
       Z->R,I

       FSINCOS
       FROT FEXP
       FSWAP
       FOVER F*
       -FROT F*

       R,I->Z
;

: ZLN ( -- ) ( f: z1 -- z2 )

       ZDUP z-temp Z!

       ZABS
       FLN

       FDUP F0= ABORT" ZLN for complex zero "

       z-temp Z@ Z->R,I

       zln-imaginary-part

       R,I->Z
;

: Z**  ( n -- ) ( f: z1 z2 -- z3 )

        z-temp Z!
        Z->R,I z-temp Z@ Z->R,I

        \ set up a local fvariable frame
        FRAME| a b c d |

        d c get-principal-value
            IF
               d FDUP F* c FDUP F* F+ FLN 0.5E0 F* &d F!
               b FOVER F*  d a F* F+               &c F!
               a F* b d F* FSWAP F-  FEXP          &b F!

               c FCOS b F*
               c FSIN b F*

            ELSE
                 0.0E0
            THEN

        |FRAME

         R,I->Z
;

: ZSIN  ( -- ) ( f: z1 -- z2 )

        Z->R,I

        F2DUP

        FCOSH FSWAP FSIN F*
        -FROT
        FSINH FSWAP FCOS F*

        R,I->Z
;

: ZCOS  ( -- ) ( f: z1 -- z2 )

        Z->R,I

        F2DUP

        FCOSH FSWAP FCOS F*
        -FROT
        FSINH FSWAP FSIN F* FNEGATE

        R,I->Z
;

: ZSINH  ( -- ) ( f: z1 -- z2 )
        Z->R,I
        F2DUP
        FCOS FSWAP FSINH F*
        -FROT
        FSIN FSWAP FCOSH F*
        R,I->Z
;

: ZCOSH  ( -- ) ( f: z1 -- z2 )
        Z->R,I

        F2DUP
        FCOS FSWAP FCOSH F*
        -FROT
        FSIN FSWAP FSINH F*
        R,I->Z
;

: POLAR> ( -- ) ( f: r t -- x y )         \ convert from polar to Cartesian form
         
         FSINCOS F*
         FROT FSWAP FOVER F*
         -FROT F*

         R,I->Z
;

: >POLAR  ( -- ) ( f: x y -- r t )            \ convert from Cartesian to polar form
          F2DUP
          ZABS
          -FROT FSWAP
          FATAN2
;

: 1/Z     ( -- ) ( f: z1 -- z2 )           \ get reciprocal

           1+0i
           ZSWAP
           Z/
;

Reset_Search_Order


TEST-CODE? [IF]   \ test code ==============================================

1 VALUE pflag


: Z.    pflag IF Z. ELSE ZDROP THEN ; ( F: r -- )
: CR?   pflag IF CR 2 .R SPACE ELSE DROP THEN ; ( ix -- )
: ".."  pflag IF CR ." .. " THEN ;
: "__"  pflag IF CR ."    " THEN ;

: zpow-test ( n -- )

        CR
        0 DO
              Z% 0.9 0.3  I S>F ZPOW
              I .  Z. CR
          LOOP
              
;


: zmath-test ( -- )

\ exp(z^-2) where z = 1+i
CR ." exp( (1+i)^-2) = [ 0.8776 -0.4794 ]  calculated: "
  Z% 1.0E0 1.0E0   -2.0E0 ZPOW  ZEXP Z.

\ sin(z) where z = 2+3i
CR CR ." z = 2+3i in all of below "
CR ." sin(z) = [ 9.1545 -4.1689 ]  calcuated: "  Z% 2.0E0 3.0E0   ZSIN  Z.

\ cos(z) where z = 2+3i
CR ." cos(z) = [ -4.1896 -9.1092 ] calculated: "  Z% 2.0E0 3.0E0   ZCOS  Z.

\ exp(z) where z = 2+3i
CR ." exp(z) [ -7.3151 1.04274 ] calculated: "  Z% 2.0E0 3.0E0   ZEXP  Z.

\ ln(z) where z = 2+3i
CR ." ln(z) = [ 1.28247 0.98279 ] calculated: "  Z% 2.0E0 3.0E0   ZLN  Z.

\ 1/z where z = 2+3i
CR ." 1/z [ 0.1538461 -0.230769 ] calculated: "  Z% 2.0E0 3.0E0   1/Z  Z.

\ x**z where x and z are 2+3i
CR ." x**z [ 0.607566665 -0.308756018 ] calculated: "  0 Z% 2.0E0 3.0E0  ZDUP Z**
Z. CR ." (x = 2+3i) " CR

;


: zmath-table ( n -- )
        0 TO pflag

        CR ."  n  zexp  zln .. zpow  z** .. zsin  zcos .. zsinh  zcosh .. 1/z"
        Z% 0.9E0 0.3E0

        0 DO
                I 10 MOD 0= TO pflag

                I CR? ZDUP ZEXP Z.
                "__" ZDUP ZLN Z.
                ".." ZDUP I S>F ZPOW Z.
                "__" 0 ZDUP I S>F FDUP R,I->Z Z** Z.
                ".." ZDUP ZSIN Z.
                "__" ZDUP ZCOS Z.
                ".." ZDUP ZSINH Z.
                "__" ZDUP ZCOSH Z.
                ".." ZDUP 1/Z Z.

                Z% 2.0E0 -1.0E0 Z/
        LOOP

        ZDROP
        1 TO pflag

;

[THEN]






