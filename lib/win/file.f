\ orig 2001 ~pinka/lib/FileExt.f
\ 

REQUIRE [UNDEFINED]           lib\include\tools.f

WINAPI: RemoveDirectoryA      KERNEL32.DLL ( lpPathName  -- bool  )   
WINAPI: MoveFileA             KERNEL32.DLL ( lpNew lpExisting -- bool )
WINAPI: CopyFileA             KERNEL32.DLL
\ CopyFile  (  bFailIfExists:BOOL lpNewFileName  lpExistingFileName -- bool )
\    BOOL  bFailIfExists     // flag for operation if file exists 
\    =true - fail, if file exist


: RENAME-FILE   ( c-addr1 u1  c-addr2 u2 -- ior )
\ FILE EXT
\ Rename the file named by the character string c-addr1 u1 to the name
\ in the character string c-addr2 u2. ior is the implementation-defined
\ I/O result code. )
  DROP NIP  SWAP  MoveFileA  ERR
;

: TOEND-FILE ( fileid -- ior )
\ Move file pointer to the end of the file
  DUP >R   FILE-SIZE  ( fileid -- ud ior ) 
  ?DUP IF R> DROP NIP NIP EXIT THEN
  R> REPOSITION-FILE  ( ud fileid -- ior ) 
;

: COPY-FILE ( src-a src-u  dst-a dst-u -- ior )
  DROP NIP SWAP
  1 \ fail if exists
  -ROT CopyFileA ERR
;

: COPY-FILE-OVER ( src-a src-u  dst-a dst-u -- ior )
  DROP NIP
  SWAP FALSE -ROT CopyFileA ERR
;

: DELETE-FOLDER ( a u -- ior )
\ will deleted only if empty
  DROP RemoveDirectoryA ERR
;
