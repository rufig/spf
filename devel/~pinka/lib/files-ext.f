\ move frome fix-refill.f

: READOUT-FILE ( a u1 h -- a u2 ior )
  >R OVER SWAP R> READ-FILE ( a u2 ior )
  DUP 109 = IF 2DROP 0. THEN
;

: READ-FILE-EXACT ( addr u h -- ior )
  >R BEGIN DUP WHILE
    2DUP R@ READ-FILE ?DUP IF NIP NIP NIP RDROP EXIT THEN ( a1 u1 u2 )
    DUP 0= IF DROP 2DROP RDROP -1002 EXIT THEN \ 109 is not throwable in spf4
    TUCK - -ROT + SWAP
  REPEAT ( a1 0 )
  NIP RDROP
;

: READOUT-FILE-CONTENT ( a-buf u-buf h -- a-buf u-data ior )
  DUP >R FILE-SIZE DUP IF RDROP EXIT THEN DROP
  ( d-buf lo hi )
  IF 2DROP -1 -1005 RDROP EXIT THEN
  ( a-buf u-buf u-data )
  TUCK U<  IF -1005 RDROP EXIT THEN
  ( a-buf u-data )
  2DUP R> READ-FILE-EXACT
;

: FILE-CONTENT ( h-file -- addr u ior )
  \ addr shoud be freed via FREE
  >R 
  R@ FILE-SIZE DUP IF RDROP EXIT THEN DROP
  ( d-size )  IF 0 -1 RDROP EXIT THEN \ too big
  DUP ALLOCATE DUP IF RDROP EXIT THEN DROP SWAP ( addr u )
  2DUP R@ READ-FILE-EXACT DUP IF
    ( addr u ior )
    2 PICK FREE DROP RDROP EXIT
  THEN ( addr u 0 )
  RDROP
;
: FILENAME-CONTENT ( d-txt-filename -- addr u )
  R/O OPEN-FILE-SHARED THROW >R
  R@ FILE-CONTENT
  R> CLOSE-FILE SWAP THROW THROW
;
: FOR-FILENAME-CONTENT ( d-txt-filename xt -- ) \ xt ( addr u -- )
  >R FILENAME-CONTENT OVER R> SWAP >R CATCH R> FREE SWAP THROW THROW
;
\ m.b. WITH-FILENAME-CONTENT ( xt d-txt-filename -- ) \ xt ( addr u -- )
