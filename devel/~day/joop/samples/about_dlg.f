\ Можно сделать получше, с отрисовкой картинки...

REQUIRE FrameWindow ~day\joop\win\framewindow.f
REQUIRE Button ~day\joop\win\control.f
REQUIRE Font ~day\joop\win\font.f

<< :setStrings
<< :b1Click

CLASS: AboutWindow <SUPER FrameWindow
        CELL VAR ver
        CELL VAR name
        Button OBJ b1
        Button OBJ frame
        Static OBJ stName
        Static OBJ stVer
        Static OBJ stCompany
        Static OBJ stURL

: :init
    own :init
    WS_DLGFRAME WS_CAPTION OR WS_SYSMENU OR vStyle !
;

: :b1Click 0 self :modalResult! ;

W: WM_CHAR wparam @ 13 = IF self :b1Click THEN ;

: :setStrings
    DROP ver !
    DROP name !
;

: :create
   own :create
   BS_GROUPBOX frame <style !
   S" Ok" 40 64 40 13 self b1 :install
   0 0 5 2 107 60 self frame :install
   ['] :b1Click b1 <OnClick !
   name @ 0 10 10 97 10 self stName :install
   ver @ 0 10 20 97 10 self stVer :install
   S" Dmitry Yakimov [c] 2000" 10 27 97 10 self stCompany :install
   S" Powered with sp-forth and jOOP, see http://www.forth.org.ru, bonus pack for Map Designer" 10 35 97 24 self stURL :install
;

;CLASS

\ Сначала имя приложения, затем версия
: ShowAbout ( c-addr1 u1 c-addr2-u2 hwnd)
   >R AboutWindow :new >R
   R@ :setStrings
   R> R> SWAP >R R@ :create
   140 100 120 92 R@ :move
   S" About..." R@ :setText
   R@ :showModal DROP
   R> :free
;
\ S" asd" S" asd" 0 ShowAbout