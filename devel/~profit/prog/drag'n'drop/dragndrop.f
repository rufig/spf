WINAPI: DragAcceptFiles shell32
WINAPI: DragQueryFile shell32

REQUIRE GRID ~yz/lib/winctl.f

CREATE tmp 100 ALLOT

MESSAGES: win-messages


M: wm_dropfiles
100 tmp 0xFFFFFFFF wparam DragQueryFile 0
DO 
100 tmp I wparam DragQueryFile 
tmp SWAP CR TYPE LOOP
M;

MESSAGES;


: run 
WINDOWS...

0 (* WS_BORDER WS_CAPTION WS_SYSMENU WS_VISIBLE *) 0 create-window-with-styles TO winmain
W: COLOR_BTNFACE syscolor winmain -bgcolor!
1 winmain -hwnd@ DragAcceptFiles DROP \ указываем на то что на окно можно сбрасывть файлы

" Заголовок" winmain -text!
GRID
" Сбрасывай сюда файлы" label -xspan -yspan |
===
GRID; winmain -grid!

285 200 winmain  winresize
winmain winshow

win-messages winmain -wndproc!

...WINDOWS
BYE ;

\ 0 TO SPF-INIT?
\ ' ANSI>OEM TO ANSI><OEM
\ TRUE TO ?GUI
\ ' run MAINX !
\ S" 2butts.exe" SAVE  

 run 