\ $Id$

REQUIRE LINUX-CONSTANTS lib/posix/const.f
REQUIRE module-((-fix ~ygrek/lib/linux/ffi.f

MODULE: MAPFILE

0
CELL -- :mapaddr
CELL -- :mapsize
CELL -- :mapfile
CONSTANT /mapping

: GETMEM ALLOCATE THROW ;
: FREEMEM FREE THROW ;

EXPORT

\ Get the mapped area
: MAPPED@ ( map -- a u ) DUP :mapaddr @ SWAP :mapsize @ ;

\ Close file and mapping
: CLOSE-FILE-MAP ( map -- )
   >R 
   R@ :mapfile @ CLOSE-FILE DROP
   (( R@ MAPPED@ )) munmap DROP ( 0 on success )
   R> FREEMEM ;

\ Open existing file and map it
: OPEN-FILE-MAP ( name-a name-n -- map -1 | err 0 ) 
   R/O OPEN-FILE IF DROP ( can't open file ) 1 0 EXIT THEN >R
   R@ FILE-SIZE IF R> CLOSE-FILE DROP ( can't get file size ) 2 0 EXIT THEN
   0 <> IF R> CLOSE-FILE DROP ( file is too big FIXME ) 3 0 EXIT THEN
   /mapping GETMEM DUP :mapfile R> SWAP ! >R
   R@ :mapsize !
   (( 0 R@ :mapsize @ PROT_READ MAP_SHARED R@ :mapfile @ 0 )) mmap 
   DUP MAP_FAILED = IF DROP R@ :mapfile CLOSE-FILE DROP R> FREEMEM ( can't mmap ) 4 0 EXIT THEN
   R@ :mapaddr !
   R> TRUE 
;

\ Create new file (always!) and map it
: CREATE-FILE-MAP ( name-a name-n size -- map -1 | err 0 )
  >R R/W CREATE-FILE IF DROP RDROP ( can't create file ) 1 0 EXIT THEN R@ SWAP >R
  DUP 1- S>D R@ REPOSITION-FILE IF DROP R> CLOSE-FILE DROP RDROP ( can't reposition ) 2 0 EXIT THEN
  PAD 1 R@ WRITE-FILE IF DROP R> CLOSE-FILE DROP RDROP ( can't write one byte ) 3 0 EXIT THEN
  0 SWAP 2 <( PROT_WRITE MAP_SHARED R@ 0 )) mmap
  DUP MAP_FAILED = IF R> RDROP CLOSE-FILE DROP ( can't map ) 4 0 EXIT THEN
  /mapping GETMEM DUP :mapfile R> SWAP ! R> SWAP >R SWAP
  R@ :mapaddr !
  R@ :mapsize !
  R> TRUE ;

;MODULE 
