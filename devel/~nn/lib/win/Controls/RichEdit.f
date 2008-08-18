REQUIRE Edit ~nn/lib/win/control.f

\ typedef struct tagNMHDR {
\    HWND hwndFrom; 
\    UINT idFrom; 
\    UINT code; 
\ } NMHDR; 

0x070B CONSTANT EN_LINK
0x0702 CONSTANT EN_SELCHANGE
WM_USER 
67 + CONSTANT EM_SETBKGNDCOLOR


\ typedef struct _compcolor
\ {
\	COLORREF crText;
\	COLORREF crBackground;
\	DWORD dwEffects;
\ }COMPCOLOR;



CLASS: RichEdit <SUPER Edit
    var vOnUrl
    var vOnSelChange
       
VM: Type S" RichEdit20A" ;

N: EN_LINK  vOnUrl GoParent  ;

N: EN_SELCHANGE vOnSelChange GoParent ;

M: SetBkColor ( coloref -- ) 0 EM_SETBKGNDCOLOR SendMessage DROP ;

;CLASS