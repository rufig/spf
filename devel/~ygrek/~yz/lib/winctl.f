\ WINLIB 1.14.1

\ $Id$

\ Библиотека пользовательского интерфейса Windows
\ ч. 2. Стандартные элементы интерфейса и их размещение
\ Ю. Жиловец, 2.02.2002

REQUIRE WINDOWS... ~ygrek/~yz/lib/winlib.f

0 VALUE common-tooltip

\ ------------------------------
\ Полезные процедуры

WINAPI: SelectObject          GDI32.DLL
WINAPI: GetTextExtentPoint32A GDI32.DLL
WINAPI: GetDC                 USER32.DLL
WINAPI: ReleaseDC             USER32.DLL

common table control
  item -font	getset	\ шрифт
  item -align 	set 	\ выравнивание текста
  item -notify  	\ обработчик уведомлений
  item -command 	\ вызов команды
  item -defcommand	\ сообщение по умолчанию
  item -updown		\ спин-симбионт
  item -tooltip  getset \ подсказка
  item -tooltipexists   \ флажок: есть ли подсказка
  item -locked          \ нельзя менять размеры
  \ специализированные слова
  item -calcsize        \ слово вычисления размеров окна
  item -ctlshow         \ слово показа элемента
  item -ctlhide         \ слово отключения показа элемента
  item -ctlresize       \ изменение размеров
  item -ctlmove		\ перестановка элемента
  item -ctladdpart      \ добавление внутренних частей к окну
endtable

VECT common-tooltip-op
VECT ctlresize

:NONAME \ get-tooltip ( z ctl -- )
  W: ttm_gettexta common-tooltip-op ;
:NONAME \ set-tooltip ( z ctl -- )
  DUP -tooltipexists@ 
  OVER TRUE SWAP -tooltipexists!
  IF W: ttm_updatetiptexta ELSE W: ttm_addtoola THEN common-tooltip-op
; -tooltip control setitem

: text-size { z ctl \ dc [ 2 CELLS ] size -- tx ty }
  ctl -hwnd@ GetDC TO dc
  ctl -font@ dc SelectObject DROP
  size z ASCIIZ> SWAP dc GetTextExtentPoint32A DROP
  dc ctl -hwnd@ ReleaseDC DROP
  size @ size 1 CELLS@ ;

: size-of-text { ctl \ [ 255 ] str -- tx ty }
  str ctl -text@  str ctl text-size ;

WINAPI: GetObjectA  GDI32.DLL
WINAPI: GetIconInfo USER32.DLL

: bitmap-size { bmp \ [ 6 CELLS ] buf -- x y }
  buf 6 CELLS bmp GetObjectA DROP
  buf 1 CELLS@ buf 2 CELLS@ ;
: icon-size { icon \ [ 5 CELLS ] buf -- x y }
  buf icon GetIconInfo DROP
  buf 3 CELLS@ DUP bitmap-size ROT DeleteObject DROP 
  buf 4 CELLS@ DeleteObject DROP ;

: +style ( style ctl -- ) DUP -style@ ROT OR SWAP -style! ;

\ -----------------------------------
\ Элементы управления

:NONAME \ get-font ( ctl -- font)
  W: wm_getfont ?send ;
:NONAME \ set-font ( font ctl -- )
  >R 1 W: wm_setfont R@ send DROP
  R> ?invalidate
; -font control setitem

USER-VALUE this

