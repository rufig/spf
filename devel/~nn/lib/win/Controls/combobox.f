REQUIRE Control ~nn/lib/win/control.f

CLASS: ComboBox <SUPER ListBox
    var OnSelChange
        
VM: Style  CBS_DROPDOWNLIST WS_VSCROLL OR WS_HSCROLL OR CBS_AUTOHSCROLL OR ;
VM: ExStyle WS_EX_CLIENTEDGE ;

VM: Type S" combobox" ;

VM: Add ( addr u -- )  DROP 0 CB_ADDSTRING  SendMessage DROP  ;

M: Delete ( index -- ) 0 SWAP CB_DELETESTRING SendMessage DROP ;

M: Length ( -- len ) 0 0 CB_GETCOUNT SendMessage ;

M: Clear ( -- ) Length 0 ?DO 0 Delete LOOP ;

M: Current ( -- index ) 0 0 CB_GETCURSEL SendMessage ;

M: Current! ( index -- ) 0 SWAP CB_SETCURSEL SendMessage DROP ;

M: Get ( a index -- a u )  OVER SWAP CB_GETLBTEXT SendMessage ;

M: GetCurrent ( a -- a u )
    Current DUP CB_ERR =
    IF DROP 0 ELSE Get THEN ;

M: GetIndex ( a u -- idx [CB_ERR - not found])
    DROP -1 CB_FINDSTRING SendMessage ;

M: SetDropWidth ( n -- ) 0 SWAP CB_SETDROPPEDWIDTH  SendMessage DROP ;

C: CBN_SELCHANGE OnSelChange GoParent ;

;CLASS

CLASS: ComboBoxEdit <SUPER ComboBox
    var OnEditChange
    
VM: Style  CBS_DROPDOWN WS_VSCROLL OR WS_HSCROLL OR CBS_AUTOHSCROLL OR ;

C: CBN_EDITCHANGE  OnEditChange GoParent ;
;CLASS