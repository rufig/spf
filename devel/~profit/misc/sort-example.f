\ http://fforum.winglion.ru/viewtopic.php?p=6242#6242
\ Использование функции сортировки

REQUIRE [DEFINED] lib/include/tools.f 

[UNDEFINED] []exch[] [IF] 
VECT []>[] 
VECT []exch[] 
VECT []<[] 
[THEN] 

REQUIRE quick_sort ~pinka/samples/2003/common/qsort.f 
REQUIRE " ~ac/lib/str5.f 

CREATE a 
" oh " , " i " , " believe " , " in " , " yesterday " , 
HERE a - CELL / VALUE n 

: s.addr CELLS a + ; 
: s ( i -- a u ) s.addr @ STR@ ; 

: print n 0 DO I s TYPE LOOP ; 

: s.compare ( i j -- ? ) s ROT s COMPARE ; 
: s.exchange { i j -- } i s.addr @ j s.addr @ i s.addr ! j s.addr ! ; 

:NONAME s.compare 0 < ; TO []>[] 
:NONAME s.compare 0 > ; TO []<[] 
' s.exchange TO []exch[] 

CR print 
0 n 1 - quick_sort 
CR print