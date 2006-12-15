( Dmitry Yakimov 2006
  Контроллер сплиттера включает в себя сам сплиттер и два окна-панели.
  И сплиттер и панели являются дочерними по отношению к окну на котором
  они находятся. Контроллер управляет сплиттером и панелями, изменяет размеры
  панелей и положение сплиттера. 

  Особенность в том что контроллер является окном и перехватывает сообщение
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
WINAPI: GetCapture USER32.DLL

( Window that can resize itself according to parent size )

CChildCustomWindow SUBCLASS CPanel

init: WS_CHILD WS_VISIBLE OR SUPER style ! 
      WS_EX_CONTROLPARENT SUPER exStyle !
;

: splitterController ( -- obj | 0 )
    0 0 MSG_GETSPLITTERCONTROLLER SUPER hWnd @ GetParent SendMessageA
;

\ percent * 100

: getPercent ( -- n )
    || CWindow p ||
    SUPER getParent p hWnd !
    p getClientRect 2DROP NIP
    DUP 0= IF EXIT THEN

    \ учтем ширину сплиттера
    splitterController 
    ?DUP IF ^ splitterWidth 2* - THEN

    SUPER getClientRect 2DROP NIP ( w1 w0 )
    10000 * SWAP /
;

;CLASS

CChildCustomWindow SUBCLASS CSplitter

          VAR controller

: setCursor ( id -- )
     0 LoadCursorA SUPER class hCursor !
;

: cursorAddr SUPER class hCursor ;

init:
    IDC_SIZEWE setCursor    
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
    2DROP DROP DUP LOWORD SWAP HIWORD 
    getController ^ buttonUp 0
;

W: WM_MOUSEMOVE
    2DROP MK_LBUTTON AND
    IF DUP LOWORD SWAP HIWORD 
       getController ^ mouseMove
    ELSE DROP
    THEN 0
;

W: WM_PAINT
    || CPaintDC dc CRect r CBrush b CPen p ||
    NIP NIP NIP
    dc create DROP

    SUPER getClientRect r ! r @
    COLOR_3DFACE b getSysColorBrush
    dc fillRect

    getController ^ drawSplitter? @ 0= IF 0 EXIT THEN

    COLOR_3DSHADOW GetSysColor p createSimple dc selectObject >R
    getController ^ vertical? @ >R
    0 0 0 dc handle @ MoveToEx SUPER -wthrow
    
    R@
    IF r height 0
    ELSE 0 r width
    THEN dc handle @ LineTo SUPER -wthrow

    0 R@
    IF
         0 r right @ 1-
    ELSE r height 1- 0
    THEN dc handle @ MoveToEx SUPER -wthrow

    R@
    IF
       r height r right @ 1- 
    ELSE r height 1- r width
    THEN dc handle @ LineTo SUPER -wthrow

    R> DROP
    R> dc selectObject DROP
    0
;

;CLASS

0 CONSTANT ID_LEFT_PANEL
1 CONSTANT ID_RIGHT_PANEL
2 CONSTANT ID_SPLITTER

10000 CONSTANT SPLIT_INTERVAL

CChildCustomWindow SUBCLASS CSplitterController

    VAR leftPane
    VAR rightPane

    VAR leftPaneOwner
    VAR rightPaneOwner

    CSplitter OBJ splitter
    CWindow OBJ parent \ own all windows

    VAR splitRatio \ 0 .. SPLIT_INTERVAL
    VAR splitWidth
    VAR cx
    VAR cy

    VAR dragStart
    VAR dragX

    VAR vertical?
    VAR drawSplitter?

: upperPane leftPane ;
: bottomPane rightPane ;

: splitterWidth splitter getClientRect 2DROP NIP ;

init:
    4 splitWidth !
    SPLIT_INTERVAL 2/ splitRatio !
    WS_CHILD SUPER style !
    TRUE vertical? !
;

dispose:
    leftPaneOwner @ IF leftPane @ FreeObj THEN
    rightPaneOwner @ IF rightPane @ FreeObj THEN
;

: setHorizontal
    FALSE vertical? !
    IDC_SIZENS splitter setCursor
;

\ invisible window

: initialPosition 0 0 0 0 ;

: ?rotate vertical? @ 0= IF SWAP 2SWAP SWAP 2SWAP THEN ;

: update ( -- )

    cx @ splitRatio @ * SPLIT_INTERVAL / ( xSplit or ySplit )
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
    vertical? @
    IF
       TRUE 0 0 xSplit @ cy @ 
    ELSE TRUE 0 0 cy @ xSplit @
    THEN Rect>Win leftPane @ ^ moveWindow

    vertical? @
    IF
       TRUE xSplit @ splitWidth @ + 0
       cx @ xSplit @ - splitWidth @ - cy @ 
    ELSE
       TRUE 0 xSplit @ splitWidth @ +
       cy @ cx @ xSplit @ - splitWidth @ -
    THEN Rect>Win rightPane @ ^ moveWindow

    \ force paint splitter
    0 0 splitter invalidate

    splitter updateWindow
;

: createSplitter ( parent-obj -- )
    DUP DUP ^ hWnd @ parent hWnd !

    ID_SPLITTER OVER splitter create DROP

    0 SWAP SUPER create DROP
    parent hWnd @ SUPER attach

    ^ getClientRect 2DROP vertical? @ 0= IF SWAP THEN cx ! cy !
    update
;

: setLeftPane ( obj parent-obj )
     OVER leftPane !
     ID_LEFT_PANEL SWAP ROT ^ create DROP
;

: setRightPane ( obj parent-obj )
     OVER rightPane !
     ID_RIGHT_PANEL SWAP ROT ^ create DROP
;

: setUpperPane ( obj parent-obj )
     setLeftPane
;
: getLeftPane leftPane @ ;
: getRightPane rightPane @ ;
: getUpperPane getLeftPane ;
: getBottomPane getRightPane ;

: setBottomPane ( obj parent-obj )
     setRightPane
;


: createPanels ( parent-obj )
    CPanel NewObj OVER setLeftPane
    CPanel NewObj SWAP setRightPane

    TRUE leftPaneOwner !
    TRUE rightPaneOwner !
;

W: WM_SIZE ( lpar wpar msg hwnd -- n )
\ change size of parent window

    leftPane @ ^ hWnd @ 0= ABORT" SplitterController: Create panels before!"

    \ we are looking for parent messages only
    DUP parent hWnd @ =
    IF
       3 PICK DUP
       vertical? @
       IF
          LOWORD cx !
          HIWORD cy !
       ELSE
          LOWORD cy !
          HIWORD cx !
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
    SPLIT_INTERVAL * cx @ /
    0 MAX SPLIT_INTERVAL MIN
    splitRatio !
    update
;

: setPercent ( n -- )
    SPLIT_INTERVAL 100 / *
    0 MAX SPLIT_INTERVAL MIN
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
    cy @
    splitWidth @ 1+ vswap
    0
    dragX @ vswap
    splitWidth @ 2/ vertical? @ IF - ELSE >R SWAP R> - SWAP THEN
    dc handle @
    PatBlt SUPER -wthrow
;

: captureChanged
    \ erase previous divider
    drawMark
    dragX @ moveSplitter
;

: setDragX ( x )
    W>S dragStart @ + 
    splitWidth @ 2/ MAX
    cx @ splitWidth @ 2/ - MIN
    dragX !
;

: buttonUp ( x y )
    vdrop
    setDragX
    ReleaseCapture DROP
;

: buttonDown ( x y )
    vover >R
    splitter hWnd @ SetCapture DROP
    splitter clientToScreen vdrop ( xSplitter )
    0 0 parent clientToScreen vdrop ( xParent  )
    -
    DUP  dragX !
    R> - ( start of control )
    dragStart !


    drawMark
;

: mouseMove ( x y -- )
    GetCapture splitter hWnd @ = 0= IF 2DROP EXIT THEN

    vdrop
  
    \ erase previous 
    drawMark

    \ draw new
    setDragX
    drawMark
;

;CLASS
