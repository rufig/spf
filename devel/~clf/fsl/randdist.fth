NEEDS FSL_Util
NEEDS isaac
\ ANEW random-number-distributions
\      Forth Scientific Library Algorithm #51

\ Copyright 1998, 1999 Pierre Henri Michel., Abbat.
\ Anyone may use this code freely, as long as this notice is preserved.
cr .( Random Number Distributions  1.1  1999-01-15    phma )
\ Generates random numbers according to the following distributions:
\ Continuous uniform
\ Discrete uniform
\ Normal
\ Normal with exclusion criteria
\ Exponential
\ Poisson
\
\ The following words are provided for the user:
\ Die ( n - random-number )
\ Rolls an n-sided die, numbered from 0 to n-1.
\
\ FRand ( f: - f )
\ Returns a floating-point random number in the interval [0,1).
\
\ FRandCentered ( f: - f )
\ Returns a floating-point random number in the interval [-1,1).
\
\ FRandUniform ( f: a b - f )
\ Returns a floating-point random number in the interval [b,a) or (a,b].
\ It can return b; it may return a because of roundoff error.
\
\ FNormal01 ( f: - f )
\ Returns a floating-point random number normally distributed with
\ mean 0 and standard deviation 1.
\
\ FNormal ( f: mean sdev - f )
\ Returns a floating-point random number normally distributed with
\ the specified mean and standard deviation.
\
\ FNormalNotched ( f: mean sdev center width - f )
\ Returns a floating-point random number from the normal distribution
\ from which a notch has been removed. Useful for simulating the
\ distribution of, for example, 10% tolerance resistors from which
\ the 1% tolerance resistors have been removed. If the width is negative,
\ the interval removed is the ratio (1-width)/(width+1) above and below
\ center (see F~). Note: If width is positive, it passes the width
\ to FNormalTail for speed, but not if width is negative.
\
\ FNormalBounded ( f: mean sdev lowbound highbound - f )
\ Returns a floating-point random number from a normal distribution
\ from which both tails have been removed.
\
\ FNormalRightWing ( f: mean sdev lowbound - f )
\ Returns a floating-point random number from the upper side
\ of a normal distribution.
\
\ FNormalLeftWing ( f: mean sdev highbound - f )
\ Returns a floating-point random number from the lower side
\ of a normal distribution.
\
\ FNormalTail ( f: mean sdev width - f )
\ Returns a floating-point random number from the tails
\ of a normal distribution. If width exceeds 8*sdev, this word
\ will be snail-slow; the limit can be changed by changing scalesize.
\
\ FExponential ( f: p - f )
\ Returns a floating-point random number exponentially distributed
\ with parameter p.
\
\ Poisson ( f: f ; - n )
\ Returns a random number Poisson-distributed with parameter f.
\ Execution time is proportional to n.
\
\ This is an ANS Forth program with environmental dependencies
\ requiring the Floating-Point word set.
\
\ Nonstandard and non-core, non-float words:
\ \                     CORE EXT
\ NEEDS                 Includes a file if it hasn't been included already.
\ FSQRT                 FLOATING EXT
\ FLN                   FLOATING EXT
\ FABS                  FLOATING EXT
\ FPICK                 Copies a number from somewhere in the FP stack.
\ NIP                   CORE EXT
\ PICK                  CORE EXT
\ TUCK                  CORE EXT
\ TRUE                  CORE EXT 
\ S" (interpretive)     FILE
\ [IF]                  TOOLS EXT
\ [ELSE]                TOOLS EXT
\ PAGE                  FACILITY
\ AT-XY                 FACILITY
\ KEY?                  FACILITY
\ [THEN]                TOOLS EXT
\ COLS                  Number of columns on the terminal.
\ ROWS                  " rows. If not defined, these are set to 80 and 25.
\
\ This program uses a word rand which returns a one-cell unsigned random number.
\ Such a word is defined in isaac.
\
\ Environmental dependencies:
\ This program assumes that the floating-point stack
\ is separate from the integer stack.
\
\ This program assumes that 1e-30 > 0 and there is a number
\ between 1.0000001 and 1. Both are true for single floats.
\
\ Minimum terminal facilities needed:
\ For non-test code, none. The test code uses PAGE AT-XY and KEY? .
\
\ Changes from version 1.0:
\ Added a compile switch to speed up uniform random number generation
\ at some cost in distribution smoothness.
\ Added a check of the float and cell sizes to frand.
\ Added a word to generate normals bypassing the scaling routine.
\ Added timetest to see how much faster they are.



BASE @ DECIMAL

