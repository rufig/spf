REQUIRE WFL ~day/wfl/wfl.f
REQUIRE CGLWindow ~ygrek/lib/wfl/opengl/GLWindow.f
REQUIRE CBMP24 ~ygrek/lib/spec/bmp.f
REQUIRE CGLImage ~profit/lib/wfl/openGL/CGLImage.f

\ укажите путь до показываемой картинки
\ путь либо относительный от запускаемого SPF
\ либо абсолютный
: picture S" r.bmp" ;
\ Картинка должна быть в формате BMP 24bit

: PrepareLight
   GL_NORMALIZE glEnable DROP       \ Enable normalization of normales
   GL_COLOR_MATERIAL glEnable DROP  \ The color is treated as the material color
   || CGLPoint p ||
   0.2e 0.2e 0.2e 0.5e p :set4
    p :getv GL_AMBIENT GL_LIGHT1 glLightfv DROP
   GL_LIGHT1 glEnable DROP \ Enable our light source
   GL_LIGHTING glEnable DROP \ Enable lighting in general
;
 
CGLWindow SUBCLASS CMyGLWindow

: :prepare SUPER :prepare PrepareLight ;
;CLASS
 
0 VALUE list1
 
0 VALUE bmp

: test ( -- n )
|| CMyGLWindow aa CMessageLoop loop ||

CGLObjectList NewObj TO list1
CGLImage NewObj TO bmp
picture bmp :: CGLImage.:load-image

200 0 0 bmp :: CGLImage.:set-color
50 0 DO
100 0 DO I J bmp => :pixel LOOP LOOP

bmp list1 :: CGLObjectList.:add
 
list1 aa :add
0 aa create DROP
SW_SHOW aa showWindow

loop run ;

test BYE

\EOF
 
: save
   0 TO SPF-INIT?
   ['] ANSI>OEM TO ANSI><OEM
   TRUE TO ?GUI
   ['] test TO <MAIN>
   ['] test MAINX !
   S" wflgl.exe" SAVE ;