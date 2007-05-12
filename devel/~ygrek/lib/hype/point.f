REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS lib/include/float2.f
NEEDS ~day/hype3/hype3.f

\ --------------------------

\ класс "точка" 4D = x y z w
\ координаты вещественные 4 байт

CLASS CPoint4f

    4 DEFS x
    4 DEFS y 
    4 DEFS z
    4 DEFS w

: :x@ x SF@ ; : :x! x SF! ;
: :y@ y SF@ ; : :y! y SF! ;
: :z@ z SF@ ; : :z! z SF! ;
: :w@ w SF@ ; : :w! w SF! ;

: :set ( F: x y z -- ) :z! :y! :x! ;
: :set4 :w! :set ;
: :getv ( -- v ) x ;
: :get ( -- F: x y z )  :x@ :y@ :z@ ;
: :get4 ( -- F: x y z w ) :get :w@ ;
: :getr ( -- F: z y x ) :z@ :y@ :x@ ;
: :print  ." Point(" :x@ F. ." , " :y@ F. ." , " :z@ F. ." , " :w@ F. ." )" ;

: :inc ( F: x y z -- ) 
  :z@ F+ :z!
  :y@ F+ :y!
  :x@ F+ :x!
;

\ : :pdec ( p -- ) :: CPoint4f.:get :dec3 ;
   
\ этот обьект скопировать из обьекта-точки на стеке
: :pset ( p -- ) :: CPoint4f.:get :set ;

: :cross3 ( F: x y z -- F: f ) :z@ F* FSWAP :y@ F* F+ FSWAP :x@ F* F+ ;
: :pcross ( p -- F: f ) :: CPoint4f.:get :cross3 ;

: :pvect ( p -- F: x y z )
   >R
   :y@ R@ :: CPoint4f.:z@ F* :z@ R@ :: CPoint4f.:y@ F* F-
   :z@ R@ :: CPoint4f.:x@ F* :x@ R@ :: CPoint4f.:z@ F* F-
   :x@ R@ :: CPoint4f.:y@ F* :y@ R@ :: CPoint4f.:x@ F* F- 
   RDROP
;

init:
  0e :x!
  0e :y! 
  0e :z!
  1e :w! 
  ( ." Point init. ")
;

dispose: ;

: :xmult :x@ F* :x! ;
: :ymult :y@ F* :y! ;
: :zmult :z@ F* :z! ;

: :mult ( F: factor -- )
   FDUP  :xmult
   FDUP  :ymult
   ( f ) :zmult 
;

;CLASS
