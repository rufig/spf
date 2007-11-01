
NEEDS ~day\lib\staticlist.f


\ Defines message routes
 \ every CMsgController contains a list of controllers

( Контроллер сообщений это способ перехватывать Windows сообщения другим объектам
  не используя Windows очередь сообщений. Так как hype не поддерживает
  множественное наследование то мы динамически собираем цепочку обработчиков
  Windows сообщений, первым пунктом в цепочке является сам класс окна.
  Таким образом достигается изменение поведения классов без наследования,
  простым добавлением контроллеров в цепочку обработки Windows сообщений )

CWinBaseClass SUBCLASS CMsgController

    CELL PROPERTY parent-obj
    CELL PROPERTY bHandled
    CELL PROPERTY msgControllers

    CWinMessage OBJ msg
  
    CELL PROPERTY result

init:
     TlsIndex@ SUPER threadUserData!
     CELL /node + CreateList msgControllers!
;

: checkParentObj
    parent-obj@ ?DUP
    IF
       ^ checkWindow DROP
    THEN
;

: injectMsgController ( obj )
     DUP
     msgControllers@ AllocateNodeBegin /node + !
     SELF OVER :: CMsgController.parent-obj!

     DUP :: CMsgController.checkParentObj

     DEPTH >R
     ^ onAttached
     DEPTH R> - -1 = 0= ABORT" Wrong stack size in onAttached"
;

: onAttached ;

: sendWinMessage ( x*i c u -- x*i 0 | n 1 )
    FormatWordFromWinMessage \ 2DUP TYPE CR BYE
    SELF @ ( class ) ROT ROT HYPE::MFIND
    IF 
       EXECUTE TRUE
    ELSE 2DROP DROP 0
    THEN
;

: SetHandled ( f -- )
    parent-obj@ ?DUP
    IF 
       :: CMsgController.bHandled!
    ELSE bHandled!
    THEN
;

: (sendToControllers) ( node -- f )
    DEPTH >R

     /node + @ ( obj )

     DUP SELF = 0=
     IF
        \ initialize controller
        DUP >R msg @ R> :: CMsgController.msg !
     THEN

     TRUE bHandled!

     \ process message
     [CHAR] W msg message @ ROT :: CMsgController.sendWinMessage
     IF
        result ! bHandled@ INVERT
     ELSE TRUE
     THEN

    DEPTH R> - 0=  INVERT S" Wrong data stack size" SUPER abort
;

: sendMsgToContollers ( -- handled )
     msgControllers@  ?ForEach: (sendToControllers)
;

: message ( lpar wpar msg hwnd -- result )
    msg !
    sendMsgToContollers 0=
    IF
       SELF ^ inheritWinMessage
    ELSE result @
    THEN
;

: FreeControllerNode ( node )
    FREE THROW
;

: wthrow ( n )
   0= INVERT GetLastError 0= INVERT AND 
   IF  1 SUPER returnStack.
       GetLastError FormatMessage 
      -1 ROT ROT SUPER abort
   THEN
;

: -wthrow ( n )
   0= wthrow
;

