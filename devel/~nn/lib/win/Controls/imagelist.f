REQUIRE Control ~nn/lib/win/control.f

\ WINAPI: ImageList_Create comctl32.dll
WINAPI: ImageList_LoadImageA comctl32.dll
: LoadImageListBMP { x-size a u -- hlist ior }
    LR_DEFAULTCOLOR IMAGE_BITMAP CLR_DEFAULT 0 x-size a HINST ImageList_LoadImageA  ;


WINAPI: ImageList_Create comctl32.dll
\  HIMAGELIST ImageList_Create(int cx, int cy, UINT flags, int cInitial,  int cGrow  );

WINAPI: ImageList_Add comctl32.dll
\ int ImageList_Add(HIMAGELIST himl, HBITMAP hbmImage, HBITMAP hbmMask );

WINAPI: ImageList_ReplaceIcon comctl32.dll
\ int ImageList_ReplaceIcon(HIMAGELIST himl, int i, HICON hicon);




CLASS: ImageList
    var vFlags
    var vInitImages
    var vMaxImages
    var vCX
    var vCY

    var handle

CONSTR: init
    ILC_MASK ILC_COLOR32 OR vFlags !
    1 vInitImages !
    16 vMaxImages !
    16 vCX !
    16 vCY !
;

M: Create ( -- )
    vMaxImages @ vInitImages @ vFlags @ vCY @ vCX @
    ImageList_Create handle !
\    [ DEBUG? ] [IF] ." ImageList_Create=" handle @ . GetLastError . CR [THEN]
;

M: AddHBMP ( hmbp --) 0 OVER handle @ ImageList_Add
\    [ DEBUG? ] [IF] ." ImageList_Add=" DUP . GetLastError . CR [THEN]
    DROP
    DeleteObject DROP
;

M: AddBMP ( a u --)
    DROP HINST LoadBitmapA
\    [ DEBUG? ] [IF] ." LoadBitmapA=" DUP . GetLastError . CR [THEN]
    AddHBMP
;

M: AddHIcon ( hicon -- n )
    -1 handle @ ImageList_ReplaceIcon
\    [ DEBUG? ] [IF] ." ImageList_ReplaceIcon=" DUP . GetLastError . CR [THEN]
;

M: AddIcon ( a u -- n )
    DROP HINST LoadIconA
\    [ DEBUG? ] [IF] ." LoadIconA=" DUP . GetLastError . CR [THEN]
    AddHIcon
;

M: ReplaceHIcon ( i hicon -- ) SWAP handle @ ImageList_ReplaceIcon DROP ;

M: ReplaceIcon ( i a u -- ) DROP  HINST LoadIconA  ReplaceHIcon ;

;CLASS