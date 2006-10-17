
: S>UNICODE { a u \ buf -- addr2 u2 }
  u 2* CELL+ DUP ALLOCATE THROW TO buf
  u IF
      buf u a 0 ( flags) 0 ( CP_ACP)
      MultiByteToWideChar DUP ERR THROW
  ELSE DROP 0 THEN
  buf
  SWAP 2* 
  2DUP + 0 SWAP W!
\  2DUP DUMP CR
;

: AZ>UNICODE DUP IF ASCIIZ> S>UNICODE DROP THEN ;

: UASCIIZ> ( addr -- addr u ) \ вариант ASCIIZ> для Unicode
  0 OVER
  BEGIN
    DUP W@ 0<>
  WHILE
    2+ SWAP 1+ SWAP
  REPEAT DROP
;

: UNICODE>S { wa u1 \ buf -- a u2 }
    u1 1+ ALLOCATE THROW TO buf
    0 0 u1 1+ buf u1 1+ wa 0 CP_ACP WideCharToMultiByte 
    DUP ERR THROW
    buf SWAP ?DUP IF 1- THEN ;
