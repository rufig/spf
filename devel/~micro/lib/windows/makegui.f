WINAPI: EndDialog user32.dll

MODULE: DlgProcParams

\ as it placed in the stack while callback called

0
CELL -- .hdlg
CELL -- .msg
CELL -- .wParam
CELL -- .lParam
DUP CONSTANT /DlgProcParams
\ additional field
CELL -- .handled
CONSTANT /DlgProcLocals

100 CONSTANT LocalsStackSize
CREATE LocalsStack
	LocalsStackSize /DlgProcLocals * ALLOT
0 VALUE LocalsStackDepth
0 VALUE LocalsStackMaxDepth

: CurrentLocals ( -- &locals )
	LocalsStackDepth 1- /DlgProcLocals *
	LocalsStack + ;

: PushParams ( lParam wParam msg hdlg -- )
	LocalsStackDepth LocalsStackSize < 0= IF ." DlgProc locals stack overflow" THEN
	LocalsStackDepth 1+
	DUP LocalsStackMaxDepth > IF
		DUP TO LocalsStackMaxDepth
	THEN
	TO LocalsStackDepth
	SP@ CurrentLocals /DlgProcParams MOVE
	FALSE CurrentLocals .handled !
	2DROP 2DROP ;
: PopLocals ( -- )
	LocalsStackDepth 0 > 0= IF ." DlgProc locals stack empty" THEN
	LocalsStackDepth 1- TO LocalsStackDepth ;
EXPORT

: hdlg ( -- hdlg )
	CurrentLocals .hdlg @ ;
: msg ( -- msg )
	CurrentLocals .msg @ ;
: wParam ( -- wParam )
	CurrentLocals .wParam @ ;
: lParam ( -- lParam )
	CurrentLocals .lParam @ ;
: IsHandled? ( -- f )
	CurrentLocals .handled @ ;
: Handled ( -- )
	TRUE CurrentLocals .handled ! ;
: Unhandled ( -- )
	FALSE CurrentLocals .handled ! ;

;MODULE

\ распределённый case

: HitchEH ( xt0 xt1 -- )
	EXECUTE
	IsHandled? IF
		DROP
	ELSE
		EXECUTE
	THEN ;
: e+ ( xt0 xt1 -- xt2 )
	:NONAME >R
	SWAP
	POSTPONE LITERAL
	POSTPONE LITERAL
	POSTPONE HitchEH
	POSTPONE ;
	R> ;
: e:
	:NONAME
	POSTPONE Handled ;
: ;e
	POSTPONE ;
	e+ ; IMMEDIATE
: e> ( f -- )
	0= IF
		RDROP
		Unhandled
		EXIT
	THEN ;
: preEH ( lParam wParam msg hdlg -- )
	{{ DlgProcParams PushParams }} ;
: postEH ( -- f )
	IsHandled?
	{{ DlgProcParams PopLocals }} ;

\ прочее

e:
	msg WM_INITDIALOG = e> ;

e:
	msg WM_COMMAND = e>
	wParam IDCANCEL = e>
	0 hdlg EndDialog DROP ;e
	
CONSTANT DefaultForm

: eCatchDefault ( hdlg err -- )
		." error:" . ." in dialog " . ;

' eCatchDefault VALUE eCatch

: eCatcher
	CATCH ?DUP IF
		hdlg SWAP
		eCatch EXECUTE
	THEN ;

: eCallback:
	:NONAME >R
	POSTPONE preEH
	POSTPONE LITERAL
	POSTPONE eCatcher
	POSTPONE postEH
	POSTPONE ;
	R> WNDPROC: ;
