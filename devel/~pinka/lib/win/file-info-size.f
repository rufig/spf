\ Reliably determine a file size
\ get the size of a target file in case of symlink

\ 2015-08-05

REQUIRE FILENAME-SYMLINK ~pinka/lib/win/file-info-symlink.f

: FILENAME-SIZE ( d-txt-filename -- d-size | 0 0 )
  \ it may throw ERROR_ACCESS_DENIED at the least
  0. 2SWAP \ size is zero if the file is not exists
  LAMBDA{ ( 0 0 addr u data )
    -ROT >R >R >R 2DROP
    R@ nFileSizeLow   T@
    R@ nFileSizeHigh  T@
    [ /CELL 8 < 0= ] [IF] 32 LSHIFT OR 0 [THEN] \ recombination in case of 64bits system
    2DUP D0= IF
    R@ dwFileAttributes T@ FILE_ATTRIBUTE_REPARSE_POINT AND IF
    R@ dwReserved0      T@ IO_REPARSE_TAG_SYMLINK = IF \ file is symlink
      2DROP
      RDROP R> R> R/O OPEN-FILE-SHARED THROW DUP >R FILE-SIZE THROW R> CLOSE-FILE THROW
      EXIT
    THEN THEN THEN
    RDROP RDROP RDROP
  } FOR-FILE1-PROPS
;
\ TODO: throw error in case of the file is not found #maybe

\ see also: ~ac/lib/win/file/filesize.f
