
\ Append a char to the end of the string
: CHAR-APPEND ( a1 u1 c -- ) -ROT + C! ;

\ append a string to the buffer
: STR-APPEND ( a1 u1 a2 u2 -- ) 2SWAP + SWAP CMOVE> ;

\ get string bounds
: BOUNDS ( addr u -- addr+u addr ) OVER + SWAP ;

\ make asciiz string
: >ASCIIZ ( addr u -- z ) OVER + 0 SWAP C! ;