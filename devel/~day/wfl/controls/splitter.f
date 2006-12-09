( Dmitry Yakimov 2006
  Контроллер сплиттера включает в себя сам сплиттер и два окна-панели.
  И сплиттер и панели являются дочерними по отношению к окну на котором
  они находятся. Контроллер управляет сплиттером и панелями, изменяет размеры
  панелей и положение сплиттера. 

  Особенность в том что контролеер является окном и перехватывает сообщение
  WM_SIZE окна родителя для того чтобы при изменении окна родителя соответсвенно
  изменить и размеры панелей.

  Пример:
         CSplitterController OBJ vsplitter

W: WM_CREATE \ Или WM_INITDIALOG
   SELF hsplitter createPanels
   SELF hsplitter createSplitter
   ...
)

WM_USER 1501 + CONSTANT MSG_GETSPLITTERCONTROLLER

WINAPI: SetROP2  GDI32.DLL
WINAPI: PatBlt   GDI32.DLL
WINAPI: DrawEdge USER32.DLL

( Window that can resize itself according to parent size )

CChildCustomWindow SUBCLASS CPanel

init: WS_CHILD WS_VISIBLE OR SUPER style ! 
      WS_EX_CONTROLPARENT SUPER exStyle !
;

;CLASS

CChildCustomWindow SUBCLASS CSplitter

          VAR controller

: setCursor ( id -- )
     0 LoadCursorA SUPER class hCursor !
;

: cursorAddr SUPER class hCursor ;

init:
    IDC_SIZEWE  setCursor
    COLOR_BTNFACE GetSysColorBrush SUPER class hbrBackground !
;

: getController ( obj )
     controller @ 0=
     IF
        0 0 MSG_GETSPLITTERCONTROLLER SUPER hWnd @ GetParent SendMessageA
        controller !
     THEN
     controller @ DUP 0= ABORT" Splitter controller should be attached to main window"
;

W: WM_CAPTURECHANGED
     2DROP 2DROP 
     getController ^ captureChanged 0
;

W: WM_LBUTTONDOWN
    2DROP DROP DUP LOWORD SWAP HIWORD 
    getController ^ buttonDown 0
;

W: WM_LBUTTONDBLCLK
    2DROP DROP DUP LOWORD SWAP HIWORD 
    getController ^ buttonDown 0
;

W: WM_LBUTTONUP
    ReleaseCapture DROP
    2DROP 2DROP 0
;

W: WM_MOUSEMOVE
    2DROP MK_LBUTTON AND
    IF DUP LOWORD SWAP HIWORD 
       getController ^ mouseMove
    ELSE DROP
    THEN 0
;

W: WM_PAINT
    || CPaintDC dc CRect r CBrush b ||
    NIP NIP NIP
    dc create DROP

    SUPER getClientRect r ! r @
    COLOR_3DFACE b getSysColorBrush
    dc fillRect

    getController ^ vertical? @ 0=
    IF
      BF_BOTTOM BF_TOP OR
    ELSE BF_LEFT BF_RIGHT OR
    THEN

    EDGE_RAISED
    r addr
    dc handle @ DrawEdge DROP
    0
;

;CLASS

0 CONSTANT ID_LEFT_PANEL
1 CONSTANT ID_RIGHT_PANEL
2 CONSTANT ID_SPLITTER

CChildCustomWindow SUBCLASS CSplitterController

    CPanel OBJ leftPane
    CPanel OBJ rightPane
    CSplitter OBJ splitter
    CWindow OBJ parent \ own all windows

    VAR splitRatio \ in %
    VAR splitWidth
    VAR cx
    VAR cy

    VAR dragStart
    VAR dragX

    VAR vertical?

: upperPane POSTPONE leftPane ; IMMEDIATE
: bottomPane POSTPONE rightPane ; IMMEDIATE

init:
    6 splitWidth !
    50 splitRatio !
    WS_CHILD SUPER style !
    TRUE vertical? !
;

: setHorizontal
    FALSE vertical? !
    IDC_SIZENS splitter setCursor
;

\ invisible window

: initialPosition 0 0 0 0 ;

: ?rotate vertical? @ 0= IF SWAP 2SWAP SWAP 2SWAP THEN ;

: update ( -- )

    cx @ splitRatio @ * 100 / ( xSplit or ySplit )
    0 MAX
    DUP splitWidth @ + cx @ >
    IF
       DROP cx @ splitWidth @ -
    THEN

    || R: xSplit ||

    \ move splitter but do not paint
    0 xSplit @ 0 splitWidth @ cy @ ?rotate
    Rect>Win splitter moveWindow

    \ resize panes
    TRUE 0 0 xSplit @ cy @ ?rotate Rect>Win leftPane moveWindow
    TRUE xSplit @ splitWidth @ + 
         0
         cx @ xSplit @ - splitWidth @ -
         cy @ ?rotate Rect>Win
         rightPane moveWindow

    \ force paint splitter
    0 0 splitter invalidate

    splitter updateWindow
;

: createSplitter ( parent-obj -- )
    DUP DUP ^ hWnd @ parent hWnd !

    ID_SPLITTER SWAP splitter create DROP

    0 SWAP SUPER create DROP
    parent hWnd @ SUPER attach

    update
;

: createPanels ( parent-obj )

    ID_LEFT_PANEL OVER leftPane create DROP
    ID_RIGHT_PANEL OVER rightPane create DROP

    ^ getClientRect 2DROP cx ! cy !
;

W: WM_SIZE ( lpar wpar msg hwnd -- n )
\ change size of parent window

    leftPane hWnd @ 0= ABORT" SplitterController: Create panels before!"

    \ we are looking for parent messages only
    DUP parent hWnd @ =
    IF
       3 PICK DUP
       vertical? @ 0=
       IF 
         LOWORD cy !
         HIWORD cx !
       ELSE
         LOWORD cx !
         HIWORD cy !
       THEN

       update
    
       SUPER inheritWinMessage
    ELSE 2DROP 2DROP 0
    THEN
;

W: MSG_GETSPLITTERCONTROLLER
    2DROP 2DROP SELF
;

: moveSplitter ( x -- )
    100 * cx @ /
    0 MAX 100 MIN
    splitRatio !
    update
;

: vswap vertical? @ 0= IF SWAP THEN ;
: vdrop  vertical? @ 0= IF NIP ELSE DROP THEN ;
: vover vertical? @ 0= IF DUP ELSE OVER THEN ;

: drawMark 
    || CDC dc CBrush b ||
    parent hWnd @ dc create DROP
    b createHalftoneBrush dc selectObject DROP

    PATINVERT
    cy @ 1-
    splitWidth @  vswap
    0
    dragX @ vswap
    dc handle @
    PatBlt SUPER -wthrow
;

: captureChanged
    \ erase previoud divider
    drawMark
    dragX @ splitWidth @ 2/ + moveSplitter
;

: buttonDown ( x y )
    vover >R
    splitter hWnd @ SetCapture DROP
    splitter clientToScreen vdrop ( xSplitter )
    0 0 parent clientToScreen vdrop ( xParent  )
    - R@ - splitWidth @ 2/ - DUP dragStart !

    R> + dragX !    

    drawMark
;

: mouseMove ( x y -- )
    vdrop
  
    \ erase previous 
    drawMark

    \ draw new
    W>S dragStart @ + 
    splitWidth @ 2/ MAX 
    cx @ splitWidth @ - MIN dragX !

    drawMark
;

;CLASS