( The following [IF] changes whether Die uses UM* or a mask.
  Setting it to FALSE makes it more accurate; setting it
  to TRUE makes it faster.
  On my computer I got these speeds for 1000000 dice, frands, and others:
              Slow Fast
  Die          40   22  seconds with FAST-RAND? false and true, respectively
  FRand        45   25  seconds using one and two cells per float, respectively
  FNormal      72   65  seconds with scaling and using FNormal01, respectively
  FNormal01         64  seconds
  1e0 Poisson 564  528  seconds with FExponential F- and FRand F*, respectively
  )

FALSE [IF]

: Die ( u - u' )
( Rolls a u-sided die. Result is from 0 to u-1.
  If u=0 or u=1, returns 0. )
  rand UM* NIP ;

[ELSE]

: mask ( n - n )
( e.g. 100 - 127 )
  [ S" ADDRESS-UNIT-BITS" ENVIRONMENT? [IF] CELLS [ELSE] 16 [THEN] ]
  LITERAL 1 DO
    DUP I RSHIFT OR
  I +LOOP ;

: Die ( u - u' )
( Rolls a u-sided die. Result is from 0 to u-1.
  If u=0, same as rand. If u=1, returns 0. )
  1- DUP mask
  BEGIN
    rand OVER AND
  DUP 3 PICK U> WHILE
    DROP
  REPEAT NIP NIP ;

[THEN]

1 FLOATS 1 CELLS <= [IF]
( If a float is no bigger than a cell, there is no point in getting
  two cells to fill a float. )

0 1 D>F FCONSTANT singlesize

: FRand ( f: - f )
( Returns a random number from 0 inclusive to 1 exclusive. )
  rand S>F singlesize F/
  FDUP F0< IF 1E0 F+ THEN ;

: FRandCentered ( f: - f )
( Returns a random number from -1 inclusive to 1 exclusive. )
  rand S>F singlesize F/ F2* ;

[ELSE]

0 1 D>F FDUP F* FCONSTANT doublesize

: FRand ( f: - f )
( Returns a random number from 0 inclusive to 1 exclusive. )
  rand rand D>F doublesize F/
  FDUP F0< IF 1E0 F+ THEN ;

: FRandCentered ( f: - f )
( Returns a random number from -1 inclusive to 1 exclusive. )
  rand rand D>F doublesize F/ F2* ;

[THEN]

: FRandUniform ( f: high low - f )
  FOVER F- FRand F* F+ ;

: circle>normals ( f: x y x^2+y^2 - norm1 norm2 )
  FDUP F0> IF ( if it's zero, leave it alone and don't make infinity )
    FDUP FLN FNEGATE F2* FSWAP F/ FSQRT
  THEN
  FDUP FROT F* FROT FROT F* ;

: 2normals ( f: scale - f1 f2 )
  BEGIN
    FRandCentered FOVER F* FRandCentered 2 FPICK F*
    FOVER FDUP F* FOVER FDUP F* F+
    FDUP 1E0 F> WHILE
    FDROP FDROP FDROP
  REPEAT
  circle>normals FROT FDROP ;

: 2normals-unscaled ( f: - f1 f2 )
  BEGIN
    FRandCentered FRandCentered
    FOVER FDUP F* FOVER FDUP F* F+
    FDUP 1E0 F> WHILE
    FDROP FDROP FDROP
  REPEAT
  circle>normals ;

64 CONSTANT scalesize
scalesize FLOAT ARRAY tempnormal{
scalesize 1 CHARS ARRAY oddnormal{
scalesize FLOAT ARRAY scale{

MARKER DISCARD

: invscale ( f: y - norm1^2 )
  0E0 FSWAP FDUP FDUP F* circle>normals FDROP FDUP F* ;

: scale ( f: norm1^2 - y )
  1e0 1e-30
  BEGIN
    F2DUP F+ F2/
    FDUP invscale 4 FPICK F> IF
      FSWAP FDROP
    ELSE
      FROT FDROP FSWAP
    THEN
  F2DUP -2E-7 F~ UNTIL
  FDROP FSWAP FDROP ;

: fill-scale
  scalesize 0 DO
    I S>F scale scale{ I } F!
    TRUE oddnormal{ I } C!
  LOOP ;

fill-scale DISCARD

: (fnormal) ( n ; f: - f )
  oddnormal{ OVER } DUP C@ TUCK 0= SWAP C! IF
    scale{ OVER } F@ 2normals tempnormal{ SWAP } F!
  ELSE
    tempnormal{ SWAP } F@
  THEN ;

: FNormal01 ( f: - f )
( fast normal variate with mean 0 and sd 1 )
  [ oddnormal{ 0 } ] LITERAL DUP C@ TUCK 0= SWAP C! IF
    2normals-unscaled [ tempnormal{ 0 } ] LITERAL F!
  ELSE
    [ tempnormal{ 0 } ] LITERAL F@
  THEN ;

: FNormal ( f: mean sdev - f )
  FNormal01 F* F+ ;

: (tails) ( f: tail - f )
( Returns a random number, at least tail in absolute value,
  from the unit normal distribution. Tail should be at most 8. )
  FABS FDUP FDUP F* FLOOR F>S scalesize 1- MIN
  BEGIN
    DUP (fnormal) F2DUP FABS F> WHILE
    FDROP
  REPEAT
  DROP FSWAP FDROP ;

: FNormalTail ( f: mean sdev width - f )
  FOVER F/ (tails) F* F+ ;

: FNormalUpperTail ( f: mean sdev width - f )
  FOVER F/ (tails) FABS F* F+ ;

: FNormalLowerTail ( f: mean sdev width - f )
  FOVER F/ (tails) FABS FNEGATE F* F+ ;

: FNormalNotched ( f: mean sdev center width - f )
  FRAME| a b c d |
  a -1E0 F< ABORT" Invalid width" ( otherwise it would hang )
  a F0> IF
    b a F+ d F- ( high end of reject interval minus mean )
    d b a F- F- ( mean minus low end of reject interval )
    FMIN 0E0 FMAX
  ELSE
    0E0
  THEN
  &e F!
  BEGIN
    d c e FNormalTail
    FDUP b a F~ WHILE
    FDROP
  REPEAT |FRAME ;

: FNormalBounded ( f: mean sdev lowbound highbound - f )
  FRAME| a b c d |
  BEGIN
    d c FNormal
    FDUP b F> FDUP a F< XOR WHILE
    FDROP
  REPEAT |FRAME ;

: FNormalRightWing ( f: mean sdev lowbound - f )
  FRAME| a b c |
  a c F- 0E0 FMAX &e F!
  BEGIN
    c b e
    FDUP F0= IF FNormalTail ELSE FNormalUpperTail THEN
    FDUP a F< WHILE
    FDROP
  REPEAT |FRAME ;

: FNormalLeftWing ( f: mean sdev highbound - f )
  FRAME| a b c |
  c a F- 0E0 FMAX &e F!
  BEGIN
    c b e
    FDUP F0= IF FNormalTail ELSE FNormalLowerTail THEN
    FDUP a F> WHILE
    FDROP
  REPEAT |FRAME ;

: FExponential ( f: p - f )
  FRand FDUP F0> IF FLN FNEGATE THEN F* ;

\ : Poisson ( f: lambda ; - n )
\   0 BEGIN
\     1E0 FExponential F-
\   FDUP F0> WHILE
\     1+
\   REPEAT FDROP ;

: Poisson ( f: lambda - ; - n )
  FNEGATE FEXP  1E0    0
  BEGIN
    FRand F*
    F2DUP F< WHILE
    1+
  REPEAT  FDROP FDROP ;

TEST-CODE? [IF]
( Warning: DO NOT change the screen width
  between compiling and using this code! )

S" COLS" FORTH-WORDLIST SEARCH-WORDLIST 0= [IF]
80 CONSTANT COLS
[ELSE]
DROP
[THEN]

S" ROWS" FORTH-WORDLIST SEARCH-WORDLIST 0= [IF]
25 CONSTANT ROWS
[ELSE]
DROP
[THEN]

COLS CELL ARRAY histo{
VARIABLE PLOTTING

: STAR   [CHAR] * EMIT ;

: clear-histo
  COLS 0 DO
    histo{ I } OFF
  LOOP
  PLOTTING ON ;

: +histo ( n )
  DUP COLS 1- U< IF
    histo{ OVER } 1 OVER +!
    @ 15 + 16 / DUP ROWS > IF
      PLOTTING OFF 2DROP
    ELSE
      ROWS SWAP - AT-XY STAR
    THEN
  ELSE
    DROP
  THEN ;

: f+histo ( f: n )
  FLOOR F>S +histo ;

: )plot ( 'fun )
( Plots a histogram of fun. Fun should take no arguments
  and return one float. For interesting results, fun should
  be a random-number generator or an input. )
  PAGE clear-histo
  BEGIN
    PLOTTING @ IF
      DUP EXECUTE f+histo
    THEN
  KEY? UNTIL
  DROP PAGE ;

: u20-60 ( f: - f )
  2E1 6E1 FRandUniform ;

: n40-10 ( f: - f )
  4E1 1E1 FNormal ;

: n40-40 ( f: - f )
  4E1 FDUP FNormal ;

: n40-10-n30-5 ( f: - f )
  4E1 1E1 3E1 5E0 FNormalNotched ;

: n40-10-n40-35 ( f: - f )
  4E1 1E1 FOVER 35E0 FNormalNotched ;

: n40-40-n35-7 ( f: - f )
  4E1 FDUP 35E0 7E0 FNormalNotched ;

: n40-40-n45-9 ( f: - f )
  4E1 FDUP 45E0 9E0 FNormalNotched ;

: n40-10-b28-35 ( f: - f )
  4E1 1E1 28E0 35E0 FNormalBounded ;

: n40-10-b36-54 ( f: - f )
  4E1 1E1 36E0 54E0 FNormalBounded ;

: n40-10-r20 ( f: - f )
  4E1 1E1 2E1 FNormalRightWing ;

: n40-10-r60 ( f: - f )
  4E1 1E1 6E1 FNormalRightWing ;

: n40-10-l20 ( f: - f )
  4E1 1E1 2E1 FNormalLeftWing ;

: n40-10-l60 ( f: - f )
  4E1 1E1 6E1 FNormalLeftWing ;

: n37-15-t10
  37E0 15E0 1E1 FNormalTail ;

: fish10 ( f: - f )
  1E1 Poisson S>F ;

: fish40 ( f: - f )
  4E1 Poisson S>F ;

: exp10
  1E1 FExponential ;

: exp40
  4E1 FExponential ;

: .menu
  PAGE
  ." A   Uniform Distribution" CR
  ." B   Normal Distribution" CR
  ." C   Normal Distribution" CR
  ." D   Notched Normal Distribution" CR
  ." E   Notched Normal Distribution" CR
  ." F   Notched Normal Distribution" CR
  ." G   Notched Normal Distribution" CR
  ." H   Right Wing of Normal Distribution" CR
  ." I   Right Wing of Normal Distribution" CR
  ." J   Left Wing of Normal Distribution" CR
  ." K   Left Wing of Normal Distribution" CR
  ." L   Bounded Normal Distribution" CR
  ." M   Bounded Normal Distribution" CR
  ." N   Tails of Normal Distribution" CR
  ." O   Poisson Distribution" CR
  ." P   Poisson Distribution" CR
  ." Q   Exponential Distribution" CR
  ." R   Exponential Distribution" CR
  ." X   Exit" CR
  ;

: (test) ( - ? )
  TRUE 0E0 ( in case an off-menu option is selected )
  .menu KEY -33 AND ( convert to upper ) CASE
    [CHAR] A OF  USE( u20-60           ENDOF
    [CHAR] B OF  USE( n40-10           ENDOF
    [CHAR] C OF  USE( n40-40           ENDOF
    [CHAR] D OF  USE( n40-10-n30-5     ENDOF
    [CHAR] E OF  USE( n40-10-n40-35    ENDOF
    [CHAR] F OF  USE( n40-40-n35-7     ENDOF
    [CHAR] G OF  USE( n40-40-n45-9     ENDOF
    [CHAR] H OF  USE( n40-10-r20       ENDOF
    [CHAR] I OF  USE( n40-10-r60       ENDOF
    [CHAR] J OF  USE( n40-10-l20       ENDOF
    [CHAR] K OF  USE( n40-10-l60       ENDOF
    [CHAR] L OF  USE( n40-10-b28-35    ENDOF
    [CHAR] M OF  USE( n40-10-b36-54    ENDOF
    [CHAR] N OF  USE( n37-15-t10       ENDOF
    [CHAR] O OF  USE( fish10           ENDOF
    [CHAR] P OF  USE( fish40           ENDOF
    [CHAR] Q OF  USE( exp10            ENDOF
    [CHAR] R OF  USE( exp40            ENDOF
    [CHAR] X OF  0=                    ENDOF
    USE( FDUP SWAP
  ENDCASE
  DUP IF
    )plot KEY DROP
  THEN FDROP ;

: test
  BEGIN (test) 0= UNTIL ;

: time ( - seconds )
  time&date drop 2drop 60 * + 60 * + ;

: .elapse ( starttime stoptime )
  swap - 86400 + 86400 mod . ." seconds" ;

: timetest
  time
  1000000 0 DO
    I Die DROP
\   FRand FDROP
\   0e0 1e0 FNormal FDROP
\   1E1 Poisson DROP
  LOOP
  time .elapse ;

[THEN]
BASE !
