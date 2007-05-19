\ Mersenne Twister
( <!--BASE HREF="http://home.earthlink.net/~neilbawd/mersenne.html"--> )

MODULE: MERSENNE_TWISTER

REQUIRE 'th ~ygrek/lib/neilbawd/toolbelt.f

0 [IF] =======================================================
                                          Wil Baden 2000-05-27

        Billions and Billions of Random Numbers

In 1997, Makoto Matsumoto and Takuji Nishimura developed the
Mersenne Twister. The Mersenne Twister is "designed with
consideration of the flaws of various existing generators,"
has a super-astronomical period of 2^19937 - 1, gives a
sequence that is 623-dimensionally equidistributed, and "has
passed many stringent tests, including the die-hard test of
G. Marsaglia and the load test of P. Hellekalek and S.
Wegenkittl."  It is efficient in memory usage (typically
using 2506 bytes of static data, and the code is quite short
as well).  It generates random numbers in batches of 624 at a
time, so the caching and pipelining of modern systems is
exploited. It is also divide- and mod-free.

And it is fast.  In C, it's four times faster than the
inadequate Standard C Library function `rand`.  Elko
Tchernev reports 100 million random numbers in 22 seconds
using SwiftForth.

For full information, http://www.math.keio.ac.jp/~matumoto/emt.html

It is easy to port the C code to Standard Forth.

------------------------------------------------------- [THEN]
0 [IF] =======================================================
A Forth program for MT19937: Integer version (1999/10/28)
`GENRAND` generates one pseudorandom unsigned integer (32bit)
which is uniformly distributed among 0 to 2^32-1  for each
call. `seed SGRENRAND` sets initial values in the working
area of 624 words. Before `GENRAND`, `seed SGENRAND` must be
called once. (`seed` is any 32-bit integer.)

Coded in C by Takuji Nishimura, considering the suggestions by
Topher Cooper and Marc Rieffel in July-Aug. 1997.

Converted to Standard Forth by Wil Baden, 2000-05-15.

C version copyright (C) 1997, 1999 Makoto Matsumoto and
Takuji Nishimura. When you use this, send an email to:
<A HREF="mailto:matumoto@math.keio.ac.jp">M. Matsumoto</A>
with an appropriate reference to your work.

REFERENCE

  M. Matsumoto and T. Nishimura,

  "Mersenne Twister: A 623-Dimensionally Equidistributed Uniform
  Pseudo-Random Number Generator",

  ACM Transactions on Modeling and Computer Simulation,
  Vol. 8, No. 1, January 1998, pp 3--30.

------------------------------------------------------- [THEN]
0 [IF] =======================================================

        Needed from Tool Belt

NEEDS
           'th
/NEEDS

------------------------------------------------------- [THEN]

    : PRIME       ( n -- flag )
        DUP 1 AND 0= IF  2 =  EXIT THEN
        1                                     ( n d)
        BEGIN  2 +
               2DUP DUP * U< IF  2DROP  TRUE EXIT  THEN
               2DUP MOD 0=
        UNTIL  2DROP                          ( )
        FALSE ;

\  Period parameters

624 CONSTANT MTN  \  "N" has been renamed "MTN".
397 CONSTANT MTM  \  "M" has been renamed "MTM".

    0x09908B0DF CONSTANT Matrix-A    \  Constant vector A
    0x080000000 CONSTANT Upper-Mask  \  Most significant bits
    0x07FFFFFFF CONSTANT Lower-Mask  \  Least significant bits

\  Tempering parameters

    0x09D2C5680 CONSTANT Tempering-Mask-B
    0x0EFC60000 CONSTANT Tempering-Mask-C

    : Tempering-Shift-U  11 RSHIFT ;
    : Tempering-Shift-S   7 LSHIFT ;
    : Tempering-Shift-T  15 LSHIFT ;
    : Tempering-Shift-L  18 RSHIFT ;

CREATE MT  MTN CELLS ALLOT  \  The array for the state vector.
CREATE MTI  -1 ,
    \  Unsigned MTI > MTN means MT[...] isn't initialized.

EXPORT

\  Initializing the array with a seed.

