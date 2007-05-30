: ZP@ ( — a )
  ZP @
;
: ZP! ( a — )
  ZP !
;
: Z@ ( — x )
  ZP @ @
;
: 2Z@ ( — x x )
  ZP @ CELL+ @
  ZP @ @
;
: >Z ( x — )
  ZP CELL-!  ZP@ !
;
: Z> ( — x )
  ZP@ @   ZP CELL+!
;
: 2>Z ( x x — )
  -2 CELLS ZP +!  ZP@ 2!
;
: 2Z> ( — x x )
  ZP@ 2@   2 CELLS ZP +!
;
: ZDROP ( — )
  CELL ZP +!
;
