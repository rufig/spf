REQUIRE DateTime# ~ac/lib/win/date/date-int.f

WINAPI: SystemTimeToFileTime KERNEL32.DLL
WINAPI: FileTimeToSystemTime KERNEL32.DLL
WINAPI: GetFileTime          KERNEL32.DLL
WINAPI: FileTimeToLocalFileTime KERNEL32.DLL
WINAPI: GetSystemTimeAsFileTime KERNEL32.DLL

USER CreationTime   4 USER-ALLOT
USER LastAccessTime 4 USER-ALLOT
USER LastWriteTime  4 USER-ALLOT


: UTC>LOCAL ( filetime1 -- filetime2 )  \ ( filetime ) is ( tlo thi )
  SWAP SP@ DUP FileTimeToLocalFileTime
  0= IF 2DROP 0 0 THEN SWAP
;
: GET-FILETIME-WRITE ( h -- filetime ) \ UTC
  >R LastWriteTime LastAccessTime CreationTime R>
  GetFileTime IF LastWriteTime 2@ SWAP ELSE 0 0 THEN
;
: GET-FILETIME ( h -- filetime ) \ local time
  GET-FILETIME-WRITE DUP IF UTC>LOCAL THEN
;
: FILETIME>TIME&DATE ( tlo thi -- sec min hr day mt year )
  SWAP SP@  ( filetime )
  /SYSTEMTIME ALLOCATE THROW DUP /SYSTEMTIME ERASE DUP >R
  SWAP
  FileTimeToSystemTime DROP
  2DROP
     R@ wSecond W@
     R@ wMinute W@
     R@ wHour   W@
     R@ wDay    W@
     R@ wMonth  W@
     R@ wYear   W@
  R> FREE THROW
;
: GET-FILE-LASTWRITETIME ( h -- sec min hr day mt year )
  GET-FILETIME-WRITE  UTC>LOCAL FILETIME>TIME&DATE
;
: NOW-FILETIME ( -- filetime )
  0. SP@ ( a-filetime )
  GetSystemTimeAsFileTime 
  IF SWAP UTC>LOCAL ELSE 2DROP 0 0 THEN
;
6 6 * 24 * CONSTANT NS-IN-DAY

: DAYS-OLD ( h -- days )
  >R NOW-FILETIME R> GET-FILETIME DNEGATE D+
  DUP 0< IF 2DROP 0 0 THEN
  4000000000 UM/MOD NIP
  4 NS-IN-DAY */
;
: DELETE-IF-OLDER ( filename days -- flag )
  >R
  2DUP R/O OPEN-FILE
  IF DROP 2DROP R> DROP FALSE
  ELSE DUP DAYS-OLD R> > SWAP CLOSE-FILE DROP
       IF DELETE-FILE DROP TRUE
       ELSE 2DROP FALSE THEN
  THEN
;
: FileDateTime# ( h -- )
  GET-FILE-LASTWRITETIME DateTime#
;
: FileDateTime#GMT ( h -- )
  GET-FILE-LASTWRITETIME DateTime#GMT
;
