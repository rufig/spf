\ SPLITTER 1.0
\ –азделитель между сетками
\ ё.∆иловец, 13.03.2005

REQUIRE create-control ~yz/lib/winctl.f

6 == splitter-size

control table splitter-t
  item -grid1	    \ перва€ сетка
  item -grid2	    \ втора€ сетка
  item -isvert	    \ вертикальный разделитель?
  item -ratio   set \ –азмер первой сетки в % от общего размера разделител€
  item -spcur       \ “екущее положение разделител€ (в точках)
  item -spmin	    \ крайнее левое значение (в точках)
  item -spmax	    \ крайнее правое значение (в точках)
  item -size2       \ минимальный размер второй сетки в направлении разделител€
  item -spdrag      \ флажок: режим перемещени€
endtable

: rect! ( x1 y1 x2 y2 rect -- )
  >R
  R@ 3 CELLS!  R@ 2 CELLS!
  R@ 1 CELLS!  R> !
;

\ ----------------------------
\ ќтрисовка 

WINAPI: CreatePen GDI32.DLL
WINAPI: MoveToEx  GDI32.DLL
WINAPI: LineTo    GDI32.DLL

: line ( x1 y1 x2 y2 syscolor -- )
  GetSysColor 1 W: ps_solid CreatePen
  windc SelectObject >R
  2>R SWAP 0 -ROT windc MoveToEx DROP
  R> R> windc LineTo DROP
  R> windc SelectObject DeleteObject DROP
;

PROC: draw-splitter { \ x y [ 4 CELLS ] rect }
  thiswin -xsize@ TO x  thiswin -ysize@ TO y
  thiswin -isvert@ IF
    thiswin -spcur@ TO x
    x 0  x splitter-size +  y  rect rect!
    W: color_3dface 1+ rect windc FillRect DROP 
    x 0 x y W: color_3dlight line
    x 1+ 0 x 1+ y W: color_3dhilight line
    x splitter-size + 1- 0 OVER y W: color_3ddkshadow line
    x splitter-size + 2- 0 OVER y W: color_3dshadow line
  ELSE
    thiswin -spcur@ TO y
    0 y x y splitter-size + rect rect!
    W: color_3dface 1+ rect windc FillRect DROP 
    0 y x y W: color_3dlight line
    0 y 1+ x OVER W: color_3dhilight line
    0 y splitter-size + 1- x OVER W: color_3ddkshadow line
    0 y splitter-size + 2- x OVER W: color_3dshadow line
  THEN
PROC;

\ -----------------------------
\ ѕересчет параметров

: remap-grids { sp \ x1 y1 x2 y2 w h -- }
  sp child-win-rect TO y2 TO x2 TO y1 TO x1
  sp -isvert@ IF
      y2 y1 - TO h
    x2 x1 - splitter-size - sp -spcur@ - TO w
    x1 y1  sp -spcur@  h  sp -grid1@ map-grid
    x1 sp -spcur@ + splitter-size +  y1  w h sp -grid2@ map-grid
  ELSE
    x2 x1 - TO w
    y2 y1 - splitter-size - sp -spcur@ - TO h
    x1 y1  w sp -spcur@  sp -grid1@ map-grid
    x1 y1 sp -spcur@ + splitter-size + w h sp -grid2@ map-grid
  THEN
;

: size-in-dimension ( sp -- size)
  DUP -isvert@ IF -xsize@ ELSE -ysize@ THEN
;

: recalc-splitter { pos sp -- }
  pos sp -spcur!
  pos 100 sp size-in-dimension */ -ratio sp store
  sp remap-grids
;
: new-splitter-pos ( pos sp -- )
  >R
  R@ -spmin@ MAX  R@ -spmax@ MIN
  R@ recalc-splitter
  R> -parent@ force-redraw
;

PROC: new-splitter-pos-in-percents ( pos sp -- )
  DUP >R size-in-dimension 100 */ R> new-splitter-pos
PROC;

