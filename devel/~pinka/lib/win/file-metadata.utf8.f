\ 2026-04-15
\ `FOR-FILENAME-METADATA` accepts a file name in UTF-8 encoding


REQUIRE-WORD [:                  lib/include/quotations.f
REQUIRE-WORD R:UTF8>UTF16        devel/~pinka/lib/win/utf16-rbuf.f


TRUE CONSTANT utf8.file-metadata.win.lib.spf4  \ an identifier for this library file


[UNDEFINED] FindFirstFileW  [IF] WINAPI: FindFirstFileW     kernel32.dll [THEN]
[UNDEFINED] FindClose       [IF] WINAPI: FindClose          kernel32.dll [THEN]


[UNDEFINED] FILE_ATTRIBUTE_DIRECTORY [IF] 16 CONSTANT FILE_ATTRIBUTE_DIRECTORY [THEN]


[UNDEFINED] ftLastWriteTime  [UNDEFINED] cFileNameW  AND [IF]

  0 \ WIND32_FIND_DATAW structure
  4 -- dwFileAttributes
  8 -- ftCreationTime
  8 -- ftLastAccessTime
  8 -- ftLastWriteTime
  4 -- nFileSizeHigh
  4 -- nFileSizeLow
  4 -- dwReserved0
  4 -- dwReserved1
260 2* -- cFileNameW          \ MAX_PATH WideChar
 14 2* -- cAlternateFileNameW \ 14 of WideChar
  3 4 * + \ Obsolete fields
CONSTANT /WIN32_FIND_DATAW

  0 cFileNameW
260  -- cFileName          \ MAX_PATH bytes
 14  -- cAlternateFileName \ 14 bytes
  3 4 * + \ Obsolete fields
CONSTANT /WIN32_FIND_DATA


[ELSE]

  0 cFileName \ ( u.offset )
260 2* -- cFileNameW          \ MAX_PATH WideChar
 14 2* -- cAlternateFileNameW \ 14 of WideChar
  3 4 * + \ Obsolete fields
CONSTANT /WIN32_FIND_DATAW

[THEN]



\ https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-findfirstfilew

: FOR-FILENAME-METADATA? ( i*x sd.filename.utf8 xt -- j*x true | i*x false )
  \ xt ( i*x a-addr.data -- j*x )
  UNROT R:UTF8>UTF16 DROP ( xt a-addr.fn )
  /WIN32_FIND_DATAW RBUF DROP ( xt a-addr.fn a-addr.data )
  TUCK SWAP  FindFirstFileW ( xt a-addr.data  x.handle )
  DUP -1 = IF DROP 2DROP FALSE EXIT THEN  FindClose ERR THROW ( xt a-addr.data )
  SWAP EXECUTE TRUE
;

: FOR-FILENAME-METADATA ( i*x sd.filename.utf8 xt -- j*x ) \ xt ( i*x a-addr.data -- j*x )
  FOR-FILENAME-METADATA? IF EXIT THEN -67 THROW
;

: FILENAME-FILETIME ( sd.filename -- ud.filetime ) \ UTC
  [: ftCreationTime 2@ SWAP ;] FOR-FILENAME-METADATA
;

: FILENAME-FILETIME-W ( sd.filename -- ud.filetime ) \ UTC
  [: ftLastWriteTime 2@ SWAP ;] FOR-FILENAME-METADATA
;


\ see-also: devel/~ac/lib/win/file/fileprop.f
\   where `FOR-FILE1-PROPS` accepts a file name in ASCII/OEM encoding
