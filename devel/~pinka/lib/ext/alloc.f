\ 06.Apr.2004  перенес код из hash-table.f

: SALLOC ( a u -- a1 )
  DUP ALLOCATE THROW DUP >R SWAP CMOVE R>
;                  
: CALLOC ( a u -- a1 )
  TUCK DUP 2+ ALLOCATE THROW DUP >R 1+ SWAP CMOVE R@ C! R> 
;
: ZALLOC ( az -- a1 )
  ASCIIZ> 1+ SALLOC
;
