\ 12.Jul.2001 Thu 18:59  Ruv
\ 16.Jul.2001 Mon 14:56  - переписанно. 

\ за пример брался  modem-monitor\monitor_wnd.f by AC

\ InitIcons ( -- ) \ перед использованием компонента (Поток должен успеть запустится до вызова NewIconPlace)
\ FreeIcons ( -- ) \ когда компонент больше не нужен. Удаляет все иконки из трея.
\ NewIconPlace ( -- place ) \ место. должно быть для каждой иконки. (однопоточное слово).
\   Нижеследующие слова можно употреблять в любом порядке и в любом количестве 
\ IconHint! ( addr u  place -- ) \ хинт для иконки. Если иконка показана, то обновляется.
\ IconFile! ( a u  place -- ) \ файл иконки. Если иконка есть в трее, то она обновляется.
\ IconImage! ( hImage  place -- ) \ или любым образом полученная картинка для иконки
\ IconToken! ( param xt  place -- )
\   если установлено, то по приходу сообщения от иконки вызывется xt ( wnd event param -- )
\ ShowIcon ( place -- ) \ показать иконку в трее, если еще не показанна
\ HideIcon ( place -- ) \ убрать иконку из трея, если она там есть
\ При смене картинок предыдущая картинка автоматически освобождается. Утечек нет.

REQUIRE MODULE:         spf_modules.f
REQUIRE TUCK            spf_ext.f
REQUIRE Create-TrayIcon ~pinka\lib\win\tray\notify_icon_ex.f
REQUIRE Wait            ~pinka\lib\multi\synchr.f
REQUIRE PostMessageA    ~pinka\lib\multi\messages.f

MODULE: VocTrayIconsSupport

\ ===============================
\ component's data structures

0
\ 1 CELLS --   p.link
 1 CELLS --   p.xt  \ xt ( event param -- )
 1 CELLS --   p.xt_param
 1 CELLS --   p.ic_id   \ NOTIFYICONDATA
 1 CELLS --   p.msg
 1 CELLS --   p.hImage
64 CHARS --   p.hint
 1 CELLS --   p.icon-fname
CONSTANT /iconplace

0 VALUE IconWindow
0 VALUE IconThread
\ VARIABLE IconList   IconList 0!
0 VALUE Icons \ array

WM_USER 10 +  CONSTANT Icon0#

30 VALUE #MaxIcons
 0 VALUE #Icons


: FromIcon? ( msg -- place true | false )
  Icon0# - DUP #Icons U< IF
  CELLS Icons + @  TRUE  ELSE
  DROP FALSE             THEN
;
: AddIcon ( place -- )
  #Icons #MaxIcons = ABORT" Too many icons."
  Icons #Icons CELLS + !
  #Icons 1+ TO #Icons
;

\ ===============================
\ Window's procedure

: (IconWindowProc) { lparam wparam msg wnd \ pl -- lresult }
  ." IconWindowProc:  msg= " msg . CR
  msg FromIcon?     IF
  -> pl
  ."  - from icon. event= " lparam . CR
  pl p.xt @  IF
  wnd
  lparam \ event
  pl p.xt_param @
  pl p.xt @  ( wnd event param -- )
  EXECUTE    THEN   THEN

  lparam wparam msg wnd   wnd WindowOrigProc
;
' (IconWindowProc)  WNDPROC: IconWindowProc

\ ===============================
\ Window's thread

: (IconTask) ( 0 -- )
  DROP
  S" STATIC"  WS_DISABLED WS_MINIMIZE OR WS_OVERLAPPEDWINDOW OR  
  0  Window  TO IconWindow    IconWindow IF
  ['] IconWindowProc  IconWindow  WindowSubclass
  IconWindow MessageLoop  
  IconWindow WindowDelete               
          0  TO IconWindow               THEN
; ' (IconTask)  TASK: IconTask

\ ===============================
\ control

: ?free ( addr_of_memblock -- )
  DUP @ DUP IF FREE THROW 0! ELSE 2DROP THEN
;

EXPORT

: ShowIcon ( place -- )  >R
  R@ p.ic_id @ IF ( \ уже показана ) RDROP EXIT THEN
  R@ p.hint ASCIIZ>  
  R@ p.icon-fname @ ?DUP IF ASCIIZ> ELSE 0 0 THEN
  R@ p.msg @  IconWindow
  Create-TrayIcon  R@ p.ic_id !
  R@ p.hImage @ ?DUP IF R@ p.ic_id @ Modify-TrayIconImage THEN
  RDROP
;
: HideIcon ( place -- )
  p.ic_id DUP @ IF DUP @ Delete-TrayIcon 0! ELSE DROP THEN
;
: IconToken! ( param xt  place -- )
\ xt ( wnd event param -- )
  TUCK
  p.xt !  p.xt_param !
;
: IconToken@  ( place -- param xt )
  DUP p.xt_param @ SWAP p.xt @
;
: IconFile! ( a u  place -- )
  >R
  R@ p.hImage 0!  R@ p.icon-fname ?free
  2DUP HEAP-COPY  R@ p.icon-fname !
  R> p.ic_id @ ?DUP IF Modify-TrayIconFile ELSE 2DROP THEN
;
: IconImage! ( hImage  place -- )
  2DUP p.hImage !
  DUP p.icon-fname  ?free
  p.ic_id @ ?DUP IF Modify-TrayIconImage ELSE DROP THEN
;
: IconHint! ( addr u  place -- )
  >R  2DUP 64 MIN R@ p.hint DUP 64 ERASE SWAP  CMOVE
  R> p.ic_id @ ?DUP IF Modify-TrayIconText ELSE 2DROP THEN
;
: NewIconPlace ( -- place )
  IconWindow 0= IF 100 PAUSE THEN
  IconWindow 0= IF 500 PAUSE THEN
  IconWindow 0= ABORT" Icons not initialized"

  /iconplace ALLOCATE THROW >R
  R@ /iconplace ERASE
  Icon0# #Icons + R@ p.msg !
  R@ AddIcon
  R>
;

\ ===============================
\ Initialization 

: InitIcons ( -- )
  Icons IF EXIT THEN
  0 TO #Icons
  #MaxIcons CELLS ALLOCATE THROW   TO Icons
  Icons #MaxIcons CELLS ERASE
  0 IconTask START                 TO IconThread
;

DEFINITIONS
: FreeIcon ( place -- )
\  DUP p.ic_id @ Delete-TrayIcon
  DUP HideIcon
  DUP p.icon-fname ?free
  FREE THROW
;
EXPORT

: FreeIcons ( -- )
  Icons 0= IF EXIT THEN
  Icons #Icons CELLS + Icons ?DO I @ FreeIcon 1 CELLS +LOOP
  0 0 WM_CLOSE  IconWindow PostMessageA DROP
  IconThread 2000 Wait   DROP \ поток не может завершить сам себя,
  \ IconThread TERMINATE      \ поэтому жду ограниченно на случай вызова из IconToken-а
  IconThread CloseHandle DROP   0 TO IconThread
  Icons FREE THROW              0 TO Icons
;


;MODULE

\ : BYE FreeIcons BYE ;

 (
\ ALSO  VocTrayIconsSupport
InitIcons
NewIconPlace VALUE p  p . CR

: test \ wnd event param -- \
  ." param= " . CR
  ." event= " . CR
  ." wnd=   " . CR   
;

11 ' test p IconToken!

S" modem16.ico" p IconFile!
S" Test eserv monitor" p IconHint!
p ShowIcon
PREVIOUS
\ )

