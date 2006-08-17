\ ==================  Описание объекта  ==================

: OBJECT
  ' >BODY
  CREATE IMMEDIATE
  DUP @ , CELL+ @ HERE OVER ALLOT
  SWAP ERASE
  DOES>
  ?PREVIOUS
  DUP CELL+ SWAP @
  ALSO-IT
  POSTPONE LITERAL
;

\ ======================  Debug  =========================

: SHOWCLASS
  >IN @
  ' >WIDOF @ NLIST
  >IN !
  POSTPONE SIZEOF ." Size=" .
;

: (RUN) ( addr u -- )
  SFIND IF
    EXECUTE
  ELSE
    ABORT" Unknown method!"
  THEN
  ?PREVIOUS
;

: RUN
  ?COMP
  NextWord
  POSTPONE SLITERAL
  POSTPONE (RUN)
  POSTPONE ?PREVIOUS
; IMMEDIATE

: CLASS ( size -- size1 )
  ' DUP >R ( size class )
  >SIZEOF @ OVER + SWAP ( size1 size )
  CREATE IMMEDIATE , 
  R> >WIDOF @ ,
  DOES>
  ?PREVIOUS
  DUP CELL+ @ ALSO-IT
  @
  STATE @ IF
    POSTPONE LITERAL
    POSTPONE +
  ELSE
    +
  THEN
;
