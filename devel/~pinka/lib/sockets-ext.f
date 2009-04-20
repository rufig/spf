REQUIRE ReadSocket ~ac/lib/win/winsock/SOCKETS.F

: READOUT-SOCK ( a u1 h -- a u2 ior ) \ on likeness READOUT-FILE
  >R OVER SWAP R>   ( a a h1 h )
  ReadSocket        ( a u2 ior )
  DUP -1002 = IF 2DROP 0. THEN
;
: ReadoutSocket ( a u1 h -- a u2 ior ) \ on likeness ReadSocket
  READOUT-SOCK
;

: ReadSocketExact ( a u socket -- ior )
  >R BEGIN DUP WHILE
    2DUP R@ ReadSocket ?DUP IF NIP NIP NIP RDROP EXIT THEN ( a1 u1 u2 )
    TUCK - -ROT + SWAP
  REPEAT ( a1 0 )
  NIP RDROP
;
