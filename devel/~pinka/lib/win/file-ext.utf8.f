\ ext file and directory functions accepting file names in UTF-8 encoding
\ 2015-10-01 -- initial version (in another project)

\ See also: devel/~ac/lib/win/file/utils.f

\ Windows API references:
\ see: https://learn.microsoft.com/en-us/windows/win32/fileio/file-management-functions
\ see: https://learn.microsoft.com/en-us/windows/win32/fileio/directory-management-functions


REQUIRE-WORD [IF]            lib/include/tools.f
REQUIRE-WORD ?WINAPI:        devel/~ygrek/lib/win/winapi.f
REQUIRE-WORD R:UTF8>UTF16    devel/~pinka/lib/win/utf16-rbuf.f


REQUIRE-WORD utf8.file-core.win.lib.spf4   devel/~pinka/lib/win/file-core.utf8.f

TRUE CONSTANT utf8.file-ext.win.lib.spf4  \ an identifier for this library file


[UNDEFINED] ?WINAPI(  [IF]
: ?WINAPI(  ( "ccc<rparen>" -- )   [CHAR] ) PARSE ['] ?WINAPI: EVALUATE-WITH ;
[THEN]

[UNDEFINED] FILE_ATTRIBUTE_DIRECTORY    [IF] 16 CONSTANT FILE_ATTRIBUTE_DIRECTORY   [THEN]
[UNDEFINED] INVALID_FILE_ATTRIBUTES     [IF] -1 CONSTANT INVALID_FILE_ATTRIBUTES    [THEN]


?WINAPI( MoveFileW             kernel32.dll ) ( lpNew lpExisting -- bool )
\ https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-movefilew
: RENAME-FILE ( sd.filename-old  sd.filename-new -- ior )
  R:UTF8>UTF16 DROP UNROT
  R:UTF8>UTF16 DROP
  MoveFileW ERR
;

?WINAPI( CopyFileW             kernel32.dll ) ( bFailIfExists:bool lpNewFileName  lpExistingFileName -- bool )
\ https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-copyfile
: COPY-FILE ( sd.filename-old  sd.filename-new -- ior )
  R:UTF8>UTF16 DROP UNROT  ( a.new sd.filename-old )
  R:UTF8>UTF16 DROP  ( a.new a.old )
  1 UNROT   ( u.bFailIfExists a.new a.old )
  CopyFileW ERR
;
: COPY-FILE-OVER ( sd.filename-old  sd.filename-new -- ior )
  R:UTF8>UTF16 DROP UNROT  ( a.new sd.filename-old )
  R:UTF8>UTF16 DROP  ( a.new a.old )
  0 UNROT   ( u.bFailIfExists a.new a.old )
  CopyFileW ERR
;


?WINAPI( CreateDirectoryW    kernel32.dll ) ( lpSecurityAttributes lpPathName -- bool )
\ https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createdirectoryw
: MAKE-DIRECTORY ( sd.filename -- ior )
  R:UTF8>UTF16 DROP
  0 SWAP CreateDirectoryW ERR
;

?WINAPI( RemoveDirectoryW      kernel32.dll ) ( lpPathName  -- bool  )
\ https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-removedirectoryw
: DELETE-DIRECTORY ( sd.filename -- ior )
  R:UTF8>UTF16 DROP
  RemoveDirectoryW ERR
;

?WINAPI( GetFileAttributesW  kernel32.dll ) ( lpFileName -- dwFileAttributes )
\ https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfileattributesw
: FILENAME-DIRECTORY ( sd.filename -- flag ) \ In contrast to "FILE-*" words, "FILENAME-*" words do not return an ior
  R:UTF8>UTF16
  DROP GetFileAttributesW
  DUP INVALID_FILE_ATTRIBUTES = IF DROP 0 EXIT THEN
  FILE_ATTRIBUTE_DIRECTORY AND 0<>
;

\ m.b.
\ SYNONYM DIRECTORY-EXISTS      FILENAME-DIRECTORY
\ SYNONYM CREATE-DIRECTORY      MAKE-DIRECTORY
\ SYNONYM DELETE-FOLDER         DELETE-DIRECTORY


\ see: devel/~pinka/samples/2005/lib/lay-path.f
: LAY-PATH-CATCH ( sd.filename -- ior )
  CUT-PATH DUP 0= IF NIP EXIT THEN
  /CHAR - ( a u' )
  2DUP FILENAME-EXISTING IF 2DROP 0 EXIT THEN
  2DUP RECURSE DUP IF NIP NIP EXIT THEN DROP
  MAKE-DIRECTORY ( ior )
;
: LAY-PATH ( sd.filename -- )
  LAY-PATH-CATCH THROW
;
: FORCE-PATH ( sd.filename -- sd.filename )
  2DUP LAY-PATH
;


\ #eof
