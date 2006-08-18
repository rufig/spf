\ Taken from ~yz/prog/tprint/tprint.f

REQUIRE single-method ~yz/lib/combase.f 
REQUIRE { lib/ext/locals.f
REQUIRE [UNDEFINED] lib/include/tools.f

[UNDEFINED] MAX_PATH [IF]
 255 CONSTANT MAX_PATH
[THEN]

WINAPI: SHBrowseForFolder   SHELL32.DLL
WINAPI: SHGetPathFromIDList SHELL32.DLL
WINAPI: SHGetMalloc         SHELL32.DLL

5 single-method ::Free

\ xt ( a u -- )
: ShellGetDir { prompt hwnd xt \ shmalloc [ 8 CELLS ] binfo [ MAX_PATH ] dirname }
  binfo init->>
  hwnd >>      \ window handle
  0 >>         \ PIDL root
  dirname >>   \ buffer for display name
  prompt >>    \ prompt
  0x9 >> \ flags ( return only file system directories)
  0 >>   \ callback
  0 >>   \ userdata
  0 >>   \ image number
  binfo SHBrowseForFolder ?DUP IF
    DUP dirname SWAP SHGetPathFromIDList DROP
    dirname ASCIIZ> xt EXECUTE
    \ теперь надо освободить возвращенный PIDL
    \ делается это, как и все в Майкрософте, через извращение
    ^ shmalloc SHGetMalloc DROP
    shmalloc ::Free DROP
    shmalloc release
  THEN
;

