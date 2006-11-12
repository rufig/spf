

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
;

;CLASS