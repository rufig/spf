\ 2026-04-15
\ UTF-8 version of words from "./file-info-*.f" files


REQUIRE-WORD [:                         lib/include/quotations.f
REQUIRE-WORD lexicon.basics-aligned     devel/~pinka/lib/ext/basics.f  \ to access fields via Q@ and T@
REQUIRE-WORD R:UTF16>UTF8               devel/~pinka/lib/win/utf16-rbuf.f

REQUIRE-WORD utf8.file-metadata.win.lib.spf4    devel/~pinka/lib/win/file-metadata.utf8.f \ `FOR-FILENAME-METADATA` word
REQUIRE-WORD utf8.file-core.win.lib.spf4        devel/~pinka/lib/win/file-core.utf8.f \ `OPEN-FILE-SHARED` word

TRUE CONSTANT utf8.file-info.win.lib.spf4  \ an identifier for this library file





\ "./file-info-attr.f"

0x1 CONSTANT FILE_ATTRIBUTE_READONLY
0x2 CONSTANT FILE_ATTRIBUTE_HIDDEN
0x4 CONSTANT FILE_ATTRIBUTE_SYSTEM


: FILENAME-ATTRIBUTES ( sd.filename -- flags )
  [: dwFileAttributes T@ ;] FOR-FILENAME-METADATA
;
: FILENAME-SYSTEM ( sd.filename -- flag )
  FILENAME-ATTRIBUTES FILE_ATTRIBUTE_SYSTEM AND 0<>
;
: FILENAME-HIDDEN ( sd.filename -- flag )
  FILENAME-ATTRIBUTES FILE_ATTRIBUTE_HIDDEN AND 0<>
;




\ "./file-info-symlink.f"

0x400 CONSTANT FILE_ATTRIBUTE_REPARSE_POINT
\ http://msdn.microsoft.com/en-us/library/gg258117.aspx

0xA000000C CONSTANT IO_REPARSE_TAG_SYMLINK
0xA0000003 CONSTANT IO_REPARSE_TAG_MOUNT_POINT
\ http://msdn.microsoft.com/en-us/library/dd541667.aspx

: FILENAME-REPARSE-TAG ( sd.filename -- 0 | x.tag )
  [: DUP dwFileAttributes T@ FILE_ATTRIBUTE_REPARSE_POINT AND 0= IF DROP 0 EXIT THEN dwReserved0 T@ ;] FOR-FILENAME-METADATA
;
: FILENAME-SYMLINK ( sd.filename -- flag )
  FILENAME-REPARSE-TAG  IO_REPARSE_TAG_SYMLINK =
;
: FILENAME-JUNCTION ( d-txt-filename -- flag )
\ The flag is true iff the filename is directory junction or volume mount point
  FILENAME-REPARSE-TAG  IO_REPARSE_TAG_MOUNT_POINT =
;




\ "./file-info-hardlink.f"

REQUIRE-WORD BHFI devel/~pinka/lib/win/file-information.f

: FILE-HARDLINKS-TOTAL ( fileid -- u ior )
  \ u is the number of hardlinks (at least 1 if successful)
  BHFI::/BY_HANDLE_FILE_INFORMATION RBUF DROP
  ( fileid a-addr.buf ) DUP ROT
  GetFileInformationByHandle IF BHFI::nNumberOfLinks T@  0 EXIT THEN
  DROP 0  GetLastError
;

: FILENAME-HARDLINKS-TOTAL ( sd.filename -- u )
  \ NB: it does not work for directories
  R/O OPEN-FILE-SHARED THROW DUP >R
  FILE-HARDLINKS-TOTAL  R> CLOSE-FILE  SWAP THROW THROW
;

SYNONYM FILENAME-HARDLINK FILENAME-HARDLINKS-TOTAL




\ "./file-info-size.f"

: WIDECHARZ>STRING ( addr.widecharZ -- addr.widechar u.bytes )
  DUP BEGIN DUP W@ 0<> WHILE 2+ REPEAT OVER -
;

: FILENAME-SIZE-SIMPLE ( sd.filename -- ud.size ) \ in bytes
  R/O OPEN-FILE-SHARED THROW DUP >R FILE-SIZE  R> CLOSE-FILE  SWAP THROW THROW
;

: FILENAME-SIZE ( sd.filename -- ud.size ) \ in bytes
  \ it throws an exception if a file is not found or the file is a symlink and cannot be opened (e.g., ERROR_ACCESS_DENIED)
  [: >R
    R@ nFileSizeLow   T@
    R@ nFileSizeHigh  T@
    [ 1 CELLS 8 < 0= ] [IF] 32 LSHIFT OR 0 [THEN] \ recombination if on a 64bit system
    2DUP D0= INVERT IF RDROP EXIT THEN
    \ the file size is zero (maybe a directory or symlink)
    R@ dwFileAttributes T@  FILE_ATTRIBUTE_REPARSE_POINT AND 0= IF RDROP EXIT THEN
    R@ dwReserved0      T@  IO_REPARSE_TAG_SYMLINK <> IF RDROP EXIT THEN
    \ the file is a symlink
    R> cFileNameW WIDECHARZ>STRING R:UTF16>UTF8 \ so, there is a double encoding conversion
    FILENAME-SIZE-SIMPLE
  ;] FOR-FILENAME-METADATA
;



\ #eof
