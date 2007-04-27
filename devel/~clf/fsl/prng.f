\ Pseudo random number generator in ANS Forth
\
\         Forth Scientific Library Algorithm #57
\
\       Leaves a pseudo random number in the range (0,1)
\           on fp stack.
\
\ ---------------------------------------------------
\     (c) Copyright 1998  Julian V. Noble.          \
\       Permission is granted by the author to      \
\       use this software for any application pro-  \
\       vided this copyright notice is preserved.   \
\ ---------------------------------------------------
\
\   Based on GGUBS algorithm:  s' = 16807*s mod (2^32-1)
\   P. Bratley, B.L. Fox and L.E. Schrage, A guide to simulation
\   (Springer, Berlin, 1983).
\
\   To simplify transport to 16-bit machines the 32-bit
\   modular division is performed by synthetic division:
\   note that
\
\       bigdiv = divis * m1 + m2
\
\   so that ( [n] means "largest integer <= n" )
\
\       s' = s*m1 - [s*m1/b]*b = m1 * (s - [s/d]*d) - m2 * [s/d]
\
\   Environmental dependences:
\
\       1. assumes at least 32-bit DOUBLEs
\       2. needs FLOATING and DOUBLE wordsets
\       3. assumes separate floating point stack
\



\ MARKER -rand

2VARIABLE     seed


21474.83647   D>F   FCONSTANT  bigdiv             \ 2^31-1
1277.73       D>F   FCONSTANT  divis
16807.        D>F   FCONSTANT  m1
2836.         D>F   FCONSTANT  m2

: (rand)    ( adr --)   ( f: -- seed')
    LOCALS| adr |
    adr 2@  D>F                 ( f: seed)
    divis FOVER FOVER           ( f: s d s d)
    F/  F>D                     ( [s/d])
    2DUP   D>F      ( [s/d])    ( f: s d [s/d])
    F*   F-                     ( f: s-d*[s/d] = s mod d)
    m1   F*                     ( f: m1*[s mod d])
    D>F  m2  F*  F-             ( f: seed')
    FDUP  F>D                   ( seed')    ( f: seed')
    adr  2! ;                   \ save seed'

: prng      ( f: -- random#)
    seed  (rand)  bigdiv            ( f: -- seed 2**31-1)
    FSWAP  FDUP  F0<        ( -- f) ( f: -- 2**31-1 seed)
    IF   FOVER  F+   THEN   FSWAP  F/  ;

: test  0.1  seed 2!  1000 0 DO  prng  FDROP  LOOP  seed 2@ D. ;
\ TEST 522329230  ok



