\ Forth Inc. benchmark tests adapted by Tom Zimmer, MPE, et. al.
\ Other tests added by MPE.

\ 20030115 Added SPF4
\ 19991201 SFP004 Added iForth 1.11 (7 Nov 99) harness
\ 19991006 SFP003 Added Marcel Hendrix' DHRYSTONE test.
\     Factored out the system interface tests
\     Added results section
\ 19990928 SFP002 Added KEY? test to measure system I/O performance
\ 19990927 SFP001 Removed KEY? DROP from LZ77. This reduces the
\       API overhead which is tested elsewhere.
\     Added BigForth harness courtesy of Bernd Paysan

: start
  S" FORTH-SYS" ENVIRONMENT? IF
    S" SP-FORTH" COMPARE 0= IF
      S" lib\include\tools.f" INCLUDED
    THEN
  THEN
;
start

0 [IF]
Introduction 
============
The application tests have been separated from the primitive tests.
Constants have been declared and modified so that the runtimes
of the application tests (Sieve, Fibonacci, QuickSort) can be
made similar.

The QuickSort test has been refactored to reduce the effect of the
array initialisation, and this is tested in a separate test.

Some compilers include special optimiser rules to eliminate
some of the benchmark code! This is seen in the some of the
primitive test results which are faster than the DO ... LOOP test.
The word [O/N] is to stop some optimising compilers from
throwing away the multiply and divide operations.
The implementation of [O/N] should lay a NOP opcode on
optimising systems, and may be an immediate NOOP on others

Results for optimising compilers
================================

***********************************************
Athlon 700MHz under Windows XP with 128Mb RAM
***********************************************

MPE VFX Forth for Windows IA32   3.40.0849   5 April 2002
SPF4 build 10   19 February 2003
SwiftForth 2.2.2.9 07May2001

Primitives using no extensions
Test time (ms) including overhead       VFX3.4    SPF4      SF
DO LOOP                                   40       40       40
+                                         30       40       40
M+                                        60       60      100
*                                         40       50       80
/                                        350      331      391
M*                                        70       50       80
M/                                       351      430      370
/MOD                                     380      351      371
*/                                       461      471      461
ARRAY fill                                10       20       40
==============================================================
Total:                                  1802     1843     1973

Win32 API: SendMessage                    90      150      130
Win32 API: GetTickCount                   70      170      160
System I/O: KEY?                          40      791     1622
==============================================================
Total:                                   240     1131     1912

Eratosthenes sieve 1899 Primes           460      321      561
Fibonacci recursion ( 35 -> 9227465 )    361      310      681
Hoare's quick sort (reverse order)       350      431     1032
Generate random numbers (1024 kb array)  341      290      480
LZ77 Comp. (400 kb Random Data Mem>Mem)  410      421     1973
Dhrystone (integer)                      351      501     1112
==============================================================
Total:                                  2333     2314     5849
[THEN]

DECIMAL


\ ************************************************
\ Select system to be tested, set FORTHSYSTEM
\ to value of selected target.
\ Set SPECIFICS false to avoid system dependencies
\ Set SPECIFICS true to show off implementation tricks
\ ************************************************

1  CONSTANT VfxForth        \ MPE ProForth VFX 3.4
2  CONSTANT Pfw22           \ MPE ProForth 2.2
3  CONSTANT SwiftForth20    \ FI SwiftForth 2.0
4  CONSTANT SwiftForth15    \ FI SwiftForth 1.5
5  CONSTANT Win32Forth      \ Win32Forth 4.2
6  CONSTANT BigForth        \ BigForth 11 July 1999
7  CONSTANT BigForth-Linux  \ BigForth 11 July 1999
8  CONSTANT iForth          \ iForth 1.12 5 Aug 2001
9  CONSTANT SPF4            \ SPF4

\ select system to test
S" FORTH-SYS" ENVIRONMENT? [IF]
  S" SP-FORTH" COMPARE 0= [IF] SPF4 [ELSE] BYE [THEN]
[ELSE]
  [DEFINED] SWIFT-BAR [IF] SwiftForth20 [ELSE] VfxForth [THEN]
[THEN] CONSTANT ForthSystem

FALSE CONSTANT specifics  \ true to use system dependent code
 TRUE CONSTANT ANSSystem  \ Some Forth 83 systems cannot compile
        \ all the test examples without carnal
        \ knowledge, especially if the cmpiler
        \ checks control structures.

: .specifics  \ -- ; display trick state
  ."  using"  specifics 0=
  IF  ."  no"  THEN
  ."  extensions"
;
: ALIGN-CACHE HERE 4096 2DUP MOD DUP IF - + ELSE 2DROP THEN HERE - ALLOT ;


\ ********************
\ ProForth VFX harness
\ ********************

VfxForth ForthSystem = [IF]
\ specifics 0= [if] -short-branches [then]  \ remove this line for v3.0
specifics [if] absurd inlining [then]

extern: DWORD PASCAL GetTickCount( void )

: COUNTER   \ -- ms
  GetTickCount ;

[undefined] >pos [if]
: >pos          \ n -- ; step to position n
  out @ - spaces
;
[then]

: [o/n]   \ --
  postpone []
; immediate
[THEN]


\ ********************
\ ProForth 2.2 harness
\ ********************

Pfw22 ForthSystem = [IF]

include valPFW22

: COUNTER   \ -- ms
  WinGetTickCount ;

: >pos          \ n -- ; step to position n
  out @ - spaces
;

: M/            \ d n1 -- quot
  m/mod nip
;

: buffer: \ n -- ; -- addr
  create
    here  over allot  swap erase
;

: m+    \ d n -- d'
  s>d d+
;

