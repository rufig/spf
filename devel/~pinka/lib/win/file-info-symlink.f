\ Determining whether a file is a symbolic link
\ see also: http://msdn.microsoft.com/en-us/library/aa363940.aspx

REQUIRE lexicon.basics-aligned  ~pinka/lib/ext/basics.f  \ to access fields via Q@ and T@

REQUIRE FOR-FILE1-PROPS ~ac/lib/win/file/fileprop.f
REQUIRE LAMBDA{         ~pinka/lib/lambda.f


0x400 CONSTANT FILE_ATTRIBUTE_REPARSE_POINT
\ http://msdn.microsoft.com/en-us/library/gg258117.aspx

0xA000000C CONSTANT IO_REPARSE_TAG_SYMLINK
\ http://msdn.microsoft.com/en-us/library/dd541667.aspx


: FILENAME-SYMLINK ( d-txt-filename -- flag )
  LAMBDA{ ( addr u data -- )
    >R 2DROP
    R@ dwFileAttributes T@ FILE_ATTRIBUTE_REPARSE_POINT AND 0= IF RDROP FALSE EXIT THEN
    R> dwReserved0      T@ IO_REPARSE_TAG_SYMLINK =
  } FOR-FILE1-PROPS
;
