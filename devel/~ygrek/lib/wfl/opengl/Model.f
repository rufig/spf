REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS ~ygrek/lib/filelines.f
NEEDS lib/include/float2.f
NEEDS ~ygrek/lib/hype/array.f
NEEDS ~ygrek/lib/parse.f
NEEDS ~ygrek/lib/debug/ensure.f

: ?FLOAT-EXT ( addr u -- bool )
    DUP 2 < IF 2DROP 0 EXIT THEN
    1   0 <SIGN>    >R
    16  0 <DIGITS>  >R
    1   1 <DOT>     >R
    16  0 <DIGITS>  >R
    1   0 <EXP>     >R
    1   0 <SIGN>    >R
    4   0 <DIGITS>  >R
    NIP 0= \ После всего этого должен быть конец строки
    2R> 2R> 2R> R> AND
    AND AND AND AND AND
    AND
;

: >FLOAT-EXT ( addr u -- F: r true | false )
  2DUP ?FLOAT-EXT
  IF
    PAST-COMMA 0! FALSE ?IS-COMMA !
    OVER C@ DUP [CHAR] - =    \ addr u c flag
    IF DROP SKIP1 >FLOAT-ABS FNEGATE
    ELSE [CHAR] + = IF SKIP1 THEN
                    >FLOAT-ABS
    THEN
  ELSE
   2DROP 0
  THEN
;

: PARSE-FLOAT PARSE-NAME >FLOAT-EXT ENSURE ;
: PARSE-NUMBER PARSE-NAME NUMBER ENSURE ;

CLASS CTriBase

 CELL PROPERTY v1 
 CELL PROPERTY v2 
 CELL PROPERTY v3

 : :print ." Tri (" v1@ . v2@ . v3@ . ." )" ;

 : :setv v3! v2! v1! ;

;CLASS

\ --------------------------

CTriBase SUBCLASS CTri

 CELL PROPERTY n1 
 CELL PROPERTY n2 
 CELL PROPERTY n3

 : :setn n3! n2! n1! ;

 : :set1 n3! SUPER v3! n2! SUPER v2! n1! SUPER v1! ;

;CLASS

\ ------------------------------------------------------------------------------

CLASS CSimpleModelBase

 vector OBJ ver

init: CGLPoint ^ size ver :setup ;

: :xmax ( -- F: f ) { | a } 
   ver :start -> a 
   0e
   ver :size 0 ?DO a :: CGLPoint.:x@ FABS FMAX a ver :iterate -> a LOOP ;

: :ymax ( -- F: f ) { | a } 
   ver :start -> a 
   0e
   ver :size 0 ?DO a :: CGLPoint.:y@ FABS FMAX a ver :iterate -> a LOOP ;

: :zmax ( -- F: f ) { | a } 
   ver :start -> a 
   0e
   ver :size 0 ?DO a :: CGLPoint.:z@ FABS FMAX a ver :iterate -> a LOOP ;

: :vertices ( -- n ) ver :size ;
: :vnth ( n -- a ) ver :nth ;

: :printall { | a }
   ver :start -> a
   ver :size 0 DO CR a :: CGLPoint.:getr F. F. F. a ver :iterate -> a KEY DROP LOOP ;

: :print CR ." Total vertices = " :vertices . ;

: :add-vertex ( F: x y z -- )
   ver :resize1
   ver :last :: CGLPoint.:set ;

;CLASS

\ ------------------------------------------------------------------------------

CSimpleModelBase SUBCLASS CSimpleModel

 vector OBJ tri
 vector OBJ norm

init:
  CTri ^ size tri :setup
  CGLPoint ^ size norm :setup
;

: :faces ( -- n ) tri :size ;
: :tnth ( n -- a ) tri :nth ;
: :nnth ( n -- a ) norm :nth ;

: :print 
   SUPER :print
   ." Total faces = " :faces . ;

: :add-tri ( v1 v2 v3 -- )
   tri :resize1
   tri :last :: CTri.:setv ;

: :add-tri-with-norm ( v1 n1 v2 n2 v3 n3 -- )
   tri :resize1
   tri :last :: CTri.:set1 ;

: :add-norm ( F: x y z -- )
   norm :resize1
   norm :last :: CGLPoint.:set ;

\ Посчитать нормаль к точке p0 для треугольника p0-pa-pb
( [pb-p0]x[pa-p0] )
: (tri-norm) ( p0 pa pb -- F: x y z )
   || CGLPoint p0 CGLPoint pa CGLPoint pb ||

   pb :pset
   pa :pset
   p0 :pset

   -1e p0 :mult
   p0 :get pa :inc ( a := a - 0 )
   p0 :get pb :inc ( b := b - 0 )

   pa this pb :pvect ;

