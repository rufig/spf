REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS ~ygrek/lib/data/opengl.f

: status
  ( CR
  ." f=" FDEPTH .
  ." d=" DEPTH  . 
  DEPTH 10 MIN .SN )
  GetLastError ?DUP IF CR ." Error " . THEN
  glGetError ?DUP IF CR ." GL error " . THEN
;

NEEDS ~day/hype3/locals.f
NEEDS ~ygrek/lib/list/write.f
NEEDS ~pinka/lib/lambda.f
NEEDS ~ygrek/lib/hype/timer.f
NEEDS ~ygrek/lib/hype/point.f
NEEDS  lib/ext/const.f
S" ~ygrek/lib/data/opengl.const" ADD-CONST-VOC

: float ( F: f -- D: f )
[ 0x8D C, 0x6D C, 0xFC C,
  0xD9 C, 0x5D C, 0x00 C,
  0x87 C, 0x45 C, 0x00 C,
  0xC3 C, ] ;

: double ( F: f -- D: f1 f2 ) FLOAT>DATA SWAP ;

\ -----------------------------------------------------------------------

CPoint4f SUBCLASS CGLPoint

: :getf ( -- D: z y x ) SUPER :z@ float  SUPER :y@ float  SUPER :x@ float ;

: :vertex SUPER :getv glVertex3fv DROP ;
: :normal SUPER :getv glNormal3fv DROP ;

;CLASS

NEEDS ~ygrek/lib/wfl/opengl/Model.f

\ -----------------------------------------------------------------------

\ всё что рисуется в GL окне - наследуется от этого класса
CLASS CGLObject

     CGLPoint OBJ angle
     CGLPoint OBJ angle.speed
     CGLPoint OBJ shift
     CGLPoint OBJ scale
     CELL PROPERTY <visible

: :print
  CR ." CGLObject :print"
  CR ." angle : " angle :print
  CR ." angle.speed : " angle.speed :print
  CR ." shift : " shift :print
  CR ." scale : " scale :print
  CR ." <visible : " <visible @ .
;

: :draw
   <visible@ 0= IF 0e float 0e float 0e float glScalef DROP EXIT THEN

   shift :getf glTranslatef DROP \ Сдвиг
   scale :getf glScalef DROP \ сжатие-растяжение

   1e float 0e float 0e float  \ вектор-ось вращения
   angle :x@ float glRotatef DROP  \ Поворот

   0e float 1e float 0e float
   angle :y@ float glRotatef DROP

   0e float 0e float 1e float
   angle :z@ float glRotatef DROP
;

: :prepare ;

init: 1e 1e 1e scale :set TRUE <visible! ;
dispose: ;

: :setAngle ( F: x y z -- ) angle :set ;
: :getAngle ( -- F: x y z ) angle :get ;
: :setAngleSpeed ( F: x y z -- ) angle.speed :set ;
: :getAngleSpeed ( -- F: x y z ) angle.speed :get ;
: :setShift ( F: x y z -- ) shift :set ;
: :getShift ( -- F: x y z ) shift :get ;
: :setScale ( F: x y z -- ) scale :set ;
: :getScale ( -- F: x y z ) scale :get ;
: :resize ( F: f -- ) FDUP FDUP :setScale ;

: :rotate
   \ ." Rotate "
   angle :x@ angle.speed :x@ F+ angle :x!
   angle :y@ angle.speed :y@ F+ angle :y!
   angle :z@ angle.speed :z@ F+ angle :z!
;

;CLASS

\ -----------------------------------------------------------------------

\ класс - список обьектов как один обьект для отрисовки
CGLObject SUBCLASS CGLObjectList

VAR _list

init: () _list ! ;
dispose:
    LAMBDA{ => dispose } _list @ mapcar \ удалим все обьекты в списке
    _list @ FREE-LIST \ удалим сам список
;

: :add ( obj -- ) vnode _list @ cons _list ! ;

: :draw ( -- )
   SUPER :draw
   LAMBDA{
     glPushMatrix DROP
       => :draw
     glPopMatrix DROP
   }
   _list @ mapcar ;

: :rotate ( -- ) SUPER :rotate LAMBDA{ => :rotate } _list @ mapcar ;

: :prepare SUPER :prepare LAMBDA{ => :prepare } _list @ mapcar ;

;CLASS

\ -----------------------------------------------------------------------

: SetColor ( F: r g b -- ) float float float ( b g r ) glColor3f DROP ;
: Red    1e 0e 0e ;
: Green  0e 1e 0e ;
: Blue   0e 0e 1e ;
: Yellow 1e 1e 0e ;
: Magenta 1e 0e 1e ;
: Orange 1e 0.5e 0e ;
: White  1e 1e 1e ;
: Black  0e 0e 0e ;

