\ POLRAT :  Neville type algorithms for
\		Polynomial Interpolation and Extrapolation,
\		Rational Function Interpolation and Extrapolation

\ Forth Scientific Library Algorithm #17

\ POLINT.
\ Given arrays xa[0..n-1] and ya[0..n-1] and given a value x, this routine 
\ returns a value y and an error estimate dy. If P(x) is a polynomial of 
\ degree n-1 such that P(xai)=yai, i=0..n-1, then the returned value is y=P(x)
\ Ref: Stoer, J. and Bulirsch, R. 1980, 'Introduction to Numerical Analysis'
\      New York: Springer-Verlag, pp25.2

\ RATINT.
\ Given arrays xa[0..n-1] and ya[0..n-1] and given a value x, this routine 
\ returns a value y and an error estimate dy. The value returned is that of 
\ the diagonal rational function, evaluated at x, which passes through the 
\ points (xai,yai) where i = 0..n-1.
\ Ref: Stoer, J. and Bulirsch, R. 1980, 'Introduction to Numerical Analysis'
\      New York: Springer-Verlag, pp2.2


\ This is an ANS Forth program requiring:
\	1. The Floating-Point word set
\	2. The words F2DUP and F>
\		: F2DUP  FOVER FOVER ; 
\		: F>     FSWAP F< ;
\	3. Uses FSL words from fsl_util.xxx,
\		V: and DEFINES to revector functions
\       4. The compilation of the test code is controlled by the VALUE TEST-CODE?
\          and the conditional compilation words in the Programming-Tools wordset.
\	5. The second test uses 'Logistic' for the logistic function and
\		S>F to convert single integers to floats

\ Note: the code uses six fp stack cells (iForth vsn 1.05) when executing
\       the error-testi words. This means the code may fail to run on a 
\	minimal ANS Forth system.

\ 'Numerical recipes in Pascal, The Art of Scientific computing',
\ William H. Press, Brian P. Flannery, Saul A. Teukolsky and William
\ T. Vetterling.
\ 1989; Cambridge University Press, Cambridge, ISBN 0-521-37516-9

\ (c) Copyright 1994 Marcel Hendrix.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.

CR .( POLRAT            V1.2           29 October 1994   MH )

Private:

