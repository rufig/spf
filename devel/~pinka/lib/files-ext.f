\ move frome fix-refill.f

: READOUT-FILE ( a u1 h -- a u2 ior )
  >R OVER SWAP R> READ-FILE ( a u2 ior )
  DUP 109 = IF 2DROP 0. THEN
;
