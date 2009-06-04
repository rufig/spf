WINAPI: CreateFileMappingA KERNEL32.DLL
WINAPI: MapViewOfFileEx    KERNEL32.DLL
WINAPI: UnmapViewOfFile    KERNEL32.DLL

DECIMAL
4 CONSTANT PAGE_READWRITE
2 CONSTANT FILE_MAP_WRITE

HEX 83000000 DECIMAL VALUE MAP-BASE

: MAP-FILE ( mapbase size c-addr u -- fileid objid ior )
  OVER >R
  2DUP R/W OPEN-FILE      ( mapbase size c-addr u fileid ior )
  IF DROP R/W CREATE-FILE
  ELSE NIP NIP 0 THEN        ( mapbase size fileid ior )
  ?DUP IF NIP R> DROP EXIT THEN \ не удалось открыть/создать файл
                     ( mapbase size fileid )
  R> SWAP >R
  OVER               ( mapbase size name size )
  0                  ( mapbase size name sizelow sizehigh=0 )
  PAGE_READWRITE     \ protection
  0                  \ security
  R@                 \ fileid
  CreateFileMappingA
  DUP 0= IF R> 2DROP GetLastError EXIT THEN
                     ( mapbase size objid )
  >R                 ( R: fileid objid )
  0 0                \ offset
  FILE_MAP_WRITE     \ access
  R@                 \ objid
  MapViewOfFileEx
  IF R> R> SWAP 0
  ELSE R> R> GetLastError THEN
;
: UNMAP-FILE ( fileid objid mapbase -- ior )
  UnmapViewOfFile
  0= IF 2DROP GetLastError EXIT THEN
  CLOSE-FILE ?DUP IF NIP EXIT THEN
  CLOSE-FILE
;
