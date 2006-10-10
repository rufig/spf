: _ZLITERAL-CODE R> COUNT OVER + 1+ >R ;

: ZLITERAL ( a u -- )
  STATE @ IF
             ['] _ZLITERAL-CODE COMPILE,
             DUP C,
             HERE SWAP DUP ALLOT MOVE 0 C,
          ELSE
             OVER + 0 SWAP C!
          THEN
; IMMEDIATE

: Z" [CHAR] " PARSE [COMPILE] ZLITERAL ; IMMEDIATE

: ZPLACE ( a u buf -- )   SWAP 2DUP + 0 SWAP C! CMOVE ;    

: +ZPLACE ( a u buf -- )  ASCIIZ> + ZPLACE ;    

: S>ZALLOC ( a u -- a1)
     DUP 1+ ALLOCATE THROW >R
     R@ ZPLACE
     R>
;

\ You must free memory after this operation
: S>SZ ( a u -- a1 u)  S>ZALLOC ASCIIZ> ;

: S+ ( a1 u1 a2 u2 -- a3 u3)
    2OVER NIP OVER + 1+ ALLOCATE THROW >R
    2SWAP R@ ZPLACE
    R@ +ZPLACE R> ASCIIZ>    
;

: @AZ @ ASCIIZ> ;

: SZ", ( a u -- ) HERE SWAP DUP ALLOT CMOVE 0 C, ;