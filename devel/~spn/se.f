( S-expressions 20070727, Peter Sovietov )

: .s-mark ;
: .s-tag [ 1 CELLS ] LITERAL + ;
: .s-car [ 2 CELLS ] LITERAL + ;
: .s-cdr [ 3 CELLS ] LITERAL + ;
: /s-obj [ 4 CELLS ] LITERAL ;

VARIABLE s-heap
VARIABLE s-size
VARIABLE s-free

VARIABLE s-locals
VARIABLE s-lp

: lp-reset ( n ) s-locals @ s-lp ! ;
: s-depth ( -- n ) s-lp @ s-locals @ - CELL / ;

: p->s ( x -- s: x ) s-lp @ ! CELL s-lp +! ;
: s->p ( s: x -- x ) [ CELL NEGATE ] LITERAL s-lp +! s-lp @ @ ;
: s-dup ( s: x -- s: x x ) s->p DUP p->s p->s ;
: s-drop ( s: x ) s->p DROP ;
: s-swap ( s: x y -- s: y x ) s->p s->p SWAP p->s p->s ;
: s-over ( s: x y -- s: x y x )
   s->p s->p SWAP OVER p->s p->s p->s ;

VARIABLE s-calls
VARIABLE s-cp

: cp-reset ( n ) s-calls @ s-cp ! ;

: s->c ( s: x -- c: x ) s->p s-cp @ ! CELL s-cp +! ;
: c->s ( c: x -- s: x )
   [ CELL NEGATE ] LITERAL s-cp +! s-cp @ @ p->s ;
: c-pick ( n -- s: x )
   [ CELL NEGATE ] LITERAL * s-cp @ + @ p->s ;

: (pair) ( a ) p->s ;
: (null) ( a ) p->s ;
: (number) ( a ) .s-car @ ;
: (xt) ( a ) .s-car @ EXECUTE ;

CREATE '() /s-obj ALLOT ' (null) '() .s-tag !
: () ( -- s: 0 ) '() p->s ;

VARIABLE s-globals

: s-variable CREATE HERE '() , s-globals @ , s-globals ! ;
: get ( a -- s: x ) @ p->s ;
: set ( a s: x ) s->p SWAP ! ;

