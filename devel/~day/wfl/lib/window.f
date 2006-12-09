
CWinBaseClass SUBCLASS CWinMessageReceiver

  CELL PROPERTY thunkAddr
  CELL PROPERTY thunk-xt
  CELL PROPERTY oldWndProc
  CELL PROPERTY hWnd

init:
     TlsIndex@ SUPER threadUserData!
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

: createThunk
    SELF DynamicObjectWndProc 
    thunkAddr!
    thunk-xt!
;

\ we might want to overload it
: defWinProc ( lpar wpar msg hwnd -- n )
    DefWindowProcA
;

: inheritWinMessage ( lpar wpar msg hwnd -- n )
    oldWndProc@ ?DUP
    IF 
       \ the control was subclassed
       CallWindowProcA
    ELSE
       SELF ^ defWinProc
    THEN
;

: sendWinMessage ( x*i c u -- x*i 0 | n 1 )
    FormatWordFromWinMessage \ 2DUP TYPE CR
    SELF @ ( class ) ROT ROT HYPE::(MFIND)
    IF
       SELF SWAP HYPE::SEND TRUE
    ELSE 0
    THEN
;

W: WM_COMMAND  ( lpar wpar msg hwnd )
\ Send C: message by id and M: (menu) message and A: (accelerator) message
   2SWAP OVER 
   IF \ control
      DUP LOWORD OVER HIWORD SWAP ( hiword loword )
      [CHAR] C SWAP
      sendWinMessage 0=
      IF
         DROP 2SWAP inheritWinMessage
      ELSE 2DROP 2DROP 0
      THEN
      EXIT
   ELSE \ menu or accelerator
      DUP HIWORD
      IF
         DUP HIWORD 1 =
         IF \ accelerator
         ELSE \ unknown
            2SWAP inheritWinMessage
         THEN
      ELSE \ menu
         DUP LOWORD [CHAR] M SWAP
         sendWinMessage 0=
         IF
            2SWAP inheritWinMessage
         ELSE 2DROP 2DROP 0
         THEN
         EXIT
      THEN
   THEN
   2DROP 2DROP TRUE
;

W: WM_NOTIFY ( lpar wpar msg hwnd )
\ Send N: message by id
    3 PICK ( nmhdr ) DUP 2 CELLS + @ ( code )
    [CHAR] N 5 PICK sendWinMessage 0=
    IF
       2DROP inheritWinMessage
    ELSE >R 2DROP 2DROP R>
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
       hWnd@ SetWindowLongA -wthrow
       oldWndProc 0!
    THEN
;

W: WM_NCDESTROY ( lpar wpar msg hwnd )
    \ clear out window handle

    2DROP 2DROP
    \ detach object from window if it was attached
    detach

    0 hWnd! 0
;

: message ( lpar wpar msg hwnd -- result )
    DEPTH >R
    OVER [CHAR] W SWAP sendWinMessage 0=
    IF
       inheritWinMessage
    THEN
    DEPTH R> SWAP - 3 =  INVERT S" Wrong data stack size" SUPER abort
;

: checkWindow ( -- hwnd )
   hWnd@ IsWindow 0= S" Wrong window handle" SUPER abort
   hWnd@
;

: attach ( hwnd )
    hWnd ! checkWindow

    oldWndProc@
    IF detach THEN

    thunkAddr@ 0=
    IF createThunk THEN

    GWL_WNDPROC
    SWAP
    GetWindowLongA DUP -wthrow
    oldWndProc!

    thunk-xt@ ( xt hwnd )
    GWL_WNDPROC hWnd@
    SetWindowLongA -wthrow
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

: InstallThunk ( hwnd obj type )       
       \ set hWnd
       >R 2DUP :: CWinMessageReceiver.hWnd!

       \ all allocations are in a heap of the current thread
       TlsIndex@
       OVER :: CWinMessageReceiver.threadUserData@ TlsIndex!
       OVER :: CWinMessageReceiver.createThunk
       TlsIndex!

       \ replace DefWinProc by thunk

       :: CWinMessageReceiver.thunk-xt@
       OVER ( hwnd)
       R> SWAP
       SetWindowLongA -WIN-THROW

       DROP
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

: postMessage ( lpar wpar msg -- res )
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

    getTextLength DUP 1+ ALLOCATE THROW SWAP ( addr u )
    2DUP 1+ getText DROP
    str @ STR!
    str @
;

: showWindow ( flag -- )
   SUPER checkWindow
   ShowWindow DROP
;

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
;

: initialPosition
    30 60 10 10
;

;CLASS


( Frame window that can contain controls and menu )

CCustomWindow SUBCLASS CFrameWindow

  CWinClass OBJ class

0 CONSTANT createMenu

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

: create ( parent-obj | 0 -- hwnd )
   SELF ^ createMenu SWAP
   SUPER create
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