\ -----------------------------------------------------------------------

\ Пирамида
CGLObject SUBCLASS CGLPyramid

   CGLPoint OBJ top
   CGLPoint OBJ a1
   CGLPoint OBJ a2
   CGLPoint OBJ a3
   CGLPoint OBJ a4

: :draw

  SUPER :draw

  GL_TRIANGLES glBegin DROP \ Drawing Using Triangles
         Red SetColor
           top :vertex   a1 :vertex   a2 :vertex
         Yellow SetColor
           top :vertex   a2 :vertex   a3 :vertex
         Blue SetColor
           top :vertex   a3 :vertex   a4 :vertex
         Green SetColor
           top :vertex   a4 :vertex   a1 :vertex
   glEnd  DROP   \ Finished Drawing
;

init:
  +0E +1E +0E  top :set
  +1E -1E -1E   a1 :set
  +1E -1E +1E   a2 :set
  -1E -1E +1E   a3 :set
  -1E -1E -1E   a4 :set
  ( ." GLPyramid init. ")
;

;CLASS

\ -----------------------------------------------------------------------

\ Кубик разноцветный
CGLObject SUBCLASS CGLCube

   CGLPoint OBJ a1  CGLPoint OBJ b1
   CGLPoint OBJ a2  CGLPoint OBJ b2
   CGLPoint OBJ a3  CGLPoint OBJ b3
   CGLPoint OBJ a4  CGLPoint OBJ b4

: :draw
  SUPER :draw
  GL_QUADS glBegin DROP \ Drawing Using Squares
     Red SetColor   a1 :vertex   a2 :vertex   a3 :vertex   a4 :vertex
  Yellow SetColor   a1 :vertex   a2 :vertex   b2 :vertex   b1 :vertex
    Blue SetColor   a2 :vertex   a3 :vertex   b3 :vertex   b2 :vertex
   Green SetColor   a3 :vertex   a4 :vertex   b4 :vertex   b3 :vertex
  Orange SetColor   a4 :vertex   a1 :vertex   b1 :vertex   b4 :vertex
  Magenta SetColor   b1 :vertex   b2 :vertex   b3 :vertex   b4 :vertex
   glEnd  DROP   \ Finished Drawing
;


init:
  +1E -1E -1E   a1 :set      +1E +1E -1E   b1 :set
  +1E -1E +1E   a2 :set      +1E +1E +1E   b2 :set
  -1E -1E +1E   a3 :set      -1E +1E +1E   b3 :set
  -1E -1E -1E   a4 :set      -1E +1E -1E   b4 :set
  ( ." GLCube init. ")
;

;CLASS

\ -----------------------------------------------------------------------

CGLObject SUBCLASS CGLSimpleModel

 CSimpleModel OBJ model
 CGLPoint OBJ color
 CTimer OBJ timer
 VAR _list

: :setColor color :set ;
: :model model this ;

init: 0.5e 0.5e 0.5e :setColor ;
dispose: timer :ms@ CR ." Time in " SUPER name TYPE ."  = " . ;

: :draw-model { | t }
   GL_TRIANGLES glBegin DROP

   model :faces 0 ?DO

    I model :tnth TO t
    t :: CTri.n1@ model :nnth :: CGLPoint.:normal
    t :: CTri.v1@ model :vnth :: CGLPoint.:vertex

    t :: CTri.n2@ model :nnth :: CGLPoint.:normal
    t :: CTri.v2@ model :vnth :: CGLPoint.:vertex

    t :: CTri.n3@ model :nnth :: CGLPoint.:normal
    t :: CTri.v3@ model :vnth :: CGLPoint.:vertex
   LOOP

   glEnd DROP
;

: :draw
   SUPER :draw
   color :get SetColor
   timer :start
   _list @ glCallList DROP
   timer :stop
;

: :xmax model :xmax ;
: :ymax model :ymax ;
: :zmax model :zmax ;

: :prepare
   1 glGenLists _list !
   status
   GL_COMPILE _list @ glNewList DROP
    :draw-model
   glEndList DROP ;

;CLASS

\ -----------------------------------------------------------------------
\EOF
: (x,y) ( addr -- addr+16   F: x y )
  DUP DF@ 8 + DUP DF@ 8 +
;
: (x,y)! ( addr F: x y -- addr+16 )
  FSWAP DUP DF! 8 + DUP DF! 8 +
;

: Vertex3f ( F: x y z -- ) float float float glVertex3f DROP ;

