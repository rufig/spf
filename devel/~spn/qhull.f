( qhull.f, Peter Sovietov )

S" se.f" INCLUDED
S" lib\ext\rnd.f" INCLUDED

: find-car ( s: p -- s: e )
   s-dup car s-swap cdr
   BEGIN s-dup pair? WHILE s-dup s->c car
     s-dup car s-> s-over car s-> R@ EXECUTE
     IF s-swap THEN s-drop c->s cdr
   REPEAT s-drop R> DROP ;

: max-car find-car > ;
: min-car find-car < ;

: cadr cdr car ;

: x 1+ c-pick car s-> ;
: y 1+ c-pick cadr s-> ;

: distance ( s: x0y0 x1y1 x2y2 -- s: d )
   s->c s->c s->c
   1 x 0 x - 2 y 0 y - * 1 y 0 y - 2 x 0 x - * -
   c->s c->s c->s s-drop s-drop s-drop ->s ;

: cadrs ['] cadr xt->s map ;

: h-s' ( s: x0y0 x1y1 x2y2 -- s: dx0y0 )
   s->c s-over c->s s-swap s->c distance c->s 2 list ;
: h-s'' ( s: dx0y0 -- ? ) car s-> 0 > ;
: hull-split ( s: p x1y1 x2y2 -- s: p' )
   s->c s->c 1 c-pick 2 c-pick
   ['] h-s' xt->s 3 list map ['] h-s'' xt->s filter
   s-dup length 2 < IF
     c->s 1 list c->s s-drop s-swap cadrs append EXIT
   THEN s-dup max-car cadr s->c cadrs s->c
   1 c-pick 3 c-pick 2 c-pick RECURSE
   c->s c->s c->s s-drop c->s RECURSE append ;

: quick-hull ( s: p -- s: p' )
   s-dup max-car s-over min-car s->c s->c s->c
   1 c-pick 3 c-pick 2 c-pick hull-split
   c->s c->s c->s hull-split append ;

: points ( n -- s: p )
   RANDOMIZE
   DUP 0 DO 100 CHOOSE ->s 100 CHOOSE ->s 2 list LOOP list ;

: draw-points' ( s: xy )
   ." <circle cx=' " s-dup car s-> .
   ." ' cy=' " cadr s-> . ." ' r='2'/>" ;
: draw-points ( s: p ) ['] draw-points' xt->s for-each ;

: draw-hull' ( s: xy ) s-dup car s-> . ." , " cadr s-> . ;
: draw-hull ( s: p )
   ." <polygon fill='none' points='"
   ['] draw-hull' xt->s for-each ." '/>" ;

: .svg
   ." <?xml version='1.0'?>"
   ." <svg height='100' width='100'>"
   ." <g style='fill-opacity:1.0; stroke:black; stroke-width:1;'>"
   15 points s-dup draw-points quick-hull draw-hull
   ." </g></svg>" BYE ;

' .svg MAINX !
S" qhull.exe" SAVE BYE
