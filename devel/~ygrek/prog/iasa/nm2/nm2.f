WARNING 0!
REQUIRE F.   lib/include/float2.f
REQUIRE [IF] lib/include/tools.f
REQUIRE WINDOWS... ~yz/lib/winlib.f
REQUIRE PAINTSTRUCT ~ygrek/lib/data/windows.f
REQUIRE ADD-CONST-VOC  ~day/wincons/wc.f
TRUE WARNING !

PRINT-EXP
FLONG

0 VALUE A1

0e FVALUE xn
0e FVALUE yn
0e FVALUE RK.yn
0.005e FVALUE Dstep
0.01e FVALUE step
0e FVALUE old.step
0e FVALUE A.yn
0e FVALUE yn0
1e-10 FVALUE epsilon

0e FVALUE err-norma
0e FVALUE old.err-norma
0e FVALUE RK.err-norma
0e FVALUE old.RK.err-norma
0e FVALUE old.yn
0e FVALUE old.RK.yn
0e FVALUE old.err
0e FVALUE old.RK.err

0 VALUE CurColor
CREATE FPU 200 ALLOT

0 VALUE win
0 VALUE maxX
0 VALUE maxY
0 VALUE hDC
0 VALUE memDC
PAINTSTRUCT::/SIZE ALLOCATE THROW VALUE ps

0e FVALUE ZoomX 0e FVALUE Cx
0e FVALUE ZoomY 0e FVALUE Cy
150 VALUE ShiftX 
650 VALUE ShiftY 
: x-scr Cx F- ZoomX F* F>DS ShiftX + ;
: y-scr Cy F- ShiftY ZoomY F* F>DS - ;

: Fvector CREATE F-SIZE @ * ALLOCATE THROW , DOES> @ SWAP F-SIZE @ * + ;
4 Fvector fn 
: fn@ fn F@ ; : fn! fn F! ;

