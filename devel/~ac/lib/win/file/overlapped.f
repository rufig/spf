: READ-FILE ( c-addr u1 fileid -- u2 ior ) \ 94 FILE
  >R >R >R
  LP lpNumberOfBytesRead R> R> SWAP R>
  ReadFile ERR
  lpNumberOfBytesRead @ SWAP
;
