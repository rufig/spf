( Report all memory leaks, just use MemReport word )
( Use it for debug purposes, mind - it slowdowns the program! )
( [c] Dmitry Yakimov ftech@tula.net )

( + понимает str4.f
  + выводит не только утечки но распечатку стека возвратов при их возникновении
  + многопоточна, может выводить отчеты для отдельных потоков, MemReportThread
)

REQUIRE CZGETMEM ~yz\lib\common.f
REQUIRE MALLOCATE ~yz\lib\gmem.f

: GALLOCATE MALLOCATE 0 ;
: GFREE MFREE ERR ;

: ALLOCATE-ORIG ALLOCATE ;
: ALLOCATE GALLOCATE ;
: FREE-ORIG FREE ;
: FREE GFREE ;

REQUIRE list: staticlist.f
\ REQUIRE REPLACE-WORD lib\ext\patch.f

: FREE FREE-ORIG ;
: ALLOCATE ALLOCATE-ORIG ;

5 CONSTANT TRACE_DEPTH

/node
CELL -- .fileNameA
CELL -- .fileNameU
CELL -- .curstr
CELL -- .addr
CELL -- .size
CELL -- .threadId
TRACE_DEPTH CELLS -- .stackTrace
CONSTANT /allocList

/allocList list: AllocList

WINAPI: GetCurrentThreadId KERNEL32.DLL

: DebugAlloc ( n line addr u -- addr ior )
    AllocList AllocateNode >R
    R@ .fileNameU !
    R@ .fileNameA !
    R@ .curstr !
    DUP R@ .size !
    GetCurrentThreadId R@ .threadId !
    ALLOCATE 
    OVER R@ .addr !

\ хак для уменьшения вывода в str4.f    
    RP@ CELL+ @ WordByAddr S" SALLOCATE" COMPARE 0=
    IF
      RP@ CELL+ @ R@ .stackTrace !
      R@ .stackTrace CELL+ 0!
      15 CELLS RP@ + CELL+ ( skip ourselfes) R@ .stackTrace 2 CELLS + TRACE_DEPTH 2 - 
    ELSE
      RP@ CELL+ ( skip ourselfes) R@ .stackTrace TRACE_DEPTH
    THEN CELLS MOVE
    
    DUP
    IF
       R@ FreeNode
    THEN R> DROP

;

: cur-file
    CURFILE @ 0= 
    IF S" " 
    ELSE CURFILE @ ASCIIZ>
    THEN
;

: ALLOCATE ( n -- addr ior )
    STATE @ 
    IF   
       CURSTR @ POSTPONE LITERAL
       cur-file POSTPONE SLITERAL
       POSTPONE DebugAlloc
    ELSE CURSTR @ cur-file DebugAlloc
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
    DUP FindMem ?DUP
    IF FreeNode THEN
    FREE
;

: ClearMemInfo
    AllocList FreeList
;

: PrintTrace ( node )
    .stackTrace TRACE_DEPTH CELLS
    OVER + SWAP
    DO 
       I STACK-ADDR. DROP
    CELL +LOOP
;

USER vLeaks
USER vSize
USER vThreadId

: (printNode) ( node -- )
    vThreadId @
    IF
       DUP .threadId @ vThreadId @ = 0=
       IF DROP EXIT THEN
    THEN
    
    >R
    R@ .fileNameA @
    R@ .fileNameU @ TUCK TYPE
    BL EMIT
    
    30 SWAP - 0 MAX SPACES
    
    R@ .curstr @ U. 9 SPACES
    BASE @ HEX
      ." 0x" R@ .addr @ U. 9 SPACES
    BASE !
   
    R@ .size @  U. 7 SPACES
    R@ .threadId @ U.
    
    CR R> PrintTrace
;

: (countMem)
    vThreadId @
    IF
       DUP .threadId @ vThreadId @ = 0=
       IF DROP EXIT THEN
    THEN

    .size @ vSize +!
    1 vLeaks +!
;

: countMem
    vLeaks 0!
    vSize 0!
    AllocList ForEach: (countMem)
    vSize @
    vLeaks @
;

: (MemReport)
    ." File                          Line         Address           Size     Thread ID" CR
    79 0 DO [CHAR] = EMIT LOOP CR
    
    AllocList ForEach: (printNode)
    79 0 DO [CHAR] = EMIT LOOP CR
    
    countMem ." Code contains " . ." leaks, they take " . ." bytes"
    CR
;

: MemReport ( -- )
    CR ." Memory report:" CR
    vThreadId 0!
    (MemReport)
;

: MemReportThread ( threadId -- )
    CR ." Memory report for thread " DUP . [CHAR] : EMIT CR
    vThreadId !
    (MemReport)
;

: (rm) ( node )
    DUP .threadId @ vThreadId @ =
    IF FreeNode 
    ELSE DROP
    THEN
;

: RemoveThreadMemoryInfo ( threadId )
    vThreadId !
    AllocList ForEach: (rm)
;

..: AT-THREAD-FINISHING GetCurrentThreadId RemoveThreadMemoryInfo ;..

\EOF

~ac\lib\str4.f

: test "   " ;

:NONAME test ; TASK: trah

0 trah START DROP

\ EOF
STARTLOG


: test "  " ;

: tt 100 ALLOCATE THROW ;


\ MemReport
