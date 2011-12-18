
WINAPI: CreateHardLinkA  kernel32.dll

( BOOL WINAPI CreateHardLink(
  __in        LPCTSTR lpFileName,
  __in        LPCTSTR lpExistingFileName,
  __reserved  LPSECURITY_ATTRIBUTES lpSecurityAttributes
)


WINAPI: CreateSymbolicLinkA  kernel32.dll

( BOOLEAN WINAPI CreateSymbolicLink
  __in  LPTSTR lpSymlinkFileName,
  __in  LPTSTR lpTargetFileName,
  __in  DWORD dwFlags
)


: COPY-FILE-HARDLINK ( d-src d-trg -- ior )
  DROP NIP \ ASCIIZ
  0 -ROT
  CreateHardLinkA ERR
;

: COPY-FILE-SYMLINK ( d-src d-trg -- ior )
  DROP NIP \ ASCIIZ
  0 -ROT
  CreateSymbolicLinkA ERR
;

\ The name and the stack is in a manner of the COPY-FILE, COPY-FILE-OVER, etc
