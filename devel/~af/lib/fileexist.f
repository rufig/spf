\ $Id$
WINAPI: GetFileAttributesA   KERNEL32.DLL

: FileExist ( addr u -- flag )
  DROP GetFileAttributesA -1 <>
;
