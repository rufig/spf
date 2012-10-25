\ Determining whether a file is a symbolic link
\ see also: http://msdn.microsoft.com/en-us/library/aa363940.aspx

REQUIRE lexicon.basics-aligned  ~pinka/lib/ext/basics.f  \ to access fields via Q@ and T@

REQUIRE FOR-FILE1-PROPS ~ac/lib/win/file/fileprop.f
REQUIRE LAMBDA{         ~pinka/lib/lambda.f


0x400 CONSTANT FILE_ATTRIBUTE_REPARSE_POINT
\ http://msdn.microsoft.com/en-us/library/gg258117.aspx

0xA000000C CONSTANT IO_REPARSE_TAG_SYMLINK
\ http://msdn.microsoft.com/en-us/library/dd541667.aspx

: FILENAME-REPARSE-TAG ( d-txt-filename -- 0|u )
  0 -ROT \ 0 if the file is not exists
  LAMBDA{ ( 0 addr u data -- flag )
    >R 2DROP DROP
    R@ dwFileAttributes T@ FILE_ATTRIBUTE_REPARSE_POINT AND 0= IF RDROP 0 EXIT THEN
    R> dwReserved0      T@
  } FOR-FILE1-PROPS
  \ may be throw 3 ERROR_PATH_NOT_FOUND ?
;
: FILENAME-SYMLINK ( d-txt-filename -- flag )
  FILENAME-REPARSE-TAG
    IO_REPARSE_TAG_SYMLINK =
;