: create-control-exstyle-notchild { table class style exstyle -- ctl/0 }
  table new-table TO this
  common-control-proclist this -messages!
  0 IMAGE-BASE 0 
  current-window -hwnd@ 
  0 0 0 0 style  "" class exstyle
  CreateWindowExA DUP 0= IF this del-table EXIT THEN
  DUP >R this -hwnd! this R> window!
  W: color_3dface syscolor this -bgcolor!
  W: color_btntext syscolor this -color!
  ['] NOOP this -command!
  ['] NOOP this -painter!
  def-font ?DUP IF this -font! THEN
  20 20 this resize
  this ;

: create-control-exstyle ( table class style exstyle -- ctl/0)
  SWAP W: ws_child OR SWAP create-control-exstyle-notchild ;

: create-control ( table class style -- ctl ) 0 create-control-exstyle ;

:NONAME
  lparam @ window@ TO thisctl
  thisctl 0= IF FALSE EXIT THEN \ сообщение не от наших объектов не обрабатываем
  lparam 3 CELLS + TO lparam
  lparam CELL- @
  \ подменяем сообщение для панели инструментов
  DUP W: tbn_dropdown = IF DROP W: bn_clicked THEN
  DUP thisctl -defcommand@ = IF
    DROP thisctl -command@ EXECUTE
  ELSE
    thisctl -notify@ find-in-xtable DROP
  THEN TRUE
; TO notifyproc

\ ----------------------------------
\ Шрифт по умолчанию

: default-font ( font -- ) TO def-font ;
: -sysfont  0 this -font! ;

\ ----------------------------------
\ Строки статуса

WINAPI: CreateStatusWindow COMCTL32.DLL

: create-status ( win -- )
  >R 0 R@ -hwnd@ "" (* ws_child ws_visible *) CreateStatusWindow
  control new-table >R
  DUP R@ SWAP window!
  R@ -hwnd!
  ['] NOOP R@ -command!
  W: nm_click R@ -defcommand!
  R@ win-size PRESS
  R> R@ -status! 
  R> -minusbottom! ;

: split-status { array no win -- }
  no array W: sb_setparts win -status@ send DROP ;

: set-status ( z no win -- )
 >R SWAP W: sb_settexta R> -status@ send DROP ;

\ --------------------------------
\ Статические элементы

0 == left
1 == center
2 == right

" STATIC" ASCIIZ static

control table buttonlike
  item -xpad		\ горизонтальное расстояние от текста до края
  item -ypad		\ вертикальное расстояние от текста до края
  item -image	getset	\ текущая картинка
  item -state	getset
endtable

: +pads { x y ctl -- x1 y1 }
  ctl -xpad@ 2* x +  ctl -ypad@ 2* y + ;

: resize-if-unlocked ( xsize ysize win -- )
  DUP -locked@ IF DROP 2DROP ELSE ctlresize THEN ;

: adjust-size { ctl -- }
  ctl size-of-text  ctl +pads  ctl resize-if-unlocked ;

:NONAME \ set-labeltext ( z ctl -- ) 
  2DUP set-text DUP ?invalidate DUP adjust-size 
  \ заставим элемент перерисоваться еще раз
  set-text
; -text buttonlike storeset

:NONAME \ set-font ( font ctl -- )
  >R 1 W: wm_setfont R@ send DROP
  R@ ?invalidate
  R> adjust-size
; -font buttonlike storeset

: rectangle ( -- ctl)
  control static (* ss_notify ss_left *) create-control 
  black OVER -bgcolor! ;

: hline ( -- ctl) rectangle >R 1 1 R@ resize R> ;

: filler ( -- ctl) control static (* ss_notify ss_left *) create-control
  transparent OVER -bgcolor! ;

: set-stalign ( align ctl -- )
  2DUP -align SWAP store
  DUP -style@ W: ss_typemask INVERT AND ROT OR OVER -style!
  ?invalidate ;

: label ( z -- ctl)
  buttonlike static (* ss_notify ss_left ss_noprefix *) create-control >R
  DUP R@ text-size R@ resize
  R@ -text! 
  ['] set-stalign -align R@ storeset
  R> ;

: set-icon ( hicon ctl -- )
  >R DUP icon-size R@ +pads R@ resize
  0 W: stm_seticon R> send DROP ;
: get-icon ( ctl -- hicon)
  W: stm_geticon ?send ;

: icon ( hicon -- ctl)
  buttonlike static (* ss_icon ss_notify *) create-control >R
  ['] get-icon ['] set-icon -image R@ setitem
  R@ -image! 
  R> ;

: set-image ( hbmp ctl -- )
  >R DUP bitmap-size R@ +pads R@ resize
  W: image_bitmap SWAP W: stm_setimage R> send DROP ;
: get-image ( ctl -- hbmp)
  >R W: image_bitmap 0 W: stm_getimage R> send ;

: bitmap ( hbmp -- ctl)
  buttonlike static (* ss_bitmap ss_notify *) create-control >R
  ['] get-image ['] set-image -image R@ setitem
  R@ -image! 
  R> ;

: groupedge ( -- ctl )
  control static W: ss_blackframe W: ws_ex_staticedge 
  create-control-exstyle ;

\ -----------------------------
\ Кнопки

" BUTTON" ASCIIZ buttons

: groupbox ( z -- ctl )
  control buttons W: bs_groupbox create-control >R
  R@ -text!  R>
;

(* bs_left bs_center bs_right *) INVERT == bs_alignmask

: button-align ( align ctl -- )
  2DUP -align SWAP store
  DUP -style@ bs_alignmask AND ROT 
  CASE
    left OF W: bs_left ENDOF
    right OF W: bs_right ENDOF
  DROP W: bs_center
  END-CASE
  OR SWAP -style!
;

: button ( z -- ctl)
  buttonlike buttons (* bs_pushbutton bs_notify ws_tabstop *) create-control >R
  10 R@ -xpad!
  5 R@ -ypad!
  R@ -text!
  ['] button-align -align R@ storeset
  center -align R@ store
  R> ;

: -defbutton  ( -- ) 
  W: bs_defpushbutton this +style 
  this current-window -defaultbutton! ;

: ok-button ( z xt -- ctl ) >R button -defbutton R> this -command! ;

: cancel-button ( z -- ctl) button
  ['] dialog-cancel this -command! ;

: set-buttonicon ( hicon ctl -- )
  >R DUP icon-size R@ +pads R@ resize
  W: image_icon SWAP W: bm_setimage R> send DROP ;
: get-buttonicon ( ctl -- hicon)
  >R W: image_icon 0 W: bm_getimage R> send ;

: icon-button ( icon -- ctl )
  buttonlike buttons (* bs_pushbutton bs_notify ws_tabstop bs_icon *) create-control 
  >R
  ['] get-buttonicon ['] set-buttonicon -image R@ setitem
  3 R@ -xpad!  3 R@ -ypad!
  R@ -image!
  R> ;

: set-buttonbmp ( hbmp ctl -- )
  >R DUP bitmap-size R@ +pads R@ resize
  W: image_bitmap SWAP W: bm_setimage R> send DROP ;
: get-buttonbmp ( ctl -- hbmp)
  >R W: image_bitmap 0 W: bm_getimage R> send ;

: bitmap-button ( icon -- ctl )
  buttonlike buttons (* bs_pushbutton bs_notify ws_tabstop bs_bitmap *) create-control 
  >R
  ['] get-buttonbmp ['] set-buttonbmp -image R@ setitem
  3 R@ -xpad!  3 R@ -ypad!
  R@ -image!
  R> ;

: checkbox-align ( align ctl -- )
  2DUP -align SWAP store
  DUP -style@ ROT left = 
  IF W: bs_lefttext OR ELSE W: bs_lefttext INVERT AND THEN 
  SWAP -style! ;

: get-state ( ctl -- )  W: bm_getcheck ?send ;
: set-state ( state ctl -- )
  >R 0 W: bm_setcheck R> send DROP ;
 
: checkbox ( z -- ctl)
  buttonlike buttons (* bs_autocheckbox bs_notify ws_tabstop *) 
  create-control >R
  10 R@ -xpad!
  1 R@ -ypad!
  R@ -text!
  right -align R@ store
  ['] checkbox-align -align R@ storeset
  ['] get-state ['] set-state -state R@ setitem
  R> ;

: ?uncheck-group ( grp -- ) CELL+ @ ?DUP IF 0 SWAP set-state THEN ;

\ Формат группы:
\ +0	cell	Код установленной кнопки
\ +4	cell	Адрес установленной кнопки

: GROUP ( ->bl; -- ) 
  CREATE -1 , 0 , ;

0 VALUE last-group
VARIABLE (ws_group)  (ws_group) 0!

: ?ws_group ( n -- n) (ws_group) @ DUP IF (ws_group) 0! THEN OR ;

: start-group ( group -- ) TO last-group  (* ws_group ws_tabstop *) (ws_group) ! ;

: clear-group ( grp -- ) DUP ?uncheck-group DUP OFF DUP CELL+ ON ;

buttonlike table radiobutton
  item -group
  item -value
endtable

: check-radio ( ctl -- )
  DUP get-state
  IF
    DROP
  ELSE
    DUP -group@ ?uncheck-group
    DUP -value@ OVER -group@ !
    1 OVER set-state
    DUP -group@ CELL+ !
  THEN ;

PROC: check-this-radio ( -- ) thisctl check-radio ;

\ игнорируем state - радиокнопки не надо сбрасывать по одной
: set-radio-state ( state ctl -- )
  PRESS check-radio ;

: radio ( value z -- ctl)
  radiobutton buttons (* bs_radiobutton bs_notify *) ?ws_group
  create-control >R
  10 R@ -xpad!
  1 R@ -ypad!
  R@ -text!
  R@ -value!
  last-group R@ -group!
  right -align R@ store
  ['] checkbox-align -align R@ storeset
  ['] get-state ['] set-radio-state -state R@ setitem
  check-this-radio R@ -command!
  W: bn_clicked R@ -defcommand!
  R> ;

\ -----------------------------
\ Строка редактирования

" EDIT" ASCIIZ edits

: adjust-height ( ctl -- ) >R 
  R@ -xsize@ " ." R@ text-size PRESS 6 + R> resize-if-unlocked ;

: set-editfont ( font ctl -- )
  >R 1 W: wm_setfont R@ send DROP
  R@ ?invalidate
  R> adjust-height ;

: edit ( -- ctl)
  control edits (* es_autohscroll es_autovscroll ws_tabstop *) W: ws_ex_clientedge
  create-control-exstyle  >R
  ['] set-editfont -font R@ storeset
  0xFFFFFF R@ -bgcolor!
  R@ adjust-height
  R> ;

: password-edit ( -- ctl)
  control edits (* es_password es_autohscroll es_autovscroll ws_tabstop *) W: ws_ex_clientedge
  create-control-exstyle  >R
  ['] set-editfont -font R@ storeset
  0xFFFFFF R@ -bgcolor!
  R@ adjust-height
  R> ;

: multiedit ( -- ctl)
  control edits 
  (* es_autohscroll es_autovscroll es_multiline es_wantreturn ws_tabstop *) 
  W: ws_ex_clientedge create-control-exstyle >R 
  0xFFFFFF R@ -bgcolor!
  R> ;

: limit-edit ( n ctl -- ) W: em_setlimittext wsend DROP ;

\ ------------------------------
\ Обработка сообщения wm_command

:NONAME
  lparam window@ TO thisctl
  thisctl 0= IF EXIT THEN
  wparam HIWORD DUP thisctl -defcommand@ = IF
    DROP thisctl -command@ EXECUTE
  ELSE
    thisctl -notify@ find-in-xtable DROP
  THEN
; TO command

\ -----------------------------
\ Окна-списки

control table listlike
  item -selected getset	\ Текущий выбранный элемент
endtable

: lb-getsel ( ctl -- pos)
  W: lb_getcursel ?send ;
: lb-setsel ( pos ctl -- )
  >R 0 W: lb_setcursel R> send DROP ;

: listbox ( -- ctl) 
  listlike " LISTBOX" (* ws_vscroll lbs_notify ws_tabstop *) W: ws_ex_clientedge
  create-control-exstyle >R
  ['] lb-getsel ['] lb-setsel -selected R@ setitem
  0xFFFFFF R@ -bgcolor!
  R> ;

: lb-addstring ( z ctl -- )
  >R 0 SWAP W: lb_addstring R> send DROP ;
: lb-insertstring ( z pos ctl -- )
  >R SWAP W: lb_insertstring R> send DROP ;
: lb-clear ( ctl -- )
  W: lb_resetcontent ?send DROP ;
: lb-deletestring ( pos ctl -- )
  >R 0 W: lb_deletestring R> send DROP ;
: fromlist ( addr pos ctl -- )
  >R SWAP W: lb_gettext R> send DROP ;
: lb-dir ( mask attr ctl -- )
  >R SWAP W: lb_dir R> send DROP ;
: lb-count ( lb -- n) W: lb_getcount ?send ;

\ ----------------------------------
\ Комбинированные списки

: cb-getsel ( ctl -- pos)
  W: cb_getcursel ?send ;
: cb-setsel ( pos ctl -- )
  >R 0 W: cb_setcursel R> send DROP ;

: combo ( -- ctl)
  listlike " COMBOBOX" (* cbs_dropdownlist ws_vscroll ws_tabstop *) create-control >R
  ['] cb-getsel ['] cb-setsel -selected R@ setitem
  1 0 W: cb_setextendedui R@ send DROP
  0xFFFFFF R@ -bgcolor!
  W: cbn_selendok R@ -defcommand!
  R@ adjust-height
  R> ;

: addstring ( z ctl -- )  W: cb_addstring lsend DROP ;
: insertstring ( z pos ctl -- )
  >R SWAP W: cb_insertstring R> send DROP ;
: clear-combo ( ctl -- )
  W: cb_resetcontent ?send DROP ;
: deletestring ( pos ctl -- )  W: cb_deletestring wsend DROP ;
: fromcombo ( addr pos ctl -- )
  >R SWAP W: cb_getlbtext R> send DROP ;
: combo-dir ( mask attr ctl -- )
  >R SWAP W: cb_dir R> send DROP ;
: combo-count ( lb -- n) W: cb_getcount ?send ;

\ --------------------------------
\ Полосы прокрутки

" SCROLLBAR" ASCIIZ scrolls

control table scrolllike
  item -pos	getset	\ Позиция бегунка
  item -min	getset  \ минимальная позиция прокрутки
  item -max	getset	\ максимальная позиция прокрутки
endtable

WINAPI: GetScrollPos   USER32.DLL
WINAPI: SetScrollPos   USER32.DLL
WINAPI: GetScrollRange USER32.DLL
WINAPI: SetScrollRange USER32.DLL

: get-pos ( ctl -- pos)
  -hwnd@ W: sb_ctl SWAP GetScrollPos ;
: set-pos ( pos ctl -- )
  >R TRUE SWAP W: sb_ctl R> -hwnd@ SetScrollPos DROP ;

: scrollminmax { ctl \ min max -- min max }
  ^ max ^ min W: sb_ctl ctl -hwnd@ GetScrollRange DROP
  min max ;

: setscrollminmax ( min max ctl -- )
  >R SWAP TRUE -ROT W: sb_ctl R> -hwnd@ SetScrollRange DROP ;

: get-min ( ctl -- min)
  scrollminmax DROP ;
: set-min ( min ctl -- )
  DUP -max@ SWAP setscrollminmax ;

: get-max ( ctl -- max)
  scrollminmax PRESS ;
: set-max ( max ctl -- )
  DUP -min@ -ROT setscrollminmax ; 

: hscroll ( -- ctl )
  scrolllike scrolls W: sbs_horz create-control >R
  R@ -xsize@ W: sm_cyhscroll GetSystemMetrics R@ resize
  ['] get-pos ['] set-pos -pos R@ setitem
  ['] get-min ['] set-min -min R@ setitem
  ['] get-max ['] set-max -max R@ setitem
  100 R@ -max!
  R> ;

: vscroll ( -- ctl )
  scrolllike scrolls W: sbs_vert create-control >R
  W: sm_cxvscroll GetSystemMetrics R@ -ysize@ R@ resize
  ['] get-pos ['] set-pos -pos R@ setitem
  ['] get-min ['] set-min -min R@ setitem
  ['] get-max ['] set-max -max R@ setitem
  100 R@ -max!
  R> ;

:NONAME
  lparam window@ TO thisctl
  wparam LOWORD thisctl -notify@ find-in-xtable DROP
; TO scrollctlproc

\ -----------------------------
\ Размещение объектов

: ctl-size ( ctl -- x y)
  DUP -calcsize@ ?DUP IF
    >R DUP R> EXECUTE
  ELSE
    DUP win-size
  THEN
  ROT -updown@ ?DUP IF
    win-size DROP ROT + 2- SWAP
  THEN
;

: (set-ud) ( ctl what -- )
  SWAP >R 0 W: udm_setbuddy R> -updown@ send DROP ;

\ спин делается видимым, так как система почему-то при добавлении
\ прячет его, если спин относится к полю ввода
: add-ud ( ctl -- ) DUP DUP -hwnd@ (set-ud) -updown@ winshow ;

: remove-ud ( ctl -- ) DUP ctl-size 2 PICK 0 (set-ud) ROT resize ;

: ctlmove  ( x y ctl -- )
  DUP -ctlmove@ ?DUP 0= IF ['] winmove THEN
  ( x y ctl xt -- )
  OVER -updown@ IF
    OVER remove-ud  OVER >R EXECUTE  R> add-ud
  ELSE
    EXECUTE
  THEN ; 

:NONAME  ( x y ctl -- )
  DUP -ctlresize@ ?DUP 0= IF ['] resize THEN
  ( x y ctl xt -- )
  OVER -updown@ IF
    OVER remove-ud  OVER >R EXECUTE  R> add-ud
  ELSE
    EXECUTE
  THEN ; TO ctlresize

: ctlshow { ctl -- }
  ctl -ctlshow@ ?DUP IF
    ctl SWAP EXECUTE
  ELSE
    ctl winshow
  THEN
  ctl -updown@ ?DUP IF winshow THEN ;

: ctlhide { ctl -- }
  ctl -ctlhide@ ?DUP IF
    ctl SWAP EXECUTE
  ELSE
    ctl winhide
  THEN
  ctl -updown@ ?DUP IF winhide THEN ;

: ctl-destroy ( ctl -- ) >R
  R@ -tooltipexists@ IF 0 R@ W: ttm_deltoola common-tooltip-op THEN
  R> destroy-window 
;

WINAPI: GetParent  USER32.DLL
WINAPI: SetParent USER32.DLL

: link-to-current ( ctl -- )
  >R current-window -hwnd@ R@ -hwnd@ SetParent DROP
  current-window R> -parent! ;

: set-parent ( ctl -- )
  DUP link-to-current
  -updown@ ?DUP IF link-to-current THEN ;

: place ( x y ctl -- )
  DUP set-parent
  SWAP current-window -minustop@ + SWAP
  DUP >R ctlmove R> ctlshow ;

: another-place ( x y ctl -- )
  SWAP current-window -minustop@ + SWAP ctlmove ;

: remove ( ctl -- ) 
  DUP winhide 0 SWAP -parent! ;

\ Быстрая инициализация текущего объекта
\ (/ -font f  -color blue  -bgcolor white  /)

\ Более хитрые вещи:
\ (/ -name value-var  -size 100 200 /)

-1 == -size

: (/  (( ;
: /) ( ... -- )
  )) 2DUP < IF
  DO
    I @ CASE
    -size OF 
      I CELL- @ I 2 CELLS - @ this ctlresize
      3 ( параметра)
    ENDOF
      I CELL- @ SWAP this setproc
      2 ( параметра)
    END-CASE
  CELLS NEGATE +LOOP
  ELSE
    2DROP
  THEN remove-stack-block
;

: -name ( ->bl; -- ) POSTPONE this [COMPILE] TO ; IMMEDIATE

: max-win-size ( win -- w h)
  \ -hwnd@ GetParent ?DUP IF 
  \  window@ DUP -xsize@ SWAP -ysize@
  \ ELSE
  \  screen-x 10 - screen-y 20 - ( с небольшой поправкой на оформление окна)
  \ THEN ;
  DROP screen-x 10 - screen-y 20 - ;

S" ~ygrek/~yz/lib/wingrid.f" INCLUDED

: -boxed ( -- ) "" groupbox  cur-grid @ :gbox ! ;
: -bevel ( -- ) groupedge cur-grid @ :gbox ! ;


\ Модальные диалоги ==================

: MODAL... ( z -- oldmw olddlg )
  modal-window dialog 
  winmain dialog-window TO dialog 
  ROT dialog -text! ;


: INITMODAL ( grid -- ) dialog -grid! ;

: SHOWMODAL
  dialog wincenter
  dialog -hwnd@ TO modal-window
  FALSE end-dialog
  dialog winshow ;

: LOOPMODAL { \ [ 7 CELLS ] msg -- }
  0 TO dialog-termination
  BEGIN
    0 0 0 msg GetMessageA DROP
    msg ?dialog 0= IF
      msg TranslateMessage DROP
      msg DispatchMessageA DROP
    THEN
  dialog-termination UNTIL ;

: HIDEMODAL
  0 TO modal-window
  dialog winhide ;

: SHOW ( grid -- )
  INITMODAL
  SHOWMODAL
  LOOPMODAL
  HIDEMODAL ;

: ...MODAL  ( oldmw olddlg -- )
  dialog destroy-window 
  DUP TO dialog ?DUP IF winfocus THEN
  TO modal-window
  0 TO dialog-termination
;
