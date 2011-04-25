
REQUIRE T@ ~pinka/lib/ext/basics.f


0
4 -- dwSize
4 -- cntUsage
4 -- th32ThreadID
4 -- th32OwnerProcessID
4 -- tpBasePri
4 -- tpDeltaPri
4 -- dwFlags
CONSTANT /THREADENTRY32

0x00000004 CONSTANT TH32CS_SNAPTHREAD \ threads

\ MSDN: To identify the threads that belong to a specific process, 
\ compare its process identifier to the th32OwnerProcessID member 
\ of the THREADENTRY32 structure when enumerating the threads.



WINAPI: CreateToolhelp32Snapshot    kernel32.dll ( th32ProcessID flags -- handle )

WINAPI: Thread32First               kernel32.dll ( threadentry32 h_shapshot -- bool )

WINAPI: Thread32Next                kernel32.dll ( threadentry32 h_shapshot -- bool )

WINAPI: GetCurrentProcessId         kernel32.dll ( -- id )


: ENUM-THREADS ( xt -- ) \ xt ( thread-id -- )
  GetCurrentProcessId
  /THREADENTRY32 >CELLS 1+ DUP RALLOT SWAP >R  ( xt own-id entry )
  /THREADENTRY32 OVER dwSize T! \ set size field of the structure
  0 TH32CS_SNAPTHREAD CreateToolhelp32Snapshot DUP ERR THROW
  \ ProcessId param is not used when TH32CS_SNAPTHREAD flag specified
  2DUP >R >R ( xt own-id  entry h )
  Thread32First ( ... flag ) DUP 0= IF ERR R> CloseHandle DROP THROW ABORT THEN
  BEGIN ( xt own-id flag ) WHILE ( xt  own-id )
    DUP R@ th32OwnerProcessID T@ = IF
      R@ th32ThreadID T@ -ROT >R DUP >R ( thread-id xt ) EXECUTE R> R>
    THEN
    2R@ SWAP Thread32Next
  REPEAT 2DROP
  RDROP R> CloseHandle ERR THROW
  R> RFREE
;

\ see also: Traversing the Thread List -- http://msdn.microsoft.com/en-us/library/ms686852%28v=vs.85%29.aspx
