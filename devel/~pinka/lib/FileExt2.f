\ 29.Mar.2004 + RENAME-FILE-OVER

\ REQUIRE RENAME-FILE  ~pinka\lib\FileExt.f

WINAPI: MoveFileExA            KERNEL32.DLL \ working only in NT
\ CopyFile
(   BOOL bFailIfExists  // flag for operation if file exists 
    LPCTSTR lpNewFileName,  // pointer to filename to copy to 
    LPCTSTR lpExistingFileName, // pointer to name of an existing file 
   -- BOOL )


1 CONSTANT MOVEFILE_REPLACE_EXISTING

: RENAME-FILE-OVER   ( c-addr1 u1  c-addr2 u2 -- ior )
  DROP NIP  SWAP
  MOVEFILE_REPLACE_EXISTING -ROT 
  MoveFileExA  ERR
;
