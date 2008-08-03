\ $Id$
\ 
\ see lib/posix/file.f

REQUIRE CREATE-MAP-FILE ~ygrek/lib/linux/mapfile.f
REQUIRE { lib/ext/locals.f

: COPY-FILE-OVER ( src-a src-u  dest-a dest-u -- ior )
  { | src dest }
  2SWAP OPEN-FILE-MAP 0= IF NIP NIP EXIT THEN 
  -> src
  ( a u ) src MAPPED@ NIP CREATE-FILE-MAP 0= IF src CLOSE-FILE-MAP EXIT THEN
  -> dest
  
  src MAPPED@ dest MAPPED@ DROP SWAP MOVE

  src CLOSE-FILE-MAP
  dest CLOSE-FILE-MAP
  0 ;

