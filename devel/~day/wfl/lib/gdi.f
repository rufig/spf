

CLASS CDCHandle
    VAR handle
    VAR hWnd

: create ( hwnd -- hdc )
    DUP GetDC DUP -WIN-THROW
    DUP CreateCompatibleDC DUP -WIN-THROW
    DUP handle !

    ROT ROT SWAP ReleaseDC DROP
;

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

;CLASS


CDCHandle SUBCLASS CDC

      VAR ?own

init:
    TRUE ?own !
;

dispose:
  SUPER handle @ 0= 0= ?own @ AND
  IF
    SUPER handle @ SUPER hWnd @ ReleaseDC DROP
  THEN
;

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

: createSimple ( color pen -- hPen )
    1 PS_SOLID create
;

;CLASS

CGDIObject SUBCLASS CBrush

: createSolid ( rgb -- brush )
    SUPER handle @ IF SUPER releaseObject THEN
    CreateSolidBrush DUP -WIN-THROW
    DUP SUPER handle !

    SUPER handle @ .
;


;CLASS


CPen SUBCLASS CPenHandle

init: FALSE SUPER ?own ! ;

;CLASS

CBrush SUBCLASS CBrushHandle

init: FALSE SUPER ?own ! ;

;CLASS
