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
