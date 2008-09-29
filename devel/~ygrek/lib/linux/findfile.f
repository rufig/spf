\ $Id$
\ 
\ interface compatible with ~ac/lib/win/file/findfile-r.f
\ FIND-FILES ( a u xt -- )
\ a u -- directory to enumerate files in
\ xt ( a u data dir? -- )
\ a u -- path
\ data -- implementation defined information about entry
\ dir? -- true if directory

REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE CEQUAL ~pinka/spf/string-equal.f
REQUIRE LINUX-CONSTANTS lib/posix/const.f
REQUIRE /TEST ~profit/lib/testing.f

: IS..? ( a u -- ? )
  2DUP S" .." CEQUAL IF 2DROP TRUE EXIT THEN
       S" ." CEQUAL ;

: IS-DIR? ( dirent -- ? ) OFFSETOF_D_TYPE + B@ DT_DIR = ;

: FIND-FILES ( a u xt -- ) \ xt: ( a u data dir? -- )
  >R
  ANSI-FILE::>ZFILENAME DROP 1 <( )) opendir
  DUP 0= IF RDROP EXIT THEN
  BEGIN
   DUP 1 <( )) readdir ?DUP 
  WHILE
   ( dirent )
   DUP OFFSETOF_D_NAME + ASCIIZ> 
   2DUP IS..? IF 2DROP DROP ELSE ( a u ) ROT DUP IS-DIR? R@ EXECUTE THEN
  REPEAT
  RDROP
  1 <( )) closedir DROP ;

: FIND-FILES-R ( a u xt -- )
  TRUE ABORT" not implemented"
  FIND-FILES
  ;

/TEST

S" ." :NONAME ( a u data dir? -- ) . DROP TYPE CR ; FIND-FILES

