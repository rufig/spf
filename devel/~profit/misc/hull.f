REQUIRE CHOOSE lib/ext/rnd.f
REQUIRE F. lib/include/float2.f

REQUIRE PRO ~profit/lib/bac4th.f
: 2DROPB R> EXECUTE 2DROP ;

REQUIRE split ~profit/lib/bac4th-str.f
REQUIRE iterateByByteValues ~profit/lib/bac4th-iterators.f

REQUIRE HASH!R ~pinka/lib/hash-table.f
\ Итератор по хэшу
: hash=> ( hash --> addrI uI addrEl|value \ <-- ) R> for-hash ;

VARIABLE row
VARIABLE col

\ Читаем строку addr u как псевдографику с точками
: str-points=> ( addr u --> x y n / <-- x y n ) PRO
row 0!

2DUP byRows split DUP STR@ \ разбить по строкам
2DROPB                     \ вычисленные через STR@ addr u на обратном ходу убирать
DUP 0= ONFALSE             \ пустые строки игнорируем (?)
row 1+!                    \ считать строки
col 0!                     \ сбросить колонку в начале строки
2DUP iterateByByteValues   \ разбить по буквам
col 1+!                    \ считать колонки
DUP [CHAR] . <> IF         \ если не точка, то
col @ OVER row @ SWAP CONT \ генерируем данные "на выход"
2DROP DROP THEN ;

\ Создаём хэш
small-hash VALUE POINTS

\ Цикл по всем точкам в хэше
: points=> ( --> addrEl \ <-- addrEl ) PRO POINTS hash=> 2DROP ( addrEl ) CONT DROP ;

\ У нашего хэша будет такая структура:
\ Элемент хэша состоит из
\ Координаты точки -- в первых двух (x, y).
\ Поле имени -- хранит дубль индекса-строки (чтобы не делать поиск для обратного преобразования адреса элемента в индекса)

0
2 CELLS -- xy
   CELL -- name
CONSTANT /point

