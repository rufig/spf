REQUIRE Control ~nn/lib/win/control.f
-302 CONSTANT HDN_ITEMCLICK
-303 CONSTANT HDN_ITEMDBLCLICK
0x1205 CONSTANT HDM_LAYOUT

\ typedef struct _HDITEM {
CLASS: HDItem
    var mask        \   UINT    mask; 
    var cxy         \   int     cxy; 
    var pszText     \   LPTSTR  pszText; 
    var hbm         \   HBITMAP hbm; 
    var cchTextMax  \   int     cchTextMax; 
    var fmt         \   int     fmt; 
    var lParam      \   LPARAM  lParam; 
\ #if (_WIN32_IE >= 0x0300)
    var iImage      \   int     iImage;
    var iOrder      \   int     iOrder;
\ #endif
\ } HDITEM, FAR * LPHDITEM;
    CONSTR: init ( a u width --)
        cxy !
        DUP cchTextMax !
        S>ZALLOC pszText !
        HDI_TEXT HDI_WIDTH OR mask !
        HDF_CENTER fmt !
    ;
    DESTR: free  pszText @ ?DUP IF FREE DROP THEN ;
;CLASS

CLASS: HeaderControl <SUPER Control

VM: Type S" SysHeader32" ;
VM: Style HDS_HORZ HDS_BUTTONS OR WS_BORDER OR ;
M: Insert ( a u width idx -- )
    >R HDItem NEW R>   0x1201 SendMessage DROP ;
M: Layout ( -- )
    HDM_LAYOUT SendMessage DROP ;
N: HDN_ITEMCLICK OnClick GoParent ;
N: HDN_ITEMDBLCLICK OnDoubleClick GoParent ;

;CLASS