: SGENRAND          ( seed -- )
    MTN 0 DO
        DUP 0x0FFFF0000 AND  I 'th MT !
        69069 * 1+
        DUP 0x0FFFF0000 AND 16 RSHIFT  I 'th MT @ OR  I 'th MT !
        69069 * 1+
    LOOP DROP       ( )
    MTN MTI ! ;

0 [IF] =======================================================
Initialization by `SGENRAND` is an example. Theoretically,
there are 2^19937-1 possible states as an initial state. The
following function allows choosing any of 2^19937-1 states.
Essential bits in `seed-array[]` are the following 19937
bits: `seed-array[0]&Upper-Mask`, `seed-array[1]`, ...,
`seed-array[MTN-1]`. `seed-array[0]&Lower-Mask` is discarded.

Theoretically, `seed-array[0]&Upper-Mask`, `seed-array[1]`,
..., `seed-array[MTN-1]` can take any values except all zeros.
------------------------------------------------------- [THEN]

: LSGENRAND         ( &seed-array -- )
    \  The length of seed-array[] must be at least MTN cells.
    MTN 0 DO
        I 'th OVER @  I 'th MT !
    LOOP DROP       ( )
    MTN MTI ! ;

: GENRAND           ( -- u )

    MTI @  MTN U< 0= IF    \  Generate MTN words at one time.

        MTI @ MTN = 0= IF  \  If SGENRAND hasn't been called,
            4357 SGENRAND   \  a default initial seed is used.
        THEN

        \  {0...N-M-1}
        MTN MTM - 0 DO
            I 'th MT @ Upper-Mask AND
                I 1+ 'th MT @ Lower-Mask AND  OR  ( y)
            DUP 1 RSHIFT SWAP  ( x y)
            1 AND IF  Matrix-A XOR  THEN  ( x)
            I MTM + 'th MT @  XOR
            I 'th MT !  ( )
        LOOP

        \  {N-M...N-2}
        MTN 1-  MTN MTM -  DO
            I 'th MT @ Upper-Mask AND
                I 1+ 'th MT @ Lower-Mask AND  OR  ( y)
            DUP 1 RSHIFT SWAP  ( x y)
            1 AND IF  Matrix-A XOR  THEN  ( x)
            I MTM + MTN - 'th MT @  XOR
            I 'th MT !  ( )
        LOOP

        \  N-1, 0
        MTN 1- 'th MT @ Upper-Mask AND
            MT @ Lower-Mask AND  OR  ( y)
        DUP 1 RSHIFT SWAP  ( x y)
        1 AND IF  Matrix-A XOR  THEN  ( x)
        MTM 1- 'th MT @  XOR
        MTN 1- 'th MT !  ( )

        0 MTI !
    THEN

    MTI @ 'th MT @   1 MTI +!  ( u)
    DUP Tempering-Shift-U  XOR
    DUP Tempering-Shift-S  Tempering-Mask-B AND  XOR
    DUP Tempering-Shift-T  Tempering-Mask-C AND  XOR
    DUP Tempering-Shift-L  XOR ;

0 [IF] =======================================================

The speed and staggering features make this a powerful
candidate for Monte Carlo simulation and cryptography.

2^19937-1 is a big number, suitable for billions and billions
of pseudo-random numbers.  How big can be seen by writing it
in decimal -- 6002 digits.

------------------------------------------------------- [THEN]

\  `u GENRANDMAX`  yields a uniform random integer < `u`.

: GENRANDMAX        ( u -- n )
    GENRAND UM* NIP ;

\  Mersenne Twister for Floating Point.

: FGENRAND          ( F: -- 0. <= r <= 1. )
    GENRAND 0 D>F S" 2.3283064370807974E-10 F*" EVALUATE
    ;

: FGENRAND-1        ( F: -- 0. <= r < 1. )
    GENRAND 0 D>F S" 2.3283064365386963E-10 F*" EVALUATE
    ;

0 [IF] =======================================================

A _Mersenne number_ is a number of the form 2^_w_-1.  A _Mersenne
prime_ is a Mersenne number that is prime.  A necessary but not
sufficient condition for a Mersenne prime is that _w_ is prime.
Another condition will make it sufficient.

As of May 2000, there are 38 known Mersenne primes.  2^19937-1
is the 24th and has 6002 decimal digits.  The 38th is
2^6972593-1 and I don't know how many decimal digits.

