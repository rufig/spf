\ 20.Jul.2002 Sat 14:02

REQUIRE @FTime ~pinka\lib\ftime.f

WINAPI: GetFileInformationByHandle KERNEL32.DLL (
    LPBY_HANDLE_FILE_INFORMATION lpFileInformation  // address of structure 
    HANDLE hFile,   // handle of file 
  -- BOOL )   

2 CELLS CONSTANT /FILETIME

MODULE: BY_HANDLE_FILE_INFORMATION

0 \ typedef struct _BY_HANDLE_FILE_INFORMATION // bhfi  
 1 CELLS --   dwFileAttributes 
 /FILETIME -- ftCreationTime
 /FILETIME -- ftLastAccessTime
 /FILETIME -- ftLastWriteTime
 1 CELLS --   dwVolumeSerialNumber
 1 CELLS --   nFileSizeHigh
 1 CELLS --   nFileSizeLow
 1 CELLS --   nNumberOfLinks
 1 CELLS --   nFileIndexHigh
 1 CELLS --   nFileIndexLow

CONSTANT /BY_HANDLE_FILE_INFORMATION

;MODULE

ALSO BY_HANDLE_FILE_INFORMATION

: FILE-CTIME ( h -- ftime-lo ftime-hi ior )
  /BY_HANDLE_FILE_INFORMATION RALLOT DUP ROT
  GetFileInformationByHandle IF ( a )
  ftCreationTime @FTime 0    ELSE
  DROP 0 0 GetLastError      THEN
  /BY_HANDLE_FILE_INFORMATION RFREE    
;
: FILE-WTIME ( h -- ftime-lo ftime-hi ior )
  /BY_HANDLE_FILE_INFORMATION RALLOT DUP ROT
  GetFileInformationByHandle IF ( a )
  ftLastWriteTime @FTime 0   ELSE
  DROP 0 0 GetLastError      THEN
  /BY_HANDLE_FILE_INFORMATION RFREE    
;
: FILE-ATIME ( h -- ftime-lo ftime-hi ior )
  /BY_HANDLE_FILE_INFORMATION RALLOT DUP ROT
  GetFileInformationByHandle IF ( a )
  ftLastAccessTime @FTime 0  ELSE
  DROP 0 0 GetLastError      THEN
  /BY_HANDLE_FILE_INFORMATION RFREE    
;

PREVIOUS