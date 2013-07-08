\ 2001

\ 31.Mar.2004  + COPY-FILE-OVER

REQUIRE [UNDEFINED]           lib\include\tools.f

WINAPI: MoveFileA              KERNEL32.DLL
WINAPI: CopyFileA              KERNEL32.DLL

: RENAME-FILE   ( c-addr1 u1  c-addr2 u2 -- ior )
\ FILE EXT
\ Rename the file named by the character string c-addr1 u1 to the name
\ in the character string c-addr2 u2. ior is the implementation-defined
\ I/O result code. )

  DROP NIP  SWAP  MoveFileA  ERR
;


: TOEND-FILE ( fileid -- ior )
\ переместить указатель файла  в конец файла.

  DUP >R   FILE-SIZE  ( fileid -- ud ior ) 
  ?DUP IF R> DROP NIP NIP EXIT THEN
  R> REPOSITION-FILE  ( ud fileid -- ior ) 
;


\ CopyFile  (  bFailIfExists:BOOL lpNewFileName  lpExistingFileName -- flag:BOOL )
\    BOOL  bFailIfExists     // flag for operation if file exists 
\    =true - fail, if file exist

\  MoveFile (  lpNewFileName  lpExistingFileName -- flag:BOOL )

: COPY-FILE ( src-a src-u  dst-a dst-u -- ior )
  DROP NIP SWAP
  1 \ fail if exists
  -ROT CopyFileA ERR
;
: COPY-FILE-OVER ( src-a src-u  dst-a dst-u -- ior )
\ This operation doesn't change the hardlinks number of the dst file.
  DROP NIP
  SWAP FALSE -ROT CopyFileA ERR
;


WINAPI: RemoveDirectoryA KERNEL32.DLL (
    LPCTSTR lpPathName  // address of directory to remove  
  -- BOOL  )   

: DELETE-FOLDER ( a u -- ior )
\ will deleted only if empty
  DROP RemoveDirectoryA ERR
;


[UNDEFINED] MAX_PATH  [IF]
260 CONSTANT MAX_PATH [THEN]

WINAPI: GetFullPathNameA KERNEL32.DLL (
    LPTSTR *lpFilePart  // address of filename in path
    LPTSTR lpBuffer,    // address of path buffer 
    DWORD nBufferLength,    // size, in characters, of path buffer 
    LPCTSTR lpFileName, // address of name of file to find path for 
  -- DWORD )

: ExtFilePathName ( a u -- a u1 )
\ пишет имя с путем вместо имени в буфер по адресу a.
\ буфер должен быть не менее MAX_PATH
  OVER + 0! >R
  0 SP@ R@
  MAX_PATH R@
  GetFullPathNameA
  DUP MAX_PATH > OVER 0= OR IF 2DROP R> 0 EXIT THEN
  NIP R> SWAP
  2DUP + 0 SWAP C!
;

