WINAPI: CreatePipe            KERNEL32.DLL
WINAPI: DuplicateHandle       KERNEL32.DLL
WINAPI: GetCurrentProcess     KERNEL32.DLL

00000002 CONSTANT DUPLICATE_SAME_ACCESS

: DUP-HANDLE-INHERITED ( h1 -- h2 ior )
  0 >R
  >R DUPLICATE_SAME_ACCESS TRUE 0 RP@ CELL+
  GetCurrentProcess R> GetCurrentProcess DuplicateHandle
  R> SWAP ERR
\  IF R> 0 ELSE R> DROP 0 GetLastError THEN
;
