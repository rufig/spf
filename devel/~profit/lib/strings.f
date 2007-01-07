: lastChar ( addr len --> addr len-1 lastCh ) 1 CHARS - 0 MAX 2DUP + C@ ;
: firstChar ( addr len --> addr len firstCh ) OVER C@ ;
: restOfString ( addr len --> addr+1 len-1 ) DUP 0 > IF SWAP 1 CHARS + SWAP 1 CHARS - THEN ;