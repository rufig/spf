\ Система дифуров первого порядка
\ Математическое моделирование
\ (c) yGREK Heretix mailto:heretix@yandex.ru
\ 08.Mar.2005

REQUIRE runRK         ~ygrek/lib/difur.f
REQUIRE GLWindow      ~ygrek/lib/joopengl/GLWindow.f

model5.f
ALSO Model5

profiles.f

' init TO difur-init
' solution TO difur-solution

: runRK
  xn FTO fn ['] func_x TO difur-func RungeKutta
  yn FTO fn ['] func_y TO difur-func RungeKutta 
   FDUP 0e F< IF FDROP 0e THEN FTO yn \ ограничения по нулям не забыли
   FDUP 0e F< IF FDROP 0e THEN FTO xn \ чтобы для yn использовать старые xn

  tn step F+ FTO tn
;
PREVIOUS


: RUN { \ w s1 s d }
   GLWindow :new -> w
   0 w :create
   S" Мат моделирование - Модель Фергюльста" w :setText
   w :maximize

   GLPlot2D :new -> s
   s w :add

 difur-init
 10 0 DO
  10 0 DO
   Graph2D :new -> s1   
   [ ALSO Model5 ]
   difur-init 
   xn 0.1e I DS>F F* F+ FTO xn
   yn 0.1e J DS>F F* F+ FTO yn
  [ PREVIOUS ]
   #steps 2 * 8 * ALLOCATE THROW -> d
   #steps d s1 :data!
   #steps 0 DO
     runRK \ output CR
     Model5::xn d DF!   d 8 + -> d 
     Model5::yn d DF!   d 8 + -> d  
   LOOP
   s1 s :add
  LOOP
 LOOP
   0e 1e 0e 1e s :setScale
   s :scaleLast

   Graph2D :new -> s1   
   2 2 * 8 * ALLOCATE THROW -> d
   2 d s1 :data!
   2 0 DO
      I DS>F 1e F* d DF!   d 8 + -> d
      Model5::b Model5::n F/ I DS>F 1e F* F* Model5::s Model5::n F/ F+
      d DF!   d 8 + -> d
   LOOP
   Yellow s1 <color @ :set
   s1 s :add
   s :scaleLast

   Graph2D :new -> s1   
   2 2 * 8 * ALLOCATE THROW -> d
   2 d s1 :data!
   2 0 DO
      I DS>F 1e F* d DF!   d 8 + -> d
      Model5::m Model5::a F/ I DS>F 1e F* F* Model5::r Model5::a F/ F-
      d DF!   d 8 + -> d
   LOOP
   Magenta s1 <color @ :set
   s1 s :add
   s :scaleLast

   w :show
   w :run 
   w :free
;


r>0s>0ab<mn  RUN
r<0s<0ab=mn  RUN
r<0s<0ab<mn  RUN
r<0s<0ab>mn  RUN
r<0s>0ab<mn  RUN
r<0s>0ab=mn  RUN

BYE

