\ Adaptive integration using trapezoidal rule
\ with Richardson extrapolation
\   Integrate a real function from xa to xb
\
\      Forth Scientific Library Algorithm #53

\ ---------------------------------------------------
\     (c) Copyright 1997  Julian V. Noble.          \
\       Permission is granted by the author to      \
\       use this software for any application pro-  \
\       vided this copyright notice is preserved.   \
\ ---------------------------------------------------

\ Usage:  use( fn.name xa xb err )integral
\ Examples:

\       use( fsqrt  0e  1e  1e-3 )integral fs. 6.666659e-1 ok
\       use( fsqrt  0e  2e  1e-4 )integral fs. 1.885618e0 ok

\       : f1     FDUP FSQRT F*  ;  ok
\       use( f1  0e  1e  1e-3 )integral fs. 4.00000017830E-1  ok
\       use( f1  0e  2e  1e-4 )integral fs. 2.26274170358E0  ok


\ Programmed by J.V. Noble (from "Scientific FORTH" by JVN)
\ ANS Standard Program  -- version of  October 15th, 1998

\ This is an ANS Forth program requiring:
\      The FLOAT and FLOAT EXT word sets
\ Environmental dependencies:
\       Assumes independent floating point stack
\ The FORmula TRANslator in ftran110.f can convert the commented
\ phrases  f" ... ", replacing the following forth code.

MARKER  -int

\ Non STANDARD words:

: undefined   BL WORD  FIND  NIP  0=  ;
undefined s>f       [IF]  : s>f     S>D  D>F  ;     [THEN]
undefined f0.0      [IF]  0.0E0  FCONSTANT  f0.0    [THEN]

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

\ Data structures
FVARIABLE  c43
4 S>F  3 S>F  F/   c43  F!

20 long 1 FLOATS    1array X{
20 long 1 FLOATS    1array E{
20 long 1 FLOATS    1array F{
20 long 1 FLOATS    1array I{

0 VALUE  N
0 VALUE  NN

FVARIABLE  oldI
FVARIABLE  finI
FVARIABLE  deltaI

\ Begin program
: )INT  ( n --)  TO NN              \ trapezoidal rule
    \ f" ( F{NN} + F{NN_1-} ) * ( X{NN} - X{NN_1-} )  "
    F{ NN } F@ F{ NN 1- } F@ F+ X{ NN } F@ X{ NN 1- } F@ F- F*
    F2/
    I{ NN 1- } F!  ;

v: DUMMY                                  \ dummy function name

: INITIALIZE  ( xt --)  ( f: xa xb eps -- integral)
     DEFINES  DUMMY
     1 TO N
     E{ 0 } F!   X{ 1 } F!   X{ 0 } F!
\    f" f{0} = dummy( x{0} ) "
     X{ 0 } F@ DUMMY F{ 0 } F!
\    f" f{1} = dummy( x{1} ) "
     X{ 1 } F@ DUMMY F{ 1 } F!
     1 )INT
     f0.0  finI F!   ;

: check.n       N  19 >   ABORT" Too many subdivisions!"  ;
: E/2   E{ N  1- }  DUP   F@   F2/    F! ;

: }down    ( adr n --)
        OVER @  >R   }   DUP   R@ +   R>   MOVE  ;

: move.down    E{ N  1-       }down
               x{ N           }down
               f{ N           }down  ;

: x'   \ f" x{N} + x{N_1-} " 
       X{ N } F@ X{ N 1- } F@ F+
       F2/  x{ N } F!
       \ f" f{N} = dummy( x{N} ) "
       X{ N } F@ DUMMY F{ N } F!  ;

: N+1   N 1+   TO N  ;
: N-2   N 2 -  TO N  ;

: subdivide
        CHECK.N     E/2   move.down
        \ f" oldI = I{N_1-} "
        I{ N 1- } F@ oldI F!
        x'   N )INT   N 1+ )INT    ;

: converged?   ( f: --)  ( -- f)
        \ f" I{N} + I{N_1-} - oldI "
        I{ N } F@ I{ N 1- } F@ oldI F@ F- F+
        FDUP   deltaI  F!   FABS
        E{ N 1- } F@   F2*    F<  ;

: interpolate    \ f" finI = deltaI * c43 + oldI + finI "
                 deltaI F@ c43 F@ F* oldI F@ finI F@ F+ F+ finI F!  ;


: )integral    ( f: A B ERR -- I[A,B]) ( xt --)
     initialize
     BEGIN   N 0>   WHILE
        subdivide
        converged?    N+1
        IF    interpolate  N-2    THEN
     REPEAT   finI  F@  ;
