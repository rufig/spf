: STR>MEM ( addr u -- addr1 )
  2DUP DUP 2+ ALLOCATE THROW DUP >R
  1+ SWAP MOVE
  DUP R@ + 1+ 0 SWAP C!
  R@ C!
  DROP R>
;
