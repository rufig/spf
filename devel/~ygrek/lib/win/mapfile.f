\ $Id$
\ Отображение файлов
\ Ю. Жиловец, 6.04.2003
\ 
\ ~ygrek 2007
\ * fixed some bugs
\ * changed stack-effect and renamed words
\ + MAPPED@

MODULE: MAPFILE

WINAPI: CreateFileMappingA KERNEL32.DLL
WINAPI: MapViewOfFile      KERNEL32.DLL
WINAPI: UnmapViewOfFile    KERNEL32.DLL

0
CELL -- :mapaddr \ должен стоять первым (кстати зачем?)
CELL -- :mapsize
CELL -- :mapobj
CELL -- :mapfile
CONSTANT /mapping

: GETMEM ALLOCATE THROW ;
: FREEMEM FREE THROW ;

EXPORT

\ Get the mapped area
\ NB u is in symbols, because FILE-SIZE returns symbols
: MAPPED@ ( map -- a u ) DUP :mapaddr @ SWAP :mapsize @ ;

\ Open existing file and map it
: OPEN-FILE-MAP ( name-a name-n -- map -1 | err 0 ) 
  R/O OPEN-FILE IF DROP 1 0 EXIT THEN >R
  0 0 0 2 ( page_readonly) 0 R@ CreateFileMappingA
  ?DUP 0= IF R> CLOSE-FILE DROP 2 0 EXIT THEN
  /mapping GETMEM DUP :mapfile R> SWAP ! >R
  R@ :mapobj !
  R@ :mapfile @ FILE-SIZE OR ( bad ior or file is larger than 2GB )
  IF R@ :mapfile @ CLOSE-FILE R> FREEMEM 3 0 EXIT THEN
  R@ :mapsize !
  0 0 0 4 ( file_map_read) R@ :mapobj @ MapViewOfFile
  ?DUP 0= IF R@ :mapfile @ CLOSE-FILE DROP R> FREEMEM 4 0 EXIT THEN
  R@ ! R> TRUE ;

\ Create new file (always!) and map it
: CREATE-FILE-MAP ( name-a name-n size -- map -1 | err 0 )
  >R R/W CREATE-FILE IF DROP 1 0 EXIT THEN R@ SWAP >R
  0 SWAP 0 4 ( page_readwrite) 0 R@ CreateFileMappingA
  ?DUP 0= IF R> RDROP CLOSE-FILE DROP 2 0 EXIT THEN
  /mapping GETMEM DUP :mapfile R> SWAP ! R> SWAP >R SWAP
  R@ :mapobj !
  R@ :mapsize !
  0 0 0 2 ( file_map_write) R@ :mapobj @ MapViewOfFile
  ?DUP 0= IF R@ :mapfile @ CLOSE-FILE DROP R> FREEMEM 3 0 EXIT THEN
  R@ ! R> TRUE ;

\ Close file and mapping
: CLOSE-FILE-MAP ( map -- ) 
  DUP @ UnmapViewOfFile DROP
  DUP :mapobj @ CloseHandle DROP
  DUP :mapfile @ CLOSE-FILE DROP 
  FREEMEM ;

;MODULE