<A HREF="http://www.utm.edu/research/primes/programs/gallot/proths.html">
Finding Primes
</A>

    \  Lukas-Lehmer Test for Mersenne Primes
    : Lukas-Lehmer  ( w -- flag )
        DUP 2 < IF  1 =  EXIT THEN
        DUP 1 AND 0= IF  2 =  EXIT THEN
        DUP PRIME NOT IF  DROP FALSE  EXIT THEN
        1 OVER LSHIFT 1- SWAP      ( 2^w-1 w)

        4 SWAP 1- 1 DO             ( 2^w-1 u)
            DUP UM* -2 M+ THIRD UM/MOD DROP
        LOOP

        NIP 0= ;

    \  Mersenne primes in 32 bits.

    MARKER ONCE
    : RUN  CR ." \  "
        CR 32 2 DO
            I Lukas-Lehmer IF  1 I LSHIFT 1- . THEN
        LOOP ;
    RUN ONCE

    \  3 7 31 127 8191 131071 524287 2147483647

2^61-1 and 2^89-1 are the next two Mersenne primes.

For cryptography, replace `SGENRAND` with a function using a
secure hash to fill MT.

`COUNTER SGENRAND` or `uCOUNTER XOR SGENRAND` is usually good
enough to initialize simple randomizing.

For best performance, use macros to define ancillary words.

    : Tempering-Shift-U  S" 11 RSHIFT " EVALUATE ; IMMEDIATE
    : Tempering-Shift-S  S"  7 LSHIFT " EVALUATE ; IMMEDIATE
    : Tempering-Shift-T  S" 15 LSHIFT " EVALUATE ; IMMEDIATE
    : Tempering-Shift-L  S" 18 RSHIFT " EVALUATE ; IMMEDIATE

        How Mersenne Twister Works

One way to define a linear congruential series is to pick
numbers _m_ and _p_, where _p_ is a prime, and _m_ is a "generator" for
it.  A generator for a prime _p_ is a number such that its
powers modulo _p_ yield all positive numbers less than _p_.  Thus
you can start with any positive number less than _p_, and
continue multiplying by _m_ to get all positive numbers less
than _p_.

For example, 3 and 5 are the generators for 7.

    MARKER Run-and-Forgotten

    7 VALUE The-Prime

    : Generator-Check            ( -- )
        The-Prime 1 DO  CR
            I BEGIN                 ( x)
                DUP .  DUP 1 >
            WHILE
                I *  The-Prime MOD
            REPEAT DROP             ( )
        LOOP ;

    Generator-Check  Run-and-Forgotten

    1
    2 4 1
    3 2 6 4 5 1
    4 2 1
    5 4 6 2 3 1
    6 1

In the Mersenne Twister, instead of numbers, we are working
with vectors of 19937 bits.  In this, the equivalent of a
generator is a 19937 by 19937 matrix that can successively
multiply any of the vectors that is not all 0 to obtain every
vector that is not all 0.  The arithmetic is done modulo 2.
Addition is _x + y mod 2_ and multiplication is _x * y mod 2_.
These are the same as _x xor y_ and _x and y_.

In the program, `Matrix-A` is a value that can be used to form
such a matrix.  The once-every-624-times part of the program
takes this value and does calculations that are equivalent to
multiplying by the full matrix.

This gives 2^19937-1 combinations of 19937 bits.

The matrix has the following form, but 19937 by 19937.

    0 1 0 0 0 0
    0 0 1 0 0 0
    0 0 0 1 0 0
    0 0 0 0 1 0
    0 0 0 0 0 1
    a b c d e f

The done-every-time part twists the output to obscure the
algebraic connection between successive elements.  It's
equivalent to multiplying by an invertible 19937 by 19937
matrix.

------------------------------------------------------- [THEN]

;MODULE

\EOF

: RUN  1000 0 DO  I 5 MOD 0= IF CR THEN  GENRAND U. CR  LOOP ;

WINAPI: GetTickCount KERNEL32.DLL

10000000 VALUE #N

: TEST
  GetTickCount DUP SGENRAND
  #N DUP 0 DO
   GENRAND DROP
  LOOP
  SWAP GetTickCount - ABS / . ." pseudorandom numbers in 1 ms"
;

\ На Celeron 3.2 GHz - 5 000 000 псевдослучайных чисел в секунду
