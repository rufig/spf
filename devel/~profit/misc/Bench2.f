REQUIRE BENCHMARK ~profit/misc/Bench.f
REQUIRE PLACE ~mak/place.f
REQUIRE U.R lib/include/core-ext.f

: STRING,             ( str len -- )
    HERE  OVER 1+  ALLOT  PLACE ;
: ," [CHAR] " PARSE  STRING, ; IMMEDIATE

: PAGE ;
: -? WARNING 0! ;

\ =====================================================================
\ FORTH, INC. Highlevel benchmark series
\
\ Copyright (c) 1972-1999, FORTH, Inc.
\
\ These simple benchmarks are used for comparisons of FORTH, Inc.
\ implementations.  Execute BENCHMARK to run all of them.  Timing is
\ only as accurate as the granularity of the target's millisecond
\ counter.
\
\ Requires: @DATE @TIME -? BENCHMARK
\
\ Exports: BENCHMARK
\
\ =====================================================================
\
\ --------------------------------------------------------------------
\ Eratosthenes sieve benchmark program
\
\ This is the original BYTE benchmark.
\
\ --------------------------------------------------------------------

8190 CONSTANT SIZE
CREATE FLAGS   SIZE ALLOT

: DO-PRIME ( -- n )
   FLAGS SIZE -1 FILL
   0 SIZE 0 DO
      I FLAGS + C@ IF
         I 2* 3 + DUP I +  BEGIN
            DUP SIZE < WHILE
               DUP FLAGS + 0 SWAP C! OVER +
         REPEAT  2DROP  1+
   THEN  LOOP ;

: $SIEVE$ ( -- )
   BEGIN [$ DO  DO-PRIME  I DROPS LOOP $] UNTIL
   ." Eratosthenes sieve " DO-PRIME . ." Primes" ;

\ --------------------------------------------------------------------
\ Fibonacci Benchmark
\
\ FIB produces a fibonacci sequence from the given number using
\ recursion.
\
\ --------------------------------------------------------------------

[DEFINED] RECURSE [IF]
   : FIB ( u -- u' )
      DUP 1 > IF
         DUP 1- RECURSE  SWAP 2 -  RECURSE  +
      THEN ;
[THEN]

: $FIB$ ( -- )   [DEFINED] RECURSE [IF]
      BEGIN [$ DO  24 FIB  I DROPS LOOP $] UNTIL
      ." Fibonacci recursion ("  SPACE
      24 DUP .  ." -> "  FIB U.  ." )"
   [ELSE] N/A ." Recursion" [THEN] ;

: $DATE$ ( -- )   [DEFINED] @DATE [IF]
      BEGIN [$ DO  @DATE  I DROPS LOOP $] UNTIL
      ." Date access ("  SPACE DATE  ." )"
   [ELSE] N/A ." Date access" [THEN] ;

: $TIME$ ( -- )   [DEFINED] @TIME [IF]
      BEGIN [$ DO  @TIME  I DROPS LOOP $] UNTIL
      ." Time access ("  SPACE TIME  ." )"
   [ELSE] N/A ." Time access" [THEN] ;

\ --------------------------------------------------------------------
\ EDN Benchmark
\
\ This is EDN's benchmark which does a string comparison.
\
\ --------------------------------------------------------------------

CREATE DST \ The following line is too long to be on this line
," 00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000THERE IS A MATCH000000000000000"

CREATE SRC  ," HERE IS A MATCH"

: $MATCH$ ( -- )
   BEGIN [$ DO  DST COUNT  SRC COUNT  SEARCH  I DROPS LOOP $] UNTIL
   ." EDN's string comparison" ;

\ --------------------------------------------------------------------
\ QuickSort from Hoare & Wil Baden
\
\ --------------------------------------------------------------------

7 CELLS CONSTANT THRESHOLDS

: Precedes ( n1 n2 -- f )   U< ;
: Exchange ( a1 a2 -- )   2DUP  @ SWAP @ ROT !  SWAP ! ;
: Both-Ends ( f l pivot -- f l )
    >R  BEGIN
       OVER @ R@ Precedes WHILE
          1 CELLS 0 D+
    REPEAT  BEGIN
       R@ OVER @ Precedes WHILE
          1 CELLS -
    REPEAT  R> DROP ;

: Order3 ( f l -- f l pivot )
   2DUP OVER - 2/ 1 CELLS NEGATE AND + >R
   DUP @ R@ @ Precedes IF
      DUP R@ Exchange
   THEN  OVER @ R@ @ SWAP Precedes IF
      OVER R@ Exchange  DUP @ R@ @ Precedes IF
         DUP R@ Exchange
   THEN  THEN  R> ;

: Partition ( f l -- f l' f' l )
   Order3 @ >R  2DUP  1 CELLS DUP NEGATE D+  BEGIN
      R@ Both-Ends 2DUP 1+ U< IF
         2DUP Exchange 1 CELLS DUP NEGATE D+
      THEN  2DUP SWAP U<
   UNTIL  R> DROP SWAP ROT ;

: Sink ( f key where -- f )
   ROT >R  BEGIN
      1 CELLS - 2DUP @ Precedes WHILE
         DUP @ OVER 1 CELLS + !  DUP R@ = IF
            ! R>  EXIT
         THEN  ( key where -- )
   REPEAT  1 CELLS + ! R> ;

: Insertion ( f l -- )
   2DUP U< IF
      1 CELLS + OVER 1 CELLS + DO
         I @ I Sink
      1 CELLS +LOOP  DROP
   ELSE  ( f l -- ) 2DROP
   THEN ;

: Hoarify ( f l -- ... )
   BEGIN
      2DUP THRESHOLDS 0 D+ U< WHILE
         Partition  2DUP - >R  2OVER - R> > IF
            2SWAP
   THEN  REPEAT  Insertion ;

: QUICK ( f l -- )
   DEPTH >R  BEGIN
      Hoarify DEPTH R@ <
   UNTIL  R> DROP ;

: SORT ( a n -- )
   DUP 0= ABORT" Nothing to sort "
   1- CELLS  OVER +  QUICK ;

CREATE POINTERS   #CELLS CELLS ALLOT

: fill-data ( -- )
   #CELLS 0 DO
      #CELLS ( I') I -  I CELLS POINTERS + !
   LOOP ;

: $SORT$ ( -- )
   BEGIN [$ DO  fill-data POINTERS #CELLS SORT  I DROPS LOOP $] UNTIL
   ." Hoare's quick sort (reverse order)" ;

: Z ( -- )   PAGE  #CELLS 0 DO  I CELLS POINTERS + @  8 U.R  LOOP ;

-? : BENCHMARK ( -- )   BENCHMARK
   $FIB$  $SIEVE$  $SORT$  /#LOOPS  $MATCH$  $DATE$  $TIME$ ;