: [o/n]   \ -- ; stop optimiser treating * DROP etc as no code
; immediate

: SendMessage \ hwn msg wparam lparam -- result
  WinSendMessage
;

: chars   \ n -- n'
; immediate

0 constant ANSSystem
[THEN]


\ ********************
\ SwiftForth15 harness
\ ********************

SwiftForth15 ForthSystem = [IF]
: >pos          \ n -- ; step to position n
  c# @ - spaces
;

: [o/n]   \ -- ; stop optimiser treating * DROP etc as no code
; immediate
[THEN]


\ ********************
\ SwiftForth20 harness
\ ********************

SwiftForth20 ForthSystem = [IF]
: >pos          \ n -- ; step to position n
  get-xy drop - spaces
;

: [o/n]   \ -- ; stop optimiser treating * DROP etc as no code
  postpone noop
; immediate
[THEN]


\ ******************
\ Win32Forth harness
\ ******************

Win32Forth ForthSystem = [IF]
: COUNTER   \ -- ms
  Call GetTickCount ;

: >pos          \ n -- ; step to position n
  getxy drop - spaces
;

: M/            \ d n1 -- quot
  fm/mod nip
;

: buffer: \ n -- ; -- addr
  create
    here  over allot  swap erase
;

: 2-    \ n -- n-2
  2 -
;

: [o/n]   \ -- ; stop optimiser treating * DROP etc as no code
; immediate

: SendMessage \ h m w l -- res
  swap 2swap swap   \ Win32Forth uses reverse order
  Call SendMessage
;

: GetTickCount  \ -- ms
  Call GetTickCount
;
[THEN]


\ ****************
\ BigForth harness
\ ****************

BigForth ForthSystem =
BigForth-Linux ForthSystem =  OR
[IF]

cd
cd \MyApps\BigForth
include ans.str
cd
cd \Products\VfSfp

Code u2/  \ n -- n/2
  1 # AX shr
  Next
end-code  macro

: COUNTER       \ -- ms
  timer@ >us &1000 um/mod nip ;

: >pos          \ n -- ; step to position n
  at? swap drop - spaces
;

: M/            \ d n1 -- quot
  fm/mod nip
;

: buffer:       \ n -- ; -- addr
  create
    here  over allot  swap erase
;

: [o/n]         \ -- ; stop optimiser treating * DROP etc as no code
; immediate

BigForth ForthSystem = [if]
also DOS
0 User32 SendMessage SendMessageA ( l w m h -- res )
0 kernel32 GetTickCount GetTickCount  ( -- ticks )
previous

: SendMessage   \ h m w l -- res
  swap 2swap swap               \ BigForth uses reverse order
  SendMessage
;

0 constant HWND_DESKTOP
16 constant WM_CLOSE
[then]
[THEN]


\ ***************
\ iForth harness
\ ***************

iForth ForthSystem = [IF]

1 CELLS constant CELL
   0    constant HWND_DESKTOP 
   1    constant WM_CLOSE

: NOT ( u1 -- u2 )
  EVAL" 0= " ; IMMEDIATE

: COUNTER   \ -- ms
  EVAL" ?MS " ; IMMEDIATE

: >pos          \ n -- ; step to position n
  ?AT NIP AT-XY ;

0 [if]
: M/            \ d n1 -- quot
  EVAL" SM/REM NIP " ; IMMEDIATE
[then]

: buffer: \ n -- ; -- addr
  create here  over allot  swap erase IMMEDIATE 
  does> ALITERAL ;

: [o/n]   \ -- ; stop optimiser treating * DROP etc as no code
; immediate

: SendMessage \ h m w l -- res
  EVAL" 3DROP " ; IMMEDIATE

: u2/   \ u -- u'
  EVAL" 1 RSHIFT"  ;  IMMEDIATE

0 [if]
: 3drop   \ x1 x2 x3 --
  EVAL" DROP DROP DROP"  ; IMMEDIATE
[then]
[THEN]


\ ***************
\ SPForth harness
\ ***************

SPF4 ForthSystem = [IF]

REQUIRE .R	lib\include\core-ext.f
REQUIRE LOCALS|	~af\lib\locals-ans.f
REQUIRE CASE	lib\ext\case.f
REQUIRE CASE-INS	lib\ext\caseins.f
CASE-INS ON
REQUIRE getxy	~af\lib\getxy.f
WINAPI: SendMessageA	user32.dll
WINAPI: GetTickCount	kernel32.dll

 0 CONSTANT HWND_DESKTOP
16 CONSTANT WM_CLOSE
: >pos          \ n -- ; step to position n
  getxy DROP - SPACES
;
: COUNTER   \ -- ms
  GetTickCount
;
: SendMessage \ h m w l -- res
  SWAP 2SWAP SWAP   \ SPF uses reverse order
  SendMessageA
;
: [o/n] ; IMMEDIATE
: buffer: \ n -- ; -- addr
  CREATE
  HERE  OVER ALLOT  SWAP ERASE
;
: M/ ( d n1 -- quot )  FM/MOD NIP ;
: M+  ( d n -- d ) S>D D+ ;
: u2/ ( u -- u/2 ) 2/ ;
: NOT ( u1 -- u2 ) 0= ;
: <=  > 0= ;
: >=  < 0= ;

[THEN]


\ *************************************
\ Let's measure the generated code size
\ *************************************

here value start-here


\ ************************************
\ FORTH, Inc.  32 Bit Benchmark Source
\ ************************************

CELL NEGATE CONSTANT -CELL

CR .( Loading benchmark routines)


\ ***********************
\ Benchmark support words
\ ***********************

\ column positions
40 constant time-pos
50 constant iter-pos
60 constant each-pos
70 constant extra-pos

