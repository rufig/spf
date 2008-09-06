REQUIRE ReadSocket ~ac/lib/win/winsock/SOCKETS.F

: READ-SOCK-EXACT ( a u socket -- ior )
  >R BEGIN DUP WHILE
    2DUP R@ ReadSocket ?DUP IF NIP NIP NIP RDROP EXIT THEN ( a1 u1 u2 )
    TUCK - -ROT + SWAP
  REPEAT ( a1 0 )
  NIP RDROP
;
: ReadSocketExact ( a u socket -- ior )
  READ-SOCK-EXACT
;
