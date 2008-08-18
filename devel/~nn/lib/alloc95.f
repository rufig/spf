\ Попытка преодоления глюка выделения памяти Win 9x
REQUIRE WinNT? ~nn/lib/winver.f

USER 9xLIST

: 9x? WinNT? 0= ;

: ALLOCATE9x ( n -- a ior )
    9x? 
    IF 
        2 CELLS MAX 3 + 0xFFFFFFFC AND ( ." <" DUP .) >R
        9xLIST 
        BEGIN DUP @ ?DUP WHILE
          CELL+ @ R@ =
          IF ( a )
            DUP @ DUP @ ROT !
            0 RDROP EXIT 
          THEN
          @
        REPEAT
        DROP R> ALLOCATE
    ELSE
        ALLOCATE
    THEN
;

: FREE9x ( a -- ior)
    9x? 
    IF 
        DUP CELL- 0 THREAD-HEAP @ HeapSize  ( a size -- )
        CELL - ( ." >" DUP .) OVER CELL+ !
        9xLIST @ OVER !
        9xLIST !
        0
    ELSE
        FREE
    THEN
;

: FREE9xALL
    9xLIST @
    BEGIN ?DUP WHILE
        DUP @ SWAP FREE DROP
    REPEAT
;