( f'=-y*lny/x )
: func ( F: x y -- F: f ) FDUP FLN F* FSWAP F/ FNEGATE ;
\ f=exp(1/x)
: solution ( F: x -- f ) 1e FSWAP F/ FEXP ;

: half 2e F/ ;
: F1 xn yn func ;
: F2 xn step half F+
     F1 step half F* yn F+ func ;
: F3 xn step half F+ 
     F2 step half F* yn F+ func ;
: F4 xn step F+ 
     F3 step F* yn F+ func ;

: RungeKutta ( -- F: f )
 F1 
 F2 2.E F* F+
 F3 2.E F* F+ 
 F4 F+
 step F* 
 6.E F/
 yn F+
;

: fncalc
  4 0 DO
   RungeKutta FTO yn  
   xn step F+ FTO xn
   xn yn func I fn! 
  LOOP
;

: fnrecalc
 1 fn@ ( FDUP F. SPACE ) 0 fn!
 2 fn@ ( FDUP F. SPACE ) 1 fn!
 3 fn@ ( FDUP F. SPACE ) 2 fn!
 xn yn func ( FDUP F. SPACE ) 3 fn!
\ CR
;
: Adams
   0 fn@  -9.E F*
   1 fn@  37.E F* F+
   2 fn@ -59.E F* F+
   3 fn@  55.E F* F+ 
   step F* 24.E F/
;

: AdamsMoulton
   0 fn@   1.E F*
   1 fn@  -5.E F* F+
   2 fn@ 19.E F* F+
   3 fn@  9.E F* F+ 
   step F* 24.E F/
;

: iterate 
  yn FTO yn0   
  3 fn@ step F* yn0 F+ FTO A.yn
  fnrecalc

  xn step F+ FTO xn
  BEGIN
   A.yn FTO yn
   xn yn func 3 fn! 
   AdamsMoulton yn0 F+ FTO A.yn
   A.yn yn F- FABS epsilon F<
  UNTIL
  A.yn 
  xn step F- FTO xn
;

: run 
 [ A1 ] [IF]  
  Adams yn F+ FTO yn
 [ELSE] 
 iterate FTO yn 
 [THEN]
  yn FPU FSAVE
    RK.yn FTO yn 
    RungeKutta FTO RK.yn
  FPU FRSTOR  FTO yn

  xn step F+ FTO xn 
 [ A1 ] [IF] 
  fnrecalc 
 [THEN]
;

PROC: paint
   W: srccopy 0 0 memDC maxY maxX 0 0 windc BitBlt DROP \ из памяти на экран
PROC;


: CreateMyWindow
 0 create-window TO win
  win TO winmain
  " Численные методы Лаба 2. yGREK heretix  КА-21 ИПСА" win -text!
  paint win -painter!
  win winmaximize
  win winshow
;

: CreateMemDC 
   \ образ экрана в памяти и будем все операции рисования делать
   \ только в memDC
   W: sm_cxscreen GetSystemMetrics TO maxX
   W: sm_cyscreen GetSystemMetrics TO maxY
   winmain -hwnd@ GetDC TO hDC
   hDC CreateCompatibleDC TO memDC
   maxY maxX hDC CreateCompatibleBitmap ( hbit ) memDC SelectObject DROP
   W: white_brush GetStockObject ( hbr  ) memDC SelectObject DROP
   W: patcopy maxY maxX 0 0 memDC PatBlt DROP
   hDC winmain -hwnd@ ReleaseDC DROP
;

: RGB2CR ( r g b -- u ) ( Convert RGB to COLORREF )
 0xFF AND 16 LSHIFT -ROT
 0xFF AND  8 LSHIFT -ROT
 0xFF AND  OR OR
;
: SetColor ( r g b ) RGB2CR TO CurColor ;

: LineT ( F: x y )
 CurColor
 0 PS_SOLID CreatePen memDC SelectObject DROP
   y-scr x-scr memDC LineTo DROP
 winmain force-redraw
;

: Line ( F: x1 y1 x2 y2 )
 CurColor
 0 PS_SOLID CreatePen memDC SelectObject DROP
 0 y-scr x-scr memDC MoveToEx DROP
   y-scr x-scr memDC LineTo DROP
;
 
: err-count
  xn solution yn F- FABS FDUP F* err-norma F+ FTO err-norma

  xn solution RK.yn F- FABS FDUP F* RK.err-norma F+ FTO RK.err-norma
; 

: output 
\   ." FDEPTH : " FDEPTH .
\   xn F. 3 SPACES
 \  ." FDEPTH : " FDEPTH .
   xn solution FDUP F. SPACE
                 \  yn F. SPACE
              FDUP yn F- FABS F. SPACE 
                  \ RK.yn F. SPACE
                   RK.yn F- FABS F.  CR
;


: graph 
  0xFF 0x00 0x00 SetColor
  xn step F- 
   FDUP solution 
  xn
  xn solution 
  Line
  0x00 0x00 0xFF SetColor
 xn step F- old.RK.yn xn RK.yn Line
  0x00 0xFF 0x00 SetColor
 xn step F- old.yn xn yn Line

(  0x00 0xFF 0x00 SetColor
  xn 0e xn xn solution Line
  0e xn solution xn xn solution Line)
;

: error xn solution F- FABS ;

: graph2
  0x00 0x00 0xFF SetColor
 xn step F- old.RK.err xn RK.yn error Line
  0x00 0xFF 0x00 SetColor
 xn step F-    old.err xn    yn error Line
\ CR xn x-scr . yn error y-scr . CR 
(  0x00 0xFF 0x00 SetColor
  xn 0e xn xn solution Line
  0e xn solution xn xn solution Line)
;


: ^4 FDUP F* FDUP F* ;
: _4 FDUP FSQRT FDUP FSQRT ;

: err-graph
  0xFF 0x00 0x00 SetColor
  old.step old.err-norma step err-norma Line

  err-norma >FNUM SWAP err-norma y-scr 0e x-scr 120 - memDC TextOutA  DROP

  PRINT-FIX  5 FFORM !
       step >FNUM SWAP 0e y-scr 5 + step x-scr memDC TextOutA DROP
  PRINT-EXP  9 FFORM !

  0x00 0x00 0xFF SetColor
  old.step  old.RK.err-norma step RK.err-norma Line

  0x00 0xFF 0x00 SetColor
  step 0e step err-norma Line
  0e err-norma step err-norma Line
;


: init 
 1e FTO xn  
 1e FEXP FTO yn 
 yn FTO RK.yn
;


: main1
 WINDOWS...
 CreateMyWindow
 CreateMemDC

 5e2 FTO ZoomX
 5e2 FTO ZoomY
 1e FTO Cx 1.5e FTO Cy

 0x00 0x00 0x00 SetColor
 Cx Cy Cx 10e F+ Cy Line
 Cx Cy Cx Cy 10e F+ Line 
 init
 fncalc
 yn FTO RK.yn
 1.E step F/ F>DS 0 DO
  yn FTO old.yn  RK.yn FTO old.RK.yn
  run output graph 
 LOOP
 ...WINDOWS
;

: main2
 WINDOWS...
 CreateMyWindow
 CreateMemDC

 0.8e3 FTO ZoomX
 2e10 FTO ZoomY
 1e FTO Cx 0e FTO Cy

 0x00 0x00 0x00 SetColor
 Cx Cy Cx 1e F+ Cy Line
 Cx Cy Cx Cy 1e-7 F+ Line 
 init fncalc yn FTO RK.yn
 run yn error FTO old.err RK.yn error FTO old.RK.err
 1.E step F/ F>DS 0 DO
  run output graph2 
  yn error FTO old.err RK.yn error FTO old.RK.err
 LOOP
 ...WINDOWS
;


: main3
 WINDOWS...
 CreateMyWindow
 CreateMemDC

 1.5e4 FTO ZoomX
 2e7 FTO ZoomY

 0x00 0x00 0x00 SetColor
 0e 0e 1e ZoomX F/ 1000e F* 0e Line
 0e 0e 0e 1e ZoomY F/ 1000e F* Line 
 step FTO old.step
 10 0 DO
  init
  0e FTO err-norma
  0e FTO RK.err-norma

  fncalc
  yn FTO RK.yn
  1e step F/ F>DS 0 DO run err-count LOOP
  err-norma FSQRT FTO err-norma
  RK.err-norma FSQRT FTO RK.err-norma

  ." step " step F. ."  --  Adams : " err-norma F. ."   RK : " RK.err-norma F. CR
 
  err-graph

  RK.err-norma FTO old.RK.err-norma
  err-norma FTO old.err-norma
  step FTO old.step

  step Dstep F+ FTO step

 winmain force-redraw
 LOOP

 ...WINDOWS
;
 main3
 BYE
