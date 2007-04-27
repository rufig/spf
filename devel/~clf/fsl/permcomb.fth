
cr
.( Permutations & Combinations. Version FSL1.0  27th October 1994) cr
.(         Gordon Charlton - gordon@charlton.demon.co.uk) cr
cr

\ Forth Scientific Library Algorithm #59

\ (c) Copyright 1994 Gordon R Charlton.  Permission is granted by
\ the author to use this software for any application provided this
\ copyright notice is preserved.

\ ANS Forth Program.
\ Requiring the Double-Number word set (namely M*/).
\ Requiring .( ?DO \ from the Core Extensions word set.


: mu* ( ud1 u--ud2)  TUCK * >R  UM*  R> + ;
\
\ multiply unsigned double d1 by unsigned single u giving unsigned double ud2.


: perms ( u1 u2--ud)  1. 2SWAP
                       SWAP 1+ DUP ROT -
                       ?DO  I mu*  LOOP ;
\
\ return nPr, where u1=n u2=r. All arguments are unsigned, result is double.
\
\ This is an iterative version of the recurrence;
\      r=0 --> nPr = 1
\      r>0 --> nPr = nP(r-1)(n-r+1)


VARIABLE temp  \ private to combs

: combs ( u1 u2--ud)  1. 2SWAP
                       2DUP - MIN
                       SWAP temp !
                       1+ 1 ?DO  temp @  I M*/
                                 -1 temp +!
                            LOOP ;
\
\ return nCr, where u1=n u2=r. All arguments are unsigned, result is double.
\
\ This is an iterative version of the recurrence;
\      r=0 --> nCr = 1
\      r>0 --> nCr = nC(r-1)(n-r+1)/r
\
\ This recurrance was chosen in favour of the more common
\      nCr = n!/(n-r)! r!
\ to avoid excessively large intermediate results. Use of integer maths
\ necessitates that the multiplication be done before the division, to avoid
\ truncation errors, hence the use of M*/, which has a triple length
\ intermediate result. Advantage is taken of the symmetry of the function
\ to minimise the number of iterations.

\ end of Permutations & Combinations.


\ for testing...
: testingcode  ( -- )
cr
." Permutations.." cr
cr
." 7 0 perms = " 7 0 perms D. ."    should be 1" cr
." 7 3 perms = " 7 3 perms D. ."  should be 210" cr
." 7 5 perms = " 7 5 perms D. ." should be 2520" cr
." 7 7 perms = " 7 7 perms D. ." should be 5040" cr
cr
." Combinations.." cr
cr
." 7 0 combs = " 7 0 combs D. ."  should be 1" cr
." 7 3 combs = " 7 3 combs D. ." should be 35" cr
." 7 5 combs = " 7 5 combs D. ." should be 21" cr
." 7 7 combs = " 7 7 combs D. ."  should be 1" cr
cr
;

