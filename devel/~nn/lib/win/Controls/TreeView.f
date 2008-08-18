REQUIRE Control ~nn/lib/win/control.f
REQUIRE ImageList ~nn/lib/win/controls/imagelist.f

CLASS: TVItem
    var vNext
    var vChild
    var vHandle
;CLASS

CLASS: TreeView <SUPER Control
    RECORD: TVINSERT
        var hParent
        var hInsertAfter
    ;RECORD /TVINSERT \ Фигня. Гораздо больше.

    RECORD: TVITEM
        var mask           \     UINT      mask;
        var hItem          \     HTREEITEM hItem;
        var state          \     UINT      state;
        var stateMask      \     UINT      stateMask;
        var pszText        \     LPTSTR    pszText;
        var cchTextMax     \     int       cchTextMax;
        var iImage         \     int       iImage;
        var iSelectedImage \     int       iSelectedImage;
        var cChildren      \     int       cChildren;
        var lParam         \     LPARAM    lParam;
        var iIntegral      \     int       iIntegral;
                        \ } TVITEMEX, FAR *LPTVITEMEX;
    ;RECORD /TVITEM
\    var vList
    var vSelectedItem
    var OnSelChange
    256 FIELD vTextBuf
    var vOrdinal
    var vLastItem
    ImageList OBJ img-list

        
CONSTR: init init 
    TVI_LAST hInsertAfter ! 
    img-list init
    img-list Create ;
    
VM: Type S" SysTreeView32" ;

VM: ExStyle WS_EX_CLIENTEDGE WS_EX_WINDOWEDGE OR ;



M: AddMask mask @ OR mask ! ;
M: SetText ( a u -- )
    TVIF_TEXT AddMask
    cchTextMax ! pszText ! ;

M: GetNext ( h1 flag -- h2 ) TVM_GETNEXTITEM SendMessage ;
M: Root ( -- h)     0 TVGN_ROOT GetNext ;
M: Next ( h -- h1)  TVGN_NEXT GetNext ;
M: Child ( h -- h1) TVGN_CHILD GetNext ;
M: Current TVGN_CARET GetNext ;
M: Parent TVGN_PARENT GetNext ;

\ M: AddItem ( item list )
\    BEGIN DUP @ ?DUP WHILE NIP REPEAT
\    !        
\ ;

\ M: GetList ?DUP IF ->CLASS TVItem vChild ELSE vList THEN ;

M: AddTextItem ( a u parent \ tvi -- )
\     parent DUP IF  ->CLASS TVItem vHandle @ THEN
     hParent ! mask 0!
     SetText TVIF_PARAM AddMask
     vOrdinal @ lParam !    vOrdinal 1+!
     TVINSERT 0 ( TV_FIRST) TVM_INSERTITEMA SendMessage vLastItem !
\     ?DUP 
\     IF
\        TVItem NEW TO tvi
\        tvi ->CLASS TVItem vHandle !
\        tvi parent GetList AddItem
\     THEN
;

M: AddItem ( iImg a u parent \ tvi -- )
\     parent DUP IF  ->CLASS TVItem vHandle @ THEN
     hParent ! mask 0!
     SetText TVIF_PARAM TVIF_IMAGE OR TVIF_SELECTEDIMAGE OR AddMask
     DUP iImage ! 1+ iSelectedImage !
     vOrdinal @ lParam !    vOrdinal 1+!
     TVINSERT 0 ( TV_FIRST) TVM_INSERTITEMA SendMessage vLastItem !
\     HEX vLastItem @ . CR DECIMAL
;

M: Expand ( h -- ) TVE_EXPAND TVM_EXPAND SendMessage DROP ;

M: ExpandAll
    Root
    BEGIN ?DUP WHILE
      DUP Expand
      Next
    REPEAT
\    vList 
\    BEGIN @ ?DUP WHILE
\        DUP Expand
\    REPEAT 
;

M: GetItem ( parent # -- item )
    SWAP ?DUP IF Child ELSE Root THEN
    SWAP 0 ?DO Next DUP 0= IF LEAVE THEN LOOP
\    SWAP GetList SWAP 
\    0 ?DO DUP @ ?DUP IF NIP ELSE LEAVE THEN LOOP
\    @
;

M: GetItemText ( h -- a u )
    hItem !
    TVIF_TEXT TVIF_HANDLE OR mask !
    vTextBuf pszText ! vTextBuf 0!
    256 cchTextMax !
    TVITEM 0 TVM_GETITEMA SendMessage 
    IF vTextBuf ASCIIZ> ELSE S" " THEN
;

M: SetImageList ( hImgList -- )  0 TVM_SETIMAGELIST SendMessage DROP ;

M: AddIcon ( a u -- ) 
    img-list AddIcon DROP
    img-list handle @ SetImageList ;

M: SelectItem ( h -- ) TVGN_CARET TVM_SELECTITEM SendMessage DROP ;

N: TVN_SELCHANGEDA 
\      ." TVN_SELCHANGEDA " this . CR
\      lparam @ . CR
    lparam @ 3 CELLS + /TVITEM + 1 CELLS + @ vSelectedItem !
\    lparam @ 3 CELLS 1 CELLS + /TVITEM + /TVITEM + DUMP CR
    OnSelChange GoParent ;

;CLASS