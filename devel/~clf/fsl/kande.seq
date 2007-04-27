\ KandE     Complete Elliptic Integrals, K and E         ACM Algorithm #165

\ Forth Scientific Library Algorithm #30

\ Evaluates the Complete Elliptic Integrals,
\     K[m1] = int_0^{\pi/2} 1/Sqrt{ 1 - (1 - m1) Sin^2(v)} dv
\     E[m1] = int_0^{\pi/2}   Sqrt{ 1 - (1 - m1) Sin^2(v)} dv
\ Note, uses the COMPLEMENTARY PARAMETER m1, 0 < m1 <= 1
\ The parameter m1 = 1 - m = 1 - k^2

\ Uses the arithmetic-geometric-mean process, the accuracy is limited only
\ the accuracy of the arithmetic.  (For single precision, this typically
\ will be 4 or 5 places).

\ The passed error tolerance parameter determines the accuracy of the result.
\ This value should be at least twice the relative error of FSQRT or the
\ routine may go into an infinite loop.

\ This is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. The word FSQRT from the Floating-Point Extensions word set.
\      3. The FCONSTANT PI (3.1415926536...)
\      4. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      5. Uses a local variable mechanism (FRAME|, |FRAME)
\         implemented in 'fsl_util.seq'
\      6. The compilation of the test code is controlled by the VALUE TEST-CODE?
\         and the conditional compilation words in the Programming-Tools wordset

\ Collected Algorithms from ACM, Volume 1 Algorithms 1-220,
\ 1980; Association for Computing Machinery Inc., New York,
\ ISBN 0-89791-017-6

\ (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\ author to use this software for any application provided the
\ copyright notice is preserved.

CR .( KandE        V1.2                 6 April 1995   EFC )

Private:


: ?ACCURATE-ENOUGH ( -- t/f ) ( F: tol sum temp -- tol sum temp )

           FROT FDUP a F* c FABS FSWAP F< 0=

           FROT FOVER FOVER F* &c F!
           FROT c FOVER F<

           OR 0=
;

Public:

: KANDE ( -- ) ( F: m1 tolerance -- K[m1] E[m1] )

         FSWAP 0.0E0 FOVER F< 0= 1.0E0 FOVER F<  OR
               ABORT" KandE, parameter m1 out of range "

         0.0E0 FOVER FSQRT 1.0E0 FRAME| a b c |

         1
         0.0E0
         1.0E0 FROT F-
         
         BEGIN
           F+
           a b F- 2.0E0 F/ &c F!

           2*

           a b F+ 2.0E0 F/
           a b F* FSQRT &b F!
           &a F!
           c FDUP F* DUP S>D D>F F*

           ?ACCURATE-ENOUGH
           
         UNTIL

         DROP
         F+ FSWAP FDROP

         PI a b F+ F/

         FSWAP
         -2.0E0 F/ 1.0E0 F+
         FOVER F*
         
         |FRAME
         
;

Reset_Search_Order

TEST-CODE? [IF]     \ test code =============================================

\ test driver,  calculates the complete elliptic integral of the first
\ and second kinds, compare with Abramowitz & Stegun, Handbook of
\ Mathematical Functions, Table 17.1

\ convert a modulus angle in degrees to the complementary parameter
: comp-parameter   PI F* 180.0E0 F/ FCOS FDUP F* ;


: kande_test ( -- )
        CR
        ."  m    m1   E(m1) exact K(m1) exact    E(m1)    K(m1) " CR

         ." 0.0  1.0   1.57079633  1.57079633     "
         1.0E0  1.0E-5 kande F. F. CR

      ." 0.44 0.56  1.38025877  1.80632756     "
      0.56E0  1.0E-5 kande F. F. CR

        ." 0.75 0.25  1.21105603  2.15651565     "
        0.25E0 1.0E-5 kande F. F. CR

      ." 0.96 0.04  1.05050223  3.01611249     "
      0.04E0 1.0E-5 kande F. F. CR


;

[THEN]

