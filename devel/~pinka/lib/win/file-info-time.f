\ filetime via GetFileInformationByHandle
\ see also: ~ac/lib/win/file/filetime.f  (filetime via GetFileTime)

REQUIRE BHFI ~pinka/lib/win/file-information.f

: FILE-FILETIME-C ( h -- ftime-lo ftime-hi ior )
  \ Creation time
  BHFI::SIZE-CELLS DUP RALLOT SWAP >R
  ( h addr-buf ) DUP ROT
  GetFileInformationByHandle IF ( addr-buf )
  BHFI::ftCreationTime Q@ 0  ELSE
  DROP 0 0 GetLastError      THEN
  R> RFREE    
;
: FILE-FILETIME-W ( h -- ftime-lo ftime-hi ior )
  \ Write time
  BHFI::SIZE-CELLS DUP RALLOT SWAP >R
  ( h addr-buf ) DUP ROT
  GetFileInformationByHandle IF ( addr-buf )
  BHFI::ftLastWriteTime Q@ 0 ELSE
  DROP 0 0 GetLastError      THEN
  R> RFREE    
;
: FILE-FILETIME-A ( h -- ftime-lo ftime-hi ior )
  \ Access time
  BHFI::SIZE-CELLS DUP RALLOT SWAP >R
  ( h addr-buf ) DUP ROT
  GetFileInformationByHandle IF ( addr-buf )
  BHFI::ftLastAccessTime Q@ 0 ELSE
  DROP 0 0 GetLastError      THEN
  R> RFREE    
;
