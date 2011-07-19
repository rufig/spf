\ 2011

REQUIRE ControlStackSupport ~pinka/spf/compiler/control-stack.f

ALSO ControlStackSupport

: CS-PICK ( CS: y i*x DS: i -- CS: y i*x y )
  CELLS ZP @ + @ >CS
;

: CS-ROLL ( CS: y i*x DS: i -- CS: i*x y )
  DUP 0 = IF DROP EXIT THEN
  DUP 1 = IF DROP ZP @ DUP >R 2@ SWAP R> 2! EXIT THEN
  CELLS DUP ZP @ + @ >R
  ZP @ DUP CELL+ ROT MOVE
  R> ZP @ !
;
\ see also: devel/~pinka/model/forthproc/hl/ds.L3.f.xml

\ 10 11 12 13 14 15
\       x  y  z

PREVIOUS