CLASS CPlot2D
  CELL VAR data  \ адрес памяти с парами точек x,y
  CELL VAR ndata \ кол-во точек
  CELL VAR cur   \ текущий адрес в таблице точек
 CGLPoint OBJ min
 CGLPoint OBJ max
 CGLPoint OBJ color

: :data! DUP cur ! data ! ndata ! ;
: :points! DUP 2 * 8 * ALLOCATE THROW own :data! ;
: :point!
     FSWAP cur @ DF!  cur @ 8 + cur !
           cur @ DF!  cur @ 8 + cur !
;

: :init
  White color :set
  0 0 own :data!
;

: :free
   data @ FREE THROW
   own :free
;

\ вычислить границы графика
: :findScale
  \ Начальные значения
  data @
   (x,y) FDUP max :y! min :y!
         FDUP max :x! min :x!
  \ ищем границы графика
  ndata @ 1- 0 DO
   (x,y) FDUP
     max :y FSWAP F< IF FDUP max :y! THEN
     FDUP min :y F< IF min :y! ELSE FDROP THEN
    FDUP
     max :x FSWAP F< IF FDUP max :x! THEN
     FDUP min :x F< IF min :x! ELSE FDROP THEN
  LOOP
  DROP
 \ min :print SPACE max :print CR
;

: :makeScale
  min :x max :x F- FABS 1e-5 F<
   IF min :x 1e-5 F+ max :x!   min :x 1e-5 F- max :x!  THEN
  min :y max :y F- FABS 1e-5 F<
   IF min :y 1e-5 F+ max :y!   min :y 1e-5 F- max :y!  THEN

 data @
  ndata @ 0 DO   \ масштабируем
   DUP (x,y) DROP
   min :y F-
   max :y min :y F- F/
   FSWAP
   min :x F-
   max :x min :x F- F/
   FSWAP
   (x,y)!
  LOOP
;

\ вручную установить масштаб
: :setScale ( min.x max.x min.y max.y -- )
  max :y! min :y! max :x! min :x!
;

: :getScale ( -- min.x max.x min.y max.y )
  min :x max :x min :y max :y
;

: :draw
\  own :draw
   ndata @ 0= IF EXIT THEN

  GL_LINE_STRIP glBegin DROP
   color :get SetColor
   data @
    ndata @ 0 DO (x,y) 0e Vertex3f LOOP
   DROP
  glEnd DROP
;

;CLASS

\ : each.show <data @ :show 0 ;

\ ==============================================

pvar: <min
pvar: <max
CLASS: GLPlot2D <SUPER GLObject
     Point OBJ max
     Point OBJ min    \ размеры окна
      List OBJ graphs \ графики
  Iterator OBJ iter

: :init
  own :init

  -0.7e -0.5e -1.5e shift :set \ для полноэкранного GL окна
  0e 0e 0e angle.speed :set

  graphs iter :set
  ( ." GLPlot init. ")
;

: :draw
  own :draw

  \ Координатные орты
  GL_LINE_STRIP glBegin DROP \ Drawing Using Lines
    Green SetColor
    -0.05e -0.05e 0e Vertex3f
     1.05e -0.05e 0e Vertex3f
     1.05e  1.05e 0e Vertex3f
    -0.05e  1.05e 0e Vertex3f
    -0.05e -0.05e 0e Vertex3f
   glEnd DROP

   iter :first
   BEGIN
    iter :next IF <data @ :draw 0 ELSE -1 THEN
   UNTIL
;

: :setScale  max :y! min :y! max :x! min :x! ;
: :getScale  min :x max :x min :y max :y ;
: :scaleLast own :getScale graphs <last @ <data @ DUP :setScale :makeScale ;

: :add graphs :addObject ;

: :maxScale ( min.x max.x min.y max.y -- )
  FDUP max :y F< IF FDROP ELSE max :y! THEN
  FDUP min :y F< IF min :y! ELSE FDROP THEN
  FDUP max :x F< IF FDROP ELSE max :x! THEN
  FDUP min :x F< IF min :x! ELSE FDROP THEN
;

: :autoScale
  iter :first
  BEGIN
    iter :next IF <data @ DUP :findScale :getScale own :maxScale 0
             ELSE -1 THEN
  UNTIL
  iter :first
  BEGIN
    iter :next IF own :getScale <data @ DUP :setScale :makeScale 0
             ELSE -1 THEN
  UNTIL
;

( : :free
  \ iter :free
  \ graphs :free
  own :free
; )

;CLASS
HERE SWAP - .( Size of GLObject class is ) . .( bytes) CR
