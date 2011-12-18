\ Determining whether a file has another hard links

REQUIRE BHFI ~pinka/lib/win/file-information.f

: FILE-HARDLINK ( h -- u ior )
\ returns hardlinks count (at least 1)
  BHFI::SIZE-CELLS DUP RALLOT SWAP >R
  ( h addr-buf ) DUP ROT
  GetFileInformationByHandle IF ( addr-buf )
  BHFI::nNumberOfLinks T@ 0  ELSE
  DROP 0 GetLastError        THEN
  R> RFREE    
;

: FILENAME-HARDLINK ( d-txt-filename -- u )
  R/O OPEN-FILE-SHARED THROW DUP >R
  FILE-HARDLINK R> CLOSE-FILE SWAP THROW THROW
;