: s-reserve ( a n )
   s-size ! s-heap ! '() s-free !
   s-heap @ DUP >R s-size @ /s-obj * +
   BEGIN R@ OVER < WHILE
     FALSE R@ .s-mark !
     ['] (pair) R@ .s-tag !
     s-free @ R@ .s-cdr !
     R@ s-free ! R> /s-obj + >R
   REPEAT R> 2DROP lp-reset cp-reset 0 s-globals ! ;

: s-mark ( a )
   BEGIN DUP '() = IF DROP EXIT THEN
     DUP .s-mark @ IF DROP EXIT THEN
     DUP .s-mark TRUE SWAP !
     DUP .s-tag @ ['] (pair) = WHILE
       DUP .s-car @ RECURSE .s-cdr @
   REPEAT DROP ;
: s-sweep 
   '() s-free ! s-heap @ DUP >R s-size @ /s-obj * +
   BEGIN R@ OVER < WHILE
     R@ .s-mark @ IF FALSE R@ .s-mark !
     ELSE ['] (pair) R@ .s-tag !
       s-free @ R@ .s-cdr ! R@ s-free !
     THEN R> /s-obj + >R
   REPEAT R> 2DROP ;
: gc
   s-locals @ >R s-lp @ BEGIN R@ OVER < WHILE
     R@ @ s-mark R> CELL+ >R REPEAT R> 2DROP
   s-calls @ >R s-cp @ BEGIN R@ OVER < WHILE
     R@ @ s-mark R> CELL+ >R REPEAT R> 2DROP
   s-globals @ BEGIN DUP WHILE DUP @ s-mark
     CELL+ @ REPEAT DROP s-sweep
   s-free @ '() = ABORT" se: gc" ;

: (cons) ( x y -- z )
   s-free @ '() = IF gc THEN
   s-free @ DUP .s-cdr @ s-free ! >R
   R@ .s-cdr ! R@ .s-car ! R> ;
: cons ( s: x y -- s: z )
   s-over s->p s-dup s->p (cons) s-drop s-drop p->s ;

: ->s ( n -- s: n )
   0 (cons) DUP .s-tag ['] (number) SWAP ! p->s ;
: xt->s ( a -- s: a )
   0 (cons) DUP .s-tag ['] (xt) SWAP ! p->s ;
: s-> ( s: x ) s->p DUP .s-tag @ EXECUTE ;

: pair? ( s: x -- ? ) s->p .s-tag @ ['] (pair) = ;
: null? ( s: x -- ? ) s->p '() = ;
: number? ( s: x -- ? ) s->p .s-tag @ ['] (number) = ;
: xt? ( s: x -- ? ) s->p .s-tag @ ['] (xt) = ;

: car ( s: x -- s: y )
   s-dup pair? 0= ABORT" se: car" s->p .s-car @ p->s ;
: cdr ( s: x -- s: y )
   s-dup pair? 0= ABORT" se: cdr" s->p .s-cdr @ p->s ;
: set-car! ( s: x y ) 
   s-dup pair? 0= ABORT" se: set-car!" s->p .s-car set ;
: set-cdr! ( s: x y ) 
   s-dup pair? 0= ABORT" se: set-cdr!" s->p .s-cdr set ;

: list ( n s: ... -- s: x )
   () BEGIN DUP WHILE cons 1- REPEAT DROP ;
: s( ( -- n ) s-depth ;
: )s ( n s: ... -- s: x ) s-depth SWAP - list ;

: eq? ( s: x y -- ? )
   s->p s->p OVER .s-tag @ OVER .s-tag @ = >R
   OVER .s-car @ OVER .s-car @ = >R
   .s-cdr @ SWAP .s-cdr @ = R> AND R> AND ;
: equal? ( s: x y -- ? )
   BEGIN s-dup pair? s-over pair? AND WHILE
     s-over car s-over car RECURSE 0= IF
       s-drop s-drop FALSE EXIT THEN cdr s-swap cdr
   REPEAT eq? ;

: list-tail ( n s: x -- s: y )
   BEGIN DUP WHILE cdr 1- REPEAT DROP ;
: list-ref ( n s: x -- s: y ) list-tail car ;

: s-execute ( s: f )
   BEGIN s-dup pair? WHILE s-dup s->c car s-> c->s cdr
   REPEAT s-dup null? IF s-drop EXIT THEN s-> ;

: for-each-pair ( s: x f )
   BEGIN s-over pair? WHILE s-dup s->c s-over cdr s->c
     s-execute c->s c->s REPEAT s-drop s-drop ;

: last-pair' ( s: x e -- s: e ) s-swap s-drop ;
: last-pair ( s: x -- s: y )
   s-dup cdr ['] last-pair' xt->s for-each-pair ;

: for-each ( s: x f ) ['] car xt->s s-swap cons for-each-pair ;

: length' ( i s: e -- j ) s-drop 1+ ;
: length ( s: x -- n ) 0 ['] length' xt->s for-each ;

: fold ( s: x z f -- s: y ) s->c s-swap c->s for-each ;

: reverse' ( s: x e -- s: y ) s-swap cons ;
: reverse ( s: x -- s: y ) () ['] reverse' xt->s fold ;

: reverse!' ( s: x e -- s: y ) s-dup s->c set-cdr! c->s ;
: reverse! ( s: x -- s: y )
   () s-swap ['] reverse!' xt->s for-each-pair ;

: map' ( s: f x e -- s: y )
   s-swap s->c s-swap s-dup s->c s-execute
   c->s s-swap c->s cons ;
: map ( s: x f -- s: y )
   s-swap () ['] map' xt->s fold reverse! s-swap s-drop ;

: list-copy ( s: x -- s: y ) () map ;

: append ( s: x y -- s: z )
   s-swap s-dup null? IF s-drop EXIT THEN
   list-copy s-dup s->c last-pair set-cdr! c->s ;

: filter' ( s: f x e -- s: y )
   s->c s->c s->c 3 c-pick 1 c-pick s-execute
   c->s c->s c->s IF s-swap cons EXIT THEN s-drop ;
: filter ( s: x f -- s: y )
   s-swap () ['] filter' xt->s fold reverse! s-swap s-drop ;

: 1pr ( a -- s: f ) s( SWAP ['] s-> xt->s xt->s )s ;
: 1op ( a -- s: f )
   s( SWAP ['] s-> xt->s xt->s ['] ->s xt->s )s ;
: 2op ( a -- s: f )
   s( SWAP ['] s-> xt->s s-dup ['] SWAP xt->s xt->s
   ['] ->s xt->s )s ;

( debug )

: (.atom) ( s: x )
   s-dup number? IF s-> . EXIT THEN
   s-dup xt? IF s-drop ." xt " EXIT THEN
   s-dup null? IF s-drop ." () " EXIT THEN
   s-drop ." ? " ;
VARIABLE '.atom ' (.atom) '.atom !
: .atom '.atom @ EXECUTE ;
: .se ( s: x )
   s-dup pair? IF ." ( "
     BEGIN s-dup car RECURSE cdr s-dup pair? 0= UNTIL
     s-dup null? IF s-drop ELSE ." . " .atom THEN ." ) "
   ELSE .atom THEN ;

: gc-free ( -- n )
   s-free @ 0 >R BEGIN DUP '() =
     IF DROP R> EXIT THEN .s-cdr @ R> 1+ >R AGAIN ;
: .free gc-free . ;
: .locals s-depth . ;

HERE 1024 CELLS ALLOT s-locals !
HERE 1024 CELLS ALLOT s-calls !
HERE 1024 /s-obj * ALLOT 1024 s-reserve
