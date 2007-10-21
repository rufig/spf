\ чтобы увидеть кролика - модель брать тут : http://www.forth.org.ru/~ygrek/files/bun_zipper.7z
\ распаковать и положить рядом

REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS ~day/wfl/wfl.f
NEEDS ~ygrek/lib/wfl/opengl/GLWindow.f
NEEDS ~day/common/clparam.f
NEEDS ~ygrek/lib/neilbawd/mersenne.f

: PrepareLight
   GL_NORMALIZE glEnable DROP       \ Enable normalization of normales

   GL_COLOR_MATERIAL glEnable DROP  \ The color is treated as the material color

   || CGLPoint p ||

   0.2e 0.2e 0.2e 0.5e p :set4
   \ p :getv GL_AMBIENT GL_LIGHT1 glLightfv DROP
   0.6e 0.6e 0.6e 1.0e p :set4
   p :getv GL_DIFFUSE GL_LIGHT1 glLightfv DROP
   0.0e 0.0e 0.0e -1.0e p :set4
   p :getv GL_POSITION GL_LIGHT1 glLightfv DROP
   0.8e 0.8e 0.8e 1.0e p :set4
   \ p :getv GL_SPECULAR GL_LIGHT1 glLightfv DROP


   GL_LIGHT1 glEnable DROP \ Enable our light source
   GL_LIGHTING glEnable DROP \ Enable lighting in general
;

CGLWindow SUBCLASS CMyGLWindow

: :prepare SUPER :prepare PrepareLight ;

;CLASS

\ -----------------------------------------------------------------------

0 VALUE K

0 VALUE list1

: FGENRANDMAX ( F: max -- f ) FGENRAND F* ;
: FGENRANDABS ( F: abs -- f ) 2e F* FGENRAND 0.5e F- F* ;

: test ( -- n )
  || CMyGLWindow aa CMessageLoop loop D: m CTimer timer CModelLoaderPLY2 ml1  CModelLoaderOFF ml2  D: filename ||

  S" bun_zipper_res2.ply2" " {s}" filename !

  \ CGLMayaModel NewObj m !
  \ S" m16.obj1" m @ => :load

  CGLObjectList NewObj TO list1

  0 TO K
  BEGIN

  K 1 <
  WHILE
    10 0 DO
      10 0 DO
       \ CR I . J . K .
       CGLCube NewObj
       DUP 0.75e :: CGLCube.:resize
       DUP 0e I DS>F 3e F* F+ 0e J DS>F 3e F* F+ 0e K DS>F 3e F* F- :: CGLObject.:setShift
       DUP 5e FGENRANDABS 5e FGENRANDABS 5e FGENRANDABS :: CGLObject.:setAngleSpeed
           list1 :: CGLObjectList.:add
      LOOP
    LOOP
    K 1+ TO K
  REPEAT

  CGLSimpleModel NewObj m !

  \ filename @ STR@ TYPE
  filename @ STR@ m @ => :model ml1 :load
  10e 2e 10e m @ => :setShift
  0e 1e 0e m @ => :setAngleSpeed
  \ 0e 90e 0e m @ => :setAngle
  10e m @ => :resize
  m @ aa :add

  CGLSimpleModel NewObj m !
  S" m16.off" m @ => :model ml2 :load
  5e 5e -10e m @ => :setShift
  1e 0e 0e m @ => :setAngleSpeed
  0e 90e 0e m @ => :setAngle
  0.01e m @ => :resize
  m @ aa :add

  \ 1e 0e 0e list1 :setAngleSpeed
  \ -1e 0e 0e list2 :setAngleSpeed

  list1 aa :add

  -15e -15e -40e aa :setShift

  0 0 aa create DROP
  SW_SHOW aa showWindow

  timer :start
  loop run
  timer :stop
  timer :ms@ CR ." Total time = " .
;

test

\EOF

: save
   0 TO SPF-INIT?
   ['] ANSI>OEM TO ANSI><OEM
   TRUE TO ?GUI
   ['] test TO <MAIN>
   ['] test MAINX !
   S" wflgl.exe" SAVE ;
