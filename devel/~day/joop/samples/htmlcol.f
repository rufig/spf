\ Подборка цветов для HTML
\ ПисАлось на время, а не на удобочитаемость или стиль :-)

REQUIRE FrameWindow ~day\joop\win\framewindow.f
REQUIRE Button ~day\joop\win\control.f
REQUIRE Font ~day\joop\win\font.f
REQUIRE CBString ~day\lib\clipboard.f
REQUIRE CASE lib\ext\case.f
REQUIRE ColorDialog ~day\joop\win\colordialog.f

~day\joop\samples\about_dlg.f

pvar: <brush
pvar: <label
pvar: <textpos

CLASS: ColorScrollBar <SUPER ScrollBar
        CELL VAR brush
        CELL VAR label
        CELL VAR textpos
;CLASS

<< :aboutClick
<< :copyClick
<< :checkClick
<< :selectClick

CLASS: AppWindow <SUPER FrameWindow

        ColorScrollBar OBJ sc1
        ColorScrollBar OBJ sc2
        ColorScrollBar OBJ sc3
        Static OBJ st1
        Static OBJ st2
        Static OBJ st3
        Static OBJ stBoard
        Button OBJ b1
        Button OBJ b2
        Button OBJ bSelect
        Button OBJ frame
        CheckBox OBJ chb1
        Font OBJ cFont
        ColorDialog OBJ ColDialog

: :init
    own :init
    WS_POPUP WS_SYSMENU OR WS_CAPTION  OR
    WS_MINIMIZEBOX OR vStyle !
    ;

: :createButtons
    S" Copy to clipboard" 70 127 50 15 self b1 :install
    S" About" 130 127 50 15 self b2 :install
    S" Choose" 10 127 50 15 self bSelect :install
    BS_GROUPBOX frame <style !
    0 0 5 2 187 120 self frame :install
    ['] :aboutClick b2 <OnClick !
    ['] :copyClick b1 <OnClick !
    ['] :selectClick bSelect <OnClick !
    S" string color" 115 112 50 8 self chb1 :install
    ['] :checkClick chb1 <OnClick !
;

: :aboutClick
   S" Html color generator" S" Version 1.0" self ShowAbout
;

: :copyClick
    sc1 :getPos 8 LSHIFT
    sc2 :getPos OR 8 LSHIFT
    sc3 :getPos OR
    HEX
    0 <# # # # # # # [CHAR] # HOLD #>
    StringToCB
;

: :changePos { obj }
     obj <textpos @ obj :getPos obj <textpos ! obj :setPos    
;
: :updateLabel { obj }
     HEX obj :getPos 0 <# # # [CHAR] # HOLD #> obj <label @ :setText
;

: :checkClick
      sc1 own :changePos sc1 own :updateLabel
      sc2 own :changePos sc2 own :updateLabel
      sc3 own :changePos sc3 own :updateLabel
;

: :createStatics
    S" #00" 15 112 20 8 self st1 :install
    S" #00" 40 112 20 8 self st2 :install
    S" #00" 65 112 20 8 self st3 :install
    st1 sc1 <label !
    st2 sc2 <label !
    st3 sc3 <label !
    SS_WHITEFRAME stBoard <style OR!
    0 0 90 10 95 100 self stBoard :install
;

: :create
  \ Здесь действия перед созданием окна ф-ей CreateWindowEx
    own :create
    255 0 0 rgb CreateSolidBrush sc1 <brush !
    0 255 0 rgb CreateSolidBrush sc2 <brush !
    0 0 255 rgb CreateSolidBrush sc3 <brush !
    self sc1 :create    10 10 20 100 sc1 :move    sc1 :show 
    self sc2 :create    35 10 20 100 sc2 :move    sc2 :show
    self sc3 :create    60 10 20 100 sc3 :move    sc3 :show
    0 255 sc1 :setRange
    0 255 sc2 :setRange
    0 255 sc3 :setRange
    own :createStatics
    own :createButtons
    S" Arial" DROP cFont <lpszFace !
    18 cFont <height !
    cFont :create
    handle @ ColDialog <hwndOwner !
;

: :drawSample ( dc)
   >R
   cFont <handle @ R@ SelectObject DROP
   TRANSPARENT R@ SetBkMode DROP
   S" And now you can" SWAP 80 42 R@ TextOutA DROP
   S" see the test string." SWAP 95 42 R@ TextOutA DROP
   S" This is just a test" SWAP 110 42 R@ TextOutA DROP
   R> stBoard <handle @ ReleaseDC DROP
;

: :updateBoard { \ rect[ /RECT ] }
   sc1 :getPos
   sc2 :getPos
   sc3 :getPos
   rgb CreateSolidBrush
   rect[ stBoard <handle @ GetClientRect DROP
   1 rect[ rect.left +!
   1 rect[ rect.top  +!
   -1 rect[ rect.right +!
   -1 rect[ rect.bottom +!
   stBoard <handle @ GetDC DUP >R
   rect[ SWAP FillRect DROP
   sc1 <textpos @
   sc2 <textpos @
   sc3 <textpos @ rgb R@ SetTextColor DROP
   R> own :drawSample
;

: :updateText
   sc1 :getPos
   sc2 :getPos
   sc3 :getPos
   rgb stBoard <handle @ GetDC DUP >R SetTextColor DROP
   R> own :drawSample
;

: :onPaint
    chb1 :checked IF own :checkClick  own :updateBoard
                     own :checkClick
                  ELSE
                     own :updateBoard
                  THEN
;

W: WM_CTLCOLORSCROLLBAR
   lparam @ HANDLE>OBJ <brush @
;

W: WM_VSCROLL { \ obj pos }
   HEX
   lparam @ HANDLE>OBJ -> obj
   obj <pos -> pos
   wparam @ LOWORD CASE
     SB_LINEUP     OF -3 ENDOF
     SB_LINEDOWN   OF  3 ENDOF
     SB_THUMBTRACK OF wparam @ HIWORD pos @ - ENDOF
     DROP 0 EXIT
   ENDCASE
   pos @ +  255 MIN 0 MAX
   DUP obj <pos !
   TRUE SWAP
   DUP 0 <# # # [CHAR] # HOLD #>
   obj <label @ :setText
   chb1 :checked IF own :updateText ELSE own :updateBoard THEN
   SB_CTL
   lparam @
   SetScrollPos DROP
   0
;

: :selectClick
     ColDialog :execute
     IF
       ColDialog :result >R
       R@ 255 AND sc1 :setPos
       R@ 8 RSHIFT 255 AND sc2 :setPos
       R> 16 RSHIFT 255 AND sc3 :setPos
       chb1 :checked IF own :updateText ELSE own :updateBoard THEN
     THEN
;

;CLASS


: RUN { \ w }
   STARTLOG
   AppWindow :new -> w
   0 w :create
   S" HTML color generator" w :setText
   100 50 200 160 w :move
   w :show
   w :run 
   w :free
   BYE
;

HERE IMAGE-BASE - 10000 + TO IMAGE-SIZE \ Вместо 10000 свое значение
' RUN MAINX !
TRUE TO ?GUI
S" htmlcol.exe" SAVE BYE
