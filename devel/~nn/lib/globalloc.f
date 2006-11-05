
USER HEAP-SAVE

: GLOBAL
    THREAD-HEAP @ HEAP-SAVE !
    GetProcessHeap THREAD-HEAP !
;

: LOCAL   HEAP-SAVE @ THREAD-HEAP ! ;


\ : GLOBAL-ALLOCATE ( u -- a-addr ior)
\    GetProcessHeap HeapAlloc DUP ERR ;    

\ : GLOBAL-FREE ( addr - ior)
\    GetProcessHeap HeapFree ERR ;