REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS ~ygrek/lib/wfl/opengl/GLCanvas.f

\ -----------------------------------------------------------------------

CStatic SUBCLASS CGLControl

CGLCanvas OBJ canvas

init: ;
dispose: ;

: create ( id h -- hwnd ) SUPER create ( hwnd ) DUP canvas :initialize ;

( W: WM_PAINT
   ." paint"
   :onPaint 
   0 ;)

W: WM_TIMER ( -- n )
   canvas :doPaint 
   0 ;

W: WM_DESTROY ( -- n ) 0 0 PostQuitMessage DROP ;

: :resize { | WindowRect }
    RECT::/SIZE ALLOCATE THROW TO WindowRect
                  0 WindowRect RECT::left ! \ Set Left Value To 0
     canvas :width@ WindowRect RECT::right ! \ Set Right Value To Requested Width  
                  0 WindowRect RECT::top ! \ Set Top Value To 0
    canvas :height@ WindowRect RECT::bottom ! \ Set Bottom Value To Requested Height

    SUPER exStyle @ FALSE SUPER style @ WindowRect AdjustWindowRectEx DROP

    WindowRect RECT::bottom @ WindowRect RECT::top @ - canvas :height!
    WindowRect RECT::right @ WindowRect RECT::left @ - canvas :width!
    WindowRect FREE THROW

    canvas :resize
;


W: WM_SIZE ( -- n )
   \ CR ." WM_SIZE"
   SUPER msg lParam @ LOWORD canvas :width!
   SUPER msg lParam @ HIWORD canvas :height!
   :resize
   0 ;

;CLASS
