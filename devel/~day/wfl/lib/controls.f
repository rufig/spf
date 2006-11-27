( Standard Windows controls )

CChildWindow SUBCLASS CGenericButton

: createClass S" BUTTON" DROP ;

;CLASS

CGenericButton SUBCLASS CButton

init: BS_PUSHBUTTON SUPER style OR! ;

;CLASS

CButton SUBCLASS CEventButton

       VAR xt ( button-obj )

: setHandler ( xt -- )
    xt !
;

: create ( id parent -- hwnd )
    SUPER create DUP SUPER attach
;

: createSimple ( height width top left xt parent )
    0 SWAP create DROP
    setHandler
    2>R 0 ROT ROT 2R> SUPER moveWindow

;

W: WM_LBUTTONUP
    xt @ ?DUP IF SELF SWAP EXECUTE THEN
    SUPER inheritWinMessage
;

;CLASS

CGenericButton SUBCLASS CCheckBox

init: BS_CHECKBOX SUPER style OR! ;

;CLASS

CChildWindow SUBCLASS CStatic

: createClass S" STATIC" DROP ;

;CLASS

CChildWindow SUBCLASS CEdit

: createClass S" EDIT" DROP ;

init: ES_AUTOHSCROLL WS_BORDER OR SUPER style OR! ;

;CLASS

( ListView control )

CLASS CLVITEM
   0 DEFS addr
   VAR mask
   VAR iItem
   VAR iSubItem
   VAR state
   VAR stateMask
   VAR pszText
   VAR cchTextMax
   VAR iImage
   VAR lParam
   VAR iIndent
   VAR iGroupId
   VAR cColumns
   VAR puColumns
;CLASS

CLASS CLVCOLUMN
   0 DEFS addr
   VAR mask
   VAR fmt
   VAR cx
   VAR pszText
   VAR cchTextMax
   VAR iSubItem
   VAR iImage
   VAR iOrder
;CLASS

CChildWindow SUBCLASS CListView 

: createClass S" SysListView32" DROP ;

: insertItem ( lvitem-obj )
     ^ addr
     0
     LVM_INSERTITEM
     SUPER sendMessage -1 = SUPER wthrow
;

: insertString ( data addr u )
     || CLVITEM lv ||
     DROP lv pszText !
     lv lParam !

     LVIF_PARAM LVIF_TEXT OR lv mask !

     lv this insertItem
;

: insertColumn ( index width addr u )
     || CLVCOLUMN lvc ||

     DROP lvc pszText !
     lvc cx !
     LVCF_TEXT LVCF_WIDTH OR lvc mask !

     lvc addr SWAP
     LVM_INSERTCOLUMN SUPER sendMessage
     -1 = SUPER wthrow

;

;CLASS