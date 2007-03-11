WINAPI: GetProcessHeaps KERNEL32.DLL
WINAPI: HeapWalk        KERNEL32.DLL

: GetHeaps ( -- addr n )
\ addr - адрес массива с хэндлами хипов
\ n - к-во хэндлов в массиве
  PAD 250 GetProcessHeaps PAD SWAP
;


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

USER MEM-TOTAL
USER MEM-SPF

: HeapEnum ( xt h -- )
  /PROCESS_HEAP_ENTRY ALLOCATE THROW ( xt h entry ) SWAP 2>R
  BEGIN
    2R@ HeapWalk
  WHILE
    2R@ DROP OVER ['] EXECUTE CATCH ?DUP IF ( ." EXC:" U. ) DROP 2DROP THEN
  REPEAT DROP
  2R> DROP FREE THROW
;

: MemDump1 ( entry -- )
  SPACE SPACE
  DUP @ 6 .0
  CELL+ @ DUP MEM-TOTAL +!
  DECIMAL 0 <# #S #> 8 OVER - 0 MAX SPACES TYPE HEX
;
: MemDump ( entry -- )
  DUP DUP MemDump1 SPACE SPACE  
  @ @ WordByAddr 

  2DUP 8 MIN S" MEMSELF_" COMPARE 0=
  IF 2DUP TYPE SPACE 
     FORTH-WORDLIST SEARCH-WORDLIST
     IF TRUE SWAP EXECUTE ELSE ." MEMSELF_ handler not found." . THEN CR
     EXIT
  THEN

  2DUP 2>R 

\  2DUP S" STRBUF" COMPARE 0= >R TYPE
  2DUP S" SALLOT" COMPARE 0= >R TYPE
  R> IF SPACE DUP @ ( 32 + ASCIIZ> TYPE) 
                    CELL+ ( XCOUNT) DUP @ SWAP CELL+ SWAP TYPE THEN
  CR
  2R> S" not " SEARCH NIP NIP IF DROP ELSE CELL+ @ MEM-SPF +! THEN
;
: MEM
  MEM-TOTAL 0! MEM-SPF 0!
  BASE @ HEX
  ['] DROP TO <EXC-DUMP>
  GetHeaps 0 ?DO CR
    DUP @ DUP 4 .0 GetProcessHeap = 
    IF ."  - Process heap (not used by SPF)" CR ['] MemDump1
    ELSE CR ['] MemDump THEN
    OVER @ HeapEnum CELL+
  LOOP DROP
  BASE !
  CR ." Total: " MEM-TOTAL @ U. ."  Forth: " MEM-SPF @ U.
;
\EOF

: MEMSELF_TEST ( false  | entry true -- )
  IF @ CELL+ @ .
  ELSE
    0x73737373 1 CELLS ALLOCATE THROW !
  THEN
;