dispose:
    ['] FreeControllerNode msgControllers@ ForEach
;

;CLASS

CMsgController SUBCLASS CWinMessageReceiver

  CELL PROPERTY thunkAddr
  CELL PROPERTY thunk-xt
  CELL PROPERTY oldWndProc
  CELL PROPERTY hWnd

: createThunk
    0 SELF 4 ['] SendFromThunk DynamicObjectWndProc 
    thunkAddr!
    thunk-xt!
;

: checkWindow ( -- hwnd )
   hWnd@ IsWindow 0= S" Wrong window handle" SUPER abort
   hWnd@
;

\ we might want to overload it
: defWinProc ( -- n )
    SUPER msg @ DefWindowProcA
;

: inheritWinMessage ( -- n )
    oldWndProc@ ?DUP
    IF 
       \ the control was subclassed
       >R SUPER msg @ R> CallWindowProcA
    ELSE
       SELF ^ defWinProc
    THEN
;

W: WM_COMMAND ( -- res )
\ Send C: message by id and M: (menu) message and A: (accelerator) message
   SUPER msg lParam @
   IF \ control
      SUPER msg wParam @
      DUP LOWORD SWAP HIWORD SWAP ( hiword loword )
      [CHAR] C SWAP
      SUPER sendWinMessage 0=
      IF
         DROP inheritWinMessage
      ELSE 0
      THEN
   ELSE \ menu or accelerator
      SUPER msg wParam @ HIWORD 1 =
      IF
         \ accelerator
         [CHAR] A SUPER msg wParam @ LOWORD
         SUPER sendWinMessage 0=
         IF
            inheritWinMessage
         ELSE 0
         THEN
      ELSE \ menu
         [CHAR] M SUPER msg wParam @ LOWORD
         SUPER sendWinMessage 0=
         IF
            inheritWinMessage
         ELSE 0
         THEN
      THEN
   THEN
;

W: WM_NOTIFY ( -- res )
\ Send N: message by id
    SUPER msg lParam @ ( nmhdr ) DUP 2 CELLS + @ ( code )
    [CHAR] N SUPER msg wParam @ SUPER sendWinMessage 0=
    IF
       2DROP inheritWinMessage
    THEN
;

\ W: WM_NCCREATE
\    DefWindowProcA
\      2DROP 2DROP TRUE
 \  inheritWinMessage
\ ;

: detach
    oldWndProc@ ?DUP
    IF
       GWL_WNDPROC
       hWnd@ SetWindowLongA SUPER -wthrow
       oldWndProc 0!
    THEN
;

W: WM_NCDESTROY ( -- res )
    \ clear out window handle

    \ detach object from window if it was attached
    detach

    0 hWnd! 0
;

: attach ( hwnd )
    hWnd ! checkWindow

    oldWndProc@
    IF detach THEN

    thunkAddr@ 0=
    IF createThunk THEN

    GWL_WNDPROC
    SWAP
    GetWindowLongA DUP SUPER -wthrow
    oldWndProc!

    thunk-xt@ ( xt hwnd )
    GWL_WNDPROC hWnd@
    SetWindowLongA SUPER -wthrow

    \ ловим Win сообщения
    SELF SUPER injectMsgController
;                                         

: set ( hwnd )
    oldWndProc@ IF detach THEN
    hWnd !
;

dispose:
    oldWndProc@ IF detach THEN

    thunkAddr@ ?DUP
    IF FreeExec THROW THEN
;

;CLASS

: InstallThunk { hwnd obj type \ tls }
       \ set hWnd
       hwnd obj :: CWinMessageReceiver.hWnd!

       \ all allocations are in a heap of the current thread
       TlsIndex@ -> tls
       obj :: CWinMessageReceiver.threadUserData@ TlsIndex!
       obj :: CWinMessageReceiver.createThunk

       \ replace DefWinProc by thunk

       obj :: CWinMessageReceiver.thunk-xt@
       type
       hwnd
       SetWindowLongA -WIN-THROW

       obj DUP :: CWinMessageReceiver.injectMsgController

       tls TlsIndex!
;

:NONAME ( lpar wpar msg hwnd -- u )
    OVER WM_NCCREATE = ( second message of any window )
    IF
       \ get object from lpCreateParams
       DUP 4 PICK @ GWL_WNDPROC InstallThunk

       \ send this message to the new object
       SendMessageA

    ELSE
       DefWindowProcA
    THEN
; WNDPROC: DefWinProc

( CWindow and its derivatives can be attached to any win control or window,
  and can get their messages )

CWinMessageReceiver SUBCLASS CWindow

: showMessage ( addr u -- )
   DROP MB_OK S" Message" DROP ROT SUPER hWnd@ MessageBoxA DROP
;

: sendMessage ( lpar wpar msg -- res )
   SUPER checkWindow
   SendMessageA
;

: postMessage ( lpar wpar msg -- )
   SUPER checkWindow
   PostMessageA SUPER -wthrow
;

: setText ( c-addr u -- )
   HEAP-COPY DUP 0 WM_SETTEXT sendMessage DROP
   FREE THROW
;

: getText ( addr u -- u1 )
\ addr - addr of text buffer
\ u - max length of text buffer
\ u1 - number of characters copied
   WM_GETTEXT sendMessage
;

: getTextLength ( -- u )
   0 0 WM_GETTEXTLENGTH sendMessage
;

: getStrText ( -- str )
    || D: str ||
    "" str !

    getTextLength DUP 1+ ALLOCATE THROW DUP >R SWAP ( addr u )
    2DUP 1+ getText DROP
    str @ STR!
    str @
    R> FREE THROW
;

: showWindow ( SW_HIDE|SW_SHOW -- )
   SUPER checkWindow
   ShowWindow DROP
;

: show SW_SHOW showWindow ;

: hide SW_HIDE showWindow ;

: getClientRect ( -- bottom right top left )
    || CRect r ||

    r addr SUPER checkWindow
    GetClientRect SUPER -wthrow
    r @
;

: updateWindow
   SUPER checkWindow UpdateWindow SUPER -wthrow
;

: moveWindow ( repaint height width y x )
   SUPER checkWindow
   MoveWindow SUPER -wthrow
;

: getWindowRect ( -- height width y x )
   || CRect r ||
   r addr SUPER checkWindow 
   GetWindowRect SUPER -wthrow
   r @
;

: getDlgItem ( id -- hwnd )
    SUPER checkWindow GetDlgItem DUP SUPER -wthrow
;

: invalidate ( fErase hRgn -- )
    SUPER checkWindow InvalidateRgn DROP
;

: modifyStyle ( n-add n-remove )
    GWL_STYLE SUPER checkWindow GetWindowLongA
    DUP SUPER -wthrow

    ROT OR
    SWAP INVERT AND
    GWL_STYLE SUPER checkWindow SetWindowLongA 
    SUPER -wthrow
;


: modifyStyleEx ( n-add n-remove )
    GWL_EXSTYLE SUPER checkWindow GetWindowLongA
    DUP SUPER -wthrow

    ROT OR
    SWAP INVERT AND
    GWL_EXSTYLE SUPER checkWindow SetWindowLongA 
    SUPER -wthrow
;

: destroyWindow 
    SUPER checkWindow DestroyWindow SUPER -wthrow
;

: setFocus
    SUPER checkWindow SetFocus DROP
;

: clientToScreen ( x y -- x1 y1 )
    || CPoint p ||
    p !
    p addr SUPER checkWindow ClientToScreen SUPER -wthrow
    p @
;

: getParent ( -- hwnd )
    SUPER checkWindow GetParent
    DUP SUPER -wthrow
;

: setFont ( hfont bRedraw -- )
    SWAP WM_SETFONT sendMessage DROP
;

;CLASS

CLASS CWinClass

     0 DEFS addr

OBJ-SIZE
     VAR     cbSize
     VAR     style
     VAR     lpfnWndProc
     VAR     cbClsExtra
     VAR     cbWndExtra
     VAR     hInstance
     VAR     hIcon
     VAR     hCursor
     VAR     hbrBackground
     VAR     lpszMenuName
     VAR     lpszClassName
     VAR     hIconSm
OBJ-SIZE SWAP -
CONSTANT /cbSize

     VAR     atom

init:
    /cbSize cbSize !
    CS_DBLCLKS CS_HREDRAW OR CS_VREDRAW OR CS_OWNDC OR style !

    \ create name of the window class if it is empty
    lpszClassName @ 0=
    IF
      BASE @ HEX
      SELF 0 <# # # # # # # # # S" FWL:" HOLDS #>
      HEAP-COPY lpszClassName !
      BASE !
    THEN

    HINST hInstance !
    COLOR_WINDOW  hbrBackground !
    ['] DefWinProc lpfnWndProc !
    1 HINST LoadIconA  hIcon !
    IDC_ARROW 0 LoadCursorA  hCursor !
;

: unregister
    atom @ ?DUP IF HINST SWAP UnregisterClassA -WIN-THROW 0 atom ! THEN
;

: register ( -- atom )
    unregister
    addr RegisterClassExA 0xFFFF AND DUP -WIN-THROW
    DUP atom !
;

dispose:
    unregister
    lpszClassName @ ?DUP IF FREE THROW THEN
;

;CLASS

( Window that can be created by ourselves )

CWindow SUBCLASS CCustomWindow

            VAR style
            VAR exStyle

: create ( id/hmenu parent-obj | 0 -- hwnd )
    >R
    SELF \ createParam
    HINST

    ROT \ hMenu or control ID

    R> DUP IF ^ checkWindow THEN \ parent
    SELF ^ initialPosition
    SELF ^ style @
    SUPER name HEAP-COPY DUP >R
    SELF ^ createClass
    SELF ^ exStyle @
    CreateWindowExA DUP SUPER hWnd ! ( for controls )
    DUP SUPER -wthrow
    R> FREE THROW

    DUP SELF ^ onCreated
;

: onCreated ( hwnd ) DROP ;

: initialPosition
    30 60 10 10
;

;CLASS


( Frame window that can contain controls and menu )

CCustomWindow SUBCLASS CFrameWindow

  CWinClass OBJ class

init:
    WS_CAPTION  WS_SYSMENU OR WS_THICKFRAME OR WS_MINIMIZEBOX OR
    WS_MAXIMIZEBOX OR WS_OVERLAPPED OR SUPER style !
    WS_EX_CONTROLPARENT SUPER exStyle !
;

dispose:
    SUPER hWnd@ 0= INVERT
    S" Window handle should be destroyed before destructor!" SUPER abort
;

: initialPosition ( x y w h )
   CW_USEDEFAULT DUP DUP DUP
;

: createClass ( -- atom )
    class register
;

: setMenu ( hmenu -- )
   SUPER checkWindow
   SetMenu SUPER -wthrow
;

;CLASS

CCustomWindow SUBCLASS CChildWindow 

init:
    WS_VISIBLE WS_CHILD OR WS_TABSTOP OR SUPER style OR!
;

;CLASS

CChildWindow SUBCLASS CChildCustomWindow

      CWinClass OBJ class

: createClass ( -- atom )
    class register
;

;CLASS

: REFLECT_NOTFICATIONS
" : message
    INHERIT 
    SUPER msg @ ReflectNotifications
    IF NIP THEN ;
 " STR@ EVALUATE ; IMMEDIATE