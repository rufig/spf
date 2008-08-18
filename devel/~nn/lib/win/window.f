S" ~nn/lib/win/adapter.f" INCLUDED
REQUIRE { /lib/ext/locals.f
REQUIRE CLASS:            ~nn/class/class.f
REQUIRE S>ZALLOC ~nn/lib/az.f
\ REQUIRE RegisterClassExA  ~nn/lib/win/wfunc.f

WINAPI: SetFocus USER32.DLL

0 VALUE MAIN-HEAP
IMAGE-BASE CONSTANT HINST \ хэндл приложения

: INIT-STRUCT ( u -- addr )
    DUP ALLOCATE THROW
    DUP ROT ERASE
;

: ShowMessage ( addr u -- )
   DROP MB_OK S" Message" DROP ROT 0 MessageBoxA DROP
;

: HIWORD 16 RSHIFT ;

: LOWORD 0xFFFF AND ;

: HANDLE>OBJ ( handle -- obj )
   GWL_USERDATA SWAP GetWindowLongA
;

WINAPI: GetDialogBaseUnits USER32.DLL
VECT GetDlgBaseUnits
' GetDialogBaseUnits TO GetDlgBaseUnits
: ToPixels { x y \ base -- x2 y2 }
    GetDlgBaseUnits  TO base
    x base LOWORD * 4 /
    y base HIWORD * 8 /
;

: FromPixels { x y \ base -- x2 y2 }
    GetDlgBaseUnits  TO base
    x 4 * base LOWORD /
    y 8 * base HIWORD /
;

: rgb           ( red green blue -- colorref )
   2               \ flag             ( for palette rgb value )
   256 * +         \ flag*256 + blue
   256 * +         \ flag*256 + blue*256 + green
   256 * +        \ flag*256 + blue*256 + green*256 + red
;

\ 0
\ CELL -- rect.left
\ CELL -- rect.top
\ CELL -- rect.right
\ CELL -- rect.bottom
\ CONSTANT /RECT

\ временно, взамен неработающей RFREE
 : _RFREE ( u)
    2 LSHIFT
    R> SWAP RP@ +
    RP! >R
 ;

: GetDesktopSize ( -- x y)
\ Получить размер десктопа
    0 0 0 0 SP@
    GetDesktopWindow
    GetClientRect DROP
    2DROP
    SWAP
;

: @RECT ( addr -- bottom right top left )
    >R
    R@ 3 CELLS + @
    R@ 2 CELLS + @
    R@ CELL+ @
    R> @
;


\ pvar: <handle

CLASS: Window

       var vWidth
       var vHeight
       var vX
       var vY
       var vText
       char vVisible

       var handle
       var hParent
       var vStyle
       var vExStyle
       var vMenu

       var lparam
       var wparam
       var message
       var hwnd


VM: Type S" Static" ;

VM: Style 0 ;
VM: ExStyle 0 ;

M: pos ( x y -- ) vY ! vX ! ;
M: size ( w h -- ) vHeight ! vWidth ! ;

M: text ( a u -- )
    vText @ ?DUP IF FREE DROP THEN
    S>ZALLOC vText !
    ;




CONSTR: init
    CW_USEDEFAULT vWidth !
    CW_USEDEFAULT vHeight !
    CW_USEDEFAULT vX !
    CW_USEDEFAULT vY !
;

VM: CreateMenu 0 ;

M: visible   1 vVisible C! ;
M: invisible 0 vVisible C! ;
M: v visible ;
M: v- invisible ;

M: Show   visible SW_SHOW handle @ ShowWindow DROP  ;
M: ?Show  vVisible C@ 0= IF Show THEN ;
M: Hide   invisible SW_HIDE handle @ ShowWindow DROP  ;
M: ?Hide  vVisible C@ IF Hide THEN ;


M: Create { owner -- }
    this
    HINST
    CreateMenu DUP vMenu !
    hParent @ ?DUP 0= IF  owner DUP IF => handle @ THEN THEN
    DUP hParent !
    vHeight @ vWidth @ vY @ vX @
    Style vStyle @ OR
        owner 0= IF WS_OVERLAPPED ELSE WS_CHILD  THEN OR
    vText @
    Type DROP
    ExStyle vExStyle @ OR
    CreateWindowExA
    DUP 0= IF  GetLastError THROW THEN
    handle !
    this GWL_USERDATA handle @ SetWindowLongA DROP
    vVisible C@ IF Show THEN
;

M: FillMessage ( l w m h -- )
     hwnd !
     message !
     wparam !
     lparam !
;

M: SendMessage ( lParam wParam msg -- res )  handle @ SendMessageA ;

M: Close ( code -- ) PostQuitMessage DROP ;

M: Move { x y w h -- }
    -1 w h ToPixels 2DUP size SWAP
       x y ToPixels 2DUP pos SWAP
       handle @ MoveWindow DROP
;
M: MovePixels { x y w h -- }   -1 h w y x handle @ MoveWindow DROP ;

M: SetSizePixels { w h -- }
    SWP_NOMOVE ( SWP_NOREDRAW OR)
    h w 0 0 HWND_TOP handle @ SetWindowPos DROP ;

M: SetSize ( w h -- ) ToPixels SetSizePixels ;

M: SetPos { x y -- }
    SWP_NOSIZE ( SWP_NOREDRAW OR)
    0 0 y x HWND_TOP handle @ SetWindowPos DROP ;

M: SetPosU { x y -- } x y ToPixels SetPos ;

M: GetRect ( -- bottom right top left )
    0 0 0 0 SP@ handle @ GetWindowRect DROP ;

M: GetPos ( -- x y )  GetRect 2SWAP 2DROP SWAP ;

M: GetWindowSize ( -- x y ) GetRect ROT SWAP - ROT ROT - ;

M: Center ( w h -- )
    0 ROT ROT ToPixels SWAP
    2DUP SWAP GetDesktopSize   ROT - 2 / ROT ROT SWAP - 2 /
    HWND_TOP handle @
    SetWindowPos DROP
;

DESTR: free
     handle @ IsWindow IF handle @ DestroyWindow DROP THEN
\     free
;

M: ParentObj  handle @ GetParent HANDLE>OBJ ;

M: GetText ( -- addr u )
    vText @ ?DUP IF FREE DROP THEN
    handle @ GetWindowTextLengthA 1+ DUP  ALLOCATE THROW DUP vText !
    handle @ GetWindowTextA
    vText @ SWAP
;

M: SetText ( addr u -- )
    text vText @ handle @ SetWindowTextA DROP ;

M: Update   handle @ UpdateWindow DROP ;

M: Disable  FALSE handle @ EnableWindow DROP ;

M: Enable   TRUE handle @ EnableWindow DROP ;

M: SetFont ( hfont -- )   0 SWAP WM_SETFONT handle @ SendMessageA DROP ;
M: GetFont ( -- hfont )   0 0 WM_GETFONT handle @ SendMessageA ;

M: AddStyle ( u -- )
    GWL_STYLE handle @ GetWindowLongA
    OR GWL_STYLE handle @ SetWindowLongA DROP
;


M: SetFocus handle @ SetFocus DROP ;

M: isActive GetFocus handle @ = ;

M: TextOut ( addr u x y)
   2>R SWAP 2R> SWAP
   handle @ GetDC
   TextOutA DROP
;

: M:: ( c "WM_..." -- )
  \ определить обработчик сообщения
  \ c - символ типа сообщения
  BASE @ >R
  NextWord EVALUATE HEX \ Для того чтобы Windows константы искались
  0 <# # # # #  # # # # ROT HOLD BL HOLD [CHAR] : HOLD #>
  EVALUATE
  R> BASE !
;

: W: [CHAR] W M:: ; \ WM_...
: C: [CHAR] C M:: ; \ WM_COMMAND
: N: [CHAR] N M:: ; \ WM_NOTIFY
: P: [CHAR] P M:: ; \ WM_PARENTNOTIFY
: MM: [CHAR] M M:: ; \ меню


;CLASS

: CreateWindow ( ... -- hwnd )
    CreateWindowExA DUP 0= IF
        GetLastError THROW
\        ABORT" Windows failed to create..."
        THEN
;

: SearchWM ( mess_id oid c -- xt -1 | -- 0)
  OVER 0= IF 2DROP DROP 0 EXIT THEN
  BASE @ >R HEX
  ROT
  0 <# # # # #  # # # # ROT HOLD #> ( 2DUP TYPE CR) HOLD 1-
  SWAP ->CLASS SUPERCLASS PARENT @ CLASS-FIND
  DUP 0= IF NIP THEN
  R> BASE !
;

: ExecuteMethod ( xt oid)
   [ ALSO OOP ]
   this >R
   TO this
   EXECUTE
   R> TO this
   [ PREVIOUS ]
;

: ->WM ( mess_id oid c)
\ Послать заданное сообщение объекту
  OVER >R SearchWM
  IF R> ExecuteMethod
  ELSE R> DROP
  THEN
;

: WM: [CHAR] W ->WM ;

