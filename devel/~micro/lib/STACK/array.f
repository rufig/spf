: NDUP ( i*x i -- i*x i*x )
  CELLS DUP >R SP@ CELL+ DUP >R
  SWAP - SP!
  R> SP@ CELL+ R> MOVE
;

: NDROP ( i*x i -- )
  CELLS SP@ CELL+ + SP!
;

: NNIP ( i*x j*x i j -- j*x )
  SWAP >R
  SP@ CELL+
  DUP R> CELLS +
  ROT CELLS
  OVER >R
  MOVE
  R> SP!
;
