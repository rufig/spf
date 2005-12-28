\ Дифуры первого порядка
\ Математическое моделирование
\ (c) yGREK Heretix mailto:heretix@yandex.ru
\ 06.Mar.2005

REQUIRE runRK         ~ygrek/lib/difur.f
REQUIRE GLWindow      ~ygrek/lib/joopengl/GLWindow.f

\ model1.f
model2.f

ALSO Model2
' init TO difur-init
' func TO difur-func
' solution TO difur-solution

: RUN { \ w s1 s d }
   GLWindow :new -> w
   0 w :create
   S" Мат моделирование - Модель Фергюльста" w :setText
   w :maximize

   GLPlot2D :new -> s
   s w :add

  30 0 DO
   Graph2D :new -> s1   
   difur-init 
   #steps 2 * 8 * ALLOCATE THROW -> d
   #steps d s1 :data!
   #steps 0 DO
     tn d DF!   d 8 + -> d
     runRK \ output CR
     fn d DF!   d 8 + -> d  
   LOOP
   s1 s :add
   N0 10e F+ FTO N0 
  LOOP
   s :autoScale

   w :show
   w :run 
   w :free
   BYE
;

( : main 
0 IF \ всё равно exe не работает :( 
  HERE IMAGE-BASE - 10000 + TO IMAGE-SIZE \ Вместо 10000 свое значение
  ['] RUN MAINX !
  TRUE TO ?GUI
  S" joopengl.exe" SAVE BYE
ELSE
 RUN
THEN
;)

RUN
