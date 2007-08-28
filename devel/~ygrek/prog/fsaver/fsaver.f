\ Remake of ~day/joop/samples/fsaver.f
\ 06.Jul.2006

REQUIRE FrameWindow ~day/joop/win/FrameWindow.f
REQUIRE Font ~day/joop/win/font.f
REQUIRE NEXT-PARAM ~day/common/clparam.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE file-get-line ~ygrek/lib/filelines.f
REQUIRE CASE lib/ext/case.f

S" filelist.f" INCLUDED
S" config.f" INCLUDED

VARIABLE Count
-15 Count !
VARIABLE FirstMouse
TRUE FirstMouse !
20 CONSTANT Threshold

CLASS: SaverWindow <SUPER FrameWindow

       Font OBJ myFont
       CELL VAR inFile
    2 CELLS VAR CURXY-OLD
    2 CELLS VAR CURXY-NEW

: :nextFile ( -- a u )
   randomName 2DUP R/O OPEN-FILE-SHARED 
   IF DROP " Failed to open file. {s}" STR@ 
   ELSE inFile ! 
   THEN ; 

: :textColor! ( cr -- ) handle @ GetDC SetTextColor DROP ;

: :init
   0 inFile !
   own :init
   WS_POPUP WS_MAXIMIZE OR vStyle !
   WS_EX_TOPMOST vExStyle !
   BLACK_BRUSH GetStockObject DefWinClass <hbrBackground !
   S" Comic Sans MS" DROP myFont <lpszFace !
   20 myFont <height !
   FW_BOLD myFont <weight !
;

W: WM_CREATE
    0 20 1 handle @ SetTimer DROP 0
    0 220 0 rgb handle @ GetDC DUP >R SetTextColor DROP
    0 R@ SetBkColor DROP
    myFont :create
    myFont <handle @ R> SelectObject DROP
;

W: WM_LBUTTONDOWN  BYE ;
W: WM_MBUTTONDOWN  BYE ;
W: WM_RBUTTONDOWN  BYE ;
W: WM_KEYDOWN      BYE ;
W: WM_SYSKEYDOWN   BYE ;
W: WM_MOUSEMOVE    FirstMouse @ IF
                                  FirstMouse 0!
                                  CURXY-OLD GetCursorPos DROP
                                ELSE
                                  CURXY-NEW GetCursorPos DROP
                                  CURXY-OLD @ CURXY-NEW @ - ABS
                                  CURXY-OLD CELL+ @ CURXY-NEW CELL+ @ - ABS
                                  + Threshold > IF  BYE THEN
                                THEN 0 ;

: :scrollWindow
   SW_ERASE
   0
   0
   0
   0
   -1 0 \ dy dx
   handle @ 
   ScrollWindowEx DROP
;

: :addLine  GetDesktopCoord 30 - NIP 0 SWAP self :textOut  ;

W: WM_TIMER
   own :scrollWindow
   Count 1+!
   Count @ 20 = IF
     Count 0!
     inFile @ IF inFile @ file-get-line ELSE 0 THEN
     DUP
     IF
       DUP STR@ own :addLine STRFREE
     ELSE
       DROP
       inFile @ IF inFile @ CLOSE-FILE THROW  0 inFile ! THEN
       \ 50 0 DO own :scrollWindow LOOP
       220 0 0 rgb own :textColor!
       own :nextFile own :addLine
       0 220 0 rgb own :textColor!
       \ 50 0 DO own :scrollWindow LOOP
     THEN
   THEN
   0
;

;CLASS

: RUN { \ w }
   \ STARTLOG
   IDLE_PRIORITY_CLASS GetCurrentProcess SetPriorityClass DROP
   NEXT-PARAM 2DROP
   NEXT-PARAM DROP 1+ C@
   CASE
    [CHAR] c 
    OF 
      0 ShowConfigDialog
    ENDOF
    [CHAR] p 
    OF
      \ S" preview" ShowMessage
      \ NEXT-PARAM - hwnd
    ENDOF
      GetConfigPath names-init
      FALSE ShowCursor DROP
      SaverWindow :new -> w
      0 w :create
      w :show
\      w <handle @ GetDC PaintDesktop DROP
      w :run \ } CATCH >R
      w :free
      TRUE ShowCursor DROP
      \ R> IF S" Error" ShowMessage THEN
   ENDCASE
   BYE   
;

\ RUN \EOF
HERE IMAGE-BASE - 100000 + TO IMAGE-SIZE
' RUN MAINX !
TRUE TO ?GUI
S" fsaver.scr" SAVE BYE
