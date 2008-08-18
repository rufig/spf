REQUIRE Control ~nn/lib/win/control.f

CLASS: HotKey <SUPER Control
    var OnChange
        
VM: Type S" msctls_hotkey32" ;

C: EN_CHANGE OnChange  GoParent ;
M: get 0 0 HKM_GETHOTKEY SendMessage ;
M: getVK get 0xFF AND ;
M: getMod get 256 / 0xFF AND ;
M: getAlt getMod HOTKEYF_ALT AND 0<> ;
M: getShift getMod HOTKEYF_SHIFT AND 0<> ;
M: getCtrl getMod HOTKEYF_CONTROL AND 0<> ;
M: getWin getMod HOTKEYF_EXT AND 0<> ;

;CLASS

