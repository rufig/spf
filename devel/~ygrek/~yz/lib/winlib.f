\ WINLIB 1.14.1

\ $Id$

\ Библиотека пользовательского интерфейса Windows
\ ч. 1. Базовые объекты, окна, меню, быстрые клавиши
\ Ю. Жиловец, 8.12.2001

REQUIRE "       ~yz/lib/common.f
REQUIRE PROC:   ~yz/lib/proc.f
REQUIRE {       lib/ext/locals.f
REQUIRE LOAD-CONSTANTS     ~yz/lib/wincons.f
REQUIRE >>      ~yz/lib/data.f
REQUIRE MGETMEM ~yz/lib/gmem.f
S" ~yz/cons/commctrl.const" LOAD-CONSTANTS

REQUIRE table ~ygrek/~yz/lib/wincore.f

" yzWinLib" ASCIIZ classname

\ ----------------------------------------
\ Свойства, общие для всех окон
0 table common
  item -hwnd    	\ дескриптор окна
  item -pre		\ выполняется до стандартной оконной процедуры
  item -wndproc		\ оконная процедура
  item -messages        \ Список обработчиков сообщений по умолчанию
  item -style 	getset 	\ стиль окна
  item -color 		\ цвет букв
  item -bgcolor set	\ цвет фона
  item -bgbrush ( _gdi type)	\ кисть для фона окна
  item -painter		\ процедура отрисовки окна
  item -xsize	\ размер окна по горизонтали
  item -ysize	\ размер окна по вертикали
  item -parent	\ окно, в котором размещен элемент
  item -text getset	\ максимальный размер строки - 255 символов. 
                	\ Для richedit и ему подобных - переопределить чтение/запись
  item -userdata        \ пользовательские данные
endtable

\ меню
0 table menu
  item -hmenu
  item -itemsinfo
endtable

WINAPI: SendMessageA USER32.DLL

: send-to-window ( wparam lparam msg hwnd -- result)
 2>R SWAP 2R> SendMessageA ;

: send ( wparam lparam msg win -- result)
  -hwnd@ send-to-window ;

: ?send ( ctl message -- n/ )  SWAP 0 0 2SWAP send ;
: wsend ( wparam ctl message -- n/ ) 0 -ROT SWAP send ;
: lsend ( lparam ctl message -- n/ ) >R 0 -ROT R> SWAP send ;

: set-text ( z ctl -- ) W: wm_settext lsend DROP ;

:NONAME \ get-text  tab --
  OVER >R >R 255 SWAP W: wm_gettext R> send R> + 0 SWAP C! ;
' set-text
-text common setitem

: -text# ( ctl -- ) W: wm_gettextlength ?send ;

0xFF0000 == red
0x00FF00 == green
0x0000FF == blue
0xFFFFFF == white
0x000000 == black
0xFFFF00 == yellow
0xFF00FF == violet
0x00FFFF == cyan

: >bgr { rgb -- bgr }
  ^ rgb C@ ^ rgb 2+ C@ ^ rgb C! ^ rgb 2+ C!
  rgb ; 
: rgb ( r g b -- rgb) SWAP 8 LSHIFT OR SWAP 16 LSHIFT OR ;

WINAPI: GetSysColor USER32.DLL

: syscolor ( index -- rgb)
  GetSysColor >bgr ;

-1 == transparent

WINAPI: CreateSolidBrush GDI32.DLL
WINAPI: GetStockObject   GDI32.DLL
WINAPI: SetBkColor       GDI32.DLL
WINAPI: SetTextColor     GDI32.DLL
WINAPI: SetBkMode        GDI32.DLL
WINAPI: DeleteObject     GDI32.DLL
WINAPI: InvalidateRect USER32.DLL
WINAPI: GetWindowRect  USER32.DLL

: invalidate { ctl \ [ 4 CELLS ] rect -- }
  ctl -parent@ IF
    rect ctl -hwnd@ GetWindowRect DROP
    TRUE rect ctl -parent@ -hwnd@ InvalidateRect DROP
  THEN ;
: ?invalidate ( ctl -- )
  DUP -bgcolor@ transparent = IF invalidate ELSE DROP THEN ;

0 \ get
:NONAME \ set-bgcolor ( rgb tab --)
  DUP >R -bgbrush@ DeleteObject DROP
  DUP -bgcolor R@ store
  DUP transparent = IF 
    DROP W: null_brush GetStockObject
    R@ invalidate
  ELSE
    >bgr CreateSolidBrush
  THEN
  R> -bgbrush!
;
-bgcolor common setitem

WINAPI: GetWindowLongA USER32.DLL
WINAPI: SetWindowLongA USER32.DLL

 :NONAME \ get-style   tab -- style
 W: gwl_style SWAP -hwnd@ GetWindowLongA ;
 :NONAME \ set-style   style tab --
 >R W: gwl_style R> -hwnd@ SetWindowLongA DROP ;
 -style common setitem

\ ----------------------------------------
common table window
 item -icon getset	\ иконка
 item -smicon getset	\ маленькая иконка
 item -menus		\ меню окна
 item -status		\ статус
 item -toolbar          \ палитра инструментов
 item -minustop		\ размер элементов, закрывающих окно сверху
 item -minusbottom	\ размер элементов, закрывающих окно снизу
 item -hscroll  	\ список обработчиков горизонтальной прокрутки
 item -vscroll		\ список обработчиков вертикальной прокрутки
 item -grid set 	\ решетка окна
 item -gridresize     	\ процедура изменения размеров решетки
\ item -gridctlresize
 item -dialog	  \ флажок: надо ли обрабатывать диалоговые кнопки
 item -defaultbutton   \ Кнопка по умолчанию
endtable

: window! ( n hwnd -- )
  W: gwl_userdata SWAP SetWindowLongA DROP ;

: window@ ( hwnd -- n)
  W: gwl_userdata SWAP GetWindowLongA ;

:NONAME \ get-icon  tab -- hicon
 >R W: icon_big 0 W: wm_geticon R> send ;
:NONAME \ set-icon  hicon tab --
 >R W: icon_big SWAP W: wm_seticon R> send DROP ;
-icon window setitem

:NONAME \ get-smicon  tab -- hicon
 >R W: icon_small 0 W: wm_geticon R> send ;
:NONAME \ set-smicon  hicon tab --
 >R W: icon_small SWAP W: wm_seticon R> send DROP ;
-smicon window setitem

WINAPI: AdjustWindowRectEx USER32.DLL

\ высчитывает полный размер окна по размеру клиентской области
\ + высота статуса + высота панели инструмента
: nc-win-size { dx dy win \ [ 4 CELLS ] rect -- ex ey }
  dx rect 2 CELLS!  dy  rect 3 CELLS!
  W: gwl_exstyle win -hwnd@ GetWindowLongA win -menus@ 
  W: gwl_style win -hwnd@ GetWindowLongA rect 
  AdjustWindowRectEx DROP
  rect 2 CELLS@ rect @ -   rect 3 CELLS@ rect 1 CELLS@ -
  win -minustop@ + win -minusbottom@ +
;

\ --------------------------------------
0 VALUE winmain
0 VALUE current-window
0 VALUE accel-xtable
\ --------------------------------------
\ оконная функция

USER-VALUE hwnd
USER-VALUE message
USER-VALUE wparam
USER-VALUE lparam
USER-VALUE thiswin
USER-VALUE thisctl

WINAPI: BeginPaint USER32.DLL
WINAPI: EndPaint   USER32.DLL

USER-VALUE windc
USER-VALUE paint-rect

: wm-paint-proc 
 { \ [ 64 ] paintstruct -- }
 paintstruct hwnd BeginPaint TO windc
 paintstruct 2 CELLS + TO paint-rect
 thiswin -painter@ EXECUTE
 paintstruct hwnd EndPaint DROP
 TRUE
;

\ --------------------------------------
\ Оконная функция для стандартных окон

MESSAGES: main-dispatch

\ закрасим фон 
WINAPI: FillRect      USER32.DLL
WINAPI: GetClientRect USER32.DLL

M: wm_erasebkgnd
\  ." WM_ERASEBKGND" CR
  { \ [ 4 CELLS ] rect -- }
  rect hwnd GetClientRect DROP
  thiswin -bgbrush@ rect wparam FillRect DROP
  TRUE RETURN
  TRUE
M;

M: wm_paint
\ ." WM_PAINT" CR
 wm-paint-proc
M;

VECT menu-painter

M: wm_drawitem
\   ." WM_DRAWITEM" CR
   lparam @ W: odt_menu = IF 
     \ это меню
     menu-painter 
   ELSE
     \ это элемент управления
     lparam 6 CELLS@ TO windc
     lparam 7 CELLS+ TO paint-rect
     lparam 5 CELLS@ window@ ?DUP IF
       -painter@ EXECUTE
     THEN
   THEN
   TRUE
M;

WINAPI: PostQuitMessage USER32.DLL

0 VALUE modal-window
VECT del-grid

M: wm_destroy
\  ." WM_DESTROY" CR
  thiswin -grid@ ?DUP IF del-grid THEN
  thiswin modal-window = IF 0 TO modal-window THEN
  winmain -hwnd@ hwnd = IF 0 PostQuitMessage DROP THEN
  TRUE
M;

0 VALUE dialog
0 VALUE dialog-termination

: end-dialog ( code -- ) TO dialog-termination ;
: dialog-ok  ( -- ) W: idok end-dialog ;
: dialog-cancel ( -- ) W: idcancel end-dialog ;

M: wm_close
\  ." WM_CLOSE" CR
  dialog 0= IF FALSE EXIT THEN
  hwnd dialog -hwnd@ = DUP >R IF dialog-cancel THEN R>
M;

WINAPI: PostMessageA USER32.DLL

\ lparam: 0  wparam: 0 - next, 1 - previous
M: wm_nextdlgctl
\  ." WM_NEXTDLGCTL" CR
  lparam 0= thiswin -dialog@ AND IF
    wparam IF
      \ имитируем нажатие Shift-Tab
      0x002A0001 W: vk_shift W: wm_keydown hwnd PostMessageA DROP
      0x000F0001 W: vk_tab   W: wm_keydown hwnd PostMessageA DROP
      0xC00F0001 W: vk_tab   W: wm_keyup   hwnd PostMessageA DROP
      0xC02A0001 W: vk_shift W: wm_keyup   hwnd PostMessageA DROP
    ELSE 
      \ имитируем нажатие Tab
      0x000F0001 W: vk_tab W: wm_keydown hwnd PostMessageA DROP
      0x800F0001 W: vk_tab W: wm_keyup   hwnd PostMessageA DROP
    THEN  
  THEN
  TRUE
M;

M: wm_size
\  ." WM_SIZE" CR
  \ запоминаем новый размер
  lparam LOWORD thiswin -xsize!
  lparam HIWORD thiswin -minustop@ - thiswin -minusbottom@ - thiswin -ysize!
  \ уведомим окно статуса и панели инструментов о том, что размер изменился
  thiswin -status@ ?DUP IF
    >R 0 0 W: wm_size R> send DROP
  THEN
  thiswin -toolbar@ ?DUP IF
    >R 0 0 W: wm_size R> send DROP
  THEN
  \ заставим решетку перерисоваться
  thiswin -grid@ IF thiswin -gridresize@ EXECUTE THEN
  TRUE
M;

M: wm_getminmaxinfo
\  ." WM_GETMAXINFO" CR
  thiswin -grid@ ?DUP IF
    DUP 2 CELLS@ SWAP 3 CELLS@ thiswin nc-win-size
    lparam 7 CELLS! lparam 6 CELLS!
    TRUE
  THEN
M;

WINAPI: SetActiveWindow USER32.DLL

0 VALUE dialog-filter

M: wm_activate
\  ." WM_ACTIVATE" CR
  \ если активизируется окно с установленным -dialog, запоминаем его 
  \ дескриптор
  wparam LOWORD W: wa_inactive <> IF 
    thiswin -dialog@ IF hwnd ELSE 0 THEN
  THEN TO dialog-filter
  \ если есть модальное окно, не даем переключиться на другое
  modal-window 0= IF FALSE EXIT THEN
  wparam LOWORD W: wa_inactive <> hwnd modal-window <> AND IF
    modal-window SetActiveWindow DROP
    TRUE
  ELSE 
    FALSE 
  THEN
M;

VECT command  ' NOOP TO command
VECT scrollctlproc  ' NOOP TO scrollctlproc
VECT notifyproc  ' NOOP TO notifyproc

10 == first-menu-id \ после всех кодов IDxxx

M: wm_command
\  ." WM_COMMAND" CR
   lparam IF
     \ привет от кнопочек
     command
   ELSE
     wparam HIWORD IF
       \ быстрые клавиши 
       wparam LOWORD accel-xtable find-in-xtable DROP
     ELSE
       wparam LOWORD DUP first-menu-id < IF
         \ завершение диалога
         DUP W: idok = IF
           \ если нажали Enter - отработаем команду
           \ кнопки по умолчанию
           DROP
           thiswin -defaultbutton@ ?DUP IF
             W: bm_click ?send DROP
           THEN
         ELSE
           end-dialog
         THEN
       ELSE
         \ привет от меню
         thiswin -menus@ find-and-execute DROP
       THEN
     THEN
   THEN
   TRUE
M;

: set-colors
  lparam window@ DUP 0= IF EXIT THEN \ не наше окно
  TO thisctl
  thisctl -bgcolor@ transparent = IF
    W: transparent wparam SetBkMode DROP
  THEN
  thisctl -bgcolor@ >bgr wparam SetBkColor DROP
  thisctl -color@ >bgr wparam SetTextColor DROP
  thisctl -bgbrush@ RETURN
  TRUE ;

M: wm_ctlcolorstatic
\  ." WM_CTLCOLORSTATIC" CR
  set-colors
M;

M: wm_ctlcoloredit
\  ." WM_CTLCOLOREDIT" CR
   set-colors
M;

M: wm_ctlcolorlistbox
\  ." WM_CTLCOLORLISTBOX" CR
  set-colors
M;

M: wm_ctlcolorscrollbar
\  ." WM_CTLCOLORSCROLLBAR" CR
  set-colors
M;

M: wm_hscroll
\  ." WM_HSCROLL" CR
  lparam IF
    scrollctlproc
  ELSE
    wparam LOWORD thiswin -hscroll@ find-in-xtable DROP
  THEN 
  TRUE
M;

M: wm_vscroll
\  ." WM_VSCROLL" CR
  lparam IF
    scrollctlproc
  ELSE
    wparam LOWORD thiswin -vscroll@ find-in-xtable DROP
  THEN
  TRUE 
M;

M: wm_notify
\  ." WM_NOTIFY" CR
   notifyproc
M;

MESSAGES;

\ ---------------------------------
\ Стандартная оконная функция для элементов управления

MESSAGES: control-std-wndproc

M: wm_paint
\  ." WM_PAINT ctl" CR
  wm-paint-proc
M;

M: wm_size
\  ." WM_SIZE ctl" CR
  lparam LOWORD thiswin -xsize!
  lparam HIWORD thiswin -ysize!
 TRUE
M;

MESSAGES;

\ -------------------------------

XLIST common-window-proclist
XLIST common-control-proclist

: extend-window-proc  ( xtable -- ) common-window-proclist insert-to-end ;

WINAPI: DefWindowProcA USER32.DLL

:NONAME ( lparam wparam msg hwnd -- result)
  TO hwnd  TO message  TO wparam  TO lparam 
\      ." hwnd=" hwnd . ." message=" message .H 
\      ." wparam=" wparam . ." lparam=" lparam .H CR
  hwnd window@ TO thiswin
  thiswin 0= IF
    \ окно еще не сформировано
    lparam wparam message hwnd DefWindowProcA EXIT
  THEN
  0 TO return-value
  message thiswin -pre@ ?find-in-xtable
  ?DUP 0= IF
    message thiswin -messages@ ?find-and-execute
    ?DUP 0= IF
      message thiswin -wndproc@ ?find-in-xtable
    THEN
  THEN
  IF  \ кто-то обработал сообщение
    return-value
  ELSE
    lparam wparam message hwnd DefWindowProcA
  THEN
\  ." /" message .H DUP . CR
; WNDPROC: dispatch

\ --------------------------------------
\ созидание и уничтожение окон

WINAPI: CreateWindowExA USER32.DLL
WINAPI: ShowScrollBar   USER32.DLL
WINAPI: LoadIconA       USER32.DLL

: create-window-with-styles  ( parent style exstyle -- )
  { parent style exstyle \ win [ 4 CELLS ] rect -- a/0 }
  (* ws_hscroll ws_vscroll *) ^ style OR!
  window new-table TO win
  common-window-proclist win -messages!
  0 IMAGE-BASE 0 
  parent DUP IF -hwnd@ style W: ws_child OR TO style THEN
  W: cw_usedefault DUP 2DUP style ""
  classname exstyle CreateWindowExA DUP 0= IF win del-table EXIT THEN
  ( hwnd) DUP >R win -hwnd!
  win R> window!
  ['] NOOP win -painter!
  \ спрячем полосы прокрутки
  FALSE W: sb_both win -hwnd@ ShowScrollBar DROP
  \ загрузим иконки
  parent 0= IF
    1 IMAGE-BASE LoadIconA win -icon!
    2 IMAGE-BASE LoadIconA win -smicon!
  THEN
  win DUP TO current-window ;

: create-window ( parent -- win/0)
  W: ws_overlappedwindow W: ws_ex_appwindow  
  create-window-with-styles
  DUP IF W: color_3dface syscolor OVER -bgcolor! THEN ;

: dialog-window ( parent -- win/0)
  DUP IF 
    (* ws_popupwindow ws_caption ws_clipsiblings *)
    (* ds_modalframe ds_setforeground ds_control *) OR
  ELSE
    (* ws_overlapped ws_caption ws_dlgframe ws_clipsiblings ws_sysmenu *) 
  THEN
  W: ws_ex_controlparent
  create-window-with-styles
  DUP IF
    W: color_3dface syscolor OVER -bgcolor!
    TRUE OVER -dialog!
  THEN ;

: tool-window ( parent -- win/0)
  W: ws_overlappedwindow W: ws_ex_palettewindow
  create-window-with-styles
  DUP IF W: color_3dface syscolor OVER -bgcolor! THEN ;

WINAPI: DestroyWindow USER32.DLL

: destroy-window ( win -- )
  DUP -hwnd@ DestroyWindow DROP
  del-table ;

\ --------------------------------------
\ элементарные операции над окнами

WINAPI: ShowWindow USER32.DLL

: (show) ( win flag -- )
  SWAP -hwnd@ ShowWindow DROP ;
: winshow ( win -- ) W: sw_show (show) ;
: winhide ( win -- ) W: sw_hide (show) ;
: winminimize ( win -- ) W: sw_minimize (show) ;
: winmaximize ( win -- ) W: sw_maximize (show) ;
: winrestore ( win -- ) W: sw_normal (show) ;

WINAPI: EnableWindow USER32.DLL

: winenable ( win -- )
  TRUE SWAP -hwnd@ EnableWindow DROP ;
: windisable ( win -- )
  FALSE SWAP -hwnd@ EnableWindow DROP ;

WINAPI: SetFocus USER32.DLL

: winfocus ( ctl -- ) -hwnd@ SetFocus DROP ;

: win-rect { win \ [ 4 CELLS ] rect -- x1 y1 x2 y2 }
  rect win -hwnd@ GetWindowRect DROP
  rect @  rect 1 CELLS@ 
  rect 2 CELLS@  rect 3 CELLS@
;

WINAPI: ScreenToClient USER32.DLL

\ То же самое, но в координатах родительского окна
: child-win-rect { win \ [ 4 CELLS ] rect -- x1 y1 x2 y2 }
  rect win -hwnd@ GetWindowRect DROP
  win -parent@ ?DUP IF
    -hwnd@ rect OVER ScreenToClient DROP
    rect 2 CELLS+ SWAP ScreenToClient DROP
  THEN
  rect @  rect 1 CELLS@ 
  rect 2 CELLS@  rect 3 CELLS@
;

\ Настоящий размер окна
: win-size ( win -- )
  win-rect SWAP >R SWAP - R> ROT - SWAP ;

WINAPI: SetWindowPos USER32.DLL

: winmove ( x y win -- )
  >R >R >R (* swp_nosize swp_noownerzorder swp_nozorder *) 0 0 R> R> SWAP
  0 R> -hwnd@ SetWindowPos DROP ;

: new-size ( xsize ysize win -- )
  >R SWAP (* swp_nomove swp_noownerzorder swp_nozorder *) -ROT 
  0 0 0 R> -hwnd@ SetWindowPos DROP ;

\ Изменить размер простого окна (типа органа управления)
: resize ( xsize ysize win -- )
  DUP >R new-size
  R@ win-size R@ -ysize! R> -xsize!
;

\ Изменить размер сложного окна
: winresize ( xsize ysize win -- )
  DUP >R nc-win-size R> new-size
  \ новый размер окна в него запишет сообщение wm_size
;

\ заставить окно перерисоваться в ближайшее время
: force-redraw ( win -- )
  TRUE 0 ROT -hwnd@ InvalidateRect DROP
;
\ --------------------------------------
\ Message Boxes

\ если = 0, по умолчанию система ставит заголовок "Ошибка"
0 VALUE mbox-title

WINAPI: MessageBoxA USER32.DLL

: message-box ( title text style -- result)
  ROT ROT winmain DUP IF -hwnd@ THEN MessageBoxA ;
: msg ( text -- )
  mbox-title SWAP (* mb_ok mb_iconwarning *) message-box DROP ;
: err ( text -- )
  mbox-title SWAP (* mb_ok mb_iconstop *) message-box DROP ;

\ --------------------------------------
\ всякая информация
WINAPI: GetSystemMetrics USER32.DLL

: screen-x ( -- x) W: sm_cxscreen GetSystemMetrics ;
: screen-y ( -- x) W: sm_cyscreen GetSystemMetrics ;

\ --------------------------------------
: wincenter ( win -- )
  DUP >R win-size screen-y SWAP - 2/ SWAP screen-x SWAP - 2/ SWAP R> 
  winmove ;

\ --------------------------------------
\ раздача идентификаторов

VARIABLE menu-id   first-menu-id menu-id !
: next-menu-id  ( -- n) menu-id @  menu-id 1+! ;
 
\ --------------------------------------
\ менюшки

VARIABLE menu-flags

: MENU: ( ->bl; -- )
  menu-flags 0!
  init-xtptr
  init-yptr
  BL PARSE save-xtname ;

: LINE ( -- )
  2 CELLS 1+ c>yptr
  CELL" line" >yptr 
  W: mf_separator >yptr 
  menu-flags 0! ;

: SUBMENU ( ->eol; menu -- )
  >R
  1 PARSE
  DUP 2+ 3 CELLS + c>yptr 
  CELL" menu" >yptr
  menu-flags @ (* mf_string mf_popup *) OR >yptr
  menu-flags 0!
  R> >yptr 
  >>yptr ;

: MENUITEM ( ->eol; proc -- )
  1 PARSE HERE ESC-CZMOVE
  HERE DUP ZLEN
  DUP 2+ 3 CELLS + c>yptr
  CELL" item" >yptr
  menu-flags @ (* mf_string mf_enabled *) OR >yptr
  menu-flags 0!
  next-menu-id DUP >yptr >xtptr 
  >>yptr
  >xtptr xttable ut++ ;

: CHECKED   W: mf_checked menu-flags OR! ;
: DISABLED  W: mf_grayed  menu-flags OR! ;

: MENU; ( -- )
  0 c>yptr
  create-saved-xtname
  \ делаем table вручную
  0 C, 0 , 0 , \ сюда в свое время будет записано hmenu
  0 C, HERE xttable utable-size + 2 CELLS + , 0 , \ адрес таблицы с информацией об элементах меню
  land-xttable  \ xttable
  land-ytable   \ информация об элементах меню
  xttable destroy-utable
  ytable destroy-utable
;

VARIABLE (wake-menu)

WINAPI: AppendMenuA USER32.DLL

: append-to-menu { menu hmenu \ ptr flags -- }
  menu -itemsinfo@ TO ptr
  BEGIN
    ptr C@
  WHILE
    ptr 1+ CELL+ @ TO flags
    ptr 1+ @ CASE
      CELL" line" OF 
        0 0 flags hmenu AppendMenuA DROP
      ENDOF
      CELL" item" OF
        ptr 1+ 3 CELLS +  ptr 1+ 2 CELLS + @ ( id) flags hmenu AppendMenuA DROP
      ENDOF
      CELL" menu" OF
        ptr 1+ 3 CELLS+  
        ptr 1+ 2 CELLS + @ ( menu)
          DUP (wake-menu) @ EXECUTE -hmenu@ flags hmenu AppendMenuA DROP
      ENDOF
    DROP
    END-CASE 
    ptr C@ ptr + TO ptr
  REPEAT
  hmenu menu -hmenu! ;

WINAPI: CreatePopupMenu USER32.DLL
WINAPI: CreateMenu      USER32.DLL
WINAPI: DestroyMenu     USER32.DLL
WINAPI: DrawMenuBar     USER32.DLL

: wake-menu ( menu -- )
  DUP -hmenu@ 0= IF
  CreatePopupMenu append-to-menu 
  ELSE
    DROP 
  THEN ;

' wake-menu (wake-menu) !

: wake-menubar ( menu -- ) 
  DUP -hmenu@ 0= IF
    CreateMenu append-to-menu 
  ELSE
    DROP 
  THEN ;

: destroy-menu ( menu -- )
  DUP -hmenu@ DestroyMenu DROP 
  0 SWAP -hmenu! ;

WINAPI: SetMenu USER32.DLL

: append-xtable-to-menuslist { menu mlist \ ptr -- }
  menu 2 #tab * + mlist insert-to-end
  menu -itemsinfo@ TO ptr
  BEGIN
    ptr C@
  WHILE
    ptr 1+ @ CELL" menu" = IF
      ptr 1+ 2 CELLS+ @ mlist RECURSE
    THEN
    ptr C@ ptr + TO ptr
  REPEAT
;

: make-menus-list ( menu -- menu-list )
  create-xlist DUP >R
  append-xtable-to-menuslist
  R> 
;

: attach-menubar ( menu window -- ) 
  SWAP DUP wake-menubar DUP make-menus-list >R -hmenu@ SWAP 
  DUP R> SWAP -menus! -hwnd@ SetMenu DROP ;
: detach-menubar ( window -- )
  DUP -menus@ MFREEMEM
  0 OVER -menus!
  0 SWAP -hwnd@ SetMenu DROP ;

WINAPI: TrackPopupMenu USER32.DLL

\ работает только при установленном winmain
: show-menu { menu x y \ menulist -- }
  menu wake-menu
  menu make-menus-list TO menulist
  0 winmain -hwnd@ 0 y x (* tpm_leftalign tpm_returncmd *) menu -hmenu@
  TrackPopupMenu
  ?DUP IF menulist find-and-execute DROP THEN
  menulist MFREEMEM
;

WINAPI: EnableMenuItem     USER32.DLL
WINAPI: SetMenuDefaultItem USER32.DLL
WINAPI: CheckMenuItem      USER32.DLL
WINAPI: CheckMenuRadioItem USER32.DLL
WINAPI: GetMenuState       USER32.DLL
WINAPI: GetMenuItemID      USER32.DLL

: check-menu-item ( no menu -- ) 
  >R (* mf_byposition mf_checked *) SWAP R> -hmenu@ CheckMenuItem DROP ;
: uncheck-menu-item ( no menu -- ) 
  >R (* mf_byposition mf_unchecked *) SWAP R> -hmenu@ CheckMenuItem DROP ;

: (un)check-me ( -- ?)
  W: mf_bycommand this-id this-xlist -3 CELLS@ GetMenuState
  W: mf_checked AND 0= >R
  R@ IF W: mf_checked ELSE W: mf_unchecked THEN 
  this-id this-xlist -3 CELLS@ CheckMenuItem DROP 
  R> ;

: check-menu-radio ( first last no menu -- )
  >R >R W: mf_byposition ROT ROT R> ROT ROT SWAP R> -hmenu@ CheckMenuRadioItem
  DROP ;

: select-me { first last -- }
  this-xlist -3 CELLS@ >R
  W: mf_bycommand this-id
  last R@ GetMenuItemID DUP -1 = IF DROP 0 THEN
  first R@ GetMenuItemID DUP -1 = IF DROP 0 THEN
  R> CheckMenuRadioItem DROP 
;

: enable-menu-item ( no menu -- ) 
  >R (* mf_byposition mf_enabled *) SWAP R> -hmenu@ EnableMenuItem DROP ;
: disable-menu-item ( no menu -- ) 
  >R (* mf_byposition mf_grayed *) SWAP R> -hmenu@ EnableMenuItem DROP ;

: default-menu-item ( no menu -- )
  >R TRUE SWAP R> -hmenu@ SetMenuDefaultItem DROP ;

: redraw-window-menu ( win -- )
  -hwnd@ DrawMenuBar DROP ;

\ --------------------------------------
\ клавиши быстрого вызова

0 VALUE acctable

: KEYTABLE ( -- )
  1000 CELLS create-utable TO acctable 
  init-xtptr
;

: ?modifier ( adr n -- adr1 n1 flags )
  OVER >R S" ctrl+"  R> OVER COMPARE 0= IF 5 - SWAP 5 + SWAP  W: fcontrol EXIT THEN
  OVER >R S" alt+"   R> OVER COMPARE 0= IF 4 - SWAP 4 + SWAP  W: falt     EXIT THEN  
  OVER >R S" shift+" R> OVER COMPARE 0= IF 6 - SWAP 6 + SWAP  W: fshift   EXIT THEN
  0
;

: parse-key ( adr n -- key flags )
  { \ flags }
  W: fvirtkey TO flags
  BEGIN 
    ?modifier ( -- adr1 n1 flag) ?DUP WHILE
    ^ flags OR!
  REPEAT
  OVER >R FIND-CONSTANT 0= IF R@ C@ THEN RDROP
  flags
;

\ таблицы клавиш заводят для процедуры еще один id, даже если у нее уже есть
\ свой код, выделенный MENUITEM. Это не страшно, поскольку 16000 id должно
\ хватить всем
: ONKEY ( ->bl; proc -- ) 
  BL PARSE parse-key acctable uc>> 
  0 acctable uc>> acctable uw>>
  next-menu-id DUP acctable uw>>
  acctable ut++
  >xtptr >xtptr  xttable ut++
;

: KEYTABLE; ( -- )
  acctable land-utable
  acctable destroy-utable 
  TO acctable
  HERE TO accel-xtable
  land-xttable
  xttable destroy-utable
;

\ ----------------------------------
\ Шрифты
VARIABLE font-attr   font-attr 0!
: bold   1 font-attr OR! ;
: italic 2 font-attr OR! ;
: underline  4 font-attr OR! ;
: strike-out 8 font-attr OR! ;

0 VALUE logpixels

: pt>devunits ( n -- n1) logpixels 72 */ NEGATE ;

WINAPI: CreateFontA GDI32.DLL

: create-font-devunits ( zname devunits -- ) 
  >R (* default_pitch ff_dontcare *) W: default_quality
  W: clip_default_precis W: out_default_precis W: ansi_charset
  font-attr @ 8 AND  font-attr @ 4 AND  font-attr @ 2 AND 
  font-attr @ 1 AND IF 700 ELSE 400 THEN
  0 0 0 R> CreateFontA 
  font-attr 0! ;

: create-font ( zname size -- font )
  pt>devunits create-font-devunits ;
  
: delete-font ( font -- ) DeleteObject DROP ;

0 VALUE def-font

\ --------------------------------------
0 VALUE hbaseunits
0 VALUE vbaseunits

\ пересчет базовых диалоговых единиц в пиксели
: hdu ( n -- n1) hbaseunits 4 */ ;
: vdu ( n -- n1) vbaseunits 8 */ ;
: dunits ( n n1 -- n2 n3) vdu SWAP hdu SWAP ;
\ --------------------------------------
\ регистрация класса окна и общая инициализация

WINAPI: InitCommonControlsEx COMCTL32.DLL

: initcc { what \ [ 2 CELLS ] buf -- }
  2 CELLS buf !
  what buf CELL+ !
  buf InitCommonControlsEx DROP ;

WINAPI: RegisterClassA     USER32.DLL
WINAPI: GetDialogBaseUnits USER32.DLL
WINAPI: LoadCursorA        USER32.DLL
WINAPI: CreateCompatibleDC GDI32.DLL
WINAPI: GetDeviceCaps GDI32.DLL
WINAPI: DeleteDC      GDI32.DLL

: WINDOWS...
\ инициализация
  main-dispatch common-window-proclist insert-to-begin
  control-std-wndproc common-control-proclist insert-to-begin
\ регистрация класса окна
  HERE init->>
\ typedef struct _WNDCLASS {    // wc  
 (* cs_vredraw cs_hredraw cs_dblclks cs_bytealignclient *) >>  \ UINT    style; 
 ['] dispatch >>  	\   WNDPROC lpfnWndProc; 
 0 >>			\   int     cbClsExtra; 
 0 >>			\   int     cbWndExtra; 
 IMAGE-BASE >>		\   HANDLE  hInstance; 
 0 >>			\   HICON   hIcon; 
 W: idc_arrow 0
 LoadCursorA >>		\   HCURSOR hCursor; 
 0 >>			\   HBRUSH  hbrBackground; 
 0 >>			\   LPCTSTR lpszMenuName; 
 classname >>		\   LPCTSTR lpszClassName; 
\ } WNDCLASS; 
 HERE RegisterClassA 0= IF " WinLib: Не могу зарегистрировать класс окна" 
      err BYE THEN
\ Узнаем логическое разрешение экрана
  0 CreateCompatibleDC W: logpixelsx OVER GetDeviceCaps
  TO logpixels DeleteDC DROP
\ Спросим размер диалоговых единиц
  GetDialogBaseUnits DUP LOWORD TO hbaseunits HIWORD TO vbaseunits
\ Общие штучки
 W: icc_win95_classes initcc ;

WINAPI: GetMessageA             USER32.DLL
WINAPI: TranslateMessage        USER32.DLL
WINAPI: DispatchMessageA        USER32.DLL
WINAPI: CreateAcceleratorTableA USER32.DLL
WINAPI: DestroyAcceleratorTable USER32.DLL
WINAPI: TranslateAccelerator    USER32.DLL
WINAPI: IsDialogMessage         USER32.DLL

: ?dialog ( msg -- ?) 
  dialog-filter DUP IF IsDialogMessage ELSE 2DROP FALSE THEN ;

: ...WINDOWS \ главный цикл окна
  { \ [ 7 CELLS ] msg keytable -- }
  acctable IF
    acctable :no @ acctable :data CreateAcceleratorTableA
  ELSE
    0
  THEN TO keytable
  BEGIN
    0 0 0 msg GetMessageA
  WHILE
    msg keytable msg @ ( hwnd) TranslateAccelerator
    0= IF
      msg ?dialog 0= IF
        msg TranslateMessage DROP
        msg DispatchMessageA DROP
      THEN
    THEN
  REPEAT
  keytable DestroyAcceleratorTable DROP ;
