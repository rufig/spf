REQUIRE [UNDEFINED] lib/include/tools.f
REQUIRE UTF8>UTF16 ~pinka/lib/win/utf16.f
REQUIRE RBUF       ~pinka/spf/rbuf.f

[UNDEFINED] CreateHardLinkW [IF]
WINAPI: CreateHardLinkW  kernel32.dll
[THEN]
( BOOL WINAPI CreateHardLink(
  __in        LPCTSTR lpFileName,
  __in        LPCTSTR lpExistingFileName,
  __reserved  LPSECURITY_ATTRIBUTES lpSecurityAttributes
)


[UNDEFINED] CreateSymbolicLinkW [IF]
WINAPI: CreateSymbolicLinkW  kernel32.dll
[THEN]
( BOOLEAN WINAPI CreateSymbolicLink
  __in  LPTSTR lpSymlinkFileName,
  __in  LPTSTR lpTargetFileName,
  __in  DWORD dwFlags
)


: R:UTF8>UTF16 ( d-txt -- d-txt2-r )
  POSTPONE ENSURE-ASCIIZ-R POSTPONE 1+ POSTPONE DUP POSTPONE 2* POSTPONE RBUF POSTPONE UTF8>UTF16
; IMMEDIATE

: COPY-FILE-HARDLINK ( d-src d-trg -- ior )
  \ works only for regular files
  R:UTF8>UTF16 2SWAP R:UTF8>UTF16 2SWAP
  DROP NIP \ ASCIIZ
  0 -ROT
  CreateHardLinkW ERR
;

: COPY-FILE-SYMLINK ( d-src d-trg -- ior )
  \ works only for regular files
  R:UTF8>UTF16 2SWAP R:UTF8>UTF16 2SWAP
  DROP NIP \ ASCIIZ
  0 -ROT
  CreateSymbolicLinkW ERR
;

\ The name and the stack is in a manner of the COPY-FILE, COPY-FILE-OVER, etc
