REQUIRE FrameWindow ~day\joop\win\framewindow.f
REQUIRE TIME&DATE lib\include\facil.f
REQUIRE MENUITEM ~day\joop\win\menu.f
REQUIRE Font    ~day\win\font.f

~day\joop\samples\about_dlg.f

101 CONSTANT ID_ABOUT
102 CONSTANT ID_CLOSE

CLASS: ClockWinClass <SUPER WinClass

: :init
     own :init
     S" Clock Class" DROP lpszClassName !
     style @ CS_SAVEBITS OR style !     
;
     
;CLASS

ClockWinClass :newLit VALUE iClockClass

CLASS: ClockWindow <SUPER FrameWindow

        Font OBJ iFont
        
M: ID_ABOUT
    S" Forth clock" S" Version 1.0" self ShowAbout
;

M: ID_CLOSE BYE ;
 
: :createPopup
   POPUPMENU
     S" About" ID_ABOUT MENUITEM
     S" Close" ID_CLOSE MENUITEM
   END-MENU
;

: :init
   own :init
   BLACK_BRUSH GetStockObject iClockClass <hbrBackground !
   WS_DLGFRAME WS_POPUP OR vStyle !
   WS_EX_TOPMOST vExStyle !    
   iClockClass vClass !
   S" Tahoma" DROP iFont <lpszFace !
   18 iFont <height !
   FW_BOLD iFont <weight !   
;

W: WM_CREATE
    0 1000 1 handle @ SetTimer DROP
    0 220 0 rgb handle @ GetDC DUP >R SetTextColor DROP    
    TRANSPARENT R@ SetBkMode DROP
    iFont :create
    iFont <handle @ R> SelectObject DROP    
    0
;

W: WM_TIMER
     TRUE 0 handle @ InvalidateRect DROP 0
;

: :onPaint
   TIME&DATE 2DROP DROP
   SWAP ROT
   0 <# # # 2DROP 0 [CHAR] : HOLD
        # # 2DROP 0 [CHAR] : HOLD
        # # #>
   SWAP 2 6 ToPixels dc TextOutA DROP   
;


W: WM_NCHITTEST
    HTCAPTION \ Обманываем Windows :)
;

W: WM_NCRBUTTONDOWN
   WM_CONTEXTMENU self WM:
;

;CLASS

: test { \ w wpar -- }
    FrameWindow :new -> wpar
    0 wpar :create
    wpar :hide
    ClockWindow :new -> w 
    wpar w :create 
    230 1 50 15 w :move
    S" jOOP clock" w :setText
    w :show
    w :run
    w :free
    wpar :free
    BYE
;


HERE IMAGE-BASE - 10000 + TO IMAGE-SIZE
' test MAINX !
TRUE TO ?GUI
S" clock.exe" SAVE BYE )