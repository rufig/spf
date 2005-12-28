\ Ещё одна система дифуров первого порядка
\ Математическое моделирование
\ (c) yGREK Heretix mailto:heretix@yandex.ru
\ 24.Mar.2005

REQUIRE runRK         ~ygrek/lib/difur.f
REQUIRE GLWindow      ~ygrek/lib/joopengl/GLWindow.f

model6.f

: morph ( x y z -- x' y' z' )
   0.1e F+ FROT \ z
   0.1e F+ FROT \ x
   0.1e F- FROT \ y
;

: RUN { \ w s1 s2 s3 s v color }
   GLWindow :new -> w
   0 w :create
   S" Мат моделирование - Модель Вольтерра" w :setText
   w :maximize

   GLPlot2D :new -> s
   s w :add

   GLPlot2D :new -> v

   Point :new -> color
   Yellow color :set

 difur-init
  10 0 DO
   [ ALSO Model6 ]
   difur-init 
   yn 0.1e I DS>F F* F+ FTO yn
   [ PREVIOUS ]
   color :get morph color :set
   Graph2D :new -> s1  color :get s1 <color @ :set  #steps s1 :points!
   Graph2D :new -> s2  color :get s2 <color @ :set  #steps s2 :points!
   Graph2D :new -> s3  color :get s3 <color @ :set  #steps s3 :points!
   #steps 0 DO
     runRK \ output CR
     Model6::xn Model6::yn s1 :point! 
     tn Model6::yn s2 :point!
     tn Model6::xn s3 :point!
   LOOP
   s1 s :add
   s2 v :add
   s3 v :add
  LOOP

   Graph2D :new -> s1   
   Magenta s1 <color @ :set
   3 s1 :points!
     [ ALSO Model6 ]
     0e Bx Ax F/ s1 :point!
     Ay By F/ Bx Ax F/ s1 :point! 
     Ay By F/ 0e s1 :point!
     [ PREVIOUS ]
   s1 s :add

   s :autoScale

   w :show
   w :run 
   w :free

   GLWindow :new -> w
   0 w :create
   S" Мат моделирование - Модель Вольтерра" w :setText
   w :maximize

   v w :add
   v :autoScale

   w :show
   w :run
   w :free
;


' RUN TO <MAIN>
S" laba3.exe" SAVE
BYE

