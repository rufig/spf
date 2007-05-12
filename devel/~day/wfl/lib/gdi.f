
WINAPI: GetSysColorBrush USER32.DLL
WINAPI: CreateBitmap     GDI32.DLL
WINAPI: CreatePatternBrush GDI32.DLL
WINAPI: MoveToEx         GDI32.DLL
WINAPI: LineTo           GDI32.DLL

CLASS CDCHandle

    VAR handle
    VAR hWnd

: checkDC ( -- hdc )
    handle @
;

: selectObject ( hgdiobj -- prevobj )
    checkDC SelectObject
    DUP -WIN-THROW
;

: fillRect ( bottom right top left brush )
   || CRect r ||
   >R r ! R>
   r addr
   checkDC FillRect -WIN-THROW
;

: setTextColor ( colorref )
   checkDC SetTextColor -WIN-THROW
;

: line ( x1 y1 x2 y2 )
   2SWAP SWAP 0 ROT ROT checkDC MoveToEx -WIN-THROW
   SWAP checkDC LineTo -WIN-THROW
;

;CLASS


CDCHandle SUBCLASS CDC

      VAR ?own

init:
    TRUE ?own !
;

: create ( hwnd -- hdc )
    GetDC DUP -WIN-THROW
    DUP SUPER handle !
;

: release ( -- )
  SUPER handle @ 0= 0= ?own @ AND
  IF
    SUPER checkDC SUPER hWnd @ ReleaseDC DROP
    0 SUPER handle !
  THEN ;

dispose: release ;


;CLASS

CDCHandle SUBCLASS CPaintDC
    /PS DEFS ps

: create ( hwnd -- hdc )
    DUP SUPER hWnd !
    ps SWAP BeginPaint DUP -WIN-THROW
    DUP SUPER handle !
;

dispose:
    ps SUPER hWnd @ EndPaint DROP
;

;CLASS

CLASS CGDIObject

    VAR handle
    VAR ?own

init: TRUE ?own ! ;

: checkHandle ( -- h ) handle @ ;

: releaseObject    
   handle @ 0= 0= ?own @ AND
   IF handle @ DeleteObject DROP handle 0! THEN
;

dispose:
   releaseObject
;

;CLASS

CGDIObject SUBCLASS CPen

: create ( color width style -- hPen )
    SUPER handle @ IF SUPER releaseObject THEN
    CreatePen DUP -WIN-THROW
    DUP SUPER handle !
;

: createSimple ( color -- hPen )
    1 PS_SOLID create
;

;CLASS

CGDIObject SUBCLASS CBrush

: createSolid ( rgb -- brush )
    SUPER handle @ IF SUPER releaseObject THEN
    CreateSolidBrush DUP -WIN-THROW
    DUP SUPER handle !
;

: getSysColorBrush ( index -- brush )
    GetSysColorBrush DUP -WIN-THROW
    DUP SUPER handle !
;

CREATE HalftonePattern 16 ALLOT

: fillHalftonePattern
    8 0 DO
      0x5555 I 1 AND LSHIFT
      HalftonePattern I 2* + W!
    LOOP
;

fillHalftonePattern

: createHalftoneBrush ( -- brush )
    HalftonePattern
    1 1
    8 8 
    CreateBitmap DUP -WIN-THROW
    DUP CreatePatternBrush DUP -WIN-THROW
    DUP SUPER handle !
    SWAP DeleteObject -WIN-THROW
;


;CLASS


CPen SUBCLASS CPenHandle

init: FALSE SUPER ?own ! ;

;CLASS

CBrush SUBCLASS CBrushHandle

init: FALSE SUPER ?own ! ;

;CLASS


CLASS CLOGFONT
   0 DEFS addr
   VAR lfHeight 
   VAR lfWidth
   VAR lfEscapement 
   VAR lfOrientation 
   VAR lfWeight 
   VAR lfItalic 
   VAR lfUnderline 
   VAR lfStrikeOut 
   VAR lfCharSet 
   VAR lfOutPrecision 
   VAR lfClipPrecision 
   VAR lfQuality
   VAR lfPitchAndFamily 
   VAR lfFaceName 
;CLASS

WINAPI: CreateFontIndirectA GDI32.DLL

CGDIObject SUBCLASS CFont

: create ( lfHeight lfWeight addr u )
    || CLOGFONT lf ||

    SUPER handle @ IF SUPER releaseObject THEN

    DROP lf lfFaceName !
    lf lfWeight !
    lf lfHeight !

    lf addr CreateFontIndirectA SUPER handle !
;

;CLASS