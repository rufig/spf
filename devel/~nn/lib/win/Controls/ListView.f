REQUIRE Control ~nn/lib/win/control.f
0x1000 27 + CONSTANT LVM_INSERTCOLUMN
0x1000 7 +  CONSTANT LVM_INSERTITEM
-108        CONSTANT LVN_COLUMNCLICK

CLASS: LVColumn
    var mask        \   UINT    mask; 
    var fmt         \   int     fmt; 
    var cx          \   int     cx; 
    var pszText     \   LPTSTR  pszText; 
    var cchTextMax  \   int     cchTextMax; 
    var iSubItem
\ #if (_WIN32_IE >= 0x0300)
    var iImage      \   int     iImage;
    var iOrder      \   int     iOrder;
\ #endif
\ } HDITEM, FAR * LPHDITEM;
    CONSTR: init ( a u width --)  
        cx !
        DUP cchTextMax ! 
        S>ZALLOC pszText !
        LVCF_TEXT LVCF_WIDTH OR LVCF_FMT OR mask !
        LVCFMT_LEFT fmt !
    ;
    DESTR: free  pszText @ ?DUP IF FREE DROP THEN ;
;CLASS

CLASS: LVItem
    var mask        \   UINT    mask; 
    var iItem
    var iSubItem
    var state
    var stateMask
    var pszText     \   LPTSTR  pszText; 
    var cchTextMax  \   int     cchTextMax; 
    var iImage      \   int     iImage;
    var lParam
\ #if (_WIN32_IE >= 0x0300)
    var iIndent      \   int     iOrder;
\ #endif
\ } HDITEM, FAR * LPHDITEM;
    CONSTR: init ( iImg a u item --)
        iItem !
        DUP cchTextMax !
        S>ZALLOC pszText !
        LVIF_IMAGE LVIF_TEXT OR mask !
        iImage !
    ;
    DESTR: free  pszText @ ?DUP IF FREE DROP THEN ;
;CLASS


CLASS: ListView <SUPER Control
    var OnColumnClick
    var OnItemChange
    var v_ex_style
    var vLastIndex
    var vSelectedItem

    RECORD: LVITEM
        var mask           \     UINT      mask;
        var iItem          
        var iSubItem
        var state          \     UINT      state;
        var stateMask      \     UINT      stateMask;
        var pszText        \     LPTSTR    pszText;
        var cchTextMax     \     int       cchTextMax;
        var iImage         \     int       iImage;
        var lParam         \     LPARAM    lParam;
        var iIndent 
    ;RECORD /LVITEM

    VM: Type S" SysListView32" ;
    VM: Style LVS_LIST ;
\    VM: ExStyle LVS_EX_GRIDLINES LVS_EX_FULLROWSELECT OR ;


    M: InsertColumn ( a u width idx -- )
        >R LVColumn NEW R> LVM_INSERTCOLUMN SendMessage DROP ;
    M: InsertItem ( iImg a u idx -- )
        LVItem NEW >R R@ 0 LVM_INSERTITEM SendMessage vLastIndex !
         R> DELETE  ;

    M: SetItem { row col a u \ item -- }
        0 a u row LVItem NEW TO item
        col item ->CLASS LVItem iSubItem !
        item row LVM_SETITEMTEXTA SendMessage DROP
        item DELETE ;

    M: SetExStyle
           v_ex_style @ ?DUP IF DUP LVM_SETEXTENDEDLISTVIEWSTYLE SendMessage DROP THEN ;
    M: SetStyle ( style -- ) 
            Hide
            GWL_STYLE handle @ GetWindowLongA LVS_TYPEMASK -1 XOR AND OR
            GWL_STYLE handle @ SetWindowLongA DROP 
            SetExStyle
            Show  ;
    M: ReportStyle 
        LVS_REPORT SetStyle 
\        GWL_EXSTYLE handle @ GetWindowLongA LVS_EX_GRIDLINES LVS_EX_FULLROWSELECT OR OR
\        GWL_EXSTYLE handle @ SetWindowLongA DROP
    ;

    M: IconStyle LVS_ICON SetStyle ;
    M: SmallIconStyle LVS_SMALLICON SetStyle ;
    M: ListStyle LVS_LIST SetStyle ;

    M: SetILNormal ( h -- )  LVSIL_NORMAL LVM_SETIMAGELIST SendMessage DROP ;
    M: SetILSmall ( h -- )  LVSIL_SMALL LVM_SETIMAGELIST SendMessage DROP ;
    M: ClearAll 0 0 LVM_DELETEALLITEMS SendMessage DROP ;
    
    M: GetColumnWidth ( n -- width ) 0 SWAP LVM_GETCOLUMNWIDTH SendMessage ;
    M: SetColumnWidth ( width n -- width ) LVM_SETCOLUMNWIDTH SendMessage  DROP ;

    N: LVN_COLUMNCLICK OnColumnClick GoParent ;
    N: NM_RCLICK OnRClick GoParent ;
    N: NM_CLICK OnClick GoParent ;
    N: NM_DBLCLK 
        lparam @ 3 CELLS + @ ( DUP . CR) vSelectedItem !
	
		\ lparam @ 4 CELLS + @ .
        OnDoubleClick GoParent ;
    N: LVN_ITEMCHANGED 
        lparam @ 3 CELLS + @ ( DUP . CR) vSelectedItem ! 
        OnItemChange GoParent ;
	

;CLASS