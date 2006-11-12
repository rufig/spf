\ WinCC example
\ need WinLib 1.14.1 +

DIS-OPT \ для SPF ниже 4.10 под NT
REQUIRE toolbar ~yz/lib/wincc.f
SET-OPT 
REQUIRE def-small-icon-il ~ygrek/~yz/lib/icons.f

0 VALUE t
0 VALUE hd
0 VALUE tv
0 VALUE lv
0 VALUE old-grid
0 VALUE tab1
0 VALUE tab2
0 VALUE tab3

: hide-selected-tab ( ctl -- )
   DUP -selected@ SWAP -iparam@ hide-grid ;

: show-selected-tab ( ctl -- )
   DUP map-current-tab-grid
   DUP -selected@ SWAP -iparam@ show-grid ;

: switch-tab { i tab -- }
   tab hide-selected-tab
   i 0  W: TCM_SETCURSEL tab send DROP
   tab show-selected-tab ;

PROC: change-tab
  t -selected@ t switch-tab
PROC;

WINAPI: FindFirstFileA KERNEL32.DLL
WINAPI: FindNextFileA  KERNEL32.DLL
WINAPI: FindClose      KERNEL32.DLL

: fill-listview { \ no fh [ 400 ] fdata }
  def-small-icon-il lv -imagelist!
  def-normal-icon-il lv -imagelist!
  " Имя файла" 0 0 lv add-column
  " Размер" 1 1 lv add-column
  fdata " *.f" FindFirstFileA TO fh
  BEGIN
    fdata 11 CELLS + 0 0 lv add-item
    \ следующий фокус с вечно нулевым последним подъэлементом не проходит, 
    \ когда включена автосортировка: номера конкретной иконки все время меняются
    \ тогда надо запоминать уникальный param и пользоваться lv-param>i
    fdata 8 CELLS@ S>D <# 0 HOLD #S #> DROP 0 1 lv -isubitem!
  fdata fh FindNextFileA 0= UNTIL
  fh FindClose DROP ;

: make-grids 
  
  \ Вкладка 1 ===========================
  GRID
    " Индикатор:" label |
    ===
    progress -xspan 60 this +pos! " Это пример индикатора" this -tooltip! | 
    ===
    " Ползунок: " label |
    ===
    W: tbs_autoticks trackbar -xspan 80 this -pos! " А вот ползунок" this -tooltip! |
    ===
    " Строка ввода со спином:" label |
    ===
    edit -xspan " 40" this -text! W: uds_setbuddyint this add-updown 
    " А это просто строка" this -tooltip! |
  GRID; TO tab1

  \ Вкладка 2 ==========================
  GRID
    0 header DUP TO hd -xspan -yfixed |
    ===
    (* tvs_haslines tvs_linesatroot tvs_hasbuttons *) treeview DUP TO tv -xspan -yspan | 
    0 calendar -xfixed |
  GRID; TO tab2

  \ 
  0 " Имя" none 0 0 hd add-item
  0 " Фамилия" none 0 1 hd add-item
  0 " Отчество" none 0 2 hd add-item
  90 0 hd -iwidth!
  100 1 hd -iwidth!
  100 2 hd -iwidth!
  \ 
  def-small-icon-il tv -imagelist!
  " yz" 0 0 0 W: tvi_first 0 tv add-item >R
  " prog" 0 0 0 W: tvi_first R> tv add-item >R
  " winlib" 0 0 0 W: tvi_first R> tv add-item >R
  " winlib-example" 0 0 0 W: tvi_last R@ tv add-item
  " winctl-example" 0 0 0 W: tvi_last R@ tv add-item
  " wincc-example" 0 0 0 W: tvi_last R> tv add-item

  \ Вкладка 3 ========================
  GRID
    0 listview DUP TO lv -xspan -yspan |
  GRID; TO tab3
  fill-listview ;

: make-tabs
  0 tabcontrol 
  this TO t
  def-small-icon-il t -imagelist!
  tab1 " Первая" 0 0 this add-item
  tab2 " Вторая" 0 1 this add-item
  tab3 " Третья" 0 2 this add-item
  -xspan
  -yspan
  ;

PROC: tbutt
  " Кнопка на панели инструментов!" msg
PROC;

PROC: mode1  lv icon-view       PROC;
PROC: mode2  lv smallicon-view  PROC;
PROC: mode3  lv list-view       PROC;
PROC: mode4  lv report-view     PROC;

: make-toolbar 
  0 winmain create-toolbar
  W: idb_view_small_color winmain -toolbar@ add-std-bitmap DROP
  none 0 W: btns_button mode1 0 winmain -toolbar@ add-item
  none 1 W: btns_button mode2 1 winmain -toolbar@ add-item
  none 2 W: btns_button mode3 2 winmain -toolbar@ add-item
  none 3 W: btns_button mode4 3 winmain -toolbar@ add-item
  winmain -toolbar@ separate
  none 4 W: btns_wholedropdown tbutt 4 winmain -toolbar@ add-item
  none 5 W: btns_button tbutt 5 winmain -toolbar@ add-item
;

: run
  WINDOWS...
  0 dialog-window TO winmain
  " Общие элементы управления" winmain -text!
  0 create-tooltip
  make-toolbar
  make-grids
  GRID
  make-tabs |
  GRID; winmain -grid!
  410 410 winmain winresize
  winmain wincenter
  winmain winshow
  0 TO old-grid

  ...WINDOWS
  BYE
;

\ 0 TO SPF-INIT?
\ ' ANSI>OEM TO ANSI><OEM
\ TRUE TO ?GUI
\ ' run MAINX !
\ S" wincс-example.exe" SAVE  
run
BYE
