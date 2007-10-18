\ $Id$
( Report all memory leaks, just use MemReport word )
( Use it for debug purposes, mind - it slowdowns the program! )
( [c] Dmitry Yakimov ftech@tula.net )

(
  + выводит не только утечки но распечатку стека возвратов при их возникновении
  + многопоточна, может выводить отчеты для отдельных потоков, MemReportThread
  + отметки блоков памяти с воможностью указать диапазон для вывода в отчёте
)

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE RTRACE ~ygrek/lib/debug/rtrace.f
REQUIRE HEAP-ID ~pinka/spf/mem.f

\ прячем всё внутрь т.к. эта либа для отладки и увеличение размера не критично
\ а отсутствие дополнительных глюков от каких-нибудь переопределений - существенно
MODULE: _VOC_MEMREPORT

REQUIRE CZGETMEM ~yz/lib/common.f
REQUIRE MALLOCATE ~yz/lib/gmem.f

  MODULE: inner

  : ALLOCATE MALLOCATE 0 ;
  : FREE MFREE ERR ;

  EXPORT

  ( Обязательно подключаем явно чтобы гарантировать
    глобальное выделение памяти для списка журнала )
  S" ~day/lib/staticlist.f" INCLUDED

  ;MODULE

20 CONSTANT TRACE_DEPTH

0 VALUE CURRENT-GENERATION

FALSE VALUE SHOW-FAILED-FREE?

/node
CELL -- .fileNameA
CELL -- .fileNameU
CELL -- .curstr
CELL -- .addr
CELL -- .size
CELL -- .threadId
CELL -- .heapId
CELL -- .generation
TRACE_DEPTH CELLS -- .stackTrace
CONSTANT /allocList

/allocList list: AllocList

WINAPI: GetCurrentThreadId KERNEL32.DLL

: PrintTrace ( node )
    .stackTrace TRACE_DEPTH CELLS
    OVER + SWAP
    DO
       I STACK-ADDR. DROP
    CELL +LOOP
;

: DebugAlloc ( addr n line filename-addr filename-u -- addr ior )
    AllocList AllocateNode >R
    R@ .fileNameU !
    R@ .fileNameA !
    R@ .curstr !
    GetCurrentThreadId R@ .threadId !
    HEAP-ID R@ .heapId !
    R@ .size !
    R@ .addr !
    CURRENT-GENERATION R@ .generation !

    RP@ CELL+ ( skip ourselfes) R@ .stackTrace TRACE_DEPTH CELLS MOVE

    RDROP
;

: cur-file
    CURFILE @ 0=
    IF S" "
    ELSE CURFILE @ ASCIIZ>
    THEN
;

: MEMREPORT-ALLOCATE ( addr n -- )
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

: MEMREPORT-FREE ( addr -- )
    DUP FindMem DUP 
    IF ( addr node )
     NIP
      DUP .heapId @ HEAP-ID <> 
      IF 
       CR ." MEMREPORT wrong heap (FREE) : "
       DUP .addr @ .
       DUP .heapId @ ." heap " .
       HEAP-ID ." current " .
       CR ."  Block was allocated at : " 
       CR
       DUP PrintTrace
       RTRACE
      THEN 
     FreeNode 
    ELSE ( addr 0 ) 
     DROP
     SHOW-FAILED-FREE?
     IF 
       CR ." MEMREPORT: FREE: Block was not previously allocated at " .
       RTRACE
     THEN
    THEN
;

EXPORT

: ALLOCATE ( n -- addr ior )
   >R
   R@ ALLOCATE ( addr ior )
   \ AllocList listSize CR ." Size : " .
   \ CR ." ALLOC : " OVER .
   DUP IF RDROP EXIT THEN \ в случае неудачи выделения памяти - не журналируем
   OVER R> MEMREPORT-ALLOCATE ;

: FREE ( addr -- ior ) 
  \ AllocList listSize CR ." Size - " .
  DUP MEMREPORT-FREE FREE ;

