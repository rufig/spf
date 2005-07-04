\ Обход каталога
\ Ю. Жиловец, 23.03.2004

REQUIRE { lib/ext/locals.f
REQUIRE " ~yz/lib/common.f

WINAPI: FindFirstFileA KERNEL32.DLL
WINAPI: FindNextFileA  KERNEL32.DLL
WINAPI: FindClose      KERNEL32.DLL

258 == MAX_PATH

0
CELL     -- :fAttr
2 CELLS  -- :fCreateTime
2 CELLS  -- :fAccessTime
2 CELLS  -- :fWriteTime
CELL     -- :fSizeHigh
CELL     -- :fSizeLow
CELL     -- :fRes1
CELL     -- :fRes2
MAX_PATH -- :fName
16       -- :fShortName
== #find-data

: is-dir? ( fd -- ?)  :fAttr @ 0x10 AND ;

: traverse-files { mask xt param \ fd h -- }
\ xt ( fd param -- )
  #find-data GETMEM TO fd
  fd mask FindFirstFileA TO h 
  h -1 = IF EXIT fd FREEMEM THEN
  BEGIN
    fd :fName C@ c: . <> IF
      fd param xt EXECUTE
    THEN
    fd h FindNextFileA
  0= UNTIL 
  h FindClose DROP
  fd FREEMEM
;

\EOF

: pfile . :fName .ASCIIZ CR ;

" *.f" ' pfile 0 traverse-files
