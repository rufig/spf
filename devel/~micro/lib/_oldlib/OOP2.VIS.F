\ ==================  Описание объекта  ==================

: OBJECT
  ' >BODY
  CREATE
  DUP @ , CELL+ @ ALLOT
  DOES>
  DUP CELL+ SWAP @
  INTERPRET-METHOD
;

\ ======================  Debug  =========================

: SHOWCLASS
  >IN @
  WIDOF NLIST
  >IN !
  SIZEOF ." Size=" .
;
