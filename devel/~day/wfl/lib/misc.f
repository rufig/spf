

CLASS CRect

   0 DEFS addr

   CELL DEFS left
   CELL DEFS top
   CELL DEFS right
   CELL DEFS bottom


: width ( -- n )
    right @ left @ -
;

: height ( -- n )
    bottom @ top @ -
;

: hw ( -- height width )
    height
    width
;

: yx ( -- y x )
    top @
    left @
;

: .
    ." left " left @ . CR
    ." top " top @ . CR
    ." right " right @ . CR
    ." bottom " bottom @ . CR
    ." width " width . CR
    ." height " height . CR
;

\ The last definitions in class

: ! ( bottom right top left )
    left !
    top !
    right !
    bottom !
;

: @ ( bottom right top left )
    bottom @
    right @
    top @
    left @
;

;CLASS

: Rect>Width ( bottom right top left -- height width top left )
    || CRect r ||
    r !
    r hw r yx
;

: Rect>Win ( x y w h -- height width y x )
    SWAP 2SWAP SWAP
;

: MoveRect ( bottom right top left deltax deltay -- )
    || CRect r ||
    2>R  r ! 2R>
    DUP r top +!
        r bottom +!
    DUP r left +!
        r right +!
    r @
;
