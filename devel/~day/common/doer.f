: DOER VECT
;

0 VALUE MARKER

: (MAKE)
   R> DUP @ ?DUP IF >R THEN
   DUP CELL+ @
   SWAP 8 + SWAP ! 
;

\ (make) 0 a-body

: MAKE
  [COMPILE] ' >BODY
  STATE @
  IF
     POSTPONE (MAKE)
     HERE TO MARKER
     0 , ,
  ELSE
     :NONAME SWAP !
  THEN
; IMMEDIATE

: ;AND
    RET,
    HERE MARKER !
; IMMEDIATE


