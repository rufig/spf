
WINAPI: CreateHardLinkA  kernel32.dll

( BOOL WINAPI CreateHardLink(
  __in        LPCTSTR lpFileName,
  __in        LPCTSTR lpExistingFileName,
  __reserved  LPSECURITY_ATTRIBUTES lpSecurityAttributes
)


: COPY-FILE-HARDLINK ( d-src d-trg -- ior )
  DROP NIP \ ASCIIZ
  0 -ROT
  CreateHardLinkA ERR
;

\ The name and the stack is in a manner of the COPY-FILE, COPY-FILE-OVER, etc
