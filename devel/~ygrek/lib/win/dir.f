\ $Id$

REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE ITERATE-FILES ~profit/lib/iterate-files.f
REQUIRE ?WINAPI: ~ygrek/lib/win/winapi.f

?WINAPI: RemoveDirectoryA KERNEL32.DLL
?WINAPI: GetFileAttributesA KERNEL32.DLL
?WINAPI: SetFileAttributesA KERNEL32.DLL

ALSO ANSI-FILE

\ Remove empty directory
: DELETE-EMPTY-DIR ( a u -- ior ) >ZFILENAME DROP RemoveDirectoryA ERR ;

PREVIOUS

5 CONSTANT ERROR_ACCESS_DENIED
1 CONSTANT FILE_ATTRIBUTE_READONLY

\ If the file deletion fails due to r/o attribute
\ try to remove r/o and delete again (if it fails again - attribute is restored)
: DELETE-FILE-ALWAYS ( a u -- ior )
   { | name attrs }
   ANSI-FILE::>ZFILENAME DROP -> name
   name DeleteFileA IF 0 EXIT THEN
   GetLastError DUP ERROR_ACCESS_DENIED <> IF ( error ) EXIT THEN DROP
   \ probably because of r/o attribute?
   name GetFileAttributesA -> attrs
   attrs FILE_ATTRIBUTE_READONLY AND 0= IF ERROR_ACCESS_DENIED EXIT THEN
   \ if so - try to remove it
   attrs FILE_ATTRIBUTE_READONLY INVERT AND 
   name SetFileAttributesA 0= IF ERROR_ACCESS_DENIED EXIT THEN
   name DeleteFileA ERR
   \ failed to delete even without r/o - restore it
   DUP IF attrs FILE_ATTRIBUTE_READONLY OR name SetFileAttributesA DROP THEN 
   ( ior ) ;

\ Remove directory recursively
: DELETE-DIR ( a u -- )
   2DUP
   START{ 
    1 ITERATE-FILES NIP 
    IF
     RECURSE
    ELSE
     DELETE-FILE-ALWAYS DROP 
    THEN
   }EMERGE 
   DELETE-EMPTY-DIR DROP ;

\ TRUE if successfull
: DELETE-DIR? ( a u -- ? )
   2DUP DELETE-DIR
   FILE-EXIST 0= ;