: .HEADER \ -- ; display test header
  cr ." Test time including overhead"
  time-pos 3 + >pos  ." ms"
  iter-pos >pos ." times"
  each-pos >pos  ." ns (each)"
;

variable ms-elapsed

: TIMER ( ms iterations -- )
  >r                                    \ number of iterations
  counter swap -                        \ elapsed time in ms
  dup ms-elapsed !      \ save for later
  time-pos >pos  dup 5 .r
  iter-pos >pos  r@ .
  r@ 1 >
  if
    each-pos >pos
    1000000 r> */ 5 .r
  else
    drop  r> drop
  then
;

: .ann    \ -- ; banner announcment
  CR  ;

: [$    \ -- ms
  COUNTER ;

\ $]  is the suffix to a testing word.  It takes the fast ticks
\    timer value and calculates the elapsed time.  It does do
\    some display words before calculating the time, but it is
\    assumed that this will take minimal time to execute.

: $]    ( n -- )   TIMER ;

\ CARRAY  creates a byte size array.
: CARRAY ( n)   CREATE  ALLOT
                DOES> ( n - a)  + ;

\ ARRAY  creates a word size array.
: ARRAY ( n)    CREATE  CELLS ALLOT
                DOES> ( n - a) SWAP CELLS + ;


\ ****************************
\ Basic FORTH, Inc. Benchmarks
\ ****************************
\ This series of tests analyses the Forth primitives.

5000000 constant /prims
\ -- #iterations; all of these words return the number of iterations
: $DO$    .ann ." DO LOOP"  [$  /prims DUP 0 DO  I [o/n] DROP LOOP  $] ;
: $*$     .ann ." *"        [$  /prims DUP 0 DO  I I * [o/n] DROP  LOOP  $] ;
: $/$     .ann ." /"        [$  /prims DUP 1+ 1 DO  1000 I / [o/n] DROP LOOP  $] ;
: $+$     .ann ." +"        [$  /prims DUP 1+ 1 DO  1000 I + [o/n] DROP  LOOP  $] ;
: $M*$    .ann ." M*"       [$  /prims DUP    0 DO  I I M* [o/n] 2DROP  LOOP  $] ;
: $M/$    .ann ." M/"       [$  /prims DUP 1+ 1 DO  1000 0 I M/ [o/n] DROP  LOOP  $] ;
: $M+$    .ann ." M+"       [$  /prims DUP 1+ 1 DO  1000 0 I M+ [o/n] 2DROP  LOOP  $] ;
: $/MOD$  .ann ." /MOD"     [$  /prims DUP 1+ 1 DO  1000 I /MOD [o/n] 2DROP  LOOP  $] ;

\ $*/$  tests the math primitive  */ .  This may or may not tell
\    you how the other math primitives perform depending on
\    how  */  has been coded.
: $*/$    .ann ." */"       [$  /prims DUP 1+ 1 DO  I I I */ [o/n] DROP  LOOP  $] ;


\ ****************************************
\ Eratosthenes sieve benchmark program
\ This is NOT the original BYTE benchmark.
\ ****************************************

8190 CONSTANT SIZE
SIZE buffer: FLAGS
ALIGN-CACHE

: DO-PRIME
      1000 0 DO
               FLAGS SIZE -1 FILL
               0 SIZE 0
               DO I FLAGS + C@
                    IF I 2* 3 + DUP I +
                         BEGIN DUP SIZE <
                         WHILE DUP FLAGS + 0 SWAP C! OVER +
                         REPEAT 2DROP
                              1+
                    THEN
               LOOP
         DROP
         LOOP
     ;

: $SIEVE$   .ann ." Eratosthenes sieve "  [$  DO-PRIME  SIZE 1000 *  ." 1899 Primes"  $] ;


\ *******************
\ Fibonacci recursion
\ *******************

35 constant /fib

