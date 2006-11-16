( Reflect some notifications from parent to child )
( It allows us to create self-containted controls )

: ?child!
   S" OF 3 PICK child ! ENDOF" EVALUATE
; IMMEDIATE

: ReflectNotifications ( lpar wpar msg hwnd -- ret -1 | 0 )
    || D: child ||
    OVER

    CASE
       WM_COMMAND OF 3 PICK ?DUP IF child ! THEN ENDOF
       WM_NOTIFY  OF 3 PICK @ child ! ENDOF
       WM_DRAWITEM OF 3 PICK 5 CELLS + child ! ENDOF
       WM_MEASUREITEM OF 2 PICK ( wpar ) ?DUP 
                         IF OVER GetDlgItem child ! THEN 
                      ENDOF
       WM_VKEYTOITEM ?child!
       WM_CHARTOITEM ?child!
       WM_HSCROLL    ?child!
       WM_VSCROLL    ?child!
       WM_CTLCOLORBTN ?child!
       WM_CTLCOLORDLG ?child!
       WM_CTLCOLOREDIT ?child!
       WM_CTLCOLORLISTBOX ?child!
       WM_CTLCOLORMSGBOX ?child!
       WM_CTLCOLORSCROLLBAR ?child!
       WM_CTLCOLORSTATIC ?child!
    ENDCASE

    child @ ?DUP
    IF 
       NIP SWAP OCM_BASE + SWAP
       SendMessageA TRUE
    ELSE 2DROP 2DROP 0
    THEN
;