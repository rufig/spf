\ Last changes 01/05/2005

\ Классы для GL окна
\ Самые полезные - GLPlot2D и GLGraph2D для рисования графиков
\ см. пример использования в ~ygrek/iasa/matmod1 matmod2
\ (c) 2005 yGREK heretix   mailto: heretix@yandex.ru
\ Started 02/2005

\ 01.May.2005  ~ygrek
\ Добавил :resize в фигуры - удобно. Теперь -1e s :resize переворачивает фигуру

\ TODO: Ортопроекцию для графиков и избавиться от хаков 
\ в подборе параметров для сцены чтобы увидеть график

REQUIRE CLASS:         ~day/joop/oop.f
REQUIRE glBegin        ~ygrek/lib/data/opengl.f  
REQUIRE F.             lib/include/float2.f
\ REQUIRE CODE           lib/ext/spf-asm.f
REQUIRE List           ~day/joop/lib/list.f
REQUIRE ADD-CONST-VOC  ~day/wincons/wc.f
S" ~ygrek/lib/data/opengl.const" ADD-CONST-VOC

HERE

\ ~yz
: float [                 
  0x8D C, 0x6D C, 0xFC C, 
  0xD9 C, 0x5D C, 0x00 C, 
  0x87 C, 0x45 C, 0x00 C, 
  0xC3 C, ] ;             
: double FLOAT>DATA SWAP ;
( CODE float                                         
       LEA  EBP, -4 [EBP]
       FSTP  DWORD [EBP] 
       XCHG  EAX, [EBP]  
       RET               
END-CODE)

\ ==============================================
<< :set  ( F: x y z -- )
<< :get  ( -- F: x y z )
<< :getf ( -- D: z y x )
<< :getr ( -- F: z y x )
<< :print \ Point(x,y,z,)
<< :x  << :x! 
<< :y  << :y! 
<< :z  << :z! 
<< :vertex
<< :resize

: Vertex3f ( F: x y z -- )
   float float float glVertex3f DROP 
;

CLASS: Point <SUPER Object
\ класс 3D точка
\ координаты вещественные 8 байт FDOUBLE
    4 VAR x1  4 VAR x2   \ x
    4 VAR y1  4 VAR y2   \ y 
    4 VAR z1  4 VAR z2   \ z

: :init
  own :init
  0e x1 DF!
  0e y1 DF! 
  0e z1 DF! 
  ( ." Point init. ")
;

: :set   z1 DF!   y1 DF!   x1 DF! ;
: :get   x1 DF@   y1 DF@   z1 DF@ ;
: :getf  z1 DF@ float   y1 DF@ float   x1 DF@ float ;
: :getr  z1 DF@   y1 DF@   x1 DF@ ;
: :x x1 DF@ ; : :x! x1 DF! ;
: :y y1 DF@ ; : :y! y1 DF! ;
: :z z1 DF@ ; : :z! z1 DF! ;
: :print  ." Point(" x1 DF@ F. ." ," y1 DF@ F. ." ," z1 DF@ F. ." )" ;
: :print  own :getr ." Point(" F. ." ," F. ." ," F. ." )" ;
: :vertex own :getf glVertex3f DROP ; 
: :free ( ." Point free. ") own :free ;

: :resize ( F: factor -- )
   FDUP own :x F*  own :x!
   FDUP own :y F*  own :y!
        own :z F*  own :z!
;

   
;CLASS

<< :draw
<< :rotate
pvar: <shift
pvar: <angle.speed
pvar: <angle
\ ==============================================
CLASS: GLObject <SUPER Object

     Point OBJ angle
     Point OBJ angle.speed
     Point OBJ shift

: :draw
   glLoadIdentity DROP  \ Reset The Current Modelview Matrix

   shift :getf glTranslatef DROP \ Сдвиг

   1E float 0E float 0E float  \ вектор-ось вращения
   angle :x float glRotatef DROP  \ Поворот

   0E float 1E float 0E float  
   angle :y float glRotatef DROP 

   0E float 0E float 1E float 
   angle :z float glRotatef DROP 
;

: :init
  own :init
  0e 0e -5e shift :set
  \ angle сам обнулится
  0e 2e 0e angle.speed :set
  ( ." Object init. ")
;

: :rotate
   \ ." Rotate "
   angle :x angle.speed :x F+ angle :x!
   angle :y angle.speed :y F+ angle :y!
   angle :z angle.speed :z F+ angle :z!
;


: :free ( ." Object free. ") own :free ;
;CLASS

