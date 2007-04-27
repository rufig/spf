\ Walsh                      Fast Walsh Transform
\ Perform the Walsh Transform on an array whose length is a power of two,
\ with or without normalization.
\
\      Forth Scientific Library Algorithm #50

\ Note: This algorithm is also practical for use in INTEGER ONLY applications.
\       To do so, change the floating point operations to integer ones, and the
\       arrays to INTEGER type.

\ This code is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. Uses S>F, ARRAY, DARRAY as defined in 'fsl-util'
\      3. Uses the dynamic array memory allocation in 'dynmem'
\      4. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control the visibility of internal code.
\      5. The compilation of the test code is controlled by VALUE TEST-CODE?
\         and the conditional compilation words in the Programming-Tools
\         wordset
\      6. The test code uses the floating point constant PI
\         3.1415926536E0 FCONSTANT PI
\
\ See: Harmuth, H.F., 1969; Applications of Walsh functions in
\      communications, IEEE Spectrum, Nov. pp. 82-91
\ 
\ Based upon the algorithm and code described in:
\ Witkov, C., 1990; The Fastest Transform of All, Embedded Systems
\ Programming, October, pp. 30 - 35

\  (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\  author to use this software for any application provided the
\  copyright notice is preserved.
 

CR .( WALSH             V1.1           30 March 1998   EFC )

Private:

VARIABLE b
VARIABLE k
VARIABLE l
VARIABLE m

FLOAT DARRAY x{
FLOAT DARRAY z{

: NOT_POWER_OF_TWO? ( n -- t/f )      \ true of n not a power of 2 (or < 2)
    DUP DUP 1- AND
    SWAP 2 < OR
;

: ** ( n1 n2 -- n1^n2 )
       1 SWAP ?DUP IF 0 DO OVER * LOOP
                   THEN

       SWAP DROP
;

: fwt_initialize ( n -- )
       0 DO
           x{ I } F@   x{ I 1+ } F@ F+            x{ I    } F!
           x{ I } F@   x{ I 1+ } F@ 2.0E0 F* F-   x{ I 1+ } F!
       2 +LOOP
;

: fwt_normalize ( n -- )
        DUP S>F 0 DO
                    x{ I } DUP F@ FOVER F/ F!
        LOOP

        FDROP
;

Public:

\ do an N point Fast Walsh Transform of data in X
\ Normalize the transform if t/f is set (normally done on the forward
\ transform and not on the inverse transform)

: }FWT ( &x n t/f -- )
      OVER NOT_POWER_OF_TWO? ABORT" Invalid array size"
      
      ROT
      & x{ &!
      SWAP

      & z{ OVER }malloc

      0 l !

      DUP fwt_initialize
      
      BEGIN
        l @ 1+ DUP l !
        2 SWAP ** DUP m !
        OVER - 0<
      WHILE
        0 b !   0 k !
        BEGIN
          m @ 0 DO
                   b @ I +
                   x{ OVER } F@ x{ OVER m @ + } F@ F+  z{ k @ } F!
                   x{ OVER } F@ x{ OVER m @ + } F@ F-  z{ k @ 1+ } F!
                   1+
                   x{ OVER } F@ x{ OVER m @ + } F@ F-  z{ k @ 2 + } F!
                   x{ OVER } F@ x{ SWAP m @ + } F@ F+  z{ k @ 3 + } F!

                        k @ 4 + k !
                2 +LOOP

                m @ 2* b @ + b !
                k @ OVER - 0< 0=
        UNTIL

           \ transfer the result back to x{}
           DUP 0 DO   z{ I } F@   x{ I } F!   LOOP
      REPEAT
      
      SWAP IF fwt_normalize ELSE DROP THEN

      & z{ }free
      
;

Reset_Search_Order


TEST-CODE? [IF]     \ test code =============================================

32 FLOAT ARRAY xx{

: wtest-init ( n -- )
       DUP 0 DO
             I 1+ 2* S>F DUP S>F F/ PI F* FSIN
             1000 S>F F*
             xx{ I } F!           
       LOOP
       DROP
;

: walsh-test ( -- )

    CR
    32 wtest-init
    ." Initial array: " 32 xx{ }fprint CR

    xx{ 32 1 }FWT                \ forward transform

    ." Transformed array: " 32 xx{ }fprint CR
    ." Should be: 0 634.57 62.5 0 0 -262.85 25.89 0 0 -52.28 -5.15 0 " CR
    ."     0 -126.22 12.43 0 0 -12.43 -1.22 0 0 5.15 -0.51 0 0 -25.89 -2.55 " CR
    ."     0 0 -62.5 6.16 0 " CR

    xx{ 32 0 }FWT                \ inverse transform

    ." Inverse transformed array (should be same as original): "
    32 xx{ }fprint CR

;

[THEN]
