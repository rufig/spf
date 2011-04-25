REQUIRE ENUM-HEAPS ~pinka/lib/win/enum-heaps.f

: TEST-HEAPENTRY-USERAREA ( entry heap -- entry heap flag )
  OVER wFlags W@ PROCESS_HEAP_ENTRY_BUSY AND 0= IF FALSE EXIT THEN
  OVER cbData @  USER-OFFS @ DUP 2/ SWAP EXTRA-MEM @ 2* + WITHIN 0= IF FALSE EXIT THEN
  OVER lpData @ @ ( entry x )
  DUP ['] USER-INIT     5 + <> IF
  DUP ['] PROCESS-INIT 10 + <> IF
    DROP FALSE EXIT
  THEN THEN DROP
  2DUP SWAP lpData @ CELL+ ( ... heap user-area-base ) \ spf4 specifics
  ['] THREAD-HEAP BEHAVIOR ( ... offset ) \ win-version specific
  + @ <> IF FALSE EXIT THEN \ test that  thread-heap @  heap =
  TRUE
;
: (IS-HEAP-FORTH) ( entry heap -- entry heap flag )
  \ using heuristics
  2DUP HeapWalk 0= IF FALSE EXIT THEN TEST-HEAPENTRY-USERAREA IF TRUE EXIT THEN
  2DUP HeapWalk 0= IF FALSE EXIT THEN TEST-HEAPENTRY-USERAREA IF TRUE EXIT THEN
  FALSE
;
: HEAP-USERAREA ( heap -- userarea|0 )
  /PROCESS_HEAP_ENTRY >CELLS 1+ DUP RALLOT SWAP >R
  DUP lpData 0!
  SWAP ( entry heap )
  (IS-HEAP-FORTH) NIP IF lpData @ CELL+ ELSE DROP 0 THEN
  R> RFREE
;
: IS-HEAP-FORTH ( heap -- flag )
  \ heuristics
  HEAP-USERAREA
;
: (ENUM-HEAPS-FORTH) ( xt heap -- xt ) \ xt ( heap -- )
  DUP IS-HEAP-FORTH 0= IF DROP EXIT THEN
  SWAP DUP >R EXECUTE R>
;
: ENUM-HEAPS-FORTH ( xt -- ) \ xt ( heap -- )
  \ only forth heaps
  ['] (ENUM-HEAPS-FORTH) ENUM-HEAPS  ( xt ) DROP
;
: (ENUM-HEAPS-OTHER) ( xt heap -- xt ) \ xt ( heap -- )
  DUP IS-HEAP-FORTH IF DROP EXIT THEN
  SWAP DUP >R EXECUTE R>
;
: ENUM-HEAPS-OTHER ( xt -- ) \ xt ( heap -- )
  \ only other heaps
  ['] (ENUM-HEAPS-OTHER) ENUM-HEAPS  ( xt ) DROP
;


\EOF

: (FOR-HEAP-FORTH) ( xt addr1 u1 -- xt ) \ xt ( addr u -- )
  SWAP CELL+ SWAP CELL-
  ROT DUP >R EXECUTE R>
;
: FOR-HEAP-FORTH ( heap xt -- ) \ xt ( addr u -- )
  \ only for allocated blocks
  SWAP ['] (FOR-HEAP-FORTH) FOR-HEAP DROP
;


\EOF


: t1 ( addr u -- ) SWAP . . CR ; 
: T1 ( heap -- ) ['] t1 FOR-HEAP-FORTH CR ; 

  ' T1 ENUM-HEAPS-FORTH

: t2 ( entry -- )
  >R
    R@ lpData @ .
    R@ cbData @ .
    R@ cbOverhead B@ .
    R@ iRegionIndex B@ .
    R@ wFlags W@ HEX . DECIMAL
  RDROP
  CR
;
: T2 DUP . CR ['] t2 FOR-HEAP-ENTRY CR ;

  ' T2 ENUM-HEAPS-FORTH