: SetColor ( F: r g b ) float float float ( b g r ) glColor3f DROP ;
: Red    1e 0e 0e ;
: Green  0e 1e 0e ;
: Blue   0e 0e 1e ;
: Yellow 1e 1e 0e ;
: Magenta 1e 0e 1e ;
: Orange 1e 0.5e 0e ;
: White  1e 1e 1e ;
: Black  0e 0e 0e ;

<< :draw
\ ==============================================
CLASS: GLPyramid <SUPER GLObject
   Point OBJ top
   Point OBJ a1
   Point OBJ a2
   Point OBJ a3 
   Point OBJ a4

: :draw
  own :draw
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

: :init
  own :init
  +0E +1E +0E  top :set
  +1E -1E -1E   a1 :set
  +1E -1E +1E   a2 :set
  -1E -1E +1E   a3 :set
  -1E -1E -1E   a4 :set
  ( ." GLPyramid init. ")
;

: :resize ( F: factor -- )
   FDUP top :resize
   FDUP a1 :resize
   FDUP a2 :resize
   FDUP a3 :resize
        a4 :resize
;

;CLASS


<< :draw
<< :resize
\ ==============================================
CLASS: GLCube <SUPER GLObject
   Point OBJ a1  Point OBJ b1
   Point OBJ a2  Point OBJ b2
   Point OBJ a3  Point OBJ b3
   Point OBJ a4  Point OBJ b4
  
: :draw
  own :draw
  GL_QUADS glBegin DROP \ Drawing Using Squares
     Red SetColor   a1 :vertex   a2 :vertex   a3 :vertex   a4 :vertex
  Yellow SetColor   a1 :vertex   a2 :vertex   b2 :vertex   b1 :vertex
    Blue SetColor   a2 :vertex   a3 :vertex   b3 :vertex   b2 :vertex
   Green SetColor   a3 :vertex   a4 :vertex   b4 :vertex   b3 :vertex
  Orange SetColor   a4 :vertex   a1 :vertex   b1 :vertex   b4 :vertex
  Magenta SetColor   b1 :vertex   b2 :vertex   b3 :vertex   b4 :vertex
   glEnd  DROP   \ Finished Drawing 
;


: :init
  own :init
  +1E -1E -1E   a1 :set      +1E +1E -1E   b1 :set
  +1E -1E +1E   a2 :set      +1E +1E +1E   b2 :set
  -1E -1E +1E   a3 :set      -1E +1E +1E   b3 :set
  -1E -1E -1E   a4 :set      -1E +1E -1E   b4 :set
  ( ." GLCube init. ")
;

: :resize ( F: factor -- )
   FDUP a1 :resize
   FDUP a2 :resize
   FDUP a3 :resize
   FDUP a4 :resize
   FDUP b1 :resize
   FDUP b2 :resize
   FDUP b3 :resize
        b4 :resize
;

;CLASS

\ ==============================================
: (x,y) ( addr -- addr+16   F: x y )
  DUP DF@ 8 + DUP DF@ 8 +
;
: (x,y)! ( addr F: x y -- addr+16 )
  FSWAP DUP DF! 8 + DUP DF! 8 +
;

<< :findScale \ вычислить границы графика
<< :getScale ( -- min.x max.x min.y max.y ) 
<< :setScale ( min.x max.x min.y max.y -- ) \ вручную установить масштаб
<< :makeScale ( -- ) \ применить масштаб
<< :data! ( ndata data -- ) \ данныые графика
<< :points! ( ndata -- ) \ кол-во точек для записи, выделить память
<< :point! ( x y -- ) \ добавить очередную точку к графику
<< :draw \ нарисовать

pvar: <color
CLASS: Graph2D <SUPER Object
  CELL VAR data  \ адрес памяти с парами точек x,y
  CELL VAR ndata \ кол-во точек
  CELL VAR cur   \ текущий адрес в таблице точек
 Point OBJ min
 Point OBJ max
 Point OBJ color

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

: :setScale ( min.x max.x min.y max.y -- )
  max :y! min :y! max :x! min :x!
;

: :getScale ( min.x max.x min.y max.y -- )
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
<< :draw  \ отрисовка графиков
<< :add ( obj -- ) \ добавить график на чертёж
<< :autoScale \ подобрать масштаб так чтобы все текущие графики были видны
<< :scaleLast \ применить текущий масштаб к последнему графику
<< :getScale ( -- min.x max.x min.y max.y ) 
<< :setScale ( min.x max.x min.y max.y -- ) \ вручную установить масштаб
<< :maxScale ( min.x max.x min.y max.y -- ) \ впихнуть и эти размеры в окно

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
