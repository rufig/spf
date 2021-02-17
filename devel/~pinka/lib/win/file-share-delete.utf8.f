REQUIRE [UNDEFINED] lib/include/tools.f
REQUIRE R:UTF8>UTF16        ~pinka/lib/win/utf16-rbuf.f


[UNDEFINED] CreateFileW             [IF]  WINAPI: CreateFileW           kernel32.dll    [THEN]


\ The original definitions are taken from: ~ac/lib/win/file/share-delete.f

: OPEN-FILE-SHARED-DELETE ( c-addr u fam -- fileid ior )
  -ROT R:UTF8>UTF16 ROT
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  OPEN_EXISTING
  SA ( secur )
  7 ( share read/write/delete )
  R> ( access=fam )
  R> ( filename )
  CreateFileW DUP -1 = IF GetLastError ELSE 0 THEN
;
: CREATE-FILE-SHARED-DELETE ( c-addr u fam -- fileid ior )
  -ROT R:UTF8>UTF16 ROT
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  CREATE_ALWAYS
  SA ( secur )
  7 ( share read/write/delete )
  R> ( access=fam )
  R> ( filename )
  CreateFileW DUP -1 = IF GetLastError ELSE 0 THEN
;
0x04000000 CONSTANT FILE_FLAG_DELETE_ON_CLOSE

: CREATE-FILE-SHARED-DELETE-ON-CLOSE ( c-addr u fam -- fileid ior )
  -ROT R:UTF8>UTF16 ROT
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
    FILE_FLAG_DELETE_ON_CLOSE OR
  CREATE_ALWAYS
  SA ( secur )
  7 ( share read/write/delete )
  R> ( access=fam )
  R> ( filename )
  CreateFileW DUP -1 = IF GetLastError ELSE 0 THEN
;
