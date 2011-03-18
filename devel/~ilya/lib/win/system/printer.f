S" \lib\ext\locals.f" INCLUDED
REQUIRE STRUCT:        lib\ext\struct.f
\ REQUIRE WINCONST       lib\win\const.f

\ S" ~af/lib/api-func.f" INCLUDED
S" ~nn/lib/usedll.f" INCLUDED
0 [IF]
 USES comdlg32.dll
 USES kernel32.dll
 USES gdi32.dll
 USES WINSPOOL.DRV
 [THEN]
 
 UseDLL comdlg32.dll
 UseDLL kernel32.dll
 UseDLL gdi32.dll
 UseDLL WINSPOOL.DRV

0 CONSTANT NULL
0x100 CONSTANT PD_RETURNDC

STRUCT: RECT
4 -- left
4 -- top
4 -- right
4 -- bottom
;STRUCT

STRUCT: PRINTDLG
4 -- lStructSize
4 -- hwndOwner
4 -- hDevMode
4 -- hDevNames
4 -- hDC
4 -- Flags
2 -- nFromPage
2 -- nToPage
2 -- nMinPage
2 -- nMaxPage
2 -- nCopies
4 -- hInstance
4 -- lCustData
4 -- lpfnPrintHook
4 -- lpfnSetupHook
4 -- lpPrintTemplateName
4 -- lpSetupTemplateName
4 -- hPrintTemplate
4 -- hSetupTemplate
;STRUCT

STRUCT: DOCINFO
4 -- cbSize
4 -- lpszDocName
4 -- lpszOutput
4 -- lpszDataType
4 -- fwType
;STRUCT

USER-CREATE Rect1 {{ RECT /SIZE USER-ALLOT }}
USER-CREATE Rect2 {{ RECT /SIZE USER-ALLOT }}
USER-CREATE pd {{ PRINTDLG /SIZE USER-ALLOT }}
USER-CREATE di {{ DOCINFO /SIZE USER-ALLOT }}
0 VALUE metaDC
0 VALUE metaFile
0 VALUE MapModeOriginal
0 VALUE PenOriginal
0 VALUE BrushOriginal
0 VALUE FontOriginal
0 VALUE BkModeOriginal
0 VALUE LogPixelsX
0 VALUE LogPixelsY
0 VALUE PhysicalOffsetX
0 VALUE PhysicalOffsetY
0 VALUE ModeRD
0 VALUE CurPage

0x000000 CONSTANT clBlack
0x000080 CONSTANT clMaroon
0x008000 CONSTANT clGreen
0x008080 CONSTANT clOlive
0x800000 CONSTANT clNavy
0x800080 CONSTANT clPurple
0x808000 CONSTANT clTeal
0x808080 CONSTANT clGray
0xC0C0C0 CONSTANT clSilver
0x0000FF CONSTANT clRed
0x00FF00 CONSTANT clLime
0x00FFFF CONSTANT clYellow
0xFF0000 CONSTANT clBlue
0xFF00FF CONSTANT clFuchsia
0xFFFF00 CONSTANT clAqua
0xFFFFFF CONSTANT clWhite

16 CONSTANT bsSolid
17 CONSTANT bsNull
 0 CONSTANT bsHorizontal
 1 CONSTANT bsVertical
 2 CONSTANT bsFDiagonal
 3 CONSTANT bsBDiagonal
 4 CONSTANT bsCross
 5 CONSTANT bsDiagcross

PS_SOLID      CONSTANT psSolid
PS_DASH       CONSTANT psDash
PS_DOT        CONSTANT psDot
PS_DASHDOT    CONSTANT psDashdot
PS_DASHDOTDOT CONSTANT psDashdotdot
PS_NULL       CONSTANT psNull


MODULE: cPEN
psSolid VALUE STYLE
      1 VALUE WIDTH
clBlack VALUE COLOR
;MODULE

MODULE: cBRUSH
bsSolid VALUE STYLE
clBlack VALUE COLOR
;MODULE

MODULE: cFONT-INT
0 VALUE NAME-FACE
;MODULE

MODULE: cFONT
-10          VALUE HEIGHT
  0          VALUE WIDTH
  0          VALUE ORIENTATION
FW_NORMAL    VALUE WEIGHT
FALSE        VALUE ITALIC
FALSE        VALUE UNDERLINE
FALSE        VALUE STRIKEOUT
ANSI_CHARSET VALUE CHARSET
VARIABLE_PITCH FF_SWISS OR VALUE PITCHANDFAMILY
: NAME [ ALSO cFONT-INT ] ( NAME-FACE STRFREE) TO NAME-FACE [ PREVIOUS ] ;
;MODULE

