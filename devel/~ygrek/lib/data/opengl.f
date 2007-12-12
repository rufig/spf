MODULE: GL-FUNCS

WINAPI: glViewport        OpenGL32.DLL
WINAPI: glMatrixMode      OpenGL32.DLL
WINAPI: glLoadIdentity    OpenGL32.DLL
WINAPI: glShadeModel      OpenGL32.DLL
WINAPI: glClearColor      OpenGL32.DLL
WINAPI: glClearDepth      OpenGL32.DLL
WINAPI: glEnable          OpenGL32.DLL
WINAPI: glDepthFunc       OpenGL32.DLL
WINAPI: glHint            OpenGL32.DLL
WINAPI: glClear           OpenGL32.DLL
WINAPI: wglMakeCurrent    OpenGL32.DLL
WINAPI: wglDeleteContext  OpenGL32.DLL
WINAPI: wglCreateContext  OpenGL32.DLL
WINAPI: wglSwapBuffers    OpenGL32.DLL
WINAPI: glGetError        OpenGL32.DLL
WINAPI: glTranslatef      OpenGL32.DLL
WINAPI: glScalef          OpenGL32.DLL
WINAPI: glBegin           OpenGL32.DLL
WINAPI: glEnd             OpenGL32.DLL
WINAPI: glVertex3f        OpenGL32.DLL
WINAPI: glVertex3fv       OpenGL32.DLL
WINAPI: glVertex3dv       OpenGL32.DLL
WINAPI: glNormal3f        OpenGL32.DLL
WINAPI: glNormal3fv       OpenGL32.DLL
WINAPI: glNormal3dv       OpenGL32.DLL
WINAPI: glColor3f         OpenGL32.DLL
WINAPI: glRotatef         OpenGL32.DLL
WINAPI: glGenTextures     OpenGL32.DLL
WINAPI: glBindTexture     OpenGL32.DLL
WINAPI: glTexImage2D      OpenGL32.DLL
WINAPI: glTexParameteri   OpenGL32.DLL
WINAPI: glTexCoord2f      OpenGL32.DLL
WINAPI: glPixelStoref     OpenGL32.DLL
WINAPI: glPixelStorei     OpenGL32.DLL
WINAPI: glPushMatrix      OpenGL32.DLL
WINAPI: glPopMatrix       OpenGL32.DLL
WINAPI: glLightf          OpenGL32.DLL
WINAPI: glLightfv         OpenGL32.DLL
WINAPI: glCallList        OpenGL32.DLL
WINAPI: glGenLists        OpenGL32.DLL
WINAPI: glEndList         OpenGL32.DLL
WINAPI: glNewList         OpenGL32.DLL
WINAPI: glDisable         OpenGL32.DLL
WINAPI: glColorMaterial   OpenGL32.DLL
WINAPI: glMaterialf       OpenGL32.DLL
WINAPI: glDrawPixels      OpenGL32.DLL
WINAPI: glLightModeli     OpenGL32.DLL
WINAPI: glFrontFace       OpenGL32.DLL
WINAPI: glCullFace        OpenGL32.DLL

WINAPI: gluPerspective    Glu32.DLL
WINAPI: gluOrtho2D        Glu32.DLL

;MODULE

ALSO GL-FUNCS

\EOF \ просмотр порядка вызова функций

REQUIRE enqueueNOTFOUND ~pinka/samples/2006/core/trans/nf-ext.f
REQUIRE [WID] ~ygrek/lib/wid.f

: LOG-THIS 2>R CR CR .S 2R> CR TYPE KEY DROP ;

:NONAME ( a u -- a u FALSE | i*x TRUE )
  2DUP [WID] GL-FUNCS SEARCH-WORDLIST 0 = IF FALSE EXIT THEN
  >R POSTPONE SLITERAL POSTPONE LOG-THIS R> COMPILE, 
  TRUE
 ; enqueueNOTFOUND