: :set-tri-normales { t }
   norm :size DUP 1+ DUP 1+ t :: CTri.:setn

   t :: CTri.v1@ SUPER :vnth
   t :: CTri.v2@ SUPER :vnth
   t :: CTri.v3@ SUPER :vnth
   (tri-norm) :add-norm

   t :: CTri.v2@ SUPER :vnth
   t :: CTri.v3@ SUPER :vnth
   t :: CTri.v1@ SUPER :vnth
   (tri-norm) :add-norm
   \ norm :last :: CGLPoint.:get :add-norm
   \ norm :last :: CGLPoint.:get :add-norm

   t :: CTri.v3@ SUPER :vnth
   t :: CTri.v1@ SUPER :vnth
   t :: CTri.v2@ SUPER :vnth
   (tri-norm) :add-norm
;

: :calculate-normales { | a }
   tri :start -> a
   :faces 0 ?DO
    a :set-tri-normales a tri :iterate -> a
   LOOP
;

;CLASS

\ ------------------------------------------------------------------------------

CLASS CModelLoader

 VAR _model

init: 0 _model ! ;
dispose: ;

: :model _model @ ;

: :load ( a u model -- ) 
    _model !
    2DUP CR ." Loading model : " TYPE
    SELF => :load-file
;

: :load-file ( a u -- ) TRUE S" virtual method!" SUPER abort ;

;CLASS

\ ------------------------------------------------------------------------------

CModelLoader SUBCLASS CModelLoaderOFF

: (parse-tri-vertex-and-normal) ( "vi//ni " -- vi ni )
  [CHAR] / PARSE NUMBER ENSURE 1- \ индексы в файле начинаются с единицы - у нас с нуля
  [CHAR] / PSKIP
  BL PARSE NUMBER ENSURE 1- ;

MODULE: obj-import

: v ( "f f f" -- ) PARSE-FLOAT PARSE-FLOAT PARSE-FLOAT SUPER :model :: CSimpleModel.:add-vertex ;

: f 
  (parse-tri-vertex-and-normal)
  (parse-tri-vertex-and-normal)
  (parse-tri-vertex-and-normal)
  SUPER :model :: CSimpleModel.:add-tri-with-norm ;

: vn PARSE-FLOAT PARSE-FLOAT PARSE-FLOAT SUPER :model :: CSimpleModel.:add-norm ;

;MODULE

: (parse-line) 
   PeekChar [CHAR] # = IF EXIT THEN \ comments
   GET-ORDER
   ONLY obj-import
   SOURCE ['] EVALUATE CATCH IF 2DROP CR ." Skipping unrecognized line : " SOURCE TYPE THEN
   SET-ORDER
;

: :load-file FileLines=> DUP STR@ ['] (parse-line) EVALUATE-WITH ;

;CLASS

\ ------------------------------------------------------------------------------

CModelLoader SUBCLASS CModelLoaderPLY2

 VAR _vertex
 VAR _face
 VAR _n

 VECT parse-line

dispose: ;

: get-face
  _n @ _face @ = IF TRUE S" No more faces expected" SUPER abort 0 _n ! EXIT THEN
  _n 1+!
  PARSE-NUMBER 3 <> S" Expecting only triangles!" SUPER abort
  PARSE-NUMBER PARSE-NUMBER PARSE-NUMBER SUPER :model :: CSimpleModel.:add-tri ;

: get-vertex
  _n @ _vertex @ = IF 0 _n ! get-face ['] get-face TO parse-line EXIT THEN
  _n 1+!
  PARSE-FLOAT PARSE-FLOAT PARSE-FLOAT SUPER :model :: CSimpleModel.:add-vertex ;

: get-face-count
  -1 PARSE NUMBER 0= S" Expected number of faces at second line" SUPER abort 
  _face !
  0 _n !
  ['] get-vertex TO parse-line ;

: get-vertex-count 
  -1 PARSE NUMBER 0= S" Expected number of vertices at first line" SUPER abort 
   _vertex !
  ['] get-face-count TO parse-line
;

init: ['] get-vertex-count TO parse-line ;

: :do-load-file FileLines=> DUP STR@ ['] parse-line EVALUATE-WITH ;

: :load-file ( a u -- ) :do-load-file SUPER :model :: CSimpleModel.:calculate-normales ;

;CLASS

\ ------------------------------------------------------------------------------
