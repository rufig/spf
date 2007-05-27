REQUIRE 2VARIABLE lib/include/double.f
REQUIRE [DEFINED] lib/include/tools.f

WINAPI: GetTickCount kernel32

: COUNTER ( -- ud ) GetTickCount ;

\ =====================================================================
\ FORTH, INC. Core benchmark series
\
\ Copyright (c) 1972-1999, FORTH, Inc.
\
\ These simple benchmarks are used for comparisons of FORTH, Inc.
\ implementations.  Execute BENCHMARK to run all of them.  Timing is
\ only as accurate as the granularity of the target's millisecond
\ counter.  This inaccuracy can be reduced when the tests are run for
\ longer periods.  Increase the #TIME constant if you want the timings
\ to be more repeatable.
\
\ Requires: COUNTER PAUSE REQUIRES IN LOAD
\
\ Exports: BENCHMARK
\
\ =====================================================================
\
\ --------------------------------------------------------------------
\ Benchmark support words
\
\ ELAPSED-TIME returns the time in milliseconds that has elapsed
\ between the execution of [$ and $].
\
\ ###,###,###,### formats the given double with the given number of
\ extra triplets.
\
\ SCALE-TIME displays the elapsed time, less the tare time established
\ the first time this routine is called.
\
\ LOOPS returns DO LOOP parameters, keeping limit positive.

\ [$ is the prefix to a testing word.  It sets the starting time and
\ the stack depth and returns the loop parameters.
\
\ STACK-DELTA returns the number of items that have been added to the
\ stack since the execution of [$.
\
\ DROPS discards the items that have been added to the stack.
\
\ $] is the suffix to a testing word.  If the loop count is negative,
\ it determines if we have been executing this test for at least 1 sec.
\ If not, it doubles the loop count and returns false to repeat the
\ test.  Otherwise, it makes the loop count positive, displays the
\ elapsed time and returns true. No display words are executed
\ between [$ and $] to avoid the overhead that this creates
\ on some systems.
\
\ /#LOOPS initializes the loop counter to a negative 16 so that a new
\ baseline will be established by $].
\
\ N/A displays an indication that this test is not available.
\
\ --------------------------------------------------------------------

1000 CONSTANT #TIME  \ Minimum time to run each test.
1024 CONSTANT #CELLS \ Cells of data needed for SORT

2VARIABLE TARE-TIME   \ Testing overhead
 VARIABLE START-TIME  \ Time we started
 VARIABLE START-DEPTH \ Stack size at start
 VARIABLE END-TIME    \ Time we ended
 VARIABLE #LOOPS      \ Number of times around DO LOOPs

: ELAPSED-TIME ( -- n )   END-TIME @ START-TIME @ - ;

: ###,###,###,### ( d n -- )
   <#  0 DO  # # #  2DUP OR IF  [CHAR] , HOLD  ELSE  LEAVE
   THEN  LOOP  2DUP OR IF  #S  THEN  #>
   15 OVER - SPACES  TYPE  SPACE ;

: SCALE-TIME ( -- )   [DEFINED] M*/ [IF]
      ELAPSED-TIME 1000 M*  1000 #LOOPS @ M*/
   [ELSE]  ELAPSED-TIME  1000000 M*  #LOOPS @ MU/MOD ROT DROP
   [THEN]  TARE-TIME 2@ OR IF
      TARE-TIME 2@ D-  DUP 0< IF
         2DROP 0 0  THEN
   ELSE  2DUP TARE-TIME 2!  THEN
   2DUP 1000000. D< IF  1
   ELSE  2DUP 1000000000. D< IF  2
   ELSE  3  THEN  THEN
   ###,###,###,### ;

: LOOPS ( -- l f )   #LOOPS @ ABS 1+ 1 ;

: [$ ( -- l f )   DEPTH START-DEPTH !  LOOPS  COUNTER START-TIME ! ;

: STACK-DELTA ( ... -- ... n )   DEPTH START-DEPTH @ - 0 MAX ;

: DROPS ( ... -- )   STACK-DELTA  BEGIN  ?DUP WHILE  NIP 1-  REPEAT ;

: $] ( -- flag )
   COUNTER END-TIME !  #LOOPS @ 0< IF
      ELAPSED-TIME 1000 < IF
         #LOOPS @ 2* #LOOPS !  0 EXIT
   THEN  THEN  #LOOPS @ ABS #LOOPS !
   CR  SCALE-TIME  ." = Timing for "  1 ;

: /#LOOPS ( -- )   -16 #LOOPS ! ;

: N/A ( -- )   CR  14 SPACES  ." 0 = Timing for NO " ;

\ --------------------------------------------------------------------
\ Core FORTH, Inc. Benchmarks
\
\ This series of tests analyze the Forth primitives.
\
\ $DO$ tests an empty DO LOOP sequence.  This should always be the
\ first test so that it establishes the tare factor.
\
\ $*$ tests the primitive math operator * .
\
\ $/$ tests the primitive math operator / .
\
\ $+$ tests the primitive math operator + .
\
\ $M*$ tests the primitive math operator M* .
\
\ $M+$ tests the primitive math operator M+ .
\
\ $*/$  tests the math primitive */ .  This may or may not tell you
\ how the other math primitives perform depending on how */ has been
\ coded.
\
\ $/MOD$ tests the primitive math operator /MOD .
\
\ $UM/MOD$ tests the primitive math operator UM/MOD .
\
\ $PAUSE$ tests the multitasker loop with PAUSE .  It is assumed that
\ each system tested has the same number of tasks defined in the round
\ robin and that they are doing the same things (i.e. nothing).
\
\ $LOAD$ tests the outer interpreter by loading the 2nd block in the
\ Bench.src file.  It is assumed that block contains stuff that will
\ not accumulate if loaded multiple times.
\
\ --------------------------------------------------------------------

: $DO$     BEGIN [$ DO I               DROPS LOOP $] UNTIL ." DO LOOP" ;

: $*$      BEGIN [$ DO I DUP *         DROPS LOOP $] UNTIL ." *" ;

: $/$      BEGIN [$ DO 1000 I /        DROPS LOOP $] UNTIL ." /" ;

: $+$      BEGIN [$ DO 1000 I +        DROPS LOOP $] UNTIL ." +" ;

: $M*$     BEGIN [$ DO I DUP M*        DROPS LOOP $] UNTIL ." M*" ;

: $M+$     BEGIN [$ DO 1000 0 I M+     DROPS LOOP $] UNTIL ." M+" ;

: $*/$     BEGIN [$ DO I DUP DUP */    DROPS LOOP $] UNTIL ." */" ;

: $/MOD$   BEGIN [$ DO 1000 I /MOD     DROPS LOOP $] UNTIL ." /MOD" ;

: $UM/MOD$ BEGIN [$ DO 1000 0 I UM/MOD DROPS LOOP $] UNTIL ." UM/MOD" ;

: BENCHMARK ( -- )   /#LOOPS  0 0 TARE-TIME 2!
   CR  ." sec  ms  us  ns = Timing for this system"
   $DO$   $*$  $/$  $+$  $M*$  $UM/MOD$  $M+$  $/MOD$  $*/$
   /#LOOPS ;

