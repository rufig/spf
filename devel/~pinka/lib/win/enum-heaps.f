
WINAPI: GetProcessHeaps             kernel32.dll ( array max-count -- count )
WINAPI: HeapWalk                    kernel32.dll ( entry heap -- bool )


WINAPI: HeapLock                    kernel32.dll ( heap -- bool )
WINAPI: HeapUnlock                  kernel32.dll ( heap -- bool )
WINAPI: HeapValidate                kernel32.dll ( addr-mem|0 flags heap -- bool )
\   valid --> nonzero
\ invalid --> zero

\ MSDN: If the HeapLock and HeapUnlock functions are called on a heap created 
\   with the HEAP_NO_SERIALIZATION flag, the results are undefined.

\ The low-fragmentation heap (LFH) cannot be enabled for a heap created 
\ with this option [ HEAP_NO_SERIALIZE 0x00000001 ]

\ If you want to validate the heap elements enumerated by the HeapWalk function, 
\ you should only call HeapValidate on the elements that have PROCESS_HEAP_ENTRY_BUSY 
\ in the wFlags member of the PROCESS_HEAP_ENTRY structure. HeapValidate returns FALSE 
\ for all heap elements that do not have this bit set.


250 VALUE MAX-ENUM-HEAPS

: ENUM-HEAPS ( xt -- ) \ xt ( heap -- )
  MAX-ENUM-HEAPS DUP ( number-of-cells ) RALLOT SWAP >R ( xt array )
  DUP R@ GetProcessHeaps DUP ERR THROW ( xt array +n )
  BEGIN DUP WHILE
    >R 2DUP 2>R @ SWAP EXECUTE
    2R> CELL+ R> 1-
  REPEAT
  2DROP DROP
  R> RFREE
;

\ see also: devel/~ac/lib/memory/heap_enum.f

0
CELL -- lpData
CELL -- cbData
   1 -- cbOverhead
   1 -- iRegionIndex
   2 -- wFlags
\    union {
\        struct {
\            HANDLE hMem;
\            DWORD dwReserved[ 3 ];
\        } Block;
\        struct {
\            DWORD dwCommittedSize;
\            DWORD dwUnCommittedSize;
\            LPVOID lpFirstBlock;
\            LPVOID lpLastBlock;
\        } Region;
\    };
5 CELLS -- xOtherInfo
CONSTANT /PROCESS_HEAP_ENTRY

\ MSDN: To initiate a heap enumeration, set the lpData field 
\  of the PROCESS_HEAP_ENTRY structure to NULL.


0x0004 CONSTANT PROCESS_HEAP_ENTRY_BUSY \ The heap element is an allocated block.

: FOR-HEAP-ENTRY ( heap xt -- ) \ xt ( entry -- )
  /PROCESS_HEAP_ENTRY >CELLS 1+ DUP RALLOT SWAP >R
  DUP lpData 0! ( heap xt entry ) ROT
  BEGIN ( xt entry heap )
    2DUP HeapWalk
  WHILE
    >R 2DUP 2>R
    SWAP EXECUTE
    2R> R>
  REPEAT
  2DROP DROP
  R> RFREE
;
: HEAPENTRY-DATA ( entry -- addr u )
  DUP  lpData @
  SWAP cbData @
;
: (FOR-HEAP) ( xt entry -- xt ) \ xt ( addr u -- )
  DUP wFlags W@ PROCESS_HEAP_ENTRY_BUSY AND 0= IF DROP EXIT THEN
  SWAP >R HEAPENTRY-DATA R@ EXECUTE R>
;
: FOR-HEAP ( heap xt -- ) \ xt ( addr u -- )
  \ only for allocated blocks
  SWAP ['] (FOR-HEAP) FOR-HEAP-ENTRY DROP
;

\ see also:
\   Enumerating a Heap -- http://msdn.microsoft.com/en-us/library/ee175819%28v=vs.85%29.aspx
