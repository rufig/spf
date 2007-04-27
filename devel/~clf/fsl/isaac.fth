\ Copyright 1997-1999 Pierre Henri Michel., Abbat as a derivative work.
\ Translated from Bob Jenkins' C code.
\ http://ourworld.compuserve.com/homepages/bob_jenkins/isaacafa.htm
\ See R. Jenkins, "ISAAC", LNCS 1039 (Fast Software Encryption), pp 41-49, February 1996.
\ Anyone may use this code freely, as long as credit is given.
CR
.( isaac.f translated from Bob Jenkins' rand.c ) CR
.( by Pierre Abbat    Version 1.4   1999-03-23 ) CR
\
\      Forth Scientific Library Algorithm #52
\
\ This random number generator works as follows:
\
\ Two pointers, m and m2, slide along mm separated by half the size of mm.
\ When one gets to the end, it jumps to the beginning.
\ Two numbers, a and b, are carried on the stack. A calculation is performed
\ on the numbers at m and m2, the numbers a and b, and two numbers in mm
\ found by indexing using two non-overlapping bytes of intermediate results.
\ The calculation modifies the number at m, a, and b, and also stores
\ the new value of b in randrsl, which is the output array. The word rand
\ returns the contents of randrsl in reverse order.
\
\ Each time a batch of numbers is computed, the counter cc is incremented
\ and added to bb (which becomes the b on the stack). This ensures that
\ the period of the RNG is at least 4294967296 batches. As ISAAC has three
\ cells and a kilobyte of internal state, the period is probably much larger.
\
\ This RNG is designed to be cryptographically secure. It is slower than
\ RNGs that are not cryptographically secure. If you do not need cryptographically
\ secure random numbers, you may want to use another RNG.
\
\ Depending on your Forth and processor, you may get a substantial speedup
\ (about twice as fast on Intel processors) by coding 5ROLL in assembly.
\
\ The following words are provided for the user:
\ rand ( - n )
\ Returns a 32-bit random number.
\
\ randinit ( flag )
\ True randinit mixes the contents of randrsl and stores them in mm.
\ False randinit stores a fixed bit-pattern in mm.
\
\ Nonstandard and non-core words:
\ \                     CORE EXT
\ ROLL                  CORE EXT
\ PICK                  CORE EXT
\ TUCK                  CORE EXT
\ NIP                   CORE EXT
\ 2ROT                  DOUBLE EXT
\ ERASE                 CORE EXT
\ 3DROP                 : 3DROP   2DROP DROP ;
\ OFF                   : OFF   0 SWAP ! ;
\ ?DO                   CORE EXT
\ BOUNDS                : BOUNDS   OVER + SWAP ;
\ CELL-                 : CELL-   1 CELLS - ;
\ U.R                   CORE EXT
\ TRUE                  CORE EXT
\ HEX                   CORE EXT
\ MS ( test code )      FACILITY EXT 
\
\ Environmental dependencies:
\ This program assumes that a cell is 32 bits and 1 CELLS is 4.
\ If the former is true, but the latter is not, only ind need be changed.
\ This program assumes 2's-complement arithmetic.
\
\ The system is still standard after loading this module.

\ NEEDS FSL_UTIL.F ( only for TEST-CODE? )
\ ANEW isaac-random-number-generator
BASE @
HEX
100 CONSTANT randsiz
8 CONSTANT randsizl
-1 CELLS CONSTANT -CELL
CREATE randrsl  randsiz CELLS ALLOT
VARIABLE randptr ( like randcnt in C )
CREATE mm  randsiz CELLS ALLOT ( internal state of isaac )
VARIABLE aa  aa OFF
VARIABLE bb  bb OFF
VARIABLE cc  cc OFF

\ The following code is a speedup for an Intel 80386 or up.
\ code 5ROLL      ( n1 n2 n3 n4 n5 n6 -- n2 n3 n4 n5 n6 n1 )
\ ( This occurs three times in rngstep, and the "optimizer"
\   turns it into a long code sequence. )
\         xchg    ebx,    0 [esp]  ( ebx is top of stack in Win32Forth )
\         xchg    ebx,    4 [esp]
\         xchg    ebx,    8 [esp]
\         xchg    ebx,    c [esp]
\         xchg    ebx,    10 [esp]
\         next    c;

: ind ( u - u' )
( Given u, produces one of the elements of mm. )
  [ randsiz 1- CELLS ] LITERAL AND  mm + @ ;

: rngstep ( a b m m2 r mix - a' b' m+4 m2+4 r+4 )
  5 ROLL XOR 2 PICK @ +                 ( b m m2 r a' )
  3 PICK @ SWAP 5 ROLL                  ( m m2 r x a' b )
  2DUP 4 PICK ind + + DUP 7 PICK ! NIP  ( m m2 r x a' y )
  randsizl RSHIFT ind ROT + DUP         ( m m2 r a' b' b' )
  2ROT CELL+ SWAP CELL+ SWAP            ( r a' b' b' m+4 m2+4 )
  ROT 5 ROLL TUCK ! CELL+               ( a' b' m+4 m2+4 r+4 ) ;

: isaac
  aa @ 1 cc +! cc @ bb @ + mm DUP randsiz CELLS 2/ + randrsl
  randsiz 2/ 0 DO
    4 PICK 0d LSHIFT rngstep
    4 PICK 06 RSHIFT rngstep
    4 PICK 02 LSHIFT rngstep
    4 PICK 10 RSHIFT rngstep
  4 +LOOP
  NIP mm SWAP
  randsiz 2/ 0 DO
    4 PICK 0d LSHIFT rngstep
    4 PICK 06 RSHIFT rngstep
    4 PICK 02 LSHIFT rngstep
    4 PICK 10 RSHIFT rngstep
  4 +LOOP
  3DROP bb ! aa ! ;

: reset-isaac
  aa OFF bb OFF cc OFF randrsl 1- randptr !
  mm randsiz CELLS ERASE ;

reset-isaac

: rand
  randptr @ randrsl U< IF
    isaac
    randrsl randsiz 1- CELLS + randptr !
  THEN
  randptr @ @  -CELL randptr +! ;

: -ROLL
( This is slow code, but it's used only in the initialization! )
  DUP 1+ SWAP
  0 ?DO
    DUP ROLL SWAP
  LOOP DROP ;

: 8@
  8 CELLS +
  8 0 DO
    CELL- DUP @ SWAP
  LOOP DROP ;

: 8!
  8 CELLS BOUNDS DO
    i !
  CELL +LOOP ;

: 8+!
  8 CELLS BOUNDS DO
    i +!
  CELL +LOOP ;

: (nextnum)
  -ROT OVER + 2SWAP TUCK + SWAP 2SWAP ROT 7 -ROLL ;

: mix ( h g f e d c b a - h' g' f' e' d' c' b' a' )
  OVER 0b LSHIFT XOR  (nextnum)
  OVER 02 RSHIFT XOR  (nextnum)
  OVER 08 LSHIFT XOR  (nextnum)
  OVER 10 RSHIFT XOR  (nextnum)
  OVER 0a LSHIFT XOR  (nextnum)
  OVER 04 RSHIFT XOR  (nextnum)
  OVER 08 LSHIFT XOR  (nextnum)
  OVER 09 RSHIFT XOR  (nextnum)
  ;

: randinit ( flag )
( Initializes isaac. If the argument is 0, use a default initialization;
  otherwise, use the contents of randrsl to compute the seed. )
  reset-isaac
  >R ( save flag )
  9e3779b9 DUP 2DUP 2DUP 2DUP mix mix mix mix
  R@ 0= IF randrsl randsiz CELLS ERASE THEN
 
  randrsl randsiz CELLS BOUNDS DO
    i 8+! i 8@ mix i mm + randrsl - DUP >R 8! r> 8@
  8 CELLS +LOOP
  r> IF
    mm randsiz CELLS BOUNDS DO
      i 8+! i 8@ mix i 8! i 8@
    8 CELLS +LOOP
  THEN
  2DROP 2DROP 2DROP 2DROP ;

TEST-CODE? [IF]

: test
  reset-isaac
  BASE @ HEX
  0a 0 DO isaac LOOP
  aa @ u. bb @ u. cc @ u.
  ." should be D4D3F473 902C0691 A" BASE ! ;

: test768
( Outputs the first 768 numbers generated by isaac
  initialized with randrsl zeroed. The second and third
  256 are the numbers in randvect.txt backward in two groups.
  randvect.txt is a test vector file on Bob Jenkins' site. )
  CR ." The first line should be"
  CR ."  182600F3 300B4A8D 301B6622 B08ACD21 296FD679 995206E9 B3FFA8B5  FC99C24"
  randrsl randsiz CELLS ERASE
  true randinit
  BASE @ HEX
  300 0 DO
    i 8 MOD 0= IF CR 77 MS THEN
    rand 9 U.R
  LOOP
  CR ."  82D53D12 1010B275 786B2908 4D3CFBDA 94A302F4 95C85EAA D7E1C7BE 82AC484F"
  CR ." should be the last line."
  BASE ! ;

[THEN]

BASE !
