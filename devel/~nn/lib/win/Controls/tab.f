REQUIRE Control ~nn/lib/win/control.f
REQUIRE S>ZALLOC ~nn/lib/az.f

CLASS: TabItem 
    var mask
    var dwState
    var dwStateMask
    var pszText
    var cchTextMax
    var iImage
    var lParam

CONSTR: init ( S" tab-name" -- )
    DUP cchTextMax !
    S>ZALLOC pszText !
    TCIF_TEXT mask !
;

DESTR: free  pszText FREE DROP ;
;CLASS

CLASS: TabElement
    var vIndex
    var vObject

CONSTR: init ( obj index -- )
    vIndex ! vObject ! ;

;CLASS

CLASS: TabControl <SUPER Control
    var OnSelChange
    var OnSelChanging
    var vElements   \ element list
    var vCurTab
VM: Style  TCS_HOTTRACK ;
\ VM: ExStyle WS_EX_CLIENTEDGE ;


VM: Type S" SysTabControl32" ;

M: Insert ( S" name" index -- )
    >R
    TabItem NEW R>
    ( 0x1307) TCM_INSERTITEMA SendMessage DROP
;

M: Current ( -- index) 0 0 TCM_GETCURSEL SendMessage ;
M: Current! ( index -- ) 0 SWAP TCM_SETCURSEL SendMessage DROP ;

M: AddEl ( obj index --)
    TabElement NEW vElements AppendNode ;

: ShowElement ( node --)
    NodeValue >R
    R@ ->CLASS TabElement vIndex @ vCurTab @ =
    IF
      R@ ->CLASS TabElement vObject @ ->CLASS Control ?Show  
    THEN
    R> DROP
;

: HideElement ( node --)
    NodeValue >R
    R@ ->CLASS TabElement vIndex @ vCurTab @ -
    IF
      R@ ->CLASS TabElement vObject @ ->CLASS Control ?Hide
    THEN
    R> DROP
;

M: SelTab
    Current vCurTab !
    ['] HideElement vElements DoList
    ['] ShowElement vElements DoList ;

N: TCN_SELCHANGE    SelTab OnSelChange GoParent ;

N: TCN_SELCHANGING  OnSelChanging GoParent ;

;CLASS 

CLASS: TabFrame <SUPER FrameWindow
\ Класс для организации закладок
\ Окно каждой закладки надо наследовать от этого класса

    M: Create { a u tabctrl num -- }
        WS_CHILD 
\        WS_VSCROLL OR WS_HSCROLL OR
        vStyle !
        tabctrl Create
\        tabctrl => vX @ 3 + tabctrl => vY @ 3 +
        10 30
        tabctrl => vWidth @ 20 - tabctrl => vHeight @ 40 - MovePixels
        AutoCreate
        this num tabctrl ->CLASS TabControl AddEl
        a u  num tabctrl ->CLASS TabControl Insert
    ;
;CLASS
