
\ 23.Jun.2001 Sat 00:21 Ruv  »справил зевок в W: WM_PAINT
\  было    handle @ EndPaint DROP
\  надо    ps[ handle @ EndPaint DROP
\  в NONAME дл€ WNDPROC: (WIN-GATE) исправлено
\  было    dep DEPTH - 0= IF 0 THEN
\  надо    DEPTH dep - 0= IF 0 THEN

REQUIRE Window   ~day\joop\win\window.f
REQUIRE WinClass  ~day\joop\win\winclass.f
REQUIRE Stack  ~day\joop\lib\stack.f
\ REQUIRE MENU    ~day\joop\win\menu.f
REQUIRE Font    ~day\joop\win\font.f


\ ~ac\lib\memory\heap_enum.f

<< :fillMessage
<< :onLMouseDown
<< :onCtlColor
<< :showMessage
<< :processMessage
<< :processMessages
<< :idle
<< :handleMessage
<< :run
<< :create
<< :showModal
<< :modalResult!
<< :setMenu
<< :createMenu
<< :createPopup
<< :trackPopup
<< :createPopup
<< :onPaint

0
4 -- MSG.hwnd
4 -- MSG.uint
4 -- MSG.wparam
4 -- MSG.lparam
4 -- MSG.time
8 -- MSG.pt
CONSTANT /MSG


:NONAME { lparam wparam uint hwnd \ heap dep -- }
     DEPTH  -> dep
     THREAD-HEAP @ -> heap
     MAIN-HEAP THREAD-HEAP !

     hwnd HANDLE>OBJ
     ?DUP 0=
     IF
       uint WM_NCCREATE =
       IF
         lparam @ hwnd OVER obj!
         lparam wparam uint hwnd lparam @ :fillMessage
         WM_NCCREATE SWAP WM:
       ELSE
         lparam wparam uint hwnd
         DefWindowProcA
       THEN
     ELSE \ »щем и вызываем обработчик
       uint OVER [CHAR] W SearchWM
       IF
           lparam wparam uint hwnd DUP HANDLE>OBJ :fillMessage           
           SWAP ExecuteMethod
       ELSE 
         DROP
         lparam wparam uint hwnd
         DefWindowProcA
       THEN
     THEN
     heap THREAD-HEAP !
     DEPTH dep - 0= IF 0 THEN
;

WNDPROC: (WIN-GATE)
' (WIN-GATE) TO WIN-GATE


:NONAME { stack hwnd -- true }
       hwnd GetActiveWindow <>
       IF
         FALSE hwnd EnableWindow
         stack :push
         hwnd stack :push
       THEN
       TRUE
;

WNDPROC: DisableWindowInTask

: DisableTaskWindows ( param -- )
   ['] DisableWindowInTask GetCurrentThreadId EnumThreadWindows DROP
;


: EnableTaskWindows { stack -- }
    stack :count 0
    ?DO
      stack :pop DUP IsWindow
      IF
        stack :pop 0= SWAP EnableWindow DROP
      ELSE
        DROP stack :drop
      THEN
    LOOP
;

USER-VALUE dc \ дл€ WM_PAINT

pvar: <lparam
pvar: <font

CLASS: FrameWindow <SUPER Window

 /MSG VAR      vMSG    \ размер структуры оконных сообщений    
 CELL VAR      vClose
 CELL VAR      menu

      CELL VAR      lparam 
      CELL VAR      wparam
      CELL VAR      message
      CELL VAR      hwnd
      CELL VAR      ModalResult
      CELL VAR      vExStyle
      CELL VAR      vStyle
      CELL VAR      popupMenu
      Font OBJ      font
      CELL VAR      vClass

: :init
    own :init
    WS_CAPTION  WS_SYSMENU OR WS_THICKFRAME OR WS_MINIMIZEBOX OR
    WS_MAXIMIZEBOX OR  WS_POPUP OR vStyle !
    WS_EX_CONTROLPARENT vExStyle !
    THREAD-HEAP @ TO MAIN-HEAP
    DefWinClass vClass !
;

: :fillMessage ( l w m h -- )
     hwnd !
     message !
     wparam !
     lparam !
;

: :bringToTop
    handle @ BringWindowToTop DROP
;

: :showMessage ( addr u -- )
   DROP >R MB_OK MB_ICONINFORMATION OR own :getText DROP R> handle @ MessageBoxA DROP
;

: :processMessage ( -- bool )
  PM_REMOVE 0 0 0 vMSG PeekMessageA DUP
  IF
    vMSG MSG.uint @ WM_QUIT <>
    IF
       vMSG TranslateMessage DROP
       vMSG DispatchMessageA DROP
    ELSE
       TRUE vClose !
       ModalResult 0!
    THEN
  THEN
;

: :processMessages ( -- )
  BEGIN
    own :processMessage 0=
  UNTIL
;

: :idle ( -- ) 
    WaitMessage DROP
;

: :handleMessage ( -- )
   own :processMessage 0=
   IF
     vClose @ 0= IF own :idle THEN
   THEN
;

: :run ( -- )
   BEGIN
     own :handleMessage
     vClose @
   UNTIL
;

(
W: WM_PARENTNOTIFY
   wparam @ LOWORD
   WM_LBUTTONDOWN =
   IF
     lparam @ DUP HIWORD
     SWAP LOWORD handle @
     ChildWindowFromPoint
     HANDLE>OBJ <OnClick @
     self SWAP EXECUTE
   THEN
;
)
: :onPaint 
;

W: WM_PAINT { \ ps[ /PS ] }
   ps[ handle @ BeginPaint TO dc
   SP@ >R
   self :onPaint
   R> SP!
   ps[ handle @ EndPaint DROP
   0
; 

W: WM_COMMAND
     lparam @ ?DUP
     IF \ контрол
       HANDLE>OBJ
       wparam @ HIWORD SWAP
       [CHAR] C ->WM
     ELSE \ меню
       handle @ GetMenu 0<>
       IF \ есть меню
         wparam @ LOWORD ?DUP
         IF \ у пункта меню есть сообщение окну
            self [CHAR] M ->WM
         THEN
       THEN 
     THEN
     0
;

W: WM_NCCREATE
   TRUE
;

W: WM_CLOSE
   handle @ GetParent DUP IsWindow
   IF TRUE SWAP EnableWindow DROP ELSE DROP THEN \ „тобы по ShowModal не моргало
   own :hide
   TRUE vClose !
   0
;

: :createPopup ( -- h)
   0
;

: :trackPopup { x y h -- }
   h 0= IF EXIT THEN
   0 handle @ 0 x y
   TPM_NONOTIFY TPM_RETURNCMD OR
   h TrackPopupMenu self [CHAR] M ->WM
;

\ „тобы создать свое меню - перегрузите
: :createMenu ( -- h)
   0
;

W: WM_CONTEXTMENU
   lparam @ LOWORD
   lparam @ HIWORD SWAP
   popupMenu @
   self :trackPopup
   0
;

: :create { owner -- }
    self       \ lpParam
    HINST
    self :createMenu  DUP menu ! \ hmenu
    owner DUP IF <handle @ THEN
    CW_USEDEFAULT DUP DUP DUP
    vStyle @  owner 0= IF WS_OVERLAPPED ELSE 0 THEN OR
    0
    vClass @ :register
    vExStyle @
    CreateWindow DROP
    self :createPopup popupMenu !
    font :create
;

\ ћаксимум 64 открытых окон приложени€

: :showModal { \ stack aw -- u }
    GetActiveWindow -> aw
    own :show
    Stack :new -> stack
    stack DisableTaskWindows \ ќтключить все окна и запомнить их состо€ние
    TRUE handle @ EnableWindow DROP    
    own :run
    stack EnableTaskWindows \ восстановить состо€ние окон
    stack :free
    aw SetActiveWindow DROP        
    ModalResult @
;

: :modalResult! ( u -- )
     ModalResult !
     TRUE vClose !
;

: :setMenu ( menu -- )
   handle @ SetMenu DROP
;

: :free
    menu @ IsMenu IF menu @ DestroyMenu DROP THEN
    own :free
;    

;CLASS
