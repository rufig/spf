\ $Id$
\ Тренировка по освещению

REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS ~day/wfl/wfl.f
NEEDS ~ygrek/lib/wfl/opengl/GLWindow.f

WINAPI: gluSphere GLU32.DLL
WINAPI: gluNewQuadric GLU32.DLL
WINAPI: glMaterialfv OpenGL32.DLL

: PrepareLight
   || CPoint4f p ||

   1e 1e 1e 1e p :set4
   p :getv GL_SPECULAR GL_FRONT glMaterialfv DROP

   50e float GL_SHININESS GL_FRONT glMaterialf DROP

   1e 1e 1e 0e p :set4
   p :getv GL_POSITION GL_LIGHT0 glLightfv DROP

   GL_LIGHTING glEnable DROP
   GL_LIGHT0 glEnable DROP
   GL_SMOOTH glShadeModel DROP 
;

CGLSimpleCanvas SUBCLASS MyScene

: :display
   SUPER :display

   PrepareLight

   -10e float -5e float -3e float glTranslatef DROP 

   20 0 DO
    -2.0e float 1e float I DS>F FSIN float glTranslatef DROP
    50 50 1.0e double gluNewQuadric gluSphere DROP
   LOOP

;

;CLASS

\ -----------------------------------------------------------------------

: test ( -- n )
  || CGLWindow aa CMessageLoop loop MyScene scene ||

  scene this aa canvas!

  0 0 aa create DROP
  SW_SHOW aa showWindow

  TRUE 400 400 200 200 aa moveWindow

  loop run
;

: save
   0 TO SPF-INIT?
   ['] ANSI>OEM TO ANSI><OEM
   TRUE TO ?GUI
   ['] test TO <MAIN>
   S" wflgl.exe" SAVE ;

test
