REQUIRE FrameWindow ~day\joop\win\FrameWindow.f
REQUIRE Font ~day\joop\win\font.f
REQUIRE NEXT-PARAM ~day\common\clparam.f

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

: :init
   own :init
   WS_POPUP WS_MAXIMIZE OR vStyle !
   WS_EX_TOPMOST vExStyle !
   BLACK_BRUSH GetStockObject DefWinClass <hbrBackground !
   S" Comic Sans MS" DROP myFont <lpszFace !
   20 myFont <height !
   S" ssaver.txt" +ModuleDirName R/O OPEN-FILE
   IF S" Нет файлика ssaver.txt!" ShowMessage BYE ELSE  inFile ! THEN
   FW_BOLD myFont <weight !
;

W: WM_CREATE
    0 20 1 handle @ SetTimer DROP 0
    0 220 0 rgb handle @ GetDC DUP >R SetTextColor DROP    
    0 R@ SetBkColor DROP
    myFont :create
    myFont <handle @ R> SelectObject DROP
;

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


W: WM_TIMER
   own :scrollWindow
   Count 1+!
   Count @ 20 = IF
     Count 0!
     PAD 256 inFile @ READ-LINE THROW
     IF
       PAD SWAP
       GetDesktopCoord 30 - NIP 0 SWAP self :textOut   
     ELSE
       0 inFile @ REPOSITION-FILE THROW
     THEN
   THEN
   0
;

;CLASS


: RUN { \ w }
   IDLE_PRIORITY_CLASS GetCurrentProcess
   SetPriorityClass DROP
   NEXT-PARAM 2DROP
   NEXT-PARAM  DROP 1+ C@ DUP [CHAR] p = IF BYE THEN
   [CHAR] c =
   IF
      S" There aren't any options" ShowMessage
   ELSE
      FALSE ShowCursor DROP
      SaverWindow :new -> w
      0 w :create
      w :show
\      w <handle @ GetDC PaintDesktop DROP
      w :run
      w :free
      TRUE ShowCursor DROP
   THEN
   BYE   
;


HERE IMAGE-BASE - 10000 + TO IMAGE-SIZE
' RUN MAINX !
TRUE TO ?GUI
S" fsaver.scr" SAVE BYE
