\ Adaptive integration using 3 point Gauss-Legendre
\   with Richardson extrapolation
\
\      Forth Scientific Library Algorithm #54

\ ---------------------------------------------------
\     (c) Copyright 1998  Julian V. Noble.          \
\       Permission is granted by the author to      \
\       use this software for any application pro-  \
\       vided this copyright notice is preserved.   \
\ ---------------------------------------------------

\ This is an ANS Forth program requiring:
\      The FLOAT and FLOAT EXT word sets
\ Environmental dependencies:
\       Assumes independent floating point stack
\ The FORmula TRANslator in ftran110.f can convert the commented
\ phrases  f" ... ", replacing the following forth code.

\ Usage:  use( fn.name xa xb err )integral
\ Examples:
\   12 set-precision  ok
\   use( fsqrt 0e 1e 1e-8 )integral cr fs. 609  function calls
\   6.66666666670E-1  ok
\
\   : x^1.5   fdup  fsqrt  f*  ;  ok
\   use( x^1.5  0e 1e 1e-8 )integral cr fs. 165  function calls
\   3.99999999994E-1  ok

MARKER  -int

\ Non STANDARD words:

: undefined   BL WORD  FIND  NIP  0=  ;

\ vectoring: for fwd recursion, or using function names as arguments
undefined use(      [IF]
: use(      '       \ state-smart ' for syntactic sugar
    STATE @  IF  POSTPONE LITERAL  THEN  ;  IMMEDIATE

' NOOP  CONSTANT  'noop
: v:   CREATE  'noop  ,  DOES> PERFORM  ;   \ create dummy def'n
: 'dfa   ' >BODY  ;                         ( -- data field address)
: defines    'dfa   STATE @
             IF   POSTPONE  LITERAL    POSTPONE  !
             ELSE   !   THEN  ;  IMMEDIATE
\      V:   define a function vector
\      DEFINES  (IMMEDIATE)  set a vector, as in
\            V: DUMMY  ;
\            : TEST    ( xt -- ) DEFINES DUMMY
\                   DUMMY  ;
\            3 5 ' * TEST .  15 ok
\      USE(     (IMMEDIATE) get the xt of a word
\
\      the vectoring words are included in ftran110.f
[THEN]
\ end vectoring

undefined 1array [IF]
    : long   ;
    : 1array    ( len data_size --)     CREATE  2DUP  ,  ,  *  ALLOT   ;
    : _len      ( base_addr -- len)  \ determine length of an array
            CELL+  @  ;
    : }         ( base_adr indx -- adr[indx] )
            OVER  _len  OVER  <=  OVER  0<  OR  ABORT" Index out of range"
            OVER  @   *  +  CELL+  CELL+  ;
\      1array  create a a one-dimensional array
\           as in 20  1 FLOATS  1array A{
\      }    dereference a one-dimensional array
\           as in  A{ I }  ( base.adr -- base.adr + offset )
[THEN]

\ points and weights for 3 point Gauss-Legendre integration
    8e  9e   F/         FVARIABLE  w0   w0 F!
    5e  9e   F/         FVARIABLE  w1   w1 F!
    9e  15e  F/ FSQRT   FCONSTANT  x1

\ Data structures

64e  63e  F/  FVARIABLE Cinterp   Cinterp F!

20 CONSTANT Nmax
1 FLOATS  CONSTANT  float_len

Nmax long float_len    1array x{
Nmax long float_len    1array E{
Nmax long float_len    1array I{

0 VALUE  N
0 VALUE  nn

FVARIABLE  oldI
FVARIABLE  finI
FVARIABLE  deltaI

FVARIABLE dx
FVARIABLE dxi
FVARIABLE xi

\ Begin program

: scale    ( f: xa xb -- )
    FOVER    F-    F2/      ( f: [xb-xa]/2)
    FSWAP  FOVER  F+        ( f: [xb-xa]/2  [xa+xb]/2 )
    xi F!    FDUP  dx F!   x1 F*  dxi F!  ;

VARIABLE Ntimes             \ count of function evaluations

V: fdummy

: )int  ( n -- )     \ 3 point Gauss-Legendre
    TO nn
    x{ nn 1- }  F@  x{ nn }  F@   scale
    \ f" I{nn_1-}=dx*(w0*fdummy(xi)+w1*(fdummy(xi+dxi)+fdummy(xi-dxi))) "
    dx F@ w0 F@ xi F@ fdummy F* w1 F@ xi F@ dxi F@ F+ fdummy xi F@ dxi
    F@ F- fdummy F+ F* F+ F* I{ nn 1- } F!
    3 Ntimes +! ;

: initialize  ( xt --)  ( f: xa xb eps -- integral)
     defines  fdummy
     1 TO N
     E{ 0 } F!   X{ 1 } F!   X{ 0 } F!
     0 Ntimes !
     1 )int
     0e  finI F!
;

: check.n       N  [ Nmax 1- ] LITERAL >
        ABORT" Too many subdivisions!"  ;

: E/2   E{ N  1- }  DUP   F@   F2/    F! ;

: }down    ( adr n --)
        OVER @  >R   }   DUP   R@ +   R>   MOVE  ;

: move.down    E{ N  1- }down
               x{ N     }down ;

: N+1   N 1+   TO N  ;
: N-2   N 2 -  TO N  ;

: subdivide
        check.n     E/2   move.down
        \  f" oldI = I{N_1-} "
        I{ N 1- } F@ oldI F!
        \  f" x{N} + x{N_1-} "
	x{ N } F@ x{ N 1- } F@ F+
        F2/  x{ N } F!
        N )int   N 1+ )int    ;

: converged?   ( f: --)  ( -- f)
        \  f" I{N} + I{N_1-} - oldI "
        I{ N } F@ I{ N 1- } F@ F+ oldI F@ F-
        FDUP   deltaI  F!   FABS
        E{ N 1- } F@   F2*    F<  ;

: interpolate    \ f" finI = deltaI * Cinterp + oldI + finI "
                 deltaI F@ Cinterp F@ F* oldI F@ finI F@ F+ F+ finI F! ;


: )integral    ( f: xa xb err -- I[xa,xb]) ( xt --)
     initialize
     BEGIN   N 0>   WHILE
        subdivide
        converged?    N+1
        IF    interpolate  N-2    THEN
     REPEAT   finI  F@
     Ntimes @  .  ."  function calls" ;