STRUCT: logFONT
	CELL -- lfHeight
	CELL -- lfWidth 
	CELL -- lfEscapement 
	CELL -- lfOrientation
	CELL -- lfWeight 
	CELL -- lfItalic
	CELL -- lfUnderline 
	CELL -- lfStrikeOut
	CELL -- lfCharSet 
	CELL -- lfOutPrecision 
	CELL -- lfClipPrecision
	CELL -- lfQuality 
	CELL -- lfPitchAndFamily
	CELL -- lfFaceName
;STRUCT

MODULE: cPageProperty
 100 VALUE LEFTMARGIN
 100 VALUE TOPMARGIN
1900 VALUE WITHIMAGE
2770 VALUE HEIGHTIMAGE
;MODULE



\ ====================================
\ 
\ ====================================


: FillPD
  {{ PRINTDLG
    /SIZE pd lStructSize !
    NULL pd hwndOwner !
    NULL pd hDevMode !
    NULL pd hDevNames !
    NULL pd hDC !
    PD_RETURNDC pd Flags !
    1 pd nFromPage W!
    1 pd nToPage W!
    1 pd nMinPage W!
    1 pd nMaxPage W!
    1 pd nCopies W!
    NULL pd hInstance !
    0 pd lCustData !
    NULL pd lpfnPrintHook !
    NULL pd lpfnSetupHook !
    NULL pd lpPrintTemplateName !
    NULL pd lpSetupTemplateName !
    NULL pd hPrintTemplate !
    NULL pd hSetupTemplate !
  }}
;

: FillDI
  {{ DOCINFO  
    /SIZE di cbSize !
    S" Nalog-2001 print" DROP di lpszDocName !
    NULL di lpszOutput !
    NULL di lpszDataType !
    0 di fwType !
  }}          
;

:NONAME { iError hdc }
   CR ." Print abort !"
   CR ." Hdc=" hdc .
   CR ." Err=" iError .
   FALSE
;
WNDPROC: PrintAbortProc

