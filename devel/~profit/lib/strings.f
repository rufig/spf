: lastChar ( addr u -- addr u-1 lastCh ) 1 CHARS - 0 MAX  2DUP + C@ ;
: firstChar ( addr u -- addr u firstCh ) OVER C@ ;
: restOfString ( addr u -- addr+1 u-1 ) DUP 0 > IF SWAP 1 CHARS +  SWAP 1 CHARS - THEN ;