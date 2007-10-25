\ $Id$

REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE ITERATE-FILES ~profit/lib/iterate-files.f

\ FIXME DELETE-FILE fails to delete read-only files

WINAPI: RemoveDirectoryA KERNEL32.DLL

ALSO ANSI-FILE

\ Remove empty directory
: DELETE-EMPTY-DIR ( a u -- ior ) >ZFILENAME DROP RemoveDirectoryA ERR ;

PREVIOUS

\ Remove directory recursively
: DELETE-DIR ( a u -- )
   2DUP
   START{ 
    1 ITERATE-FILES NIP 
    IF
     RECURSE
    ELSE
     DELETE-FILE DROP 
    THEN
   }EMERGE 
   DELETE-EMPTY-DIR DROP ;

\ TRUE if successfull
: DELETE-DIR? ( a u -- ? )
   2DUP DELETE-DIR
   FILE-EXIST 0= ;
