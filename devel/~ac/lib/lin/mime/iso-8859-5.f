: iso-8859-5>UNICODE ( addr u -- addr2 u2 )
\ специально для чтения писем ~yz :)
  DUP 2* CELL+ ALLOCATE DROP UnicodeBuf !
  SWAP >R
  DUP 2* CELL+ UnicodeBuf @ ROT R> 0 ( flags) 28595 ( iso-8859-5)
  MultiByteToWideChar
  UnicodeBuf @ 
  SWAP 2* 
  2DUP + 0 SWAP W!
;
