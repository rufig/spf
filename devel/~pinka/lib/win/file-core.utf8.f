REQUIRE [UNDEFINED] lib/include/tools.f
REQUIRE R:UTF8>UTF16        ~pinka/lib/win/utf16-rbuf.f

\ see: https://docs.microsoft.com/en-us/windows/win32/fileio/file-management-functions

[UNDEFINED] CreateFileW             [IF]  WINAPI: CreateFileW           kernel32.dll    [THEN]
[UNDEFINED] DeleteFileW             [IF]  WINAPI: DeleteFileW           kernel32.dll    [THEN]
[UNDEFINED] GetFileAttributesW      [IF]  WINAPI: GetFileAttributesW    kernel32.dll    [THEN]



\ The original definitions are taken from: spf4/src/win/spf_win_io.f

: CREATE-FILE-SHARED ( c-addr u fam -- fileid ior )
  -ROT R:UTF8>UTF16 ROT
  NIP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  CREATE_ALWAYS
  SA ( secur )
  3 ( share )
  R> ( access=fam )
  R> ( filename )
  CreateFileW DUP -1 = IF GetLastError ELSE 0 THEN
;
: OPEN-FILE-SHARED ( c-addr u fam -- fileid ior )
  -ROT R:UTF8>UTF16 ROT
  NIP SWAP 2>R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  OPEN_EXISTING
  SA ( secur )
  7 ( FILE_SHARE_READ FILE_SHARE_WRITE OR FILE_SHARE_DELETE OR )
  2R> ( access=fam filename )
  CreateFileW DUP -1 =
  IF GetLastError ELSE 0 THEN
;
: DELETE-FILE ( c-addr u -- ior ) \ 94 FILE
  R:UTF8>UTF16 DROP DeleteFileW ERR
;
: OPEN-FILE ( c-addr u fam -- fileid ior ) \ 94 FILE
  -ROT R:UTF8>UTF16 ROT
  NIP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  OPEN_EXISTING
  0 ( secur )
  0 ( share )
  R> ( access=fam )
  R> ( filename )
  CreateFileW DUP -1 = IF GetLastError ELSE 0 THEN
;
: FILE-EXIST ( addr u -- f )
  R:UTF8>UTF16
  DROP GetFileAttributesW -1 <>
;
: FILE-EXISTS ( addr u -- f )
  R:UTF8>UTF16
  DROP GetFileAttributesW INVERT 16 ( FILE_ATTRIBUTE_DIRECTORY) AND 0<>
;
