HEX
 : dmk ( -- )
   F 7 B 3 D 5 9 1 E 6 A 2 C 4 8 0
   10 ALLOCATE THROW
   10 0 DO DUP I +  ROT SWAP C! LOOP ;
   dmk VALUE ddmk

 : revarr_ ( c -- c' )
   0 SWAP 8 BEGIN >R DUP F AND ddmk + C@ R@ 1- 4 * LSHIFT ROT + SWAP 4 RSHIFT R> 1- DUP 0= UNTIL 2DROP ;

 : revarr ( adr u -- )
   BEGIN >R DUP R@ 1- CELLS + DUP @ revarr_ SWAP ! R> 1- DUP 0= UNTIL 2DROP ;
DECIMAL