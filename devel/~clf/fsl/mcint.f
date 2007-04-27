\ One-dimensional Monte-Carlo integration
\
\       Forth Scientific Library Algorithm #58
\ 
\ ---------------------------------------------------
\     (c) Copyright 1998  Julian V. Noble.          \
\       Permission is granted by the author to      \
\       use this software for any application pro-  \
\       vided this copyright notice is preserved.   \
\ ---------------------------------------------------
\
\ Usage:  use( fn.name xa xb )monte
\ Examples:

\       use( FSQRT 10000 0e  1e  )monte FS. 6.67675E-1  ok
\       use( FSQRT 10000 0e  2e  )monte FS. 1.88408E0  ok

\       : F1     FDUP FSQRT F*  ;  ok
\       use( f1  10000 0e  1e  )monte FS. 3.97621E-1  ok
\       use( f1  10000 0e  2e  )monte FS. 2.27428E0  ok


MARKER -mcint

\ Conditional definition of non-Standard words

BL PARSE [undefined] DUP PAD C! PAD CHAR+ SWAP CHARS MOVE PAD FIND NIP 0=
[IF]  : [undefined]    BL WORD  FIND  NIP  0=  ;   [THEN]


[undefined]  prng  [IF]  S" prng.f" INCLUDED  [THEN]


[undefined] s>f   [IF] : s>f   S>D  D>F  ;    [THEN]
[undefined] f^2   [IF] : f^2   FDUP  F*  ;    [THEN]
[undefined] ftuck [IF] : ftuck  FSWAP  FOVER  ;   [THEN]

[undefined]  use( [IF]
\ Vectoring: for using function names as arguments
: use(      '       \ state-smart ' for syntactic sugar
    STATE @  IF  POSTPONE LITERAL  THEN  ;  IMMEDIATE

' NOOP  CONSTANT  'noop
: v:   CREATE  'noop  ,  DOES> PERFORM  ;   \ create dummy def'n
: 'dfa   ' >BODY  ;                         ( -- data field address)
: defines    'dfa   STATE @
             IF   POSTPONE  LITERAL    POSTPONE  !
             ELSE   !   THEN  ;  IMMEDIATE
\ end vectoring
[THEN]

\ Program starts here

\ Data structures
    v: fdummy

    1000 VALUE  Nmax
    0 VALUE Npoints

    0.1 seed 2!

    FVARIABLE xa    FVARIABLE xb-xa

    FVARIABLE  Var
    FVARIABLE  <f>

\ Actions
    : x     ( f: -- x = xa + xi*[xb-xa])    \ guess a new point
        prng   xb-xa F@  F*   xa F@   F+  ;

    : initialize    ( xt n --)    ( f: xa xb error -- integral)
        TO Nmax
        defines  fdummy
        5 TO Npoints
        \ error F!
        FOVER  F-  xb-xa F!     xa F!
        0e <f> F!     0e Var F!
        5 0  DO  x  fdummy  FDUP
                 <f> F@  F+  <f> F!
                 f^2   Var  F@   F+   Var  F!
        LOOP
        <f>   F@  Npoints  s>f  F/   <f>   F!
        Var F@  <f> F@  f^2  Npoints s>f F*  F-   Var F!   ;

    : New_point
        x fdummy
        <f> F@   ftuck  F-  ftuck       ( f: f-<f>  <f>  f-<f>)
        Npoints 1+  DUP TO  Npoints     \ n=n+1
        s>f  F/   F+   <f>   F!         \ <f'> = <f> + (f-<f>)/(n+1)
        f^2                             ( f: [f-<f>]^2 )
        Npoints DUP  1-  s>f  F*
        s>f   F/                        ( f: n*[f-<f>]^2/[n+1] )
        Var F@   F+   Var F!            \ Var' = Var + n*(f-<f>)^2/(n+1)
    ;

    : )monte    ( xt --)    ( f: xa xb error -- integral)
        initialize
        BEGIN     Npoints Nmax <
        WHILE     New_point
        REPEAT    <f>  F@  xb-xa  F@  F*  ;

    : %error   ( f: -- error )
        Var F@  FSQRT  Npoints s>f  F/
        <f> F@  FABS  FDUP  F0>
        IF    F/  1.e2  F*
        ELSE  ." <f> too close to 0"  THEN  ;

