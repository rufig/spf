\ 01.Nov.2003 Sat 15:07 ruv   \ определение HASH
\ портированно из  ~pinka\hash\search-wordlist.f ( originally 16.11.2000)

32 CONSTANT CELL-BITS@
CELL-BITS@ 1- CONSTANT CELL-BITS@'

: HASH ( a u u1 -- u2 )
 0 2SWAP ( u1 0  a u )
 OVER + SWAP DO
   33 *  I C@ +
   DUP IF DUP CELL-BITS@' RSHIFT XOR THEN
 LOOP
 SWAP ?DUP IF UMOD THEN
;
