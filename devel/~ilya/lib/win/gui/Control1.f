\ Расширения Control.f  от ~nn
\
\ 
\ Раcширение класса ListBox
\ 29.03.2005г. Абдрахимов И.А.
REQUIRE ColorON ~ilya\lib\win\gui\FrameWindowC.f
REQUIRE CASE \lib\ext\case.f
REQUIRE W>S ~ilya/lib/w-s.f
REQUIRE Control ~nn/lib/win/control.f
REQUIRE Hook ~yz\lib\comevents.f
REQUIRE FreeList ~nn\lib\list.f

ListBox REOPEN
M: ListboxScrollTo ( index  -- )
  0 SWAP LB_SETTOPINDEX  SendMessage DROP
;
\ Очистить весь список
M: ClearAll 0 0 LB_RESETCONTENT SendMessage DROP ;
\ Найти строку z  в списке
M: Find ( z -- n )
TRUE LB_FINDSTRING SendMessage 
;
\ Выбрать в списке 0 ( z) строку адресованную z
M: Select ( z -- )
TRUE LB_SELECTSTRING SendMessage DROP
;
\ Установить ширину столбца
M: SetColumnWith ( n -- )
0 SWAP LB_SETCOLUMNWIDTH SendMessage DROP
;

M: Current! ( index -- ) 0 SWAP LB_SETCURSEL SendMessage DROP ;

M: SetItem ( addr u idx -- )
NIP LB_SETITEMDATA SendMessage DROP
;

C: LBN_SELCHANGE OnClick GoParent ;

;CLASS


Edit REOPEN
\ Выделить текст
M: SetSelect ( ustart uend -- )
EM_SETSEL SendMessage DROP ;


;CLASS

\ \\\\\\\\\\\\\\\\\\\ Scroll bar \\\\\\\\\\\\\\\\\\\\\\\\\\\\

CLASS: ScrollBar <SUPER Control
		var OnChange
        var pos		\ текущая позиция "бегунка"
		var step	\ шаг перемещения "бегунка"
		var min
		var max
CONSTR: init init 
1 step !
;
VM: Type S" scrollbar" ;

\ VM: Style SBS_VERT ;
VM: Style ( SBS_HORZ) 0 ;

M: SetRange ( min max )
	2DUP max ! min !
    TRUE ROT ROT
    SWAP SB_CTL 
    handle @
    SetScrollRange DROP
;

M: GetPos ( u)
    SB_CTL handle @
    GetScrollPos
;

M: SetPos ( u)
    DUP
    TRUE SWAP
    SB_CTL handle @
    SetScrollPos DROP
    pos !
;

\ Этот метод используется в нижеследующем доопределении 
\ класса FrameWindow
M: Scroll
CASE
		SB_THUMBPOSITION OF W>S pos ! ENDOF
		SB_LINELEFT   	OF pos @ min @ max @ WITHIN
							IF
								step @ NEGATE pos +! 
							THEN
							DROP
						ENDOF
		SB_PAGELEFT   OF step @ 2* NEGATE pos +! DROP ENDOF
		SB_LINERIGHT 	OF  pos @ min @ max @ WITHIN
							IF
								step @ pos +!
							THEN
							DROP
						ENDOF
		SB_PAGERIGHT OF  step @ 2* pos +! DROP ENDOF
		\ SB_THUMBTRACK OF wparam @ HIWORD W>S pos ! ENDOF

		2DROP 0 EXIT

ENDCASE
		pos @ SetPos
		OnChange GoParent 
1
;
;CLASS

\ \\\\\\\\\\\\\\\\\\\ Static \\\\\\\\\\\\\\\\\\\\\\\\\\\\

Static REOPEN

M: SetImage ( himg img-type -- )  STM_SETIMAGE SendMessage DROP ;

;CLASS


FrameWindow REOPEN

W: WM_HSCROLL 
wparam @ HIWORD
wparam @ LOWORD 
lparam @ HANDLE>OBJ
 ->CLASS ScrollBar Scroll	
;
W: WM_VSCROLL 
wparam @ HIWORD
wparam @ LOWORD 
lparam @ HANDLE>OBJ
 ->CLASS ScrollBar Scroll	
;
;CLASS

\ EOF
\ \\\\\\\\\\\\\\\\\\\ ActiveX \\\\\\\\\\\\\\\\\\\\\\\\\\\\

WINAPI:	AtlAxCreateControl 		atl.dll
WINAPI:	AtlAxGetControl			atl.dll

2 CONSTANT COINIT_APARTMENTTHREADED
0 VALUE _cominit
: StartCOM
_cominit 0= IF
   COINIT_APARTMENTTHREADED
   0 CoInitializeEx ABORT" Cannot initialize COM"
   TRUE TO _cominit
   THEN
;

: EndCOM
   CoUninitialize DROP 
   FALSE TO _cominit
;



\ EOF
Window REOPEN 
CONSTR: init
StartCOM 
init 
;

DESTR: free 
free
EndCOM 
;

;CLASS
\ EOF
0 VALUE AXPhandle
VARIABLE AXPhandle1

CLASS: AXControl <SUPER Window
		var	control
		var lhook


\ События ActiveX 
M: AXHook ( memid xt -- )
control @ -ROT OVER >R Hook
R> lhook AppendNode
;


M: xUnhook
NodeValue control @ SWAP Unhook
;


DESTR: free 
['] xUnhook lhook DoList
lhook FreeList 
control @ Disconnect
control @ release 
free 
;


M: CreateAX ( adr n -- )	\ Где adr n - ProgId (Пример: "MSCAL.Calendar" и т.п.)
	Create 
	DROP >R 0 0  handle @ R> >unicodebuf  DUP >R  AtlAxCreateControl CR ." this!" CR R> FREE THROW CR ." AXC=" . \ ABORT" Not ax"
	control handle @ AtlAxGetControl CR ." rez=" .
	control @ Connect CR ." conn="  .
	hParent @ TO AXPhandle 
	handle @ AXPhandle1 !
	
;

;CLASS
\ : hp S" AXPhandle HANDLE>OBJ"  EVALUATE ;
: AXM: [COMPILE] : S" AXPhandle HANDLE>OBJ"  EVALUATE POSTPONE => ;
\ : AXM: [COMPILE] : S" AXPhandle HANDLE>OBJ" EVALUATE  ;
\ : AXM1: [COMPILE] : S" AXPhandle1 @ HANDLE>OBJ"  EVALUATE POSTPONE => S" OnEvent GoParent" EVALUATE ;

\ 