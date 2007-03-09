DIS-OPT \ для SPF ниже 4.10 под NT
REQUIRE toolbar ~yz/lib/wincc.f
SET-OPT 

0 VALUE t
0 VALUE hd
0 VALUE tv
0 VALUE lv

WINAPI: ImageList_Create      COMCTL32.DLL
WINAPI: ImageList_ReplaceIcon COMCTL32.DLL
WINAPI: ImageList_GetImageCount COMCTL32.DLL

: create-il ( size -- il )
  >R 5 5 W: ilc_color8 R> DUP ImageList_Create ;
: add-icon ( resno il -- ) 
  >R IMAGE-BASE LoadIconA -1 R> ImageList_ReplaceIcon DROP ;

WINAPI: FindFirstFileA KERNEL32.DLL
WINAPI: FindNextFileA  KERNEL32.DLL
WINAPI: FindClose      KERNEL32.DLL

: fill-listview { \ no fh [ 400 ] fdata }
  32 create-il DUP 1 SWAP add-icon W: lvsil_normal lv -imagelist!
  16 create-il DUP 1 SWAP add-icon W: lvsil_small  lv -imagelist!
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

: fill-header,treeview
  0 " Имя" none 0 0 hd add-item
  0 " Фамилия" none 0 1 hd add-item
  0 " Отчество" none 0 2 hd add-item
  90 0 hd -iwidth!
  100 1 hd -iwidth!
  100 2 hd -iwidth!
  \ 
  16 create-il DUP 1 SWAP add-icon 0 tv -imagelist!
  " yz" 0 0 0 W: tvi_first 0 tv add-item >R
  " prog" 0 0 0 W: tvi_first R> tv add-item >R
  " winlib" 0 0 0 W: tvi_first R> tv add-item >R
  " winlib-example" 0 0 0 W: tvi_last R@ tv add-item DROP
  " winctl-example" 0 0 0 W: tvi_last R@ tv add-item DROP
  " wincc-example" 0 0 0 W: tvi_last R> tv add-item DROP
;

: make-tabs ( -- tab)
  0 tabcontrol
  16 create-il DUP 1 SWAP add-icon 0 this -imagelist!
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
  GRID; " Первая" 0 0 this add-item

  \ Вкладка 2 ==========================
  GRID
    0 header DUP TO hd -xspan -yfixed |
    ===
    (* tvs_haslines tvs_linesatroot tvs_hasbuttons *) treeview DUP TO tv 
    200 400 this ctlresize | 
    0 calendar -xfixed |
    fill-header,treeview
  GRID; " Вторая" 0 1 this add-item

  \ Вкладка 3 ========================
  GRID
    0 listview DUP TO lv -xspan -yspan fill-listview |
  GRID; " Третья" 0 2 this add-item
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
  GRID
    make-tabs -xspan -yspan |
  GRID; winmain -grid!
  winmain wincenter
  winmain winshow
  ...WINDOWS
  BYE
;

\ 0 TO SPF-INIT?
\ ' ANSI>OEM TO ANSI><OEM
\ TRUE TO ?GUI
\ ' run MAINX !
\ S" wincc-example.exe" SAVE  
run
BYE
