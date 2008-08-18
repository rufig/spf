REQUIRE Control ~nn/lib/win/control.f


CLASS: ToolTip <SUPER Window

    RECORD: TOOLINFO
        var      cbSize 
        var      uFlags
        var      hwnd
        var      uId
        
\        RECT      rect
        var left
        var top 
        var right
        var bottom
        
        var     hinst
        var     lpszText
        var     lParam
    ;RECORD /TOOLINFO
    
    CONSTR: init init 
        /TOOLINFO cbSize ! 
        TTF_IDISHWND TTF_SUBCLASS OR ( TTF_TRACK OR TTF_ABSOLUTE OR) uFlags !
        HINST hinst !
    ;

VM: Type S" tooltips_class32" ;

VM: Style WS_POPUP TTS_NOPREFIX OR TTS_ALWAYSTIP OR ;
VM: ExStyle WS_EX_TOPMOST ;

M: Create ( a u owner toolbar -- ) 
    OVER => handle @ hwnd !
    => handle @ uId !
    Create
    S>ZALLOC lpszText !
    handle @ \ ?DUP 	<-- Исправил 29.03.05г. Абдрахимов И.А.
    IF 
        SWP_NOMOVE SWP_NOSIZE OR SWP_NOACTIVATE OR
        0 0 0 0 HWND_TOPMOST handle @
        SetWindowPos DROP
    THEN
    
   
    TOOLINFO 0 TTM_ADDTOOLA SendMessage 
 \ [ DEBUG? ] [IF] ." TTM_ADDTOOL = " DUP . GetLastError . CR [THEN]
    DROP
    
    0 1 TTM_ACTIVATE SendMessage 
 \ [ DEBUG? ] [IF] ." TTM_ACTIVATE = " DUP . GetLastError . CR [THEN]
    DROP
    
;

;CLASS