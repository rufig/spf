\ $Id$
\ 
\ Testing readdir()

REQUIRE ADD-CONST-VOC lib/ext/const.f
REQUIRE ANSI-FILE lib/include/ansi-file.f

S" lib/posix/const/linux.const" ADD-CONST-VOC

: FINDFILES ( a u xt -- ) \ xt: ( a u data -- )
  >R
  ANSI-FILE::>ZFILENAME DROP 1 <( )) opendir
  DUP 0= IF RDROP EXIT THEN
  BEGIN
   DUP 1 <( )) readdir ?DUP 
  WHILE
   ( dirent )
   DUP OFFSETOF_D_NAME + ASCIIZ> ROT R@ EXECUTE
  REPEAT
  RDROP
  1 <( )) closedir DROP ;

S" ." :NONAME ( a u data -- ) DROP TYPE CR ; FINDFILES  

