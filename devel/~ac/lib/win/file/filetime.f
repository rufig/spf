REQUIRE DateTime# ~ac/lib/win/date/date-int.f

WINAPI: SystemTimeToFileTime KERNEL32.DLL
WINAPI: FileTimeToSystemTime KERNEL32.DLL
WINAPI: GetFileTime          KERNEL32.DLL

USER CreationTime   4 USER-ALLOT
USER LastAccessTime 4 USER-ALLOT
USER LastWriteTime  4 USER-ALLOT

: GET-FILETIME ( h -- filetime )
  >R LastWriteTime LastAccessTime CreationTime R>
  GetFileTime IF LastWriteTime 2@ SWAP ELSE 0 0 THEN
;
: GET-FILE-LASTWRITETIME ( h -- filetime )
  >R 32 ALLOCATE THROW DUP DUP 8 + DUP 8 +
  ( LastWriteTime LastAccessTime CreationTime) R>
  GetFileTime
  IF >R /SYSTEMTIME ALLOCATE THROW DUP /SYSTEMTIME ERASE
     DUP R@ FileTimeToSystemTime DROP
     R> FREE DROP >R
     R@ wSecond W@
     R@ wMinute W@
     R@ wHour W@
     R@ wDay W@
     R@ wMonth W@
     R> wYear W@
  ELSE DROP 0 0 0 0 0 0 THEN
;

: NOW-FILETIME ( -- filetime )
  CreationTime
  TIME&DATE 2DROP 2DROP 2DROP SYSTEMTIME
  SystemTimeToFileTime
  IF CreationTime 2@ SWAP ELSE 0 0 THEN
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