: RESIZE ( addr n -- addr2 ior )
   2DUP RESIZE
   ?DUP IF 2SWAP 2DROP EXIT THEN \ при неудаче - ничего не делаем
   \ иначе делаем исправления в журнале
   ( addr n addr2 )
   ROT MEMREPORT-FREE
   2DUP SWAP MEMREPORT-ALLOCATE
   NIP 0 ;

: ClearMemInfo ( -- )
    AllocList FreeList
;

DEFINITIONS

USER vLeaks
USER vSize
USER vThreadId
USER vGeneration

: (printNode) ( node -- )
    vThreadId @
    IF
       DUP .threadId @ vThreadId @ = 0=
       IF DROP EXIT THEN
    THEN

    vGeneration @ 
    IF
        DUP .generation @ vGeneration @ <
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

    vGeneration @
    IF
        DUP .generation @ vGeneration @ < 
        IF DROP EXIT THEN
    THEN

    .size @ vSize +!
    1 vLeaks +!
;

EXPORT

: countMem ( -- size n )
    vLeaks 0!
    vSize 0!
    AllocList ForEach: (countMem)
    vSize @
    vLeaks @
;

DEFINITIONS

: (MemReport)
    ." File                          Line         Address           Size     Thread ID" CR
    79 0 DO [CHAR] = EMIT LOOP CR

    AllocList ForEach: (printNode)
    79 0 DO [CHAR] = EMIT LOOP CR

    countMem ." Code contains " . ." leaks, they take " . ." bytes"
    CR
;

: (rm) ( node )
    DUP .threadId @ vThreadId @ =
    IF FreeNode
    ELSE DROP
    THEN
;

EXPORT

: RemoveThreadMemoryInfo ( threadId -- )
    vThreadId !
    AllocList ForEach: (rm)
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

\ Установить новую отметку и вернуть её номер
: NewMemoryMark ( -- n ) CURRENT-GENERATION 1+ DUP TO CURRENT-GENERATION ;

\ В отчёте MemReport показывать только те блоки памяти что были выделены после отметки n 
\ 0 для того чтобы показывать все блоки
: SetReportMark ( n -- ) vGeneration ! ;

: ShowFailedFree ( -- ) TRUE TO SHOW-FAILED-FREE? ;
: HideFailedFree ( -- ) FALSE TO SHOW-FAILED-FREE? ;

..: AT-THREAD-FINISHING GetCurrentThreadId RemoveThreadMemoryInfo ;..

;MODULE

\ -----------------------------------------------------------------------

/TEST

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES memreport

\ test simple
\ -------------------------------------------

MemReport
(( countMem -> 0 0 ))
CR

" string1" " foobar :)" " leaky leaky string" 

(( countMem NIP 0= -> FALSE ))
STRFREE STRFREE STRFREE
(( countMem NIP -> 0 ))

\ test threads
\ -------------------------------------------

FALSE VALUE stop-tasks

:NONAME 100 ALLOCATE THROW DROP . BEGIN stop-tasks 0= WHILE 100 PAUSE REPEAT ; TASK: test1
: run-tasks 10 0 DO I test1 START DROP LOOP ;
run-tasks
200 PAUSE \ wait for all threads to start
(( countMem NIP -> 10 ))
TRUE TO stop-tasks
200 PAUSE \ wait for all threads to finish
(( countMem NIP -> 0 )) \ threads die and memory is freed and DebugAlloc records are deleted

\ test memory marks
\ -------------------------------------------

: LEAK ALLOCATE THROW DROP ;

: inner
   NewMemoryMark SetReportMark
   100 LEAK
   200 LEAK
   CR ." inner leaks : " countMem . .
   ;

: outer
   2000 LEAK
   100000 ALLOCATE THROW
   inner
   FREE THROW 
   3000 LEAK
;

outer

CR .( inner with subsequent leaks : ) countMem . .
(( countMem -> 3300 3 ))
0 SetReportMark
CR .( all leaks : ) countMem . .
(( countMem -> 5300 4 ))

CR
ClearMemInfo
MemReport
(( countMem -> 0 0 ))

END-TESTCASES

