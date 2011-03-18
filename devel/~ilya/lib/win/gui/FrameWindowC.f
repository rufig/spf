\ Раскрашиваем контролы
\ Абдрахимов И.А.

REQUIRE FrameWindow ~nn/lib/win/FrameWindow.f
: h. BASE @ >R HEX . R> BASE ! ;

Window REOPEN
	var vTextColor
	var vTextBkColor
	var vBkColor
	var vColored
M: Set-colors
lparam @ HANDLE>OBJ ?DUP 
IF
	DUP => vColored @ 
	IF
		TRANSPARENT wparam @ SetBkMode DROP
		DUP => vTextColor @ wparam @ SetTextColor DROP
		DUP => vTextBkColor @ wparam @ SetBkColor DROP
		=> vBkColor @ 
		
	ELSE
		DROP
	THEN
	
THEN
;

W: WM_CTLCOLORSTATIC
 Set-colors
;
 
W: WM_CTLCOLOREDIT
Set-colors
;

W: WM_CTLCOLORBTN
Set-colors 
;

W: WM_CTLCOLORLISTBOX \ CR ." listbox colors !"
\ lparam @ ." lpar=" h.
Set-colors
;
W: WM_CTLCOLORMSGBOX
Set-colors 
;
W: WM_CTLCOLORSCROLLBAR
Set-colors
;
W: WM_CTLCOLORDLG
Set-colors 
;
\ Включаем расцветку для элемента
M: ColorON
TRUE vColored !
;
\ Выключаем расцветку для элемента
M: ColorOFF
FALSE vColored !
;

M: del-bk
vColored @ IF vBkColor @ DeleteObject DROP THEN
;
M: cre-bk
vColored @ IF vBkColor @ DUP vTextBkColor ! CreateSolidBrush vBkColor ! THEN
;
\ Устанавливаем цвета для элемента
M: Set-color ( text bk -- )
del-bk
vBkColor !
cre-bk
\ DROP
vTextColor ! 
TRUE 0 handle @ InvalidateRect DROP
;

DESTR: free
del-bk
free
;
M: Create
Create 
cre-bk
;

;CLASS

