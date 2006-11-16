( URL like label )
( Needs message reflection )

\ (c) Dmitry Yakimov 2006, support@activekitten.com

WINAPI: ShellExecuteA       shell32.dll

32649 CONSTANT IDC_HAND

CStatic SUBCLASS CUrlLabel

	CString OBJ url
	VAR pressed 
	VAR pressedColor
	VAR normalColor
	VAR labelCursor

init:
    0 0 0xDE rgb normalColor !
    0xFF 0 0 rgb pressedColor !

    IDC_HAND 0 LoadCursorA labelCursor !
;

: setURL ( addr u )
    url @ STR!
;

: execute ( -- f )
    SW_SHOW
    0
    0
    url @ STR@ DROP
    S" open" DROP
    SUPER hWnd @ ShellExecuteA 32 >
;

R: WM_CTLCOLORSTATIC ( lpar wpar msg hwnd -- n )
    2DROP NIP DUP

    pressed @
    IF pressedColor @
    ELSE normalColor @
    THEN SWAP
    SetTextColor CLR_INVALID = SUPER wthrow
    
    TRANSPARENT SWAP SetBkMode DROP
    NULL_BRUSH GetStockObject
;

: setCursor
    labelCursor @ SetCursor DROP
;

W: WM_MOUSEMOVE
    setCursor
    SUPER inheritWinMessage    
;

W: WM_LBUTTONDOWN
    1 pressed !
    0 0 SUPER invalidate
    setCursor
    SUPER hWnd@ SetCapture DROP    
    2DROP 2DROP 0
;

W: WM_CANCELMODE
    pressed 0!
    2DROP 2DROP 0
;

WM_USER 1000 + CONSTANT WM_EXECUTE

W: WM_EXECUTE
    execute DROP
    2DROP 2DROP 0
;

W: WM_LBUTTONUP
    0 pressed !
    ReleaseCapture DROP
    0 0 SUPER invalidate
    setCursor
    0 0 WM_EXECUTE SUPER postMessage
    2DROP 2DROP 0
;

: attach ( hwnd -- )
    SUPER attach

    \ set SS_NOTIFY style to get mouse messages
    SS_NOTIFY 0 SUPER modifyStyle
;

: create ( id parent-obj )
    SUPER create
    SUPER checkWindow attach
;

;CLASS