: y ( addr -- addr' ) xy ;
: x ( addr -- addr' ) y CELL+ ;

\ Преобразовать символ c со стека в строковый индекс для хэша
: letter-str ( c -- addr u ) S" ." >R TUCK C! R> ;

\ CHAR a letter-str TYPE \EOF
\ CHAR Z letter-str TYPE \EOF

\ Выдать область памяти (размером в три ячейки) из хэша для символа c
: POINTS@  ( c -- addr )
DUP letter-str POINTS HASH@R ?DUP 0= IF
/point SWAP letter-str POINTS HASH!R ELSE NIP THEN ;

\ Читаем строку addr u , пишем результат в хэш POINTS
: read-points ( addr u -- )
POINTS clear-hash
str-points=>
\ DEPTH . BACK DEPTH . KEY DROP TRACKING
DUP POINTS@ 2DUP name !
2>R 2DUP R> xy 2! R> ;

\ Загружаем псевдографику в файле с именем addr u и пишем результат в хэш POINTS
: load-points ( addr u -- ) load-file read-points ;

\ cur-point хранит адрес элемента точки в хэше, а не сами значения координат
0 VALUE cur-point \ текущая точка
0 VALUE first-point \ первая точка

\ Записываем индекс самой нижней точки в cur-point (если их несколько,
\ то это на расчёт не влияет -- берётся первая попавшаяся)
: find-max-y-cur-point ( -- )
0 TO cur-point 
points=>
cur-point 0=            IF DUP TO cur-point EXIT THEN
DUP y @ cur-point y @ > IF DUP TO cur-point THEN ;

: 4DUP ( d1 d2 -- d1 d2 d1 d2 ) 2OVER 2OVER ;

: coords ( addri addrj -- x1 y1 x2 y2 )
>R xy 2@ R> xy 2@ ;

\ Квадрант угла построенного между линией (x1,y1)-(x2,y2)
\ и осью x
: quadrant ( x1 y1 x2 y2 -- quadrant# )
ROT > IF > IF 3 ELSE 4 THEN ELSE > IF 2 ELSE 1 THEN THEN ;
\         ^ y      
\         |        
\    2    |   1    
\         |        
\ --------+--------> x
\         |        
\         |        
\    3    |   4    
\         |        

\ Берём угол построенный между линией (x1,y1)-(x2,y2)
\ и осью x (угол всегда будет меньше pi/2 [90 градусов])
\ На выходе -- значение угла на стеке float
: (get-angle0) ( x1 y1 x2 y2 -- D:    F: alpha )
4DUP D=           IF
2DROP 2DROP 0.e   ELSE \ если точки одинаковы, то угол=0
ROT
- S>D D>F  ( F: dy )
- S>D D>F  ( F: dy dx )
F/ FABS FATAN     THEN ;


\ Вычисляем угол между отрезками (0,0)-(x2-x1,y2-y1) и (0,0)-(infinity,0)
: (get-angle) ( x1 y1 x2 y2 -- D:    F: alpha )
4DUP (get-angle0) quadrant \ поправка с учётом квадранта угла
DUP 1 AND 0= IF FPI 2e F/ F- FNEGATE THEN \ разворачиваем на 90 градусов в 2 и 4-м квадрантах, угол полученный от (get-angle0)
1- S>D D>F FPI F* 2e F/ F+ \ добавляем уголы нужной границы квадранта
;

\ "Развернуть" угол
: flip-angle ( F: a -- F: 2Pi-a ) FPI 2e F* FSWAP F- ;

\ Угловое расстояние -- разница двух углов (абсолютное значение)
: angle-distance ( F: angle1 angle2 -- F: delta )
F- FABS \ абсолютная разница
FDUP FPI FSWAP F< IF flip-angle THEN \ если угол больше 180 градусов (pi), то нужно его "развернуть"
;

\ Вычисляем угол между (0,0)-(infinity,0) и (x1,y1)-(x2,y2),
\ где (x1,y1) -- координаты текущей точки (cur-point)
\ где (x2,y2) -- координаты точки обозначаемой через "индекс" 
\ на стеке -- адрес элемента хэша точек
: get-angle ( addrEl -- F: angle )
cur-point SWAP coords (get-angle) ;

\ "Желаемый" угол -- угол, направление в котором шло предыдущее ребро выпуклой оболочки
\ Угол между предыдущим и следующим ребром должен быть наиближайшим значением к 
\ "желаемому углу" (при переборе всех других точек кроме текущей)
0e FVALUE desired-angle

\ Разница (угловая) между "желаемым углом" и углом линии проведённой от
\ текущей точки до точки, "индекс" которой лежит на стеке
: get-proximity ( addrEl -- F: proximity ) get-angle desired-angle angle-distance ;

\ Кандидат на следующую точку ребра
0 VALUE candidate-point
\ Кандидат на "наиближайшесть" к "желаемому" угла ребра-кандидата 
\ (ищется минимальное значение этого параметра)
100e FVALUE candidate-proximity

\ При заданных текущей точке (cur-point) и "желаемом угле" (desired-angle)
\ определить такую точку, что угол ребра из cur-point в эту точку является
\ наиближайшим к desired-angle (уголовое расстояние минимально)
: next-in-hull ( -- D: addrEl F: angle )
100e FTO candidate-proximity \ ставится заведомо высокое значение
START{ points=>
DUP cur-point = ONFALSE

\ DUP name @ CR EMIT SPACE
DUP get-proximity \ FDUP F. KEY DROP

candidate-proximity
         FOVER FSWAP F< IF   \ ." %%%"
FTO candidate-proximity
DUP TO candidate-point  ELSE \ ." &&&"
FDROP                   THEN }EMERGE
candidate-point ;

\ Итератор, последовательно выдающий точки из выпуклой оболочки
: hull=> ( --> addrEl \ addrEl <-- )
PRO
find-max-y-cur-point
cur-point TO first-point \ определяем первую точку в оболочке
0.e FTO desired-angle \ "желаемый угол" от начала будет "направо"

BEGIN
cur-point CONT DROP \ генерируем успех с текущей точкой
\ cur-point name @ CR EMIT SPACE
\ desired-angle F. KEY DROP CR

next-in-hull \ высчитываем следующую точку оболочки
DUP get-angle FTO desired-angle \ угол нового ребра
DUP TO cur-point \ теперь это -- новая текущая точка
first-point = UNTIL \ повторять, пока не уткнёмся в первую точку
;

CREATE toFind 0. , ,
VARIABLE found

\ Найти такую точку, координаты которой равны (x,y)
\ Если точка не найдена, то результат =0
: findXY ( x y -- addrEl|0 )
toFind 2! found 0!
START{ points=>
DUP xy 2@ toFind 2@ D= ONTRUE
DUP found ! }EMERGE found @ ;

\ Находим максимальную координату x среди точек
: maxX ( -- maxX )
found 0!
START{ points=> \ hull=> \ можно сравнивать и координаты точек только из оболочки, это хоть и более правильно, но расточительно
DUP x @ found @ MAX found ! }EMERGE found @ ;


\ Находим максимальную координату y среди точек
: maxY ( -- maxY )
found 0!
START{ points=>
DUP y @ found @ MAX found ! }EMERGE found @ ;

\ Случайно расставить точки по доске 40x30
: generate-points ( n -- )
POINTS clear-hash
RANDOMIZE
[CHAR] A TUCK + SWAP DO

0. BEGIN 2DROP
40 CHOOSE 30 CHOOSE
2DUP findXY 0= UNTIL \ удостоверяемся что сгенерированная точка не занята
( x y ) \ CR 2DUP . .
I POINTS@ xy 2! \ записываем координаты
I I POINTS@ name ! \ записываем имя
LOOP ;

\ Показать "доску"
: show-board
maxY 1+ 0 DO CR
maxX 1+ 0 DO
I J findXY ( addrEl )
?DUP 0= IF [CHAR] . ELSE name @ THEN EMIT
LOOP LOOP ;

\ Распечатать точки из выпуклой оболочки
: print-hull ." [ " BACK ."  ]" TRACKING hull=> DUP name @ EMIT ;

 ( отладочные строки, если эту строчку закоментировать, то они откроются

"
.........................................................................
.....................................c...................................
.........................................................................
..........a..............................................................
.........................................................................
...........................e.........................................f...
.....................................................l...................
.........................................................................
..................................i......................................
.........................................................................
.........................................................................
.................b.......................................................
.........................................................................
.........................................................................
..............r...................j.................k....................
.........................................................................
.........................................................................
.........................................................................
.........................................................................
.........................................................................
.........................................................................
..........d.............................................................g
.................................h.......................................
.........................................................................
.........................................................................
.........................................................................
...........................................m.............................
..................................q......................................
.........................................................................
.............................................z..........................."
STR@ read-points


show-board
find-max-y-cur-point

CR
S" cur point: " CR TYPE cur-point xy 2@ . . KEY DROP \ z

: point CHAR POINTS@ ;

CR
point j  point f coords quadrant . \ 1
point j  point e coords quadrant . \ 2
point j  point d coords quadrant . \ 3
point j  point m coords quadrant . \ 4
KEY DROP

CR 
point c xy 2@ . .
point c TO cur-point
point a get-angle F.
KEY DROP

point j TO cur-point

0.e FTO desired-angle

CR point k get-proximity F. S" 0" TYPE
CR point l get-proximity F.
CR point i get-proximity F. S" pi/2" TYPE
CR point e get-proximity F.
CR point a get-proximity F.
CR point b get-proximity F. 
CR point r get-proximity F. S" pi, max angle distance from 0 radians" TYPE
CR point d get-proximity F.
CR point q get-proximity F. S" pi/2" TYPE
CR point m get-proximity F.
KEY DROP

\EOF
\ )

\ На выбор: или загрузка точек из файла, либо случайная генерация
\ S" hull.txt" load-points show-board CR print-hull (
26 generate-points show-board CR print-hull \ )