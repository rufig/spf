\ logistic     The Logistic function and its first derivative
\     logistic =   Exp( c + a x ) / (1 + Exp( c + a x ) )
\   d_logistic = a Exp( c + a x ) / (1 + Exp( c + a x ) )^2

\ Forth Scientific Library Algorithm #4

\ This code conforms with ANS requiring:
\      1. The Floating-Point word set
\

\ (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.


cr .( Logistic          V1.2           17 October 1994   EFC )


: logistic ( --, f: x a c -- z )
        FROT FROT
        F* F+
        FEXP
        FDUP 1.0e0 F+
        F/
;

: d_logistic ( -- , f: x a c -- z )
        FSWAP FROT
        FOVER F* FROT F+
        FEXP
        
        FDUP 1.0e0 F+ FDUP F*
        F/ F*
;

\ Examples % 1.0 % 1.0 % 0.0 logistic f.  0.731059
\          % 3.2 % 1.5 % 0.2 logistic f.  0.993307
\          % 3.2 % 1.5 % 0.2 d_logistic f. 0.00997209






