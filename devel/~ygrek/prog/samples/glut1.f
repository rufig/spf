\ $Id$
\ This is a simple, introductory OpenGL program.

REQUIRE AUTO-FLOAT-LITERAL ~ygrek/lib/float.f
REQUIRE LINUX-CONSTANTS lib/posix/const.f
S" ~ygrek/lib/data/opengl.const" ADD-CONST-VOC \ OpenGL constants are OS-independent (really so?)

0x0 CONSTANT GLUT_SINGLE
0x0 CONSTANT GLUT_RGB

USE libglut.so.3

:NONAME
  \ clear all pixels
  (( GL_COLOR_BUFFER_BIT )) glClear DROP

  \ draw green polygon (rectangle) with corners at
  \ (0.25, 0.25, 0.0) and (0.75, 0.75, 0.0)
  (( 0.0f 1.0f 0.0f )) glColor3f DROP
  (( GL_POLYGON )) glBegin DROP
     (( 0.25f 0.25f 0.0f )) glVertex3f DROP
     (( 0.75f 0.25f 0.0f )) glVertex3f DROP
     (( 0.75f 0.75f 0.0f )) glVertex3f DROP
     (( 0.25f 0.75f 0.0f )) glVertex3f DROP
   (()) glEnd DROP \ glBegin/glEnd look like a good candidate for bac4th

  \ don't wait!
  \ start processing buffered OpenGL routines
  (( )) glFlush DROP
; 
0 CELLS CALLBACK: display

: init
  \ select clearing color
  (( 0f 0f 1f 0f )) glClearColor DROP

  \ initialize viewing values
  (( GL_PROJECTION )) glMatrixMode DROP
  (( )) glLoadIdentity DROP
  (( 0f 1f 0f 1f -1f 1f )) glOrtho DROP
;

\ : key { key x y -- }

\ Declare initial window size, position, and display mode
\ (single buffer and RGBA).  Open window with "hello"
\ in its title bar.  Call initialization routines.
\ Register callback function to display graphics.
\ Enter main loop and process events.
: main
   ARGC SP@ 1 <( ARGV )) glutInit DROP DROP
   (( GLUT_SINGLE GLUT_RGB OR )) glutInitDisplayMode DROP
   (( 250 250 )) glutInitWindowSize DROP
   (( 100 100 )) glutInitWindowPosition DROP
   (( S" hello" DROP )) glutCreateWindow DROP
   init
   (( ['] display )) glutDisplayFunc DROP
\  ['] key glutKeyboardFunc DROP
   (()) glutMainLoop DROP
;

main BYE

