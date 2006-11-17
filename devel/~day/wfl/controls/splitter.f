

CChildWindow SUBCLASS CPanel

    CWinClass OBJ class	

: createClass ( -- atom )
    class register
;

;CLASS

CChildWindow SUBCLASS CSplitter

W: WM_LBUTTONDOWN
;

W: WM_LBUTTONUP
;

W: WM_MOUSEMOVE
;

;CLASS