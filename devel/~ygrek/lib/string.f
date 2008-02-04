
\ Append a char to the end of the string
: CHAR-APPEND ( a1 u1 c -- ) -ROT CHARS + C! ;

\ append a string to the buffer
: STR-APPEND ( a1 u1 a2 u2 -- ) 2SWAP CHARS + SWAP CMOVE> ;

\ get string bounds
: BOUNDS ( addr u -- addr-end addr ) CHARS OVER + SWAP ;

\ make asciiz string
: >ASCIIZ ( addr u -- z ) CHARS OVER + 0 SWAP C! ;