: FIB ( n -- n' )
   DUP 1 > IF
      DUP 1- RECURSE  SWAP 2-  RECURSE  +
   THEN ;

: $FIB$
   .ann ." Fibonacci recursion ( "
   [$  /fib dup . ." -> " FIB dup . ." )" /fib - $] ;


\ *********************************
\ QuickSort from Hoare & Wil Baden
\ also contains the array fill test
\ *********************************

7 CELLS CONSTANT THRESHOLD
10000 constant /array
/array 1+ array pointers
ALIGN-CACHE

: Precedes  ( n n - f )    u< ;

: Exchange  ( a1 a2 -- )   2DUP  @ SWAP @ ROT !  SWAP ! ;

: Both-Ends  ( f l pivot - f l )
    >R  BEGIN   OVER @ R@ precedes
        WHILE  CELL 0 D+   REPEAT
        BEGIN   R@ OVER @ precedes
        WHILE  CELL -      REPEAT   R> DROP ;

: Order3  ( f l - f l pivot)   2DUP OVER - 2/ -CELL AND + >R
      DUP @ R@ @ precedes IF DUP R@ Exchange THEN
      OVER @ R@ @ SWAP precedes
        IF OVER R@ Exchange  DUP @ R@ @ precedes
          IF DUP R@ Exchange THEN  THEN   R>  ;

: Partition  ( f l - f l' f' l)   Order3 @ >R  2DUP
      CELL -CELL D+  BEGIN    R@ Both-Ends 2DUP 1+ precedes
      IF  2DUP Exchange CELL -CELL D+  THEN
      2DUP SWAP precedes   UNTIL R> DROP SWAP ROT ;

: Sink  ( f key where - f)   ROT >R
   BEGIN   CELL - 2DUP @ precedes
   WHILE  DUP @ OVER CELL + !  DUP R@ =
        IF  ! R> EXIT THEN   ( key where)
   REPEAT  CELL + ! R> ;

: Insertion  ( f l)   2DUP precedes
    IF  CELL + OVER CELL +   DO  I @ I Sink  CELL +LOOP DROP
    ELSE  ( f l) 2DROP  THEN ;

specifics VfxForth ForthSystem = AND [IF] -short-branches [THEN]  \ remove this line for v3.0
: Hoarify  ( f l - ...)
    BEGIN   2DUP THRESHOLD 0 D+ precedes
    WHILE  Partition  2DUP - >R  2OVER - R> >  IF 2SWAP THEN
    REPEAT Insertion ;

: QUICK  ( f l)   DEPTH >R   BEGIN  Hoarify DEPTH R@ <
      UNTIL  R> DROP ;

: SORT  ( a n)   DUP 0= ABORT" Nothing to sort "
    1- CELLS  OVER +  QUICK ;
specifics VfxForth ForthSystem = AND [IF] +short-branches [THEN]  \ remove this line for v3.0

: fillp   \ -- ; fill sort array once
  /array 0 ?DO  /array I -  I POINTERS !  LOOP ;

: $FILL$  .ann ." ARRAY fill"   [$  100 0 DO  fillp  LOOP  100 /array * $]  ;

: (sort)  200 0 DO   fillp  0 POINTERS 10000 SORT   LOOP ;

: $SORT$
  .ann ." Hoare's quick sort (reverse order)  "
  [$  (sort) 200 /array *  $] ;

\ *******************************
\ End of Forth Inc benchmark code
\ *******************************


\ *********************************
\ "Random" Numbers
\ *********************************

1024 constant /random

variable ShiftRegister
       1 ShiftRegister !
ALIGN-CACHE

: RandBit \ -- 0..1 ; Generates a "random" bit.
  ShiftRegister @ 00000001 and         \ Gen result bit for this time thru.
  dup 0<>                               \ Tap at position 31.
  ShiftRegister @ 00000008 and 0<>     \ Tap at position 28.
  xor 0<>                               \ If the XOR of the taps is non-zero...
  if
    [ HEX ] 40000000 [ DECIMAL ]       \ ...shift in a "one" bit else...
  else
    00000000                           \ ...shift in a "zero" bit.
  then
  ShiftRegister @ u2/                   \ Shift register one bit right.
  or                                    \ OR in new left-hand bit.
  ShiftRegister !                       \ Store new shift register value.
;

0 [IF]
\ More Forth-like versions of RANDBIT
: RandBit \ -- 0..1 ; Generates a "random" bit.
  ShiftRegister @ DUP >R
  1 and dup 0<>                         \ Tap at position 31.
  R@  8 and 0<>       \ Tap at position 28.
  xor                                   \ If the XOR of the taps is non-zero...
  if
    R> 1 RSHIFT $40000000 OR 
    ShiftRegister !
  else
    R> 1 RSHIFT ShiftRegister !
  then                      \ Store new shift register value.
;

: RandBit \ -- 0..1 ; Generates a "random" bit.
  ShiftRegister @
  dup dup 3 rshift  xor  1 and    \ XOR of bits 31 and 28, where bit 31=lsb
  if
    dup 1 RSHIFT $40000000 OR 
    ShiftRegister !
  else
    dup 1 RSHIFT ShiftRegister !
  then                      \ Store new shift register value.
  1 and         \ return original bit 31
;
[THEN]

: RandBits      \ n -- 0..2^(n-1) ; Generate an n-bit "random" number.
  0                                     \ Result's start value.
  swap 0
  do
    2* RandBit or                       \ Generate next "random" bit.
  loop
;

: (randtest)    \ --
  1 ShiftRegister !
  /random 256 cells * allocate
  if
    cr ." Failed to allocate " /random . ." kb for test"
    abort
  then
  /random 256 * 0 do 32 RandBits over i cells + ! loop
  free drop
;

: $RAND$
  .ann ." Generate random numbers (" /random . ." kb array)"
  [$  (randtest)  /random 256 * $] ;


\ *********************************
\ LZ77 compression
\ *********************************

0       Value   lz77-buffer
0       Value   lz77-Pos
0       Value   lz77-BytesLeft

400 constant /lz77-size
4096  CONSTANT    N     ( Size of Ring Buffer )
18    CONSTANT    F     ( Upper Limit for match-length )
2     CONSTANT    Threshold ( Encode string into position & length
                        ( if match-length is greater. )
N     CONSTANT    Nil   ( Index for Binary Search Tree Root )

VARIABLE    textsize    ( Text Size Counter )
VARIABLE    codesize    ( Code Size Counter )
\ VARIABLE  printcount  ( Counter for Reporting Progress )

( These are set by InsertNode procedure. )

VARIABLE    match-position
VARIABLE    match-length

N F + 1 -   carray text-buf   ( Ring buffer of size N, with extra
                  ( F-1 bytes to facilitate string comparison. )

( Left & Right Children and Parents -- Binary Search Trees )

N 1 +             array lson
N 257 +           array rson
N 1 +             array dad

( Input & Output Files )

0 VALUE     infile      0 VALUE     outfile

      17 carray   code-buf

      VARIABLE    len
      VARIABLE    last-match-length
      VARIABLE    code-buf-ptr

      VARIABLE    mask
ALIGN-CACHE

: init-test-buffer
  /lz77-size 256 cells * to lz77-BytesLeft
  lz77-BytesLeft allocate
  if
    cr ." Failed to allocate " /lz77-size . ." kb for test"
    abort
  then
  dup to lz77-buffer to lz77-pos
  /lz77-size 256 * 0
  do  32 randbits lz77-buffer i cells + !  loop
;

: free-test-buffer
  lz77-buffer free drop
;

: getnextchar           \ -- char true | false
  lz77-BytesLeft dup
  if
    drop
    lz77-BytesLeft 1- to lz77-BytesLeft
    lz77-Pos dup 1+ to lz77-Pos
    c@
    true
  then
;

: lz77-read-file        \ addr len fileid -- u2 ior
  drop
  0 rot rot
  0 do                  \ done addr --
    getnextchar if
      over c! 1+ swap 1+ swap
    else
      leave
    then
  loop
  drop 0
;

: lz77-write-file       \ addr len fileid -- ior
  drop 2drop 0
;

: closed
  drop
;

: checked \ flag --
  ABORT" File Access Error. " ;

: read-char \ file -- char 
        drop getnextchar 0= if -1 then
;

(     LZSS -- A Data Compression Program )
(     89-04-06 Standard C by Haruhiko Okumura )
(     94-12-09 Standard Forth by Wil Baden )
(     Use, distribute, and modify this program freely. )

( For i = 0 to N - 1, rson[i] and lson[i] will be the right and
( left children of node i.  These nodes need not be initialized.
( Also, dad[i] is the parent of node i.  These are initialized to
( Nil = N, which stands for `not used.'
( For i = 0 to 255, rson[N + i + 1] is the root of the tree
( for strings that begin with character i.  These are initialized
( to Nil.  Note there are 256 trees. )

( Initialize trees. )

: InitTree                                ( -- )
      N 257 +  N 1 +  DO    Nil  I rson !    LOOP
      N  0  DO    Nil  I dad !    LOOP
;

( Insert string of length F, text_buf[r..r+F-1], into one of the
( trees of text_buf[r]'th tree and return the longest-match position
( and length via the global variables match-position and match-length.
( If match-length = F, then remove the old node in favor of the new
( one, because the old one will be deleted sooner.
( Note r plays double role, as tree node and position in buffer. )

: InsertNode                              ( r -- )
      Nil OVER lson !    Nil OVER rson !    0 match-length !
      DUP text-buf C@  N +  1 +                 ( r p)

      1                                         ( r p cmp)
      BEGIN                                     ( r p cmp)
            0< not IF                           ( r p)

                  DUP rson @ Nil = not IF
                        rson @
                  ELSE

                        2DUP rson !
                        SWAP dad !              ( )
                        EXIT

                  THEN
            ELSE                                ( r p)

                  DUP lson @ Nil = not IF
                        lson @
                  ELSE

                        2DUP lson !
                        SWAP dad !              ( )
                        EXIT

                  THEN
            THEN                                ( r p)

            0 F DUP 1 DO                        ( r p 0 F)

                  3 PICK I + text-buf C@        ( r p 0 F c)
                  3 PICK I + text-buf C@ -      ( r p 0 F diff)
                  ?DUP IF
                        NIP NIP I
                        LEAVE
                  THEN                          ( r p 0 F)

            LOOP                                ( r p cmp i)

            DUP match-length @ > IF

                  2 PICK match-position !
                  DUP match-length !
                  F < not

            ELSE
                  DROP FALSE
            THEN                                ( r p cmp flag)
      UNTIL                                     ( r p cmp)
      DROP                                      ( r p)

      2DUP dad @ SWAP dad !
      2DUP lson @ SWAP lson !
      2DUP rson @ SWAP rson !

      2DUP lson @ dad !
      2DUP rson @ dad !

      DUP dad @ rson @ OVER = IF
            TUCK dad @ rson !
      ELSE
            TUCK dad @ lson !
      THEN                                      ( p)

      dad Nil SWAP !    ( Remove p )            ( )
;

specifics VfxForth ForthSystem = and [IF] -short-branches [THEN]  \ remove this line for v3.0

( Deletes node p from tree. )

: DeleteNode                              ( p -- )

      DUP dad @ Nil = IF    DROP EXIT    THEN   ( Not in tree. )

      ( CASE )                                  ( p)
            DUP rson @ Nil =
      IF
            DUP lson @
      ELSE
            DUP lson @ Nil =
      IF
            DUP rson @
      ELSE

            DUP lson @                          ( p q)

            DUP rson @ Nil = not IF

                  BEGIN
                        rson @
                        DUP rson @ Nil =
                  UNTIL

                  DUP lson @ OVER dad @ rson !
                  DUP dad @ OVER lson @ dad !

                  OVER lson @ OVER lson !
                  OVER lson @ dad OVER SWAP !
            THEN

            OVER rson @ OVER rson !
            OVER rson @ dad OVER SWAP !

      ( ESAC ) THEN THEN                        ( p q)

      OVER dad @ OVER dad !

      OVER DUP dad @ rson @ = IF
            OVER dad @ rson !
      ELSE
            OVER dad @ lson !
      THEN                                      ( p)

      dad Nil SWAP !                            ( )
;
specifics VfxForth ForthSystem = and [IF] +short-branches [THEN]  \ remove this line for v3.0

: Encode                                  ( -- )

      0 textsize !    0 codesize !

      InitTree    ( Initialize trees. )

      ( code_buf[1..16] saves eight units of code, and code_buf[0]
      ( works as eight flags, "1" representing that the unit is an
      ( unencoded letter in 1 byte, "0" a position-and-length pair
      ( in 2 bytes.  Thus, eight units require at most 16 bytes
      ( of code. )

      0 0 code-buf C!
      1 mask C!   1 code-buf-ptr !
      0    N F -                                ( s r)

      ( Clear the buffer with any character that will appear often. )

      0 text-buf  N F -  BL  FILL

      ( Read F bytes into the last F bytes of the buffer. )

      DUP text-buf F infile LZ77-READ-FILE checked   ( s r count)
      DUP len !    DUP textsize !
      0= IF    EXIT    THEN                     ( s r)

      ( Insert the F strings, each of which begins with one or more
      ( `space' characters.  Note the order in which these strings
      ( are inserted.  This way, degenerate trees will be less
      ( likely to occur. )

      F 1 + 1 DO                                ( s r)
            DUP I - InsertNode
      LOOP

      ( Finally, insert the whole string just read.  The
      ( global variables match-length and match-position are set. )

      DUP InsertNode

      BEGIN                                     ( s r)
\           key? drop     \ del SFP001
            ( match_length may be spuriously long at end of text. )
            match-length @ len @ > IF    len @ match-length !   THEN

            match-length @ Threshold > not IF

                  ( Not long enough match.  Send one byte. )
                  1 match-length !
                  ( `send one byte' flag )
                  mask C@ 0 code-buf C@ OR 0 code-buf C!
                  ( Send uncoded. )
                  DUP text-buf C@ code-buf-ptr @ code-buf C!
                  1 code-buf-ptr +!

            ELSE
                  ( Send position and length pair.
                  ( Note match-length > Threshold. )

                  match-position @  code-buf-ptr @ code-buf C!
                  1 code-buf-ptr +!

                  match-position @  8 RSHIFT  4 LSHIFT ( . . j)
                        match-length @  Threshold -  1 -  OR
                        code-buf-ptr @  code-buf C!  ( . .)
                  1 code-buf-ptr +!

            THEN

            ( Shift mask left one bit. )        ( . .)

            mask C@  2*  mask C!    mask C@ 0= IF

                  ( Send at most 8 units of code together. )

                  0 code-buf  code-buf-ptr @    ( . . a k)
                        outfile LZ77-WRITE-FILE checked ( . .)
                  code-buf-ptr @  codesize  +!
                  0 0 code-buf C!    1 code-buf-ptr !    1 mask C!

            THEN                                ( s r)

            match-length @ last-match-length !

            last-match-length @ DUP 0 DO        ( s r n)

                  infile read-char              ( s r n c)
                  DUP 0< IF   2DROP I LEAVE   THEN

                  ( Delete old strings and read new bytes. )

                  3 PICK DeleteNode
                  DUP 3 1 + PICK text-buf C!

                  ( If the position is near end of buffer, extend
                  ( the buffer to make string comparison easier. )

                  3 PICK F 1 - < IF             ( s r n c)
                        DUP 3 1 + PICK N + text-buf C!
                  THEN
                  DROP                          ( s r n)

                  ( Since this is a ring buffer, increment the
                  ( position modulo N. )

                  >R >R                         ( s)
                        1 +    N 1 - AND
                  R>                            ( s r)
                        1 +    N 1 - AND
                  R>                            ( s r n)

                  ( Register the string in text_buf[r..r+F-1]. )

                  OVER InsertNode

            LOOP                                ( s r i)
            DUP textsize +!

            \ textsize @  printcount @ > IF

            \     ( Report progress each time the textsize exceeds
            \     ( multiples of 1024. )
            \     textsize @ 12 .R
            \     1024 printcount +!

            \ THEN

            ( After the end of text, no need to read, but
            ( buffer may not be empty. )

            last-match-length @ SWAP ?DO        ( s r)

                  OVER DeleteNode

                  >R  1 +  N 1 - AND  R>
                  1 +  N 1 - AND

                  -1 len +!    len @ IF
                        DUP InsertNode
                  THEN
            LOOP

            len @ 0> not
      UNTIL                                     2DROP

      ( Send remaining code. )

      code-buf-ptr @ 1 > IF
            0 code-buf  code-buf-ptr @  outfile  LZ77-WRITE-FILE checked
            code-buf-ptr @ codesize +!
      THEN
;

: code77        \ --
  init-test-buffer
  encode
  free-test-buffer
;

: $CODE77$
  .ann ." LZ77 Comp. (" /lz77-size . ." kb Random Data Mem>Mem)"
  [$  code77  1 $] ;


\ *********************************************
\ DHRYSTONE integer benchmark by Marcel Hendrix
\ *********************************************

0 [IF]

"DHRYSTONE" Benchmark Program

Version: Forth/1
Date:    05/03/86
Author:  Reinhold P. Weicker, CACM Vol 27, No 10, 10/84 pg. 1013

        C version translated from ADA by Rick Richardson.
        Every method to preserve ADA-likeness has been used,
        at the expense of C-ness.
        Modula-2 version translated from C by Kevin Northover.
        Again every attempt made to avoid distortions of the original.
        Forth version translated from Modula-2 by Marcel Hendrix.
        Distorting the original was inevitable, given the differences
        between a strongly typed and a user-extensible language.
        Moreover, there is serious doubt of the instruction mix being
        appropriate for Forth.

        The following program contains statements of a high-level
        programming language (Forth) in a distribution considered 
        representative:

        statements                      53%
        control statements              32%
        procedures, function calls      15%

        100 statements are dynamically executed. The program is balanced
        with respect to the three aspects:

                - statement type
                - operand type (for simple data types)
                - operand access
                    operand global, local parameter, or constant.

        The combination of these three aspects is balanced only
        approximately.

        The program does not compute anything meaningful, but it is
        syntactically and semantically correct.

        The source code was "pre-optimized" on a word-to-word basis with
        the programmer acting as a pre-processor to the compiler.

        Real Forth programmers would rather be found dead than 
        write disgusting programs like this.

        If you understand what both DHRYSTON.C and DHRYSTON.FRT are doing, 
        you'll never trust a benchmark again.

[THEN]

ANSSYSTEM [IF]
DECIMAL

\ -- Control human fatigue factor
500000 VALUE LOOPS     

\ -- Some types
1 CONSTANT Ident1       
2 CONSTANT Ident2       
3 CONSTANT Ident3       
4 CONSTANT Ident4       
5 CONSTANT Ident5       
0 CONSTANT NIL          

SPF4 ForthSystem = [IF] CASE-INS OFF [THEN]
CHAR A CONSTANT 'A'
CHAR B CONSTANT 'B'
CHAR C CONSTANT 'C'

CHAR W CONSTANT 'W'
CHAR X CONSTANT 'X'
CHAR Z CONSTANT 'Z'
SPF4 ForthSystem = [IF] CASE-INS ON [THEN]

CREATE  Array1Glob      50        CELLS ALLOT   
CREATE  Array2Glob      50 DUP *  CELLS ALLOT   

0 VALUE /bytes  
ALIGN-CACHE

\ -- Some obvious macro's
: []Array1Par    S" CELLS Array1Par + "        EVALUATE ; IMMEDIATE 
: [][]Array2Par  S" 50 * + CELLS Array2Par + " EVALUATE ; IMMEDIATE 
: ADDRESS ; IMMEDIATE 

: RECORD        CREATE  0 TO /bytes  HERE 0 ,   \ ( -- sys )
                DOES>   @ ALLOCATE THROW  ;     \ ( -- addr )

: END           /bytes SWAP ! ;                 \ ( sys -- )

: SIMPLE-TYPE   CREATE  ,                       \ ( fieldlength> -- )
                DOES>   @ 
                  CREATE IMMEDIATE
                        /bytes ,
                        /bytes + TO /bytes
                  DOES> @                       \ ( 'record -- 'offset )
                        S" LITERAL + " EVALUATE ; 

 1  CELLS SIMPLE-TYPE   RecordPtr       
 1  CELLS SIMPLE-TYPE   Enumeration             \ one of Ident1 .. Ident5
 1  CELLS SIMPLE-TYPE   OneToFifty      
31  CHARS SIMPLE-TYPE   String30                \ extra count byte

RECORD RecordType                               \ offset
                RecordPtr    PtrComp            \ 0
                Enumeration  Discr              \ 1 CELLS
                Enumeration  EnumComp           \ 2 CELLS
                OneToFifty   IntComp            \ 3 CELLS
                String30     StringComp         \ 4 CELLS
END 

\ -- Some global variables
0 VALUE IntGlob         
0 VALUE BoolGlob        
0 VALUE Char1Glob       
0 VALUE Char2Glob       
0 VALUE p^      

NIL VALUE PtrGlb        
NIL VALUE PtrGlbNext    
ALIGN-CACHE

: Proc7         S" + 2 + " EVALUATE ; IMMEDIATE \ ( n1 n2 -- n3 )

: Proc3         PtrGlb IF PtrGlb PtrComp @      \ ( 'record -- )
                          SWAP !
                     ELSE DROP 100 TO IntGlob
                     THEN
                10 IntGlob  Proc7   PtrGlb IntComp ! ; 

: Func3         S" Ident3 = " EVALUATE ; IMMEDIATE 

: Proc6 ( n1 n2 -- n )
                OVER LOCALS| n n2 n1 |
                n1 Func3 0= IF Ident4 TO n THEN
                CASE n1
                    Ident1 OF Ident1            ENDOF
                    Ident2 OF IntGlob
                               100 > IF Ident1
                                   ELSE Ident4 
                                   THEN         ENDOF
                    Ident3 OF Ident2            ENDOF
                    Ident4 OF n                 ENDOF
                    Ident5 OF Ident3            ENDOF
                    ABORT" Proc6: argument out of range"
                ENDCASE ; 

: Proc1 ( 'record -- )
                TO p^                           
                PtrGlb  p^ PtrComp !
                5       p^ IntComp !
                p^ IntComp @   p^ PtrComp @ IntComp !
                p^ PtrComp @   p^ PtrComp @ PtrComp @  !
                p^ PtrComp @ PtrComp @ Proc3
                p^ PtrComp @ Discr   @ Ident1
                = IF  6  p^ PtrComp @ IntComp  !
                      p^ PtrComp @ EnumComp  p^ EnumComp @  OVER @ Proc6 SWAP !
                      PtrGlb PtrComp  p^ PtrComp @ PtrComp !
                      p^ PtrComp @ IntComp DUP @  10  Proc7 SWAP !
                ELSE  p^ PtrComp @ p^ !
                THEN ; 

: Proc2 ( val -- val' )
                DUP 10 + LOCALS| IntLoc |
                BEGIN   Char1Glob 'A' =         \ This one never ends
                WHILE   IntLoc 1- TO IntLoc     \ unless Char = 'A' ??
                        DROP IntLoc IntGlob - 
                        TRUE
                UNTIL   THEN ; 

: Proc4         S" 'B' TO Char2Glob "                    EVALUATE ; IMMEDIATE 
: Proc5         S" 'A' TO Char1Glob  FALSE TO BoolGlob " EVALUATE ; IMMEDIATE 

: Proc8 ( 'array1 'array2 n1 n2 -- )
                SWAP 5 + LOCALS| IntLoc IntParI2 Array2Par Array1Par |
                IntLoc []Array1Par IntParI2 OVER !
                ( addr) @  IntLoc 1+ []Array1Par !
                IntLoc   DUP    30 + []Array1Par !
                IntLoc DUP DUP    [][]Array2Par  !
                IntLoc DUP DUP 1+ [][]Array2Par  !

                1  IntLoc DUP 1-  [][]Array2Par +!
                IntLoc []Array1Par @
                  IntLoc DUP 20 + SWAP [][]Array2Par !
                5 TO IntGlob ;

: Func1 ( char1 char2 -- n )
                S" = IF Ident2 ELSE Ident1 THEN " EVALUATE ; IMMEDIATE

: Func2 ( '$1 '$2 -- bool )
                2 BL LOCALS| CharLoc IntLoc '$2 '$1 |

                BEGIN  IntLoc 2 <=
                WHILE  IntLoc 1+  '$1 + C@
                       IntLoc 2 + '$2 + C@  Func1
                        Ident1 = IF 'A' TO CharLoc
                                     IntLoc 1+ TO IntLoc
                               THEN
                REPEAT

                CharLoc 'W' >=
                  IF  CharLoc 'Z' <=
                         IF 7 TO IntLoc THEN    \ dead code, IntLoc never used!
                THEN

                CharLoc 'X' = IF  TRUE EXIT  THEN

                '$1 COUNT '$2 COUNT COMPARE
                0>
                  IF  7 IntLoc + TO IntLoc TRUE \ dead code, IntLoc is local
                ELSE  FALSE
                THEN ;

: Proc0         31 ALLOCATE THROW
                31 ALLOCATE THROW
                0 0 0
                0 0 0
          \ The following must be on ONE line or Win32Forth will crash.
                LOCALS| CharIndex CharLoc EnumLoc IntLoc3 IntLoc2 IntLoc1 String2Loc String1Loc |
                RecordType TO PtrGlb            \ constructor, allocates !
                RecordType TO PtrGlbNext
                PtrGlbNext  PtrGlb PtrComp  !
                Ident1      PtrGlb Discr    !
                Ident3      PtrGlb EnumComp !
                40          PtrGlb IntComp  !
                C" DHRYSTONE PROGRAM, SOME STRING" 
                DUP C@ 1+  PtrGlb StringComp  SWAP MOVE
   LOOPS 0 DO   
                Proc5  
                Proc4
                2 TO IntLoc1  3 TO IntLoc2
                C" DHRYSTONE PROGRAM, 2'ND STRING" 
                DUP C@ 1+ String2Loc SWAP MOVE
                Ident2 TO EnumLoc
                String1Loc String2Loc  Func2 INVERT  TO BoolGlob  

                BEGIN  
                   IntLoc1 IntLoc2 <
                WHILE  
                   IntLoc1 5 * IntLoc2 - TO IntLoc3
                   IntLoc1 IntLoc2 Proc7 TO IntLoc3     \ The Forth way
                   IntLoc1 1+ TO IntLoc1
                REPEAT

                ADDRESS Array1Glob ADDRESS Array2Glob IntLoc1 IntLoc2  
    Proc8
                PtrGlb Proc1
                'A' TO CharIndex

                BEGIN  
                  CharIndex Char2Glob <=
                WHILE  
                  CharIndex 'C' Func1
                  EnumLoc = IF  Ident1 EnumLoc Proc6 TO EnumLoc
                          THEN
                  CharIndex 1+ TO CharIndex     
                REPEAT

                IntLoc1 IntLoc2 * TO IntLoc3
                IntLoc3 IntLoc1 / TO IntLoc2
                IntLoc3 IntLoc2 - 7 * IntLoc1 - TO IntLoc2
                IntLoc1 Proc2 TO IntLoc1                \ the Forth way
         LOOP   
                PtrGlb     FREE THROW
                PtrGlbNext FREE THROW
                String1Loc FREE THROW
                String2Loc FREE THROW ; 

: $DHRY$        \ --
  .ann ." Dhrystone (integer)"
  [$  proc0  loops $]
  extra-pos >pos  LOOPS 1000 ms-elapsed @ */ . ." Dhrystones/sec"
;
[THEN]


\ *********************************
\ API Call OverHead
\ *********************************

HWND_DESKTOP VALUE hWnd

500000 constant /api1

: (api1)        \ -- ; SENDMESSAGE is probably the most used API function there is!
  hWnd WM_CLOSE 0 0 SendMessage drop
;

: $API1$        \ --
  .ann ." Win32 API: SendMessage"
  [$  /api1 0 do  (api1)  loop  /api1 $]
;

2000000 constant /api2

: $API2$        \ --
  .ann ." Win32 API: GetTickCount"
  [$  /api2 0 do  counter drop  loop  /api2 $]
;

80000 constant /api3

: $API3$        \ --
  .ann ." System I/O: KEY?"
  [$  /api3 0 do  key? drop  loop  /api3 $]
;


\ *************************
\ The main benchmark driver
\ *************************

: BENCHMARK
   .ann ." This system's primitives" .specifics cr
   .header
   [$  
     $DO$
     $+$  $M+$
     $*$  $/$  $M*$  $M/$  $/MOD$  $*/$
     $FILL$
   CR  ." Total:"  1 $]

   cr cr
   .ann ." This system's O/S interface" .specifics cr
   .header
   [$
[ BigForth ForthSystem = ] [IF]
cr ." BigForth cannot run the SENDMESSAGE test"
     $API2$
cr ." BigForth cannot run the KEY? test"
[ELSE]
     $API1$
     $API2$
     $API3$
[THEN]
   CR  ." Total:"  1 $]

   cr cr
   .ann ." This system's application performance" .specifics CR
   .header
   [$  
     $SIEVE$  $FIB$  $SORT$  $RAND$  $CODE77$
   [ ANSSYSTEM ] [IF]  $DHRY$  [THEN]
   CR  ." Total:"  1 $]
;


decimal
cr cr .( Benchmark code size = ) here start-here - . .( bytes.) cr

BENCHMARK

CR CR .( To run the benchmark program again, type BENCHMARK )

