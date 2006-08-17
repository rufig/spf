\ ==================  Описание объекта  ==================

: OBJECT
  ' >BODY
  CREATE
  DUP @ , CELL+ @ ALLOT
  DOES>
  ?PREVIOUS
  DUP CELL+ SWAP @
  ALSO CONTEXT !
  1 ALSO-FOR-ONE !
;

\ ======================  Debug  =========================

: SHOWCLASS
  >IN @
  WIDOF NLIST
  >IN !
  SIZEOF ." Size=" .
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
; IMMEDIATE

: CLASS ( size -- size1 )
  ' DUP >R ( size class )
  >SIZEOF @ OVER + SWAP ( size1 size )
  CREATE IMMEDIATE , 
  R> >WIDOF @ ,
  DOES>
  ?PREVIOUS
  DUP @ ROT + SWAP CELL+ @
  ALSO CONTEXT !
  1 ALSO-FOR-ONE !
;
                  	