20 FLOAT ARRAY c{	\ scratch
20 FLOAT ARRAY d{	\ scratch
FVARIABLE x
FVARIABLE y

1.0e-30 FCONSTANT tiny	\ to prevent a rare 0 over 0 situation

FLOAT DARRAY ya{	\ pointers
FLOAT DARRAY xa{

: polint-init ( 'xa 'ya n -- n ) ( F: x -- )
	 SWAP & ya{ &!
	 SWAP & xa{ &!

	 x F!
;

: update-y ( n ns I -- n ns' ) ( F: dy -- dy' )

	FDROP
	OVER 2* 3 PICK ROT - 3 - < IF c{ OVER 1+ } F@
				 ELSE d{ OVER    } F@  1-
				 THEN
	FDUP y F@  F+ y F!

;

Public:

: POLINT ( 'xa 'ya n -- ) ( F: x -- y dy )

	DUP 20 > ABORT" polint: c{ d{ bounds exceeded "

	\ 1 LOCALS| ns n ya{ xa{ |
	\ 0e0 0e0 0e0 0e0 0e0 FLOCALS| w hp ho dy y x |
	\ because my Forth does not have locals, instead of the above two
	\ lines we do the following instead
	polint-init

	x F@ xa{ 0 } F@ F- FABS ( dif )
	0 OVER 0 DO
		  x F@ xa{ I } F@ F- FABS  ( dif newdif )
		  F2DUP F> IF FSWAP FDROP DROP I
			 ELSE FDROP
			 THEN
		  ya{ I } F@ FDUP c{ I } F!  d{ I } F!
	     LOOP FDROP

	ya{ OVER } F@ y F!
	0.0e0	 \ dummy dy

	1-
	OVER 1- 0 DO	OVER I - 1-
		0 DO	xa{ I } F@  x F@ F-
			xa{ I J + 1+ } F@ x F@ F-
			F2DUP F- FDUP
			F0= ABORT" polint: denominator too small "

			c{ I 1+ } F@  d{ I } F@ F-
			FSWAP F/ ( den )
			FSWAP FOVER F* d{ I } F!
			F* c{ I } F!
		LOOP

		I update-y

	  LOOP	y F@ FSWAP

	2DROP
 ;


\ Fit tabulated data with a diagonal rational function (order numerator n and
\ denominator m are equal, or m = n+1).
\ RATINT performs _much_ better than POLINT for the logistics data with n=9.
\ It seems to be worse than POLINT for smooth functions?

: RATINT ( 'xa 'ya n -- ) ( F: x -- y dy )
	DUP 20 > ABORT" ratint: c{ d{ bounds exceeded "

	\ 1 LOCALS| ns n ya{ xa{ |
	\ 0e0 0e0 0e0 0e0 FLOCALS| w t dy y x |
	\ because my Forth does not have locals, instead of the above two
	\ lines we do the following instead
	polint-init

	0.0e0	\ dummy dy

	x F@ xa{ 0 } F@ F- FABS ( dif )

	0 OVER 0 DO
		  x F@ xa{ I } F@ F- FABS  ( dif newdif )
		  FDUP F0= IF 2DROP F2DROP ya{ I } F@ FSWAP UNLOOP EXIT	 THEN

		  F2DUP  FSWAP F< IF FSWAP FDROP DROP I
				ELSE FDROP
				THEN
		  ya{ I } F@ FDUP c{ I } F!
			  tiny F+ d{ I } F! \ prevents a rare 0 / 0 situation
	     LOOP FDROP

	ya{ OVER } F@ y F! 1-

	OVER 1- 0 DO	OVER I - 1-
		0 DO
			xa{ I J + 1+ } F@  x F@ F- 
			    ( h is never 0, we tested above)
			xa{ I } F@  x F@ F-  d{ I } F@ F* FSWAP ( h ) F/
			FDUP c{ I 1+ } F@ F- FDUP
			F0= ABORT" ratint: pole in interpolating function "

			c{ I 1+ } F@  d{ I } F@ F-
			FSWAP F/ FDUP ( dd dd)
			( dd) c{ I 1+ } F@  F*	d{ I } F!
			( dd) F*  c{ I } F!
		LOOP

		I update-y

	  LOOP

	2DROP  y F@ FSWAP ;


Reset_Search_Order

TEST-CODE? [IF]     \ test code =============================================

10 FLOAT ARRAY x{
10 FLOAT ARRAY y{

V: polrat	' POLINT DEFINES polrat

: coords1 ( -- )
	 9 0 DO
		I S>F 0.25e0 F*
		FDUP x{ I } F!
		FSIN y{ I } F!
	   LOOP ;

\ maximum error around 3.13e-8 (polint) 4.72e-8 (ratint)
: polrat_test1 ( F: u -- )	\ u can be in the range 0..2 for this test
	coords1
	FDUP CR ." Interpolation point: " F.
	FDUP FSIN FSWAP		\ get exact value for later
	x{ y{ 9 polrat
	CR ."      interpolated value: " FSWAP F.
	CR ."      expected error: " F.
	CR ."   exact value: " F. ;

\ For use with the function plotter:  0e 2e SKETCH error1
: error1 ( F: u -- err )	\ run coords1 first
	FDUP FSIN FSWAP
	x{ y{ 9 polrat FDROP
	F- ;

: err-test1 ( -- )
       coords1
       20 0 DO
	       I S>F 9.0e-2 F* 0.10e0 F+ FDUP F.
	       error1 F. CR LOOP
;


: coords2 ( -- )
	5 0 DO
		I  2* S>F 4e0 F-
		FDUP x{ I } F!
		1.0e0 1.0e0 logistic y{ I } F!
	  LOOP ;

\ maximum error around 4.6e-2 (polint) 1.77e-2 (ratint)
: polrat_test2 ( F: u -- )		\ u is in the range -4..4 for this test
	coords2
	FDUP CR ." Interpolation point: " F.
	FDUP 1.0e0 1.0e0 logistic FSWAP \ get exact value for later
	x{ y{ 5 polrat
	CR ."      interpolated value: " FSWAP F.
	CR ."      expected error: " F.
	CR ."   exact value: " F. ;

\ For use with the function plotter:  -4e 4e SKETCH error2
: error2 ( F: u -- err )		\ run coords2 first
	FDUP 1.0e0 1.0e0 logistic FSWAP
	x{ y{ 5 polrat FDROP
	F- ;


: err-test2 ( -- )
       coords2
       20 0 DO
	       I S>F 0.40e0 F* 3.9e0 F- FDUP F.
	       error2 F. CR LOOP

;



: coords3 ( -- )
	5 -4 DO
		I S>F
		FDUP x{ I 4 + } F!
		1e0 1e0 logistic  y{ I 4 + } F!
	   LOOP ;

\ Maximum error around 6.3e-3 (polint) 1.43e-5 (ratint)
: polrat_test3 ( F: u -- )		\ u is in the range -4..4 for this test
	coords3
	FDUP CR ." Interpolation point: " F.
	FDUP 1.0e0 1.0e0 logistic FSWAP \ get exact value for later
	x{ y{ 9 polrat
	CR ."      interpolated value: " FSWAP F.
	CR ."      expected error: " F.
	CR ."   exact value: " F. ;

\ For use with the function plotter:  -4e 4e SKETCH error3
: error3 ( F: u -- err )		\ run coords3 first
	FDUP 1.0e0 1.0e0 logistic FSWAP
	x{ y{ 9 polrat FDROP
	F- ;


: err-test3 ( -- )
       coords3
       20 0 DO
	       I S>F 0.40e0 F* 3.9e0 F- FDUP F.
	       error3 F. CR LOOP

;

[THEN]

				( * End of File * )



