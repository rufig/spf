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
: FILE-FILETIME-W ( h -- d-filetime ior ) \ UTC ����� ���������� ��������� �����
  >R LastWriteTime LastAccessTime CreationTime R>
  GetFileTime IF LastWriteTime 2@ SWAP 0 ELSE 0 0 GetLastError THEN
;
: FILE-FILETIME ( h -- d-filetime ior ) \ UTC ����� �������� �����
  >R LastWriteTime LastAccessTime CreationTime R>
  GetFileTime IF CreationTime 2@ SWAP 0 ELSE 0 0 GetLastError THEN
;
: GET-FILETIME-WRITE ( h -- filetime ) \ UTC
  FILE-FILETIME-W DROP
;
: GET-FILETIME ( h -- filetime ) \ local time ��������� �����
                                 \ ��� ��������� ��� �������������
  GET-FILETIME-WRITE UTC>LOCAL
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
  GET-FILETIME FILETIME>TIME&DATE
;
: NOW-FILETIME ( -- filetime )
  0. SP@ ( a-filetime )
  GetSystemTimeAsFileTime 
  IF SWAP UTC>LOCAL ELSE 2DROP 0 0 THEN
;
: NOW-UTC-FILETIME ( -- filetime )
  0. SP@ ( a-filetime )
  GetSystemTimeAsFileTime 
  IF SWAP ELSE 2DROP 0 0 THEN
;
: NOW-FILETIME-UTC NOW-UTC-FILETIME ;

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
: CurrentDateTime#UTC 
  NOW-UTC-FILETIME FILETIME>TIME&DATE DateTime#GMT
;
: FILETIME-DD.MM.YYYY ( filetime -- addr u )
  UTC>LOCAL FILETIME>TIME&DATE
  S>D <# # # # # [CHAR] . HOLD 2DROP S>D # # [CHAR] . HOLD 2DROP S>D # # #> 2>R DROP 2DROP 2R>
;
: FILETIME-DD.MM.YYYY-HH:MM:SS ( filetime -- addr u ) \ LOCAL, ������ 12.03.2009 04:01:57
  UTC>LOCAL FILETIME>TIME&DATE
  ROT >R SWAP >R >R
  SWAP ROT
  S>D <#
  # # [CHAR] : HOLD
  2DROP S>D # # [CHAR] : HOLD
  2DROP S>D # # BL HOLD
  2DROP R> S>D # # # # [CHAR] . HOLD
  2DROP R> S>D # # [CHAR] . HOLD
  2DROP R> S>D # # #>
;
: DATETIME-UTC ( -- addr u ) \ �� ��, ��� � CurrentTimeRss � date/inixtime.f
  <<# CurrentDateTime#UTC #>
;
