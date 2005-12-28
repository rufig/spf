REQUIRE GLWindow  ~ygrek/lib/joopengl/GLWindow.f

: RUN { \ w s }
   status
   GLWindow :new -> w
   status
   ." Going to create"
   0 w :create
   S" OpenGL demo in Forth by yGREK heretix" w :setText
   100 50 200 200 w :move

   GLPyramid :new -> s 
   0e -2e 0e s <angle.speed @ :set
   s w :add

   GLPyramid :new -> s 
   -1e s :resize \ Ставим пирамиду вверх основанием
   0e 2e 0e s <angle.speed @ :set
   s w :add

   GLCube :new -> s 
   0.5E s :resize
   -3e 0e -10e s <shift @ :set
   -1e 5e 2e s <angle.speed @ :set
   s w :add

   w :show
   w :run 
\   status
   w :free
   BYE
;

\ : main
\ 1 IF 
  \ HERE IMAGE-BASE - 20000 + TO IMAGE-SIZE \ Вместо 10000 свое значение
  ' RUN TO <MAIN> 
  \ ' RUN MAINX !
  \ TRUE TO ?GUI
  \ FALSE TO ?CONSOLE
  S" joopengl.exe" SAVE 
  BYE
\ ELSE RUN THEN
\ ;

