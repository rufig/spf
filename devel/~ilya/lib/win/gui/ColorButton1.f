REQUIRE Set-colors  ~ilya/lib/win/gui/framewindowc.f
REQUIRE Control ~nn/lib/win/control.f

0 \ DRAWITEMSTRUCT
	CELL --  CtlType
    CELL --  CtlID
    CELL --  itemID 
    CELL --  itemAction
    CELL --  itemState 
    CELL --  hwndItem 
    CELL --  hDC 
    4 CELLS --  rcItem
    CELL --  itemData
CONSTANT /DRAWITEMSTRUCT

Control REOPEN
	var vOnPaintItem
M: DRAWITEM vOnPaintItem @ ?DUP IF EXECUTE ELSE DROP THEN ;
;CLASS

FrameWindow REOPEN

VM: OnDrawItem lparam @ 

WITH Control
DUP hwndItem @ HANDLE>OBJ  => DRAWITEM
ENDWITH
;

W: WM_DRAWITEM
 OnDrawItem
;

;CLASS





CLASS: ColorButton <SUPER Button
	var vBkColorUp
	var vBkColorDown		\ Цвет при нажатой клавише
	var vTextColorUp		\ Цвет при нажатой клавише
	var vTextColorDown		\ Цвет при нажатой клавише
	var vCharSize
	var vfontheight
	var vfontweight
	\ var vPaintmy

M: DRAWITEM1 { l \ tmpFont -- }
l hwndItem @ ( DUP HANDLE>OBJ) handle @ = 
IF
l itemState @ ODS_SELECTED AND 
		IF
			vX @ 3 + vY @ 3 + SetPos
			vBkColorDown @ l rcItem l hDC @ FillRect DROP
			vTextColorDown @ l hDC @ SetTextColor DROP
			DT_VCENTER  DT_SINGLELINE OR DT_CENTER OR l rcItem vText @ ASCIIZ> SWAP l hDC @ DrawTextA DROP
		ELSE
			vX @ vY @ SetPos
			\ vBkColorUp @  vBkColor !
			vBkColorUp @ l rcItem l hDC @ FillRect DROP
			vTextColor @ l hDC @ SetTextColor DROP
			DT_VCENTER  DT_SINGLELINE OR DT_CENTER OR l rcItem vText @ ASCIIZ> SWAP l hDC @ DrawTextA DROP
			\ DFCS_BUTTONPUSH DFC_BUTTON l rcItem l hDC @ DrawFrameControl .
		THEN
		TRUE
THEN
\ hParent @ HANDLE>OBJ ->CLASS Font vFont @ .

;
0 [IF]
W: WM_MOUSEMOVE
CR ." move"
TRUE
;
[THEN]

C: BN_CLICKED TRUE 0 handle @ InvalidateRect DROP OnClick GoParent ;

DESTR: free
free
vBkColorDown @ DeleteObject DROP
\ vTextColorUp @ DeleteObject DROP
\ vTextColorDown @ DeleteObject DROP
;


VM: AfterCreate { \ sfont -- }

vCharSize @ 0= IF 6 vCharSize ! THEN
Font NEW TO sfont 
WITH Font
		 \ S" Fixedsys" DROP sfont => lpszFace !
		 vfontheight @ sfont => height !
		 vfontweight @ sfont => weight !
		 \ ( 30) vWidth @ 30 - vCharSize @ / CR ." fontw=" .S sfont => width !
		 \ 150 sfont => width !
		 sfont => Create
		 sfont => handle  @  SetFont
ENDWITH
vBkColorDown @ CreateSolidBrush vBkColorDown ! 
vBkColor @ vBkColorUp !
SetOwnProc
\ vHeight @ ." vHeight=" .
\ vWidth @ ." vWidth=" .
['] DRAWITEM1 this ->CLASS Control vOnPaintItem !
 
 
;

;CLASS
