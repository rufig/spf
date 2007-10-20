( The very simple example )

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS ~day\wfl\wfl.f
NEEDS ~day\wfl\controls\splitter.f

( Панель с выводом процентов ширины )

CPanel SUBCLASS CPercentPanel

: drawPercent ( dc )
    || R: dc CRect r ||
    SUPER getClientRect r !

    DT_VCENTER DT_CENTER OR DT_SINGLELINE OR
    r addr
    SUPER getPercent 100 / S>D <# [CHAR] % HOLD #S #> SWAP
    dc @
    DrawTextA SUPER -wthrow
;

W: WM_PAINT
    || CPaintDC dc ||
    SUPER hWnd @ dc create
    DUP TRANSPARENT SWAP SetBkMode SUPER -wthrow
    drawPercent
    0
;

;CLASS

CFrameWindow SUBCLASS CVerySimpleWindow

       CSplitterController OBJ hsplitter
       CSplitterController OBJ vsplitter
       CPercentPanel       OBJ leftPane
       CPercentPanel       OBJ rightPane

W: WM_CREATE
   hsplitter setHorizontal

   \ Мы не назначаем стиль WS_EX_CLIENTEDGE панелям, как в complexsplitter
    \ примере, значит мы должны отрисовать сплиттер сами
   TRUE hsplitter drawSplitter? !
   TRUE vsplitter drawSplitter? !

   \ увеличим немного ширину
   6 hsplitter splitWidth !
   6 vsplitter splitWidth !

   \ простое создание панелей
    \ контроллер сам создаст и удалит панели

   SELF hsplitter createPanels
   SELF hsplitter createSplitter

   \ более сложное
    \ мы отвечаем за создание и удаление объектов панелей
     \ контроллер отвечает со инициализацию панелей (создание win окон)
   
   hsplitter getUpperPane ( родитель )
   leftPane this OVER vsplitter setLeftPane
   rightPane this OVER vsplitter setRightPane

   vsplitter createSplitter
   0
;

W: WM_DESTROY ( -- n )
   0 PostQuitMessage DROP
   0
;

;CLASS

: winTest ( -- n )
  || CVerySimpleWindow wnd CMessageLoop loop ||

  0 0 wnd create DROP
  SW_SHOW wnd showWindow

  loop run
;

winTest