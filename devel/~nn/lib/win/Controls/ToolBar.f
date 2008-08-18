REQUIRE Control ~nn/lib/win/control.f
REQUIRE ImageList ~nn/lib/win/controls/imagelist.f
\ REQUIRE ToolTip ~nn/lib/win/controls/tooltip.f
REQUIRE S>ZALLOC ~nn/lib/az.f
REQUIRE AppendNode ~nn/lib/list.f
\ REQUIRE S>UNICODE ~nn/lib/unicode.f

WINAPI: CreateToolbarEx comctl32.dll

CLASS: TBButton 
    RECORD: TBBUTTON
        var  iBitmap     \     int     iBitmap; 
        var  idCommand   \     int     idCommand; 
        char fsState     \     BYTE    fsState; 
        char fsStyle     \     BYTE    fsStyle; 
        var  dwData      \     DWORD   dwData; 
        var  iString     \     INT_PTR iString; 
    ;RECORD /TBBUTTON        \ } TBBUTTON, NEAR* PTBBUTTON, FAR* LPTBBUTTON;

    M: Hint! ?DUP IF S>ZALLOC iString ! ELSE DROP THEN ;
    M: Hint@ iString @ ?DUP IF ASCIIZ> ELSE 0 0 THEN ;
    
    M: Id@ idCommand @ ;
    
    CONSTR: init ( iB id state style a u -- )
        Hint!
        fsStyle C! 
        fsState C!
        idCommand !
        iBitmap !
        dwData 0!
    ;
    
;CLASS

CLASS: ToolBar <SUPER Control
    var vButtonList
    ImageList OBJ img-list

    RECORD: TBBUTTONINFO
        var cbSize
        var dwMask
        var idCommand
        var iImage
        char fsState
        char fsStyle
        2 chars cx
        var lParam
        var pszText
        var cchText
    ;RECORD /TBBUTTONINFO

VM: Type S" ToolbarWindow32" ;

VM: Style TBSTYLE_TOOLTIPS TBSTYLE_FLAT OR CCS_ADJUSTABLE OR 
( TBSTYLE_WRAPABLE OR) ;

\ VM: ExStyle TBSTYLE_EX_MIXEDBUTTONS ;

VM: AfterCreate
    0 WITH TBButton /TBBUTTON ENDWITH TB_BUTTONSTRUCTSIZE SendMessage DROP
\    0 5 CCM_SETVERSION SendMessage DROP
\    ImageList NEW TO img-list
    img-list init
\    img-list SELF ." img-list = " . CR
\    img-list vCX @ ." img-list.vCX = " . CR
    img-list Create
    /TBBUTTONINFO cbSize !

    0 0 TB_GETTOOLTIPS SendMessage ?DUP
    IF >R vOwner @ GWL_USERDATA R> SetWindowLongA DROP THEN
    
;

M: GetButton { id -- button }
    vButtonList
    BEGIN @ ?DUP WHILE
        DUP NodeValue >R
        R@ ->CLASS TBButton idCommand @ id =
        IF DROP R> EXIT THEN
        RDROP
    REPEAT
    0
;

M: SetButtonInfo ( id -- ) 
    TBBUTTONINFO SWAP TB_SETBUTTONINFOA SendMessage  DROP ;

M: SetButtonText ( a u id -- )
    NIP SWAP pszText !
    TBIF_TEXT dwMask !
    SetButtonInfo
;

M: SetState ( state id -- )
    SWAP fsState C!
    TBIF_STATE dwMask !
    SetButtonInfo
;

M: DisableButton ( id -- )  TBSTATE_INDETERMINATE SWAP SetState ;
M: EnableButton ( id -- )   TBSTATE_ENABLED SWAP SetState ;

M: GetState ( id -- state ) TB_GETSTATE SendMessage ;
M: GetStyle ( id -- state ) TB_GETSTYLE SendMessage ;

M: SetIcon { a u id \ button iBmp -- }
    id GetButton TO button
    button ->CLASS TBButton iBitmap @ TO iBmp
    iBmp a u img-list ReplaceIcon
    iBmp iImage !
    TBIF_IMAGE dwMask !
    id SetButtonInfo
    
    id GetState TBSTATE_ENABLED = 
    IF \ for preventing of merge with previous bitmap
        id DisableButton
        id EnableButton
    THEN
;

M: AddBMP ( nId hInst -- ) SP@ 1 TB_ADDBITMAP SendMessage DROP 2DROP ;

M: SetImageList ( hImgList -- )  0 TB_SETIMAGELIST SendMessage DROP ;

M: AddButtons ( a n -- )   TB_ADDBUTTONSA SendMessage DROP ;

M: add-button { button -- }
    button vButtonList AppendNode
    img-list handle @ SetImageList
    button 1 AddButtons
;

M: AddButton { aicon uicon id ahint uhint -- }
    aicon uicon img-list AddIcon ( iB -- )
    ( iB id state style -- )
    id TBSTATE_ENABLED 0 ( BTNS_SHOWTEXT) ahint uhint TBButton NEW
    add-button
;

M: AddSeparator { \ button -- }
    5 0 TBSTATE_ENABLED TBSTYLE_SEP 0 0 TBButton NEW add-button
;

M: GetButtonTip ( id -- a u )
    GetButton ?DUP 
    IF
        ->CLASS TBButton Hint@
    ELSE
        S" " 
    THEN
;

M: RemoveButton ( ) ;

;CLASS
