REQUIRE WL-MODULES ~day/lib/includemodule.f

: REQUIRE NEEDED ;

NEEDS ~ygrek/lib/wfl/opengl/GLCanvas.f

\ -----------------------------------------------------------------------

CStatic SUBCLASS CGLControl

CGLCanvas OBJ canvas

init: ;
dispose: ;

: create SUPER create ( hwnd ) canvas :initialize ;

(
W: WM_PAINT
   2DROP 2DROP
   ." paint"
   :onPaint 
   0 ;)

W: WM_TIMER
   2DROP 2DROP
   canvas :doPaint 
   0 
;

W: WM_DESTROY ( lpar wpar msg hwnd -- n )
   2DROP 2DROP 0
   0 PostQuitMessage DROP
;

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


W: WM_SIZE ( lpar wpar msg hwnd )
   \ CR ." WM_SIZE"
   3 PICK LOWORD canvas :width!
   3 PICK HIWORD canvas :height!
   2DROP 2DROP
   :resize
   0
;

;CLASS
