REQUIRE Object            ~day\joop\oop.f
REQUIRE WFUNC  ~day\joop\win\wfunc.f
REQUIRE vocLocalsSupport  lib\ext\locals.f

0 VALUE MAIN-HEAP


: INIT-STRUCT ( u -- addr )
    DUP ALLOCATE THROW 
    DUP ROT ERASE
;

: ShowMessage ( addr u -- )
   DROP MB_OK S" Message" DROP ROT 0 MessageBoxA DROP
;

: HIWORD
    16 RSHIFT
;

: LOWORD
    0xFFFFL AND
;

: HANDLE>OBJ ( handle -- obj )
   GWL_USERDATA SWAP GetWindowLongA
;

: ToPixels { x y \ base -- x2 y2 }
    GetDialogBaseUnits  -> base
    x base LOWORD * 4 /
    y base HIWORD * 8 /
;

pvar: <handle

CLASS: Window <SUPER Object

       CELL VAR handle
        
       
: :move { x y w h -- }
    -1 w h ToPixels SWAP  
       x y ToPixels SWAP
       handle @ MoveWindow DROP
;
: :movePixels { x y w h -- }
    -1 h w y x handle @ MoveWindow DROP
;

: :show
    SW_SHOW handle @ ShowWindow DROP
;

: :hide
    SW_HIDE handle @ ShowWindow DROP
;    

: :free
     handle @ IsWindow IF handle @ DestroyWindow DROP THEN
     own :free
;

: :parentObj
    handle @ GetParent HANDLE>OBJ
;

: :getText ( -- addr u )
    1024 PAD handle @ GetWindowTextA
    PAD SWAP
;

: :setText ( addr u -- )
    DROP handle @ SetWindowTextA DROP
;

: :update
    handle @ UpdateWindow DROP
;

: :disable
    FALSE handle @ EnableWindow DROP
;

: :enable
    TRUE handle @ EnableWindow DROP
;

: :setFont ( hfont -- )
    0 SWAP WM_SETFONT handle @ SendMessageA DROP
;

: :addStyle ( u -- )
    GWL_STYLE handle @ GetWindowLongA
    OR GWL_STYLE handle @ SetWindowLongA DROP
;

: :textOut ( addr u x y)
   2>R SWAP 2R> SWAP
   handle @ GetDC
   TextOutA DROP
;

;CLASS

<< :move
<< :movePixels
<< :show
<< :hide
<< :parentObj
<< :getText
<< :setText
<< :update
<< :disable
<< :enable
<< :setFont
<< :addStyle
<< :textOut

: CreateWindow ( ... -- hwnd )
    CreateWindowExA DUP 0= IF ABORT" Windows failed to create..." THEN
;

: obj! { handle self -- }
\ Записывает self в GWL_USERDATA
    handle self <handle !
    self GWL_USERDATA handle SetWindowLongA DROP
;
