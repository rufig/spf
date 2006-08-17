: >MEM ( i*x i -- addr )
  CELLS DUP CELL+ ALLOCATE THROW \ i*x len addr
  DUP >R
  SP@ 2 CELLS + \ i*x len addr from
  SWAP CELL+ 2 PICK MOVE
  DUP R@ !
  SP@ CELL+ + SP!
  R>
;

: MEM@ ( addr -- i*x )
  DUP >R @
  SP@ SWAP - CELL+ SP! SP@ \ to
  R@ @ \ to len
  R> CELL+ \ to len from
  ROT ROT MOVE
;

: MEM> ( addr -- i*x )
  DUP >R
  MEM@
  R> FREE THROW
;

: MEMDROP ( addr -- )
  FREE THROW
;