: PrintStart ( -- f )
  FillPD
  pd PrintDlgA IF
    FillDI
    ['] PrintAbortProc  pd {{ PRINTDLG hDC }} @  SetAbortProc DROP

    LOGPIXELSX       pd {{ PRINTDLG hDC }} @  GetDeviceCaps TO LogPixelsX
    LOGPIXELSY       pd {{ PRINTDLG hDC }} @  GetDeviceCaps TO LogPixelsY
    PHYSICALOFFSETX  pd {{ PRINTDLG hDC }} @  GetDeviceCaps TO PhysicalOffsetX
    PHYSICALOFFSETY  pd {{ PRINTDLG hDC }} @  GetDeviceCaps TO PhysicalOffsetY

    di pd {{ PRINTDLG  hDC }} @ StartDocA DROP

    TRUE
  ELSE FALSE
  THEN
;

: PrintEnd
  pd {{ PRINTDLG hDC }} @ EndDoc DROP
;

: PrintPage { metaFile -- }
  {{ RECT     
    {{ cPageProperty LEFTMARGIN }} 10 * LogPixelsX 2540 */ PhysicalOffsetX - Rect2 left !
    {{ cPageProperty TOPMARGIN  }} 10 * LogPixelsY 2540 */ PhysicalOffsetY - Rect2 top !
    Rect1 right  @ LogPixelsX 2540 */ Rect2 left @ + Rect2 right !
    Rect1 bottom @ LogPixelsY 2540 */ Rect2 top  @ + Rect2 bottom !
  }}          

  pd {{ PRINTDLG hDC }} @ StartPage DROP
  Rect2  metaFile  pd {{ PRINTDLG hDC }} @  PlayEnhMetaFile DROP
  pd {{ PRINTDLG hDC }} @ EndPage DROP
  metaFile DeleteEnhMetaFile DROP
;

MODULE: ReportDriver
	0 VALUE lX
	0 VALUE lY
\ : DOS>WIN ( addr u -- addr u )
\  2DUP
\  0 ?DO DUP I + C@ CDOS>WIN OVER I + C! LOOP DROP
\ ;

: TEXTALIGN ( mode)
  metaDC SetTextAlign DROP 
;

: BKMODE ( mode)
  metaDC SetBkMode DROP
;

: Brush{ 
  ALSO cBRUSH
;  \ IMMEDIATE

: }SetBrush
  {{ cBRUSH STYLE }} DUP bsNull = IF
    DROP NULL_BRUSH GetStockObject
  ELSE
    DUP bsSolid = IF
      DROP {{ cBRUSH COLOR }} CreateSolidBrush
    ELSE
      {{ cBRUSH COLOR }} SWAP CreateHatchBrush
    THEN
  THEN
  metaDC SelectObject  DeleteObject DROP
  PREVIOUS
; \ IMMEDIATE

: Pen{
  ALSO cPEN
;  IMMEDIATE

: }SetPen 
  {{ cPEN COLOR WIDTH STYLE }} CreatePen
  metaDC SelectObject  DeleteObject DROP
  PREVIOUS
;  IMMEDIATE

: Font{
   ALSO cFONT
   \ {{ cFONT
;  IMMEDIATE

: }SetFont
  {{ cFONT-INT NAME-FACE }} \ @ \ STR@ DROP
  {{ cFONT
    PITCHANDFAMILY
    DEFAULT_QUALITY
    CLIP_DEFAULT_PRECIS
    OUT_DEFAULT_PRECIS
    cFONT CHARSET
    cFONT STRIKEOUT
    cFONT UNDERLINE
    cFONT ITALIC
    cFONT WEIGHT
    cFONT ORIENTATION
    DUP
    cFONT WIDTH
    cFONT HEIGHT
  }}
  CreateFontA metaDC SelectObject  DeleteObject DROP
   PREVIOUS 
  
   \ }}
;  IMMEDIATE

: FillEllipse { LeftRect TopRect RightRect BottomRect }
  BottomRect NEGATE RightRect TopRect NEGATE LeftRect
  metaDC Ellipse DROP
;

: Ellipse
   [ ALSO cBRUSH ] 
  Brush{ STYLE >R bsNull TO STYLE }SetBrush
  FillEllipse
  Brush{ R> TO STYLE }SetBrush
   [ PREVIOUS ] 
;
: FillRectangle { LeftRect TopRect RightRect BottomRect }
  BottomRect NEGATE RightRect TopRect NEGATE LeftRect
  metaDC Rectangle DROP
;
: Rectangle
   [ ALSO cBRUSH ] 
  Brush{ STYLE >R bsNull TO STYLE }SetBrush
  FillRectangle
  Brush{ R> TO STYLE }SetBrush
   [ PREVIOUS ] 
;
: Line { X Y XEnd YEnd }
  NULL Y NEGATE X  metaDC MoveToEx DROP
  YEnd NEGATE XEnd  metaDC LineTo DROP
;

: HLINE ( x1 x2 y -- ) SWAP OVER Line ;

: VLINE ( y1 y2 x -- ) DUP >R ROT ROT R> SWAP Line ;

: Text { saddr slen x y }
  slen saddr y NEGATE x   metaDC TextOutA DROP
;

: pt ( pt -- mm*10 ) 254 72 */ NEGATE ;


: Is1-9 ( addr u -- f)
  0 ?DO DUP C@ DUP [CHAR] 0 > [CHAR] 9 1+ ROT < AND
    IF DROP TRUE UNLOOP EXIT THEN
  1+ LOOP
  DROP FALSE
;

: InitMeta
  MM_LOMETRIC metaDC SetMapMode TO MapModeOriginal
  TRANSPARENT metaDC SetBkMode TO BkModeOriginal
  BLACK_PEN GetStockObject     metaDC SelectObject TO PenOriginal
  BLACK_BRUSH GetStockObject   metaDC SelectObject TO BrushOriginal
  ANSI_VAR_FONT GetStockObject metaDC SelectObject TO FontOriginal
;

: DestroyMeta
  MapModeOriginal metaDC SetMapMode DROP
  BkModeOriginal metaDC SetBkMode DROP
  PenOriginal metaDC SelectObject  DeleteObject DROP
  BrushOriginal metaDC SelectObject  DeleteObject DROP
  FontOriginal metaDC SelectObject  DeleteObject DROP
;

: PageProperty{
  ALSO cPageProperty
; IMMEDIATE

: }SetPageProperty
  PREVIOUS
; IMMEDIATE

 \ WINAPI: CreateEnhMetaFileA gdi32.dll
: StartPage1
  {{ RECT
    0 Rect1 left !
    0 Rect1 top !
    {{ cPageProperty WITHIMAGE   }} 10 * Rect1 right !
    {{ cPageProperty HEIGHTIMAGE }} 10 * Rect1 bottom !
  }}
  CurPage 1+ TO CurPage
  
  NULL
  Rect1
  ModeRD 2 = IF NULL ELSE  metaFile \ " {ModuleDirName}page{CurPage}.emf" STR@ DROP
  THEN
  NULL
  CreateEnhMetaFileA TO metaDC

  InitMeta
;
: EndPage1
  DestroyMeta
  metaDC CloseEnhMetaFile 
  ModeRD 2 = IF PrintPage ELSE DeleteEnhMetaFile DROP  THEN
;

;MODULE
