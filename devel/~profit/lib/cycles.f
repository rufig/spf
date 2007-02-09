\ конструкция FOR .. NEXT и DO .. LOOP , не задевающий стек возвратов

REQUIRE >L ~profit\lib\lstack.f

: REF@ @ ; \ REF -- спец. тип для ссылок перехода, см. работы Гасаненко
: REF! ! ;
: REF+ CELL+ ;

: >MARK ( -- dest ) 	HERE 0 , ;
: >RESOLVE ( dest -- )	HERE SWAP REF! ;

: <MARK ( -- org )	HERE ;
: <RESOLVE ( org -- )	, ;


: (DO) ( b a -- ) \ от а до b
   SWAP >L >L ; \ положить на L-стек индекс и краевое значение

: (LOOP) L> 1+  L>
2DUP = IF  2DROP R> REF+ ELSE \ если конец, обойти ссылку
  >L >L   R> REF@ THEN  >R ; \ если нет, перейти по ссылке

: DO  POSTPONE (DO) <MARK ; IMMEDIATE
: LOOP POSTPONE (LOOP) <RESOLVE ; IMMEDIATE
:  I L@ ;

: FOR POSTPONE >L <MARK ;  IMMEDIATE
: (NEXT) L> 1-
?DUP IF >L R> REF@ ELSE R> REF+ THEN  >R ;
: NEXT POSTPONE (NEXT) <RESOLVE ;  IMMEDIATE