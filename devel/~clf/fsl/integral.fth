\ INTEGRAL.xxx :  Three different algorithms to perform Quadrature.
\
\ Forth Scientific Library Algorithm #45
\
\	1. using the Simpson rule
\	2. using Romberg's algorithm (Richardson's deferred approach to the 
\	   limit), implemented with Neville's algorithm using
\		a. Rational Function Extrapolation
\		b. Polynomial Function Extrapolation
\
\ )INTEGRAL ( xt -- ) ( F: a b eps -- result )
\ A vectored word to integrate the function xt between a and b, using a 
\ relative precision of eps. Before using )INTEGRAL execute either SIMPSON or
\ ROMBERG . ROMBERG should be combined with RATIONAL or POLYNOMIAL to select
\ the interpolation algorithm.
\ 
\ QSIMP ( xt -- ) ( F: a b eps -- r ) 
\ Integrates the function xt between a and b, using a relative precision of 
\ eps and leaves the result r. Nothing to set up. Simpson's rule is used.
\ According to Press et al, an eps smaller than 1e-7 is not realistic on 32-bit
\ machines.
\
\ QROMB ( 'func -- ) ( F: a b eps -- result ) 
\ Integrates the function xt between a and b, using a relative precision of 
\ eps and leaves the result r. Romberg's algorithm is used. Uses either
\ polynomial or rational extrapolation in the internal Neville type algorithm.
\ Execute either RATIONAL or POLYNOMIAL to select the wanted extrapolation 
\ routine.
\ According to Press et al, an eps smaller than 1e-7 is not realistic on 32-bit
\ machines.
\
\ RATIONAL ( -- )
\ Selects rational extrapolation for QROMB .
\
\ POLYNOMIAL ( -- )
\ Selects polynomial extrapolation for QROMB .
\
\ ROMBERG ( -- )  
\ This sets up the vectored word )INTEGRAL to use Romberg's integration 
\ algorithm. Execute either RATIONAL or POLYNOMIAL to set up the wanted 
\ interpolation routine before using )INTEGRAL .
\
\ SIMPSON ( -- )  
\ This sets up the vectored word )INTEGRAL to use Simpson's integration 
\ algorithm. No further options to set.

\ This is an ANS Forth program requiring:
\	1. The FLOATING and FLOATING EXT word sets
\	2. Uses FSL words from fsl_util.xxx, notably 
\	   F2DUP F> F2* F2/ S>F FRAME| |FRAME
\	3. Uses FSL routines from POLRAT.xxx

\ Note: the code uses 5 fp stack cells (iForth vsn 1.05) when executing
\       the TEST-PROGRAM word.

\ 'Numerical recipes in Pascal, The Art of Scientific computing',
\ William H. Press, Brian P. Flannery, Saul A. Teukolsky and William
\ T. Vetterling, Chapters 3 (3.1) and 4 (4.3, 4.4)
\ 1989; Cambridge University Press, Cambridge, ISBN 0-521-37516-9

\ (c) Copyright 1995 Marcel Hendrix.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.


CR .( INTEGRAL          V1.2           26 March   1996   MH )


TEST-CODE?  FALSE TO TEST-CODE?
  S" polrat.frt" INCLUDED
TO TEST-CODE?


Private:

 0  VALUE TrapzdIt	\ local to trapzd (inited when n=1)	
FVARIABLE ssum		\ static variable