: new-splitter-size { sp \ newsize -- }
  sp size-in-dimension TO newsize
  newsize splitter-size - sp -size2@ - sp -spmax!
  newsize splitter-size - sp -ratio@ 100 */ sp -spcur!
  sp remap-grids
;

\ -----------------------------
\ ќбработка сообщений

MESSAGES: splitter-messages

WINAPI: SetCursor      USER32.DLL
WINAPI: PtInRect       USER32.DLL
WINAPI: SetCapture     USER32.DLL
WINAPI: ReleaseCapture USER32.DLL

M: wm_mousemove
  { \ [ 4 CELLS ] rect x y }
  lparam LOWORD TO x  lparam HIWORD TO y
  thiswin -isvert@ IF
    thiswin -spcur@ 0 OVER splitter-size + 
    thiswin -ysize@ rect rect!
    y x rect PtInRect IF
      W: idc_sizewe 0 LoadCursorA SetCursor DROP
    THEN
    thiswin -spdrag@ IF
      x thiswin new-splitter-pos
    THEN
  ELSE
    0 thiswin -spcur@  thiswin -xsize@ OVER splitter-size + 
    rect rect!
    y x rect PtInRect IF
      W: idc_sizens 0 LoadCursorA SetCursor DROP
    THEN
    thiswin -spdrag@ IF
      y thiswin new-splitter-pos
    THEN
  THEN
  TRUE
M;

M: wm_lbuttondown
  thiswin -hwnd@ SetCapture DROP
  TRUE thiswin -spdrag!
  TRUE
M;

M: wm_lbuttonup
  ReleaseCapture DROP
  TRUE
M;

M: wm_capturechanged
  FALSE thiswin -spdrag!
  TRUE
M;

MESSAGES;

\ -----------------------------

PROC: calc-splitter-size { ctl \ w1 h1 w2 h2 w h -- }
  ctl -grid1@ grid-size TO h1 TO w1
  ctl -grid2@ grid-size TO h2 TO w2
  ctl -isvert@ IF 
    h1 h2 MAX TO h
    w1 ctl -spmin!
    w2 ctl -size2!
    w1 w2 + splitter-size + TO w
    w1 100 w splitter-size - */ -ratio ctl store
  ELSE
    w1 w2 MAX TO w
    h1 ctl -spmin!
    h2 ctl -size2!
    h1 h2 + splitter-size + TO h
    h1 100 h splitter-size - */ -ratio ctl store
  THEN 
  w h 2DUP ctl resize
PROC;

PROC: add-splitter-parts ( sp -- )
  DUP -grid1@ add-control
      -grid2@ add-control
PROC;

PROC: show-splitter { sp -- }
  sp -grid1@ show-grid
  sp -grid2@ show-grid
  (* swp_showwindow swp_nosize swp_nomove *) 0 0 0 0
  W: hwnd_bottom sp -hwnd@ SetWindowPos DROP
PROC;

PROC: hide-splitter { sp -- }
  sp -grid1@ hide-grid
  sp -grid2@ hide-grid
  sp winhide
PROC;

PROC: resize-splitter ( neww newh sp -- )
  DUP >R resize R> new-splitter-size
PROC;

PROC: move-splitter ( x y sp -- )
  DUP >R winmove R> remap-grids
PROC;

: splitter-control ( grid1 grid2 vert? -- ctl )
  splitter-t classname 0 create-control
  0= IF 2DROP DROP 0 EXIT THEN
  this -isvert! this -grid2!  this -grid1!
  draw-splitter this -painter!
  calc-splitter-size this -calcsize!
  show-splitter this -ctlshow!
  hide-splitter this -ctlhide!
  resize-splitter this -ctlresize!
  move-splitter this -ctlmove!
  splitter-messages this -wndproc!
  add-splitter-parts this -ctladdpart!
  new-splitter-pos-in-percents -ratio this storeset
  this
;

: splitter ( grid1 grid2 -- ctl )
  TRUE splitter-control
;

: hsplitter ( grid1 grid2 -- ctl )
  FALSE splitter-control
;

