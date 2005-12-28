( Салфетка Улама

  yGREK heretix  
  heretix@yandex.ru
  18.Mar.2005 
)

\ 11.Jun.2005  ~ygrek
\ Теперь работает и под WinNT

\ 18.Jun.2005 ~ygrek
\ Считает в потоке

REQUIRE GetDC  ~ygrek/lib/data/windows.f
WARNING 0!
REQUIRE button ~yz/lib/winctl.f
REQUIRE ENUM   ~ygrek/lib/enum.f

:NONAME 0 VALUE ; ENUM values

values
 win maxX maxY cx cy memDC hDC limit start
;

VARIABLE done

VECT number 

: RGB2CR ( r g b -- u )
         ( Convert RGB to COLORREF
           see BC5\INCLUDE\WINSYS\color.h )
 0xFF AND 16 LSHIFT -ROT
 0xFF AND  8 LSHIFT -ROT
 0xFF AND  OR OR
;

: ClearMemDC 
   W: white_brush GetStockObject memDC SelectObject DROP
   W: patcopy maxY maxX 0 0 memDC PatBlt DROP
;

: CreateMemDC  
   \ образ экрана в памяти и будем все операции рисования делать
   \ только в memDC
   W: sm_cxscreen GetSystemMetrics TO maxX
   W: sm_cyscreen GetSystemMetrics TO maxY
   hDC CreateCompatibleDC TO memDC
   maxY maxX hDC CreateCompatibleBitmap ( hbit ) memDC SelectObject DROP
   ClearMemDC
;

: white 255 255 255 ; 
: black 0 0 0 ;

: pixel ( x y r g b -- )
   RGB2CR ( x y CR ) -ROT SWAP ( CR y x ) memDC SetPixel DROP
;

: number-hor ( num -- x y )
   maxX /MOD 
;

: number-even { n i \ -- x y }
   n i i * i - < IF
    cx i 2/ - 
    cy i 2/ - 1+ n i 1- MOD +
   ELSE
    cx i 2/ - n i MOD +
    cy i 2/ +
   THEN
;

: number-odd { n i \ -- x y }
   i 1- TO i
   n i i * i + < IF
    cx i 2/ + 
    cy i 2/ + n i MOD -
   ELSE
    cx i 2/ + n i 1+ MOD -
    cy i 2/ -
   THEN
;


: number-spiral ( num -- x y )
   start -
   DUP 0 < IF DROP cx cy EXIT THEN
   limit 2/ 1 DO
    DUP I I * < IF I LEAVE THEN
   LOOP
  ( n i )
  DUP  1 AND IF number-odd ELSE number-even THEN
;

: message ( i -- z )
   4 MOD
   DUP 0 = IF DROP " Считаю" EXIT THEN
   DUP 1 = IF DROP " Считаю Считаю" EXIT THEN
   DUP 2 = IF DROP " Считаю Считаю Считаю" EXIT THEN
   DROP
   " Считаю Считаю Считаю Считаю"
;

:NONAME ( win -- )
  done 0!
  limit 2/ 2 DO \ бежим по числам до половины
   I 2 *
   BEGIN \ бежим по всем кратным
    DUP limit <
   WHILE
    DUP ( num )
    number black pixel \ и ставим на их место чёрную точку
    I +
   REPEAT
   DROP
   DUP I message 0 ROT set-status
  LOOP
  TRUE done !  \ флажок - посчитали
  DUP force-redraw \ отрисовали
  >R " Готово." 0 R> set-status \ сообщили
; TASK: calculate


\ -----------------------------------

PROC: quit
  " Выход" 0 win set-status
  W: wm_close winmain send DROP
PROC;

PROC: paint 
 done @ 0= IF EXIT THEN \ если ещё недосчитали то не будем обгрызки выводить
 W: srccopy 0 0 memDC maxY maxX 0 0 hDC BitBlt DROP \ из памяти на экран
PROC;

PROC: draw { \ e_num e_start buf -- }
   " Настройки" 0 win set-status
   10 ALLOCATE THROW TO buf
   " Настройки" MODAL...
     GRID
       filler 200 1 this ctlresize | 
      ===
       " Всего точек: " label -xfixed |
       edit -xspan 
       this TO e_num 
       10 this limit-edit |
      ===
       " Начинать с: " label -xfixed |
       edit -xspan
       this TO e_start 
       10 this limit-edit |
      ===
      "    Ok   " ['] dialog-ok ok-button -right | 
      " Отмена" cancel-button |
     GRID; 
      limit S>D <# #S #> DROP e_num -text!
      start S>D <# #S #> DROP e_start -text!
     SHOW
      dialog-termination W: IDOK =
       IF 
     buf e_num -text@
     0 0 buf e_num -text# >NUMBER IF DROP 2DROP ELSE DROP D>S TO limit THEN
     buf e_start -text@
     0 0 buf e_start -text# >NUMBER IF DROP 2DROP ELSE DROP D>S TO start THEN

    ClearMemDC
    win calculate START DROP
       THEN
   ...MODAL
   "" 0 win set-status
PROC;

PROC: about { \ e -- }
 " Инфа" MODAL...
  GRID
   multiedit 
   400 200 this ctlresize 
   this TO e 
   this windisable |
  GRID;
   " Называется точно не помню или 'Салфетка Улама' \r\n или 'Улитка Улама'. Смысл в том что числовая ось \r\n рисуется не по прямой, а по спирали.\r\n Простые числа отмечаются белыми точками,\r\n составные чёрными. И, ради чего это делалось,\r\n получается геометрический узор с явно заметными \r\n кусками прямых из белых точек. Наслаждайтесь.\r\n\r\n(c) yGREK heretix 20.03.2005 \r\n http://www.forth.org.ru/~ygrek"
   e -text!
  SHOW
 ...MODAL
PROC;

MENU: winmenu
  draw MENUITEM  &Рисовать
  about MENUITEM &Инфа
  quit MENUITEM &Выход
MENU;

\ -------------------------------------


: run
  done 0! 
  WINDOWS...
  0 create-window TO win
  " Arial Cyr" 12 create-font default-font
  win TO winmain
  " Салфетка Улама" win -text!
  paint win -painter!
  winmenu win attach-menubar
  win create-status
  winmain -hwnd@ GetDC TO hDC 
  CreateMemDC
  win winmaximize
  win winshow
 \ Инициализация по умолчанию
  maxX 2/ TO cx 
  maxY 2/ TO cy
  100000 TO limit
  0 TO start
  ['] number-spiral TO number

  ...WINDOWS
  hDC winmain -hwnd@ ReleaseDC DROP
  BYE ;

: main
 0 TO SPF-INIT?
 ['] ANSI>OEM TO ANSI><OEM
 TRUE TO ?GUI
 ['] NOOP TO <MAIN>
 ['] run MAINX !
 S" ulam.exe" SAVE  
 run
 BYE
;

main