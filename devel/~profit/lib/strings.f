: lastChar ( addr len --> addr len-1 lastCh ) 1- 2DUP + C@ ;
: firstChar ( addr len --> addr len firstCh ) OVER C@ ;
: restOfString ( addr len --> addr+1 len-1 ) SWAP 1+ SWAP 1- ;