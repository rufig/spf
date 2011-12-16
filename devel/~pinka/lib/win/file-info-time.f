\ filetime via GetFileInformationByHandle
\ see also: ~ac/lib/win/file/filetime.f  (filetime via GetFileTime)

REQUIRE BY_HANDLE_FILE_INFORMATION_CELLS ~pinka/lib/win/file-information.f

: FILE-FILETIME-C ( h -- ftime-lo ftime-hi ior )
  \ Creation time
  BY_HANDLE_FILE_INFORMATION_CELLS DUP RALLOT SWAP >R
  ( h addr-buf ) DUP ROT
  GetFileInformationByHandle IF ( addr-buf )
  ftCreationTime Q@ 0        ELSE
  DROP 0 0 GetLastError      THEN
  R> RFREE    
;
: FILE-FILETIME-W ( h -- ftime-lo ftime-hi ior )
  \ Write time
  BY_HANDLE_FILE_INFORMATION_CELLS DUP RALLOT SWAP >R
  ( h addr-buf ) DUP ROT
  GetFileInformationByHandle IF ( addr-buf )
  ftLastWriteTime Q@ 0       ELSE
  DROP 0 0 GetLastError      THEN
  R> RFREE    
;
: FILE-FILETIME-A ( h -- ftime-lo ftime-hi ior )
  \ Access time
  BY_HANDLE_FILE_INFORMATION_CELLS DUP RALLOT SWAP >R
  ( h addr-buf ) DUP ROT
  GetFileInformationByHandle IF ( addr-buf )
  ftLastAccessTime Q@ 0      ELSE
  DROP 0 0 GetLastError      THEN
  R> RFREE    
;
