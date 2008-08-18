REQUIRE CLASS: ~nn/class/class.f
REQUIRE Window ~nn/lib/win/window.f
\ REQUIRE Control  ~nn/lib/win/control.f
REQUIRE WinClass  ~nn/lib/win/winclass.f
REQUIRE Stack  ~nn/class/stack.f
\ REQUIRE MENU    ~day\joop\win\menu.f
REQUIRE Font    ~nn/lib/win/font.f
REQUIRE { ~nn/lib/locals.f
REQUIRE AddNode ~nn/lib/list.f

REQUIRE QWNDPROC: ~nn/lib/qwndproc.f
REQUIRE HEAP-SAVE ~nn/lib/globalloc.f
\ REQUIRE Control ~nn/lib/win/control.f

\ ~ac\lib\memory\heap_enum.f

0
4 -- MSG.hwnd
4 -- MSG.uint
4 -- MSG.wparam
4 -- MSG.lparam
4 -- MSG.time
8 -- MSG.pt
CONSTANT /MSG

WINAPI: IsDialogMessage user32.dll

WITH Stack

:NONAME { stack hwnd -- true }
       hwnd GetActiveWindow <>
       IF
         FALSE hwnd EnableWindow
         stack => Push
         hwnd stack => Push
       THEN
       TRUE
;

WNDPROC: DisableWindowInTask

: DisableTaskWindows ( param -- )
   ['] DisableWindowInTask GetCurrentThreadId  EnumThreadWindows DROP
;


: EnableTaskWindows { stack -- }
    stack => Count 0
    ?DO
      stack => Pop DUP IsWindow
      IF
        stack => Pop 0= SWAP EnableWindow DROP
      ELSE
        DROP stack => Drop
      THEN
    LOOP
;

ENDWITH

USER-VALUE dc \ дл€ WM_PAINT

\ pvar: <lparam
\ pvar: <font

CLASS: FrameWindow <SUPER Window

 /MSG FIELD    vMSG    \ размер структуры оконных сообщений
      var vClose
      var vModalResult
      var vHeap
      var vPopupMenu
      var vFont
      var vClass

      var vAutoList     \ list of controls

      var vAccel

      var onKeyDown
      var onKeyUp
      var onExit

CONSTR: init
    init
    WS_CAPTION  WS_SYSMENU OR ( WS_THICKFRAME OR) WS_MINIMIZEBOX OR
    ( WS_MAXIMIZEBOX OR)  WS_POPUP OR vStyle !
    WS_EX_CONTROLPARENT vExStyle !
    THREAD-HEAP @ TO MAIN-HEAP
\    WinClass NEW vClass
    DefWinClass SELF vClass !
;

M: AddAuto ( obj -- ) vAutoList AppendNode ;

M: BringToTop   handle @ BringWindowToTop DROP ;

M: ShowMessage ( addr u -- )
    DROP >R MB_OK MB_ICONINFORMATION OR GetText DROP R> handle @
    MessageBoxA DROP ;

M: TranslateAccel
    vAccel @
    IF vMSG vAccel @ handle @ TranslateAcceleratorA
\     [ DEBUG? ] [IF] ( DUP IF) ." TranslateAccelerator=" DUP . GetLastError . CR ( THEN) [THEN]
    ELSE
        0
    THEN
;

: ?ProcessKey ( n a -- )
    @ ?DUP
    IF
        SWAP vMSG MSG.uint @ =
        IF
            vMSG MSG.wparam @ wparam !
            vMSG MSG.lparam @ lparam !
            EXECUTE RDROP
        ELSE DROP THEN
    ELSE DROP THEN
;

M: ProcessKey ( -- ?)
    WM_KEYDOWN onKeyDown ?ProcessKey
    WM_KEYUP onKeyUp ?ProcessKey
    FALSE
;

M: ProcessMessage ( -- bool )
  PM_REMOVE 0 0 0 vMSG PeekMessageA DUP
  IF
    vMSG MSG.uint @ WM_QUIT <>
    IF
       ProcessKey 0=
       IF
           vMSG handle @ IsDialogMessage 0=
           IF
              vMSG TranslateMessage DROP
              vMSG DispatchMessageA DROP
           THEN
        THEN
    ELSE
       TRUE vClose !
       vModalResult 0!
    THEN
  THEN
;

M: ProcessMessages ( -- )
  BEGIN
    ProcessMessage 0=
  UNTIL
;

\ idle об€зательно наследовать по INHERIT, причем в конце метода
M: Idle ( -- )   WaitMessage DROP ;

M: HandleMessage ( -- )
   ProcessMessage 0=
   IF
     vClose @ 0= IF Idle THEN
   THEN
;

M: Run ( -- )
   BEGIN
     HandleMessage
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
     HANDLE>OBJ OnClick @
     this SWAP EXECUTE
   THEN
;
)

\ var vNoNotify

W: WM_NOTIFY
\    ." WM_NOTIFY " this @ . CR
    lparam @ 2 CELLS + @     \ DUP HEX U. DECIMAL
    lparam @ @               \ HEX DUP U. DECIMAL

    HANDLE>OBJ               \ DUP . CR
    >R
    R@ IF lparam @ 0 0 handle @ R@ => FillMessage THEN
    R> [CHAR] N ->WM
;


VM: OnPaint  ;


W: WM_PAINT
   32 RALLOT DUP
   handle @ BeginPaint TO dc
   SP@ >R
   OnPaint
   R> SP!
   handle @ EndPaint DROP
   32 _RFREE
   0
;


W: WM_COMMAND
\ [ DEBUG? ] [IF]   lparam @ . wparam @ . CR [THEN]
     lparam @ 0= wparam @ DUP 0<> SWAP HIWORD 0= AND OR
     IF \ меню
       handle @ GetMenu 0<>
       IF \ есть меню
         wparam @ LOWORD ?DUP
         IF \ у пункта меню есть сообщение окну
            this [CHAR] M ->WM
         THEN
       THEN
     ELSE \ контрол
\       GWL_STYLE OVER GetWindowLongA HEX . DECIMAL CR
\  [ DEBUG? ] [IF] ." WM_COMMAND2:" HEX handle @ . lparam @ . wparam @ . DECIMAL CR [THEN]
       wparam @ HIWORD
       lparam @ HANDLE>OBJ
       [CHAR] C ->WM
     THEN
     0
;

(
W: WM_SYSCOMMAND
 [ DEBUG? ] [IF] ." WM_SYSCOMMAND:"  handle @ . lparam @ . wparam @ . CR [THEN]
;
)

W: WM_NCCREATE
   TRUE
;

VM: OnExit ;

W: WM_CLOSE
   OnExit
   handle @ GetParent DUP IsWindow
   IF TRUE SWAP EnableWindow DROP ELSE DROP THEN \ „тобы по ShowModal не моргало
   Hide
   TRUE vClose !
   0
;

VM: CreatePopup ( -- h) 0 ;

M: TrackPopup { x y h -- }
   h 0= IF EXIT THEN
   0 handle @ 0 x y
   TPM_NONOTIFY TPM_RETURNCMD OR
   h TrackPopupMenu this [CHAR] M ->WM
;

VM: GetPopupMenu vPopupMenu @ ;

W: WM_CONTEXTMENU
   lparam @ LOWORD
   lparam @ HIWORD SWAP
   GetPopupMenu TrackPopup
   0
;

VM: Type vClass @ ->CLASS WinClass Register 0 ;

\ 14 VALUE DlgFontHeight
\ : GetDlgBaseUnits1  GetDialogBaseUnits  ;

M: Create { owner -- }
    Font NEW vFont !
    14 vFont @ ->CLASS Font height !
\    vFont @ ->CLASS Font height @ TO DlgFontHeight
\    ['] GetDlgBaseUnits1 TO GetDlgBaseUnits
    COLOR_BTNFACE GetSysColorBrush vClass @ ->CLASS WinClass hbrBackground !
    vFont @ ->CLASS Font Create
\      ." before create window" .S
    owner Create
\      ." after create window" .S
    CreatePopup vPopupMenu !
;

\ ћаксимум 64 открытых окон приложени€

M: ShowModal { \ stack aw -- u }
\      ." handle = " handle @ . CR
\      ." parent = " hParent @  . CR
\      ." GetActiveWindow = " GetActiveWindow . CR
GLOBAL
    GetActiveWindow TO aw
    Show
    Stack NEW TO stack
    stack DisableTaskWindows \ ќтключить все окна и запомнить их состо€ние
    TRUE handle @ EnableWindow DROP
    Run
    stack EnableTaskWindows \ восстановить состо€ние окон
    stack DELETE
    hParent @ ?DUP 0= IF aw THEN SetActiveWindow DROP
    vModalResult @
LOCAL
;

M: ModalResult! ( u -- )
     vModalResult !
     Hide
     TRUE vClose !
;

M: SetMenu ( menu -- )  handle @ SetMenu DROP ;


DESTR: free
    vMenu @ IsMenu IF vMenu @ DestroyMenu DROP THEN
    vAccel @ ?DUP IF DestroyAcceleratorTable DROP THEN
    free
;
: obj! { h obj -- }
\ «аписывает self в GWL_USERDATA
    h obj => handle !
    obj GWL_USERDATA h SetWindowLongA DROP
;

: h. BASE @ >R HEX . R> BASE ! ;
(
 USER-VALUE lparam
 USER-VALUE wparam
 USER-VALUE uint
 USER-VALUE hwnd
 USER-VALUE heap
 USER-VALUE dep
)
\ 0 VALUE LEVEL
\ : .LEVEL ." level=" LEVEL . ;
\ : LEVEL+ LEVEL + TO LEVEL ;

:NONAME { lparam wparam uint hwnd \ heap dep -- }
\    BASE @ HEX hwnd . uint . wparam . lparam . CR BASE !
\    TO hwnd TO uint TO wparam TO lparam
\    LEVEL 1 = IF 0 EXIT THEN
\     1 LEVEL+ .LEVEL
\     HEX RP@ . SP@ . DEPTH .
\     HEX  ." WinProc: " hwnd . uint . wparam . lparam . CR  DECIMAL
\     RP@ 256 DUMP CR

     DEPTH  TO dep
     THREAD-HEAP @ TO heap
     MAIN-HEAP THREAD-HEAP !

     hwnd HANDLE>OBJ
     ?DUP 0=
     IF
\       ." Not Object!" CR
       uint WM_NCCREATE =
       IF
         lparam @ hwnd OVER obj!
         lparam wparam uint hwnd lparam @ => FillMessage
         WM_NCCREATE SWAP WM:
       ELSE
         lparam wparam uint hwnd  DefWindowProcA
       THEN
     ELSE \ »щем и вызываем обработчик
\       ." Object. " DUP h. CR
       uint OVER [CHAR] W SearchWM
       IF
\           ." Ok. Message handler found: " uint h. CR
           lparam wparam uint hwnd DUP HANDLE>OBJ => FillMessage
           SWAP ExecuteMethod
\           ." AfterExec" CR
       ELSE
\         ." Message handler not found: " uint h. CR
         DROP
         lparam wparam uint hwnd DefWindowProcA
       THEN
     THEN
     heap THREAD-HEAP !

\     dep DEPTH - DUP 0= IF DROP 0 ELSE . ." depth1=" dep . ." depth2=" DEPTH . CR THEN
     DEPTH dep - 0= IF 0 THEN
\     .LEVEL -1 LEVEL+ HEX RP@ . SP@ . DEPTH . CR DECIMAL
;

\ QWNDPROC: (WIN-GATE)
\ (WIN-GATE) TO WIN-GATE
WNDPROC: (WIN-GATE)
 ' (WIN-GATE) TO WIN-GATE

;CLASS

\ : h. BASE @ HEX SWAP . BASE ! ;

