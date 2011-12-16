\ filetime via GetFileInformationByHandle
\ see also: ~ac/lib/win/file/filetime.f  (filetime via GetFileTime)

REQUIRE BY_HANDLE_FILE_INFORMATION_CELLS ~pinka/lib/win/file-information.f

: FILE-HARDLINK ( h -- u ior )
  \ Hardlinks count (at least 1)
  BY_HANDLE_FILE_INFORMATION_CELLS DUP RALLOT SWAP >R
  ( h addr-buf ) DUP ROT
  GetFileInformationByHandle IF ( addr-buf )
  nNumberOfLinks T@ 0        ELSE
  DROP 0 GetLastError        THEN
  R> RFREE    
;

: FILENAME-HARDLINK ( d-txt-filename -- u )
  R/O OPEN-FILE-SHARED THROW DUP >R
  FILE-HARDLINK R> CLOSE-FILE SWAP THROW THROW
;
