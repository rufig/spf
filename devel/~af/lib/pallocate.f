\ $Id$
\ Andrey Filatkin, af@forth.org.ru
\ Work in spf3, spf4
\ Выделение динамической памяти, доступной во всех потоках

: PALLOCATE ( u -- a-addr ior )
  CELL+ 9 ( HEAP_ZERO_MEMORY) GetProcessHeap HeapAlloc
  DUP IF R@ OVER ! CELL+ 0 ELSE -300 THEN
;
: PFREE ( a-addr -- ior )
  CELL- 0 GetProcessHeap HeapFree ERR
;
