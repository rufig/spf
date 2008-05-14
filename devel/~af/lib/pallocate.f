\ Andrey Filatkin, af@forth.org.ru
\ Work in spf3, spf4
\ Выделение динамической памяти, доступной во всех потоках

VOCABULARY PAllocSupport
GET-CURRENT ALSO PAllocSupport DEFINITIONS

: ALLOCATE ( u -- a-addr ior )
  CELL+ 9 ( HEAP_ZERO_MEMORY) GetProcessHeap HeapAlloc
  DUP IF R@ OVER ! CELL+ 0 ELSE -300 THEN
;
: FREE ( a-addr -- ior )
  CELL- 0 GetProcessHeap HeapFree ERR
;

: RESIZE ( a-addr1 u -- a-addr2 ior )
  CELL+ SWAP CELL- 9 ( HEAP_ZERO_MEMORY) GetProcessHeap HeapReAlloc
  DUP IF CELL+ 0 ELSE -300 THEN
;

SET-CURRENT PREVIOUS
