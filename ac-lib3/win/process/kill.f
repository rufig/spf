WINAPI: OpenProcess      KERNEL32.DLL
WINAPI: TerminateProcess KERNEL32.DLL

: kill ( pid -- )
  0 0xFFF OpenProcess 1 SWAP TerminateProcess .
;