REQUIRE FrameWindow ~day\joop\win\framewindow.f

0 VALUE ZOOMX
0 VALUE ZOOMY
2 VALUE koeff

CLASS: MyWindow <SUPER FrameWindow

        2 CELLS VAR CURXY

: :init
    own :init
    WS_EX_TOPMOST vExStyle @ OR vExStyle !
;

W: WM_CREATE
    0 50 1 handle @ SetTimer DROP 0
;

: :setZoom { \ [ /RECT ] r }
    r handle @ GetClientRect DROP
    r rect.right  @ r rect.left @ - koeff / TO ZOOMX
    r rect.bottom @ r rect.top  @ - koeff / TO ZOOMY
;

W: WM_TIMER  { \ deskdc deskwnd }
    own :setZoom
    GetDesktopWindow DUP -> deskwnd
    GetDC -> deskdc
    CURXY GetCursorPos DROP    
    SRCCOPY    
    ZOOMY ZOOMX
    CURXY 2@ ZOOMX 2/ - 0 MAX SWAP ZOOMY 2/ - 0 MAX
    GetDesktopCoord ZOOMY - ROT MIN \ Проверка границ
    SWAP ZOOMX - ROT MIN
    deskdc
    PAD handle @ GetClientRect DROP
    PAD @RECT
    handle @ GetDC
    StretchBlt DROP
    deskdc deskwnd ReleaseDC DROP
    0
;

;CLASS

: test { \ w wpar -- }
    MyWindow :new -> w 
    0 w :create
    100 100 200 200 w :movePixels
    S" jOOP magnify" w :setText
    w :show
    w :run
    w :free
    BYE
;

\ test

HERE IMAGE-BASE - 10000 + TO IMAGE-SIZE
' test MAINX !
TRUE TO ?GUI
S" magnify.exe" SAVE BYE
