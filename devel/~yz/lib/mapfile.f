\ Отображение файлов
\ Ю. Жиловец, 6.04.2003

MODULE: MAPFILE

REQUIRE " ~yz/lib/common.f

WINAPI: CreateFileMappingA KERNEL32.DLL
WINAPI: MapViewOfFile      KERNEL32.DLL
WINAPI: UnmapViewOfFile    KERNEL32.DLL

0
CELL -- :mapaddr \ должен стоять первым
CELL -- :mapobj
CELL -- :mapfile
== /mapping

EXPORT

: MAP-OPEN ( name-a name-n -- map/0 ) 
  R/O OPEN-FILE IF DROP 0 EXIT THEN >R
  0 0 0 2 ( page_readonly) 0 R@ CreateFileMappingA
  ?DUP 0= IF R> CLOSE-FILE DROP 0 THEN
  /mapping GETMEM DUP :mapfile R> SWAP ! >R
  R@ :mapobj !
  0 0 0 4 ( file_map_read) R@ :mapobj @ MapViewOfFile
  ?DUP 0= IF R@ :mapfile @ CLOSE-FILE DROP R> FREEMEM 0 EXIT THEN
  R@ ! R> ;

: MAP-CREATE ( name-a name-n size -- map/0 )
  >R R/W CREATE-FILE IF DROP 0 EXIT THEN R> SWAP >R
  0 SWAP 0 4 ( page_readwrite) 0 R@ CreateFileMappingA
  ?DUP 0= IF R> CLOSE-FILE DROP 0 THEN
  /mapping GETMEM DUP :mapfile R> SWAP ! >R
  R@ :mapobj !
  0 0 0 2 ( file_map_write) R@ :mapobj @ MapViewOfFile
  ?DUP 0= IF R@ :mapfile @ CLOSE-FILE DROP R> FREEMEM 0 EXIT THEN
  R@ ! R> ;

: MAP-CLOSE ( map -- ) 
  DUP @ UnmapViewOfFile DROP
  DUP :mapobj @ CloseHandle DROP
  DUP :mapfile @ CLOSE-FILE DROP 
  FREEMEM ;

;MODULE
