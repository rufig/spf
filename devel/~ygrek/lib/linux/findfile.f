\ $Id$
\ 
\ FIND-FILES and FIND-FILES-R words compatible with ~ac/lib/win/file/findfile-r.f

\ REQUIRE MemReport ~day/lib/memreport.f

REQUIRE ANSI-FILE lib/include/ansi-file.f
REQUIRE CEQUAL ~pinka/spf/string-equal.f
REQUIRE LINUX-CONSTANTS lib/posix/const.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE KEEP! ~profit/lib/bac4th.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f

: IS..? ( a u -- ? )
  2DUP S" .." CEQUAL IF 2DROP TRUE EXIT THEN
       S" ." CEQUAL ;

: IS-DIR? ( dirent -- ? ) OFFSETOF_D_TYPE + B@ DT_DIR = ;

\ readdir(3) wrapper
: READDIR ( a u xt -- ) \ xt: ( a u data dir? -- ) \ a u -- only filename
  >R
  ANSI-FILE::>ZFILENAME DROP 1 <( )) opendir
  DUP 0= IF DROP RDROP EXIT THEN
  BEGIN
   DUP 1 <( )) readdir ?DUP 
  WHILE
   ( dirent )
   DUP OFFSETOF_D_NAME + ASCIIZ> 
   2DUP IS..? IF 2DROP DROP ELSE ( a u ) ROT DUP IS-DIR? R@ EXECUTE THEN
  REPEAT
  RDROP
  1 <( )) closedir DROP ;

USER _xt
USER _dir

\ quick and dirty
\ FIXME if xt throws exception -- _dir is not STRFREE'd
: FIND-FILES ( a u xt -- )  
  OVER 0 = IF 2DROP DROP EXIT THEN
  _xt KEEP!
  >STR _dir KEEP!
  _dir @ STR@ 1- + C@ [CHAR] / <> IF S" /" _dir @ STR+ THEN
  _dir @ STR@ LAMBDA{ 2SWAP _dir @ STR@ " {s}{s}" >R R@ STR@ 2SWAP _xt @ EXECUTE R> STRFREE } READDIR 
  _dir @ STRFREE
  ;

: FIND-FILES-R ( a u xt -- )
  TRUE ABORT" not implemented"
  ;

/TEST

\ print all files in current directory
S" ." :NONAME ( a u data dir? -- ) . DROP TYPE CR ; READDIR

\ test reenterability
S" ~ygrek/spf" FIND-FULLNAME :NONAME NIP IF LAMBDA{ ." | " . DROP TYPE CR } FIND-FILES ELSE TYPE CR THEN ; FIND-FILES

[DEFINED] MemReport [IF]
MemReport
[THEN]

