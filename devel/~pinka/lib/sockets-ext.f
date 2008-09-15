REQUIRE ReadSocket ~ac/lib/win/winsock/SOCKETS.F

: READOUT-SOCK ( a u1 h -- a u2 ior ) \ on likeness READOUT-FILE
  >R OVER SWAP R>   ( a a h1 h )
  ReadSocket        ( a u2 ior )
  DUP -1002 = IF 2DROP 0. THEN
;
: ReadoutSocket ( a u1 h -- a u2 ior ) \ on likeness ReadSocket
  READOUT-SOCK
;
