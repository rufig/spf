( Report all memory leaks, just use MemReport word )
( Use it for debug purposes, mind - it slowdowns the program! )
( [c] Dmitry Yakimov ftech@tula.net )

REQUIRE list: staticlist.f

/node
CELL -- .fileNameA
CELL -- .fileNameU
CELL -- .curstr
CELL -- .addr
CELL -- .size
CONSTANT /allocList

/allocList list: AllocList

: DebugAlloc ( n line addr u -- addr ior )
    AllocList AllocateNode >R
    R@ .fileNameU !
    R@ .fileNameA !
    R@ .curstr !
    DUP R@ .size !
    ALLOCATE 
    OVER R@ .addr !
    DUP
    IF
       R@ FreeNode
    THEN R> DROP

;

: ALLOCATE ( n -- addr ior )
    STATE @ 
    IF   
       CURSTR @ POSTPONE LITERAL
       CURFILE @ ASCIIZ> POSTPONE SLITERAL
       POSTPONE DebugAlloc
    ELSE CURSTR @ CURFILE @ 
         DUP 0= IF DROP PAD 0 
                ELSE ASCIIZ> 
                THEN DebugAlloc
    THEN
; IMMEDIATE

USER vAddr

: (FindMem) ( node -- f )
     .addr @ vAddr @ = 0=
;

: FindMem ( addr -- node | 0 )
    vAddr ! 
    AllocList ?ForEach: (FindMem)
;

: FREE ( addr -- ior )
    DUP FindMem ?DUP IF FreeNode THEN
    FREE
;

: ClearMemInfo
    AllocList FreeList
;

: (printNode) ( node -- )
    >R
    R@ .fileNameA @
    R@ .fileNameU @ TUCK TYPE
    BL EMIT
    
    30 SWAP - 0 MAX SPACES
    
    R@ .curstr @ U. 9 SPACES
    BASE @ HEX
      ." 0x" R@ .addr @ U. 9 SPACES
    BASE !
   
    R@ .size @  U.
    
    R> DROP CR
;

: MemReport
    CR ." Memory report:" CR
    ." File                          Line         Address           Size" CR
    79 0 DO [CHAR] = EMIT LOOP CR
    
    AllocList ForEach: (printNode)
    CR 79 0 DO [CHAR] = EMIT LOOP CR    
;

\EOF

: test 100 ALLOCATE THROW ;

test

~ac\lib\str4.f

" ad" DROP
MemReport