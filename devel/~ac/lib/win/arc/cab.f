\ http://msdn.microsoft.com/en-us/library/ff797925%28v=VS.85%29.aspx

REQUIRE {      lib\ext\locals.f
REQUIRE DLOPEN ~ac/lib/ns/dlopen.f

: MSVCRT ( a u -- addr )
  S" MSVCRT.DLL" DLOPEN DLSYM
;

0
  4 -- cab.cb                 \ Maximum cabinet size in bytes
  4 -- cab.cbFolderThresh     \ Maximum folder size in bytes
  4 -- cab.cbReservesCFHeader
  4 -- cab.cbReserveCFFolder
  4 -- cab.cbReserveCFData
  4 -- cab.iCab        \ Number of this cabinet in a set
  4 -- cab.iDisk       \ Disk number
  4 -- cab.fFailOnIncompressible \ TRUE => Fail if a block is incompressible
  2 -- cab.setID       \ Cabinet set ID
256 -- cab.szDisk    \ [CB_MAX_DISK_NAME];
256 -- cab.szCab     \ [CB_MAX_CABINET_NAME];
256 -- cab.szCabPath \ [CB_MAX_CAB_PATH];
CONSTANT /CCAB

0
CELL -- erf.erfOper
CELL -- erf.erfType
   1 -- erf.fError
CONSTANT /ERF

WINAPI: GetCurrentDirectoryA KERNEL32.DLL
\ WINAPI: GetTempFileNameA     KERNEL32.DLL
\ WINAPI: GetTempPathA         KERNEL32.DLL

WINAPI: FCICreate       CABINET.DLL
WINAPI: FCIAddFile      CABINET.DLL
WINAPI: FCIFlushCabinet CABINET.DLL
WINAPI: FCIDestroy      CABINET.DLL

WINAPI: _open MSVCRT.DLL

\ 0x0000 CONSTANT _O_RDONLY
0x8000 CONSTANT _O_BINARY


1 CONSTANT tcompTYPE_MSZIP
VARIABLE _TMPN

:NONAME { pv cbTempName pszTempName -- void }
  
  pv cbTempName pszTempName

  _TMPN 1+!
  _TMPN @ S>D <# 0 HOLD [CHAR] _ HOLD #S [CHAR] z HOLD #>
  pszTempName SWAP MOVE
  1

( \ этот вариант не подходит для _open
  pszTempName cbTempName ERASE
  PAD 256 GetTempPathA
  IF pszTempName 0 S" CABINET" DROP PAD GetTempFileNameA ." OK:" .
     1
  ELSE FALSE THEN
)

; 3 CELLS CALLBACK: fnGetTempFileName

:NONAME ( pv fCont cb1 pszFile pccab -- void )
  \ ." file=" OVER ASCIIZ> TYPE CR
  0
; 5 CELLS CALLBACK: fnFilePlaced

:NONAME { pv err pattr ptime pdate pszName -- void }
  pv err pattr ptime pdate pszName
  _O_BINARY pszName ( S" _open" MSVCRT API-CALL) _open NIP NIP
  pattr 0! ptime 0! pdate 0! \ 1617 год :)
; 6 CELLS CALLBACK: fnGetOpenInfo

:NONAME ( pv cb1 cb2 typeStatus -- void )
  FALSE
; 4 CELLS CALLBACK: fnStatus

:NONAME
  0 EXIT
( \ не вызывается для однофайлового кабинета
  { pv cbPrevCab pccab -- void }
  CR ." ===========fnGetNextCabinet:" SP@ . 
  pv cbPrevCab DUP . pccab
  S" test.cab" pccab cab.szCab SWAP 1+ MOVE
  1
)
; 3 CELLS CALLBACK: fnGetNextCabinet

: CabCreate { a u \ c er -- fci }
  /CCAB ALLOCATE THROW -> c
  100000000 c cab.cb !
  100000000 c cab.cbFolderThresh !
  555 c cab.setID W!
  1 c cab.iCab !
  0 c cab.iDisk !
  c cab.szCabPath 256 GetCurrentDirectoryA
  IF [CHAR] \ c cab.szCabPath ASCIIZ> + C! THEN

  a u c cab.szCab SWAP 1+ MOVE

  /ERF ALLOCATE THROW -> er

  0 c
  ['] fnGetTempFileName
  S" _unlink" MSVCRT \ ['] fnFileDelete
  S" _lseek"  MSVCRT \ ['] fnFileSeek
  S" _close"  MSVCRT \ ['] fnFileClose
  S" _write"  MSVCRT \ ['] fnFileWrite
  S" _read"   MSVCRT \ ['] fnFileRead
  S" _open"   MSVCRT \ ['] fnFileOpen
  S" free"    MSVCRT \ ['] fnMemFree
  S" malloc"  MSVCRT \ ['] fnMemAlloc
  ['] fnFilePlaced
  er FCICreate 13 0 DO NIP LOOP
;
: CabAddFile { a u ta tu fci -- flag }
  tcompTYPE_MSZIP
  ['] fnGetOpenInfo
  ['] fnStatus
  ['] fnGetNextCabinet
  FALSE
  ta
  a
  fci FCIAddFile 8 0 DO NIP LOOP
;
: CabClose { fci -- }
  ['] fnStatus
  ['] fnGetNextCabinet
  FALSE
  fci
  FCIFlushCabinet NIP NIP NIP NIP
  DROP

  fci FCIDestroy 2DROP

  \ а /CCAB и /ERF утекают до конца потока
;

\EOF

: TEST { \  fci }

  S" spf_test.cab" CabCreate -> fci
  fci
  IF
    S" tar/tar.f"   S" arc/tar.f"  fci CabAddFile
    S" gzip/zlib.f" S" arc/zlib.f" fci CabAddFile +
    S" cab.f"       S" cab.f"      fci CabAddFile +
    .
    fci CabClose
  THEN
;
TEST CR

~ac/lib/win/file/findfile-r.f 

USER FCI
USER CNT

: (CabAdd) ( addr u data flag -- )
  CNT @ 10000 > OR IF DROP 2DROP EXIT THEN
  DROP
  2DUP + 2 - 2 S" .f" COMPARE IF 2DROP EXIT THEN
  2DUP TYPE CR
  2DUP 19 - SWAP 19 + SWAP FCI @ CabAddFile CNT +!
  DEPTH .
;

: TEST2 { \  fci }

  S" spf_test2.cab" CabCreate -> fci
  fci FCI !
  S" /spf4/devel/~ac/lib" ['] (CabAdd) FIND-FILES-R
  fci CabClose
;
TEST2
