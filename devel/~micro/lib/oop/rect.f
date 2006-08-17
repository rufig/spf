REQUIRE CLASS: ~micro/lib/oop/oop23.f
REQUIRE { ~ac/lib/locals.f

CLASS: RECT
CELL -- left
CELL -- top
CELL -- right
CELL -- bottom

: PUT ( l t r b inst -- )
  >R
  R@ bottom !
  R@ right !
  R@ top !
  R@ left !
  RDROP
;

: GET ( inst -- l t r b )
  >R
  R@ left @
  R@ top @
  R@ right @
  R@ bottom @
  RDROP
;

: INSIDE { r1 r2 -- [r1 inside r2] }
  r1 left @ r2 left @ >
  r1 top @ r2 top @ > AND
  r1 right @ r2 right @ < AND
  r1 bottom @ r2 bottom @ < AND
;

: Show
  2SWAP
  SWAP ." (" . ." ;" . ." ;"
  SWAP . ." ;" . ." )"
;
;CLASS
