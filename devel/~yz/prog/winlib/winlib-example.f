DIS-OPT \ для версий ниже 4.00 build 10
REQUIRE WINDOWS... ~yz/lib/winlib.f
SET-OPT

0 VALUE win
0 VALUE win2
0 VALUE times

\ -----------------------------------

PROC: quit
  winmain W: wm_close ?send DROP
PROC;

PROC: hello
  " Привет!" msg
PROC;

WINAPI: SelectObject GDI32.DLL
WINAPI: TextOutA GDI32.DLL

PROC: paint
  times windc SelectObject DROP
  " Привет всем!" ASCIIZ> SWAP 0 0 windc TextOutA DROP  
PROC;

\ Вложенное меню
MENU: inner
  hello MENUITEM Тоже привет 
MENU;

\ Основное меню
MENU: filemenu
  hello MENUITEM &Привет\tF5
  inner SUBMENU &Вложенное меню
  ' NOOP DISABLED MENUITEM Отключено
  LINE
  quit MENUITEM &Quit\tAlt-X
MENU;

MENU: mainmenu
  filemenu SUBMENU Файл
MENU;

\ -------------------------------------
MESSAGES: my

M: wm_contextmenu
  filemenu lparam LOWORD lparam HIWORD show-menu
  TRUE
M;

WINAPI: WinHelpA USER32.DLL

M: wm_help
  0 W: help_helponhelp 0 winmain -hwnd@ WinHelpA DROP
M;

MESSAGES;
\ -------------------------------------

\ Таблица быстрых клавиш
KEYTABLE
  hello ONKEY vk_f5
  quit  ONKEY alt+X
KEYTABLE;

WINAPI: CreateHatchBrush GDI32.DLL

: run
  WINDOWS...
  \ 0 - нет родительского окна
  0 create-window TO win
  \ Объявим главное окно, при закрытии которого программа завершится
  win TO winmain
  win dialog-window TO win2
  \ заголовки окон
  " Пример окна верхнего уровня" win -text!
  " Дочернее окно" win2 -text!
  \ размер и положение дочернего окна
  100 100 win2 winresize
  100 100 win2 winmove
  \ цвет дочернего окна
  win2 -bgbrush@ DeleteObject DROP
  blue >bgr W: hs_bdiagonal CreateHatchBrush win2 -bgbrush!
  \ добавить меню к основному окну
  mainmenu win attach-menubar
  \ создать шрифт
  " Times New Roman Cyr" 36 bold italic create-font TO times
  \ установить процедуру отрисовки окна
  paint win -painter!
  \ установить наш обработчик сообщений
  my win -wndproc!
  \ показать окна, поскольку по умолчанию они невидимые
  win wincenter
  win winshow
  win2 wincenter
  win2 winshow
  ...WINDOWS
  ." Программа завершилась"
  times delete-font
  BYE ;

\ 0 TO SPF-INIT?
 ' ANSI>OEM TO ANSI><OEM
\ TRUE TO ?GUI
\ ' run MAINX !
\ S" winlib-example.exe" SAVE  
run
BYE