: trapzd ( 'f n -- ) ( F: a b -- ssum )	\ This is COMPLETELY general
	LOCALS| n func |
	0e FSWAP FROT FRAME| a b c |
	n 1 = IF b a F- F2/  a func EXECUTE  b func EXECUTE F+  F*  
		 FDUP ssum F! 
		 1 TO TrapzdIt  |FRAME EXIT
	    THEN
	b a F- TrapzdIt S>F F/  ( del = point spacing)
	a FOVER F2/ F+          ( del x )
	TrapzdIt 1+ 1 DO  FDUP func EXECUTE c F+ &c F! 
			  FOVER F+
		    LOOP  F2DROP
	b a F- c F*  
	TrapzdIt S>F F/  TrapzdIt 2* TO TrapzdIt 
	ssum F@ F+ F2/ FDUP ssum F! ( refine ssum ) 
	|FRAME ;

Public:

\ Integration based on Simpson's rule.

: QSIMP ( 'func -- ) ( F: a b eps -- result ) 
	LOCALS| 'func |
	FSWAP FROT FRAME| a b c |
	-1e30 &e F!  1e-30 &d F!	\ implicitly allocate d and e
	21 1 DO  
		  'func I  a b trapzd  4e F*  e F-  3e F/
		  FDUP d F- FABS  d FABS  c F* 
		  F< IF |FRAME UNLOOP EXIT THEN  
		  &d F!  ssum F@ &e F!
	   LOOP
	|FRAME TRUE ABORT" too many steps in QSIMP" ;


\ Integration based on Romberg rule. Extrapolate with 5 points.

Private:

5 CONSTANT kk \ order of interpolation

21 1+ FLOAT ARRAY h{
21 1+ FLOAT ARRAY s{
  kk  FLOAT ARRAY c{
  kk  FLOAT ARRAY d{

v: APPROX


Public:

\ Returns the integral of the function func from a TO b. Integration is
\ performed with Romberg's method of order 2kk, where, e.g., kk=2 is Simpson's
\ rule.
: QROMB ( 'func -- ) ( F: a b eps -- result ) 
	LOCALS| 'func |
	FSWAP FROT FRAME| a b c |
	1e h{ 1 } F!
	 21 1 DO
		 'func I  a b trapzd  s{ I } F!
		 I kk >= IF kk 1+ 1 DO h{ J kk - I + } F@  c{ I 1- } F!
				       s{ J kk - I + } F@  d{ I 1- } F!
			          LOOP
 			    c{ d{ kk 0e APPROX ( y dy )
			    FABS  FOVER FABS c F* 
			    F< IF ( ss ) |FRAME UNLOOP EXIT 
			     ELSE FDROP 
			     THEN
		       THEN	
	         s{ I } F@           s{ I 1+ } F!  
	         h{ I } F@ 0.25e F*  h{ I 1+ } F!
	    LOOP
	|FRAME TRUE ABORT" too many steps in QROMB" ;


\ syntactic sugar.

: RATIONAL	['] RATINT defines APPROX ;
: POLYNOMIAL	['] POLINT defines APPROX ;

v: )INTEGRAL ( 'func -- ) ( F: a b eps -- result ) 

: SIMPSON 	['] QSIMP defines )INTEGRAL ;
: ROMBERG	['] QROMB defines )INTEGRAL ;

	RATIONAL ROMBERG	\ best!

Reset_Search_Order


TEST-CODE? [IF]

0 VALUE #evals			\ check efficiency ( # function evaluations)

: .error ( F: r1 r2 -- )
	#evals 6 .R ."  evaluations, error: " F- FABS F. 
	0 TO #evals ;

: dofunc ( c-addr u xt1 xt2 -- ) ( F: a b eps -- )
	PRECISION LOCALS| prec freal fint |
	FSWAP FROT FRAME| a b c |	\ note: d allocated implicitly
	 3 SET-PRECISION
	 CR CR ." Maximum estimated error = " c F. 
	 CR ." Integrating " TYPE ."  between " a F. ." and " b F. ." -> " 
	 16 SET-PRECISION a b freal EXECUTE FDUP &d F! F.
	 3 SET-PRECISION
	 SIMPSON fint a b c )INTEGRAL CR ." Simpson              " d .error
	  RATIONAL
	 ROMBERG fint a b c )INTEGRAL CR ." Romberg (rational)   " d .error
	  POLYNOMIAL
	 ROMBERG fint a b c )INTEGRAL CR ." Romberg (polynomial) " d .error 
	|FRAME prec SET-PRECISION ;

\ The FEXP function is very smooth. It clearly shows the much faster 
\ convergence of QROMB over QSIMP, taken any x-range. The rational 
\ approximation works best.
: _FEXP   #evals 1+ TO #evals  FEXP ;

: expresult! ( F: a b -- r )
	FEXP FSWAP FEXP F- 
	0 TO #evals ;	

: exp ( F: a b eps -- )
	S" EXP" ['] _FEXP ['] expresult! dofunc ;

\ The following example shows that QROMB has problems with FSQRT 
\ (try 0e 1e 1e-5 sqroot), but it still converges much faster than QSIMP. 
\ FSQRT has derivatives that diverge at x=0; the problem the routines have is 
\ that the appropriate step size is very small near x=0.

: _FSQRT  #evals 1+ TO #evals  FSQRT ;

: sqresult! ( F: a b -- r )
	1.5e F**   FSWAP 1.5e F**   F- F2* 3e F/
	0 TO #evals ;

: sqroot ( F: a b eps -- )
	S" SQRT" ['] _FSQRT ['] sqresult! dofunc ;

: TEST-PROGRAM
	 0e    1e  1e-7 exp
	-1e    1e  1e-7 exp
	-10e  10e  1e-7 exp
	 0e    1e  1e-8 sqroot
	 0.5e  1e  1e-8 sqroot 
	 1e   10e  1e-8 sqroot ;

	CR .( Try TEST-PROGRAM)

[THEN]

FALSE [IF] Example output

Maximum estimated error = 1.000E-7 
Integrating EXP between 0.000 and 1.000 -> 1.7182818284590452 
Simpson                  33 evaluations, error: 9.103E-9 
Romberg (rational)       17 evaluations, error: 1.619E-16 
Romberg (polynomial)     17 evaluations, error: 3.309E-14 

Maximum estimated error = 1.000E-7 
Integrating EXP between -1.000 and 1.000 -> 2.3504023872876029 
Simpson                  65 evaluations, error: 1.245E-8 
Romberg (rational)       17 evaluations, error: 2.231E-13 
Romberg (polynomial)     17 evaluations, error: 4.209E-11 

Maximum estimated error = 1.000E-7
Integrating EXP between -10.000 and 10.000 -> 22026.4657494067867596 
Simpson                1025 evaluations, error: 1.781E-5 
Romberg (rational)       65 evaluations, error: 1.779E-5 
Romberg (polynomial)    129 evaluations, error: 3.429E-6 

Maximum estimated error = 1.000E-8 
Integrating SQRT between 0.000 and 1.000 -> 0.6666666666666667 
Simpson              131073 evaluations, error: 1.711E-9 
Romberg (rational)     8193 evaluations, error: 7.582E-8 
Romberg (polynomial)   2049 evaluations, error: 7.415E-7 

Maximum estimated error = 1.000E-8
Integrating SQRT between 0.500 and 1.000 -> 0.4309644062711508 
Simpson                  65 evaluations, error: 3.613E-11 
Romberg (rational)       17 evaluations, error: 3.088E-12 
Romberg (polynomial)     17 evaluations, error: 7.259E-12 

Maximum estimated error = 1.000E-8
Integrating SQRT between 1.000 and 10.000 -> 20.4151844011225289 
Simpson                 257 evaluations, error: 3.168E-9 
Romberg (rational)       33 evaluations, error: 4.571E-7 
Romberg (polynomial)     33 evaluations, error: 9.061E-7 

[THEN]

			        ( * End of File * )
