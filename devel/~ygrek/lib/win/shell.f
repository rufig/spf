REQUIRE CZMOVE ~yz/lib/common.f
REQUIRE single-method ~yz/lib/combase.f 
REQUIRE init->> ~yz/lib/data.f
REQUIRE { lib/ext/locals.f
REQUIRE [UNDEFINED] lib/include/tools.f

[UNDEFINED] MAX_PATH [IF]
 255 CONSTANT MAX_PATH
[THEN]

: MyWINAPI: 
   >IN @
     POSTPONE [DEFINED] IF DROP NextWord 2DROP EXIT THEN \ skip definition
   >IN !
   WINAPI:
  ;

MyWINAPI: SHBrowseForFolder   SHELL32.DLL
MyWINAPI: SHGetPathFromIDList SHELL32.DLL
MyWINAPI: SHGetMalloc         SHELL32.DLL
MyWINAPI: ShellExecuteA       SHELL32.DLL

5 single-method ::Free

\ Taken from ~yz/prog/tprint/tprint.f
\ Display the standard dialog for folder selection
\ xt ( a u -- ) \ a u - path to the folder selected
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

(
   W: SW_SHOW \ nShowCmd
   "" \ directory path empty
   0 \ no parameters for 'open'
   R> \ document path
   " open" \ open action
   winmain -hwnd@ \ window handle
   ShellExecuteA 33 < IF ." ShellExecute error" THEN ;
  )
