\ FARLIB 0.0

\ $Id$

\ Полностью копия с WinLib by ~yz 
\ http://www.forth.org.ru/~yz/lib/winlib.f

REQUIRE ACCERT( lib/ext/debug/accert.f

\ level 4 - no debug info
\ level 3 - grid placement debug
\ level 2 - common debug
\ level 1 - extra verbose debug
4 ACCERT-LEVEL ! 

REQUIRE "       ~yz/lib/common.f
REQUIRE PROC:   ~yz/lib/proc.f
REQUIRE {       lib/ext/locals.f
REQUIRE LOAD-CONSTANTS     ~yz/lib/const.f
REQUIRE >>      ~yz/lib/data.f
REQUIRE MGETMEM ~yz/lib/gmem.f
S" ~ygrek/lib/data/farplugin.const" LOAD-CONSTANTS

REQUIRE table ~ygrek/~yz/lib/wincore.f

REQUIRE DEFSTRUCT  ~ygrek/lib/aus.f
REQUIRE TPluginStartupInfo  ~ygrek/lib/far/struct.f
DEFSTRUCT TPluginStartupInfo FARAPI
FARAPI. /SIZE@  FARAPI. StructSize !

MODULE: TFarDialogItemArray
  PREVIOUS ALSO FORTH \ This prevents from intercalling words cause they behave differently
                      \ when called from outside and when called from within this vocabulary
                      \ so you cant use buf in get
  : buf ( n addr -- addr u ) SWAP TFarDialogItem::/SIZE * ;
  : get ( n addr -- addr' ) SWAP TFarDialogItem::/SIZE * + ;
;MODULE

0 VALUE Items \ Указатель на массив структур TFarDialogItem
AUS TFarDialogItemArray Items

0 VALUE ItemsNumber \ Количество этих структур

0 VALUE winmain \ Главный Диалог
0 VALUE current-window

\ полученные параметры функции
USER-VALUE hdlg
USER-VALUE message
USER-VALUE param2
USER-VALUE param1

USER-VALUE thiswin
USER-VALUE thisctl

VECT del-grid


\ ----------------------------------------
\ Свойства диалога
0 table window
  item -hdlg		\ дескриптор диалога
  item -pre		\ выполняется до стандартной оконной процедуры
  item -dlgproc		\ оконная процедура
  item -messages	\ список обработчиков сообщений по умолчанию
  item -dflags		\ флаги 
  item -itemnotify	\ обработчики DN_* сообщений элементов диалога
\  item -color 		\ цвет букв
\  item -bgcolor set	\ цвет фона
  item -xsize		\ размер элемента по горизонтали
  item -ysize		\ размер элемента по вертикали
  item -grid set 	\ решетка окна
  item -gridresize     	\ процедура изменения размеров решетки
  item -param  		\ параметр
endtable


\ --------------------------------------
\ Диалоговая функция по умолчанию

MESSAGES: default-dispatch

M: dm_close
   ACCERT2( CR ." DM_CLOSE" )
   thiswin -grid@ ?DUP IF del-grid THEN
   TRUE RETURN
   TRUE
M;

M: dn_initdialog
   hdlg thiswin -hdlg!
   TRUE RETURN
   FALSE
M;

MESSAGES;

\ -------------------------------

XLIST common-dialog-proclist
\ XLIST common-item-notify

\ : extend-item-notify  ( xtable -- ) common-item-notify insert-to-end ;

:NONAME ( param2 param1 msg hdlg -- result)
  TO hdlg  TO message  TO param1  TO param2
  ACCERT2( CR    ." hdlg=" hdlg . ." message=" message . ." param1=" param1 . ." param2=" param2 . )
  winmain TO thiswin
  thiswin 0= IF
    \ окно еще не сформировано
    ACCERT2( CR ." Not init" )
    param2 param1 message hdlg FARAPI. DefDlgProc @ API-CALL EXIT
  THEN
  ACCERT2( CR ." GO" )
  0 TO return-value
  message thiswin -pre@ ?find-in-xtable
  ACCERT1( CR ." pre done" )
  ?DUP 0= IF
    ACCERT1( CR ." Do messages..." )
    message thiswin -messages@ ?find-and-execute
    ACCERT1( CR ." messages done" )
    ?DUP 0= IF
      message thiswin -dlgproc@ ?find-in-xtable
      ACCERT1( CR ." dlgproc done" )
\      ?DUP 0= IF
\        message thiswin -itemnotify@ ?find-and-execute
\      THEN
    THEN
  THEN
  IF  \ кто-то обработал сообщение
    ACCERT2( CR ." RETURN-VALUE" )
    return-value
  ELSE
    ACCERT2( CR ." Def" )
    param2 param1 message hdlg FARAPI. DefDlgProc @ API-CALL
  THEN
  ACCERT2( CR ." Message processed" )
\  ." /" message .H DUP . CR
; WNDPROC: dispatch


\ --------------------------------------
\ Инициализация либы

FALSE VALUE ?INIT

: INITFARLIB
  ?INIT IF EXIT THEN

  default-dispatch common-dialog-proclist insert-to-begin
\  default-itemnotify common-item-notify insert-to-begin
  TRUE TO ?INIT
;

\ --------------------------------------

: NEWDIALOG ( -- )
 
  INITFARLIB

  window new-table TO winmain
  winmain TO current-window
  common-dialog-proclist winmain -messages!
\  common-item-notify winmain -itemnotify!
  20 winmain -xsize!
  10 winmain -ysize!
;

: winresize ( x y win -- ) >R R@ -ysize! R> -xsize! ;


: TFarDialogItemInfo { item \ -- }
   TEMPAUS TFarDialogItem item

   CR ." ItemType = " item. ItemType @ .
   CR ." X1 Y1 X2 Y2 = " item. X1 @ . item. Y1 @ . item. X2 @ . item. Y2 @ .
   CR ." Focus = " item. Focus @ .
   CR ." Extra = " item. Extra @ .
   CR ." Flags = " item. Flags @ .
   CR ." DefaultButton = " item. DefaultButton @ .
   CR ." Data = " item. Data ASCIIZ> TYPE
;

: TFarDialogItemInfos ( n -- )
   0 DO
     I Items. get TFarDialogItemInfo
     CR
   LOOP
   CR ." ===================================="
;

\ --------------------------------------
\ поехали

: RUNDIALOG ( -- )

  ItemsNumber DUP 0 = ABORT" Empty dialog"

 \ 5 TFarDialogItemInfos

  winmain -param@ \ Param
  ['] dispatch \ FARWINDOWPROC
  winmain -dflags@ \ Flags
  0 \ Reserved
  ItemsNumber
  Items
  0 \ No help topic
  winmain -ysize@ 1+ winmain -xsize@ 1+ \ y2 x2
  -1 -1 \ y1 x1
  FARAPI. ModuleNumber @ \ PluginNumber
  FARAPI. DialogEx @ API-CALL

  ACCERT2( CR ." Exit=" DUP . )

  DROP

  winmain del-table
  0 TO winmain
  0 TO current-window
;












