\ Reliably determine a file size
\ get the size of a target file in case of symlink

\ 2015-08-05

REQUIRE FILENAME-SYMLINK ~pinka/lib/win/file-info-symlink.f

: FILENAME-SIZE ( sd-filename-full -- d-size | 0 0 )
  \ it may throw ERROR_ACCESS_DENIED at the least
  0. 2OVER \ size is zero if the file is not exists
  LAMBDA{ ( sd-filename-full 0 0 sd-filename-no-path data -- sd-filename x x )
    \ NB: sd-filename-no-path doesn't contain a path and so cannot be used here as is.
    >R 2DROP 2DROP
    R@ nFileSizeLow   T@
    R@ nFileSizeHigh  T@
    [ /CELL 8 < 0= ] [IF] 32 LSHIFT OR 0 [THEN] \ recombination in case of 64bits system
    2DUP D0= IF
    R@ dwFileAttributes T@ FILE_ATTRIBUTE_REPARSE_POINT AND IF
    R@ dwReserved0      T@ IO_REPARSE_TAG_SYMLINK = IF \ file is symlink
      2DROP
      2DUP R/O OPEN-FILE-SHARED THROW DUP >R FILE-SIZE THROW R> CLOSE-FILE THROW
    THEN THEN THEN
    RDROP
  } FOR-FILE1-PROPS  2NIP
;
\ TODO: throw error in case of the file is not found #maybe

\ see also: ~ac/lib/win/file/filesize.f
