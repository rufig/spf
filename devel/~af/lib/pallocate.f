\ Выделение динамической памяти, доступной во всех потоках ~af

: ALLOCATE-PROCESS ( u -- a-addr ior )
  CELL+ 9 ( HEAP_ZERO_MEMORY) GetProcessHeap HeapAlloc
  DUP IF R@ OVER ! CELL+ 0 ELSE -300 THEN
;
: FREE-PROCESS ( a-addr -- ior )
  CELL- 0 GetProcessHeap HeapFree ERR
;
