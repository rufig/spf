\ К конкурсу решения задач на форте (http://fforum.winglion.ru/viewtopic.php?p=7491#7491)

\ Задача о шести шахматных конях

\ Для запуска нужен дистрибутив SPF:
\ http://sourceforge.net/project/showfiles.php?group_id=17919

\ И апрельское обновление:
\ http://sourceforge.net/project/shownotes.php?release_id=497972&group_id=17919


REQUIRE HEAP-COPY ~ac/lib/ns/heap-copy.f
REQUIRE (:    ~yz/lib/inline.f
REQUIRE PRO   ~profit/lib/bac4th.f
REQUIRE __    ~profit/lib/cellfield.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE ENUM  ~nn/lib/enum.f
REQUIRE seq{  ~profit/lib/bac4th-sequence.f
REQUIRE NOT   ~profit/lib/logic.f
REQUIRE iterateByCellValues ~profit/lib/bac4th-iterators.f
REQUIRE list+ ~pinka\lib\list.f


3 CONSTANT W \ ширина поля
4 CONSTANT H \ высота поля

50 CONSTANT MAX-MOVES \ максимальное кол-во ходов в переборе

: list=> ( list --> value \ <-- ) R> SWAP List-ForEach ; \ итератор по списку

\ Структура списка
0
__ board-link
__ board-addr
__ board-moves
CONSTANT board-elem

\ Откатываемое двойное присваивание
: 2KEEP! ( d addr --> \ <-- ) PRO SWAP OVER KEEP! CELL+ KEEP! CONT ;

 \ массив который хранит указатели на представление позиций для ходов
CREATE LAST-BOARDS MAX-MOVES CELLS ALLOT

W CONSTANT HORSES \ сколько коней у белых и у чёрных

CREATE STABLES \ значения текущих положений
HORSES 2 CELLS * ALLOT \ white horses
HORSES 2 CELLS * ALLOT \ black horses

: HORSE ( i -- x y ) 2 CELLS * STABLES + ;
: WHITE ( i -- i )  ;
: BLACK ( i -- i' ) HORSES + ;

: WHITE-HORSES ( --> i \ <-- i ) PRO \ белые лошадки
HORSES 0 DO I WHITE CONT DROP LOOP ;

: BLACK-HORSES ( --> i \ <-- i ) PRO \ чёрные лошадки
HORSES 0 DO I BLACK CONT DROP LOOP ;

: WCOORD (  --> x  \  <-- x )  PRO W 1+ 1 DO  I CONT DROP  LOOP ; \ пробег по горизонтали
: HCOORD (  --> y  \  <-- y )  PRO H 1+ 1 DO  I CONT DROP  LOOP ; \ пробег по вертикали

: BOARD ( --> y x \ <-- y x ) PRO HCOORD WCOORD CONT ; \ пробег по всей доске
\ требует "чистого" стека у WCOORD и HCOORD чтобы выдавать два числа

\ фильтр, пропускает только те значения координат которые могут составлять ход конём
: ?HORSE-MOVE ( x1 y1 y2 x2 <--> x1 y1 y2 x2 ) PRO
2OVER 2OVER
ROT - ABS  -ROT - ABS
*> 2RESTB <*> SWAP <*   1 2 D= ONTRUE CONT ;

\ генерировать все возможные ходы конём из координат x y
: HORSE-MOVES ( x y --> u v \ <-- u v ) PRO 2DROPB WCOORD HCOORD ( x y ) ?HORSE-MOVE CONT ;

\ занято белой лошадкой?
: ?IS-WHITE-HERE ( x y --> x y \ <-- x y ) PRO
LOCAL x  LOCAL y
2DUP y ! x !
S| CUT: WHITE-HORSES DUP HORSE 2@ x @ y @ D= ONTRUE -CUT CONT ;

\ занято чёрной лошадкой?
: ?IS-BLACK-HERE ( x y --> x y \ <-- x y ) PRO
LOCAL x  LOCAL y
2DUP y ! x ! 
S| CUT: BLACK-HORSES DUP HORSE 2@ x @ y @ D= ONTRUE -CUT CONT ;

\ занято ли вообще?
: ?CAN-MOVE-HERE ( x y --> x y \ <-- x y ) PRO S|
NOT: ?IS-WHITE-HERE -NOT \ НЕТ БЕЛЫХ лошадок в позиции x y
                         \ И
NOT: ?IS-BLACK-HERE -NOT \ НЕТ ЧЁРНЫХ лошадок в позиции x y
CONT ;

\ атаковано белым конём?
: ?IS-ATTACKED-BY-WHITE ( x y --> x y \ <-- x y ) PRO
LOCAL x  LOCAL y
2DUP y ! x !
S| CUT: WHITE-HORSES DUP HORSE 2@ x @ y @ 2DROPB ?HORSE-MOVE -CUT CONT ;

\ атаковано чёрным конём?
: ?IS-ATTACKED-BY-BLACK ( x y --> x y \ <-- x y ) PRO
LOCAL x  LOCAL y
2DUP y ! x !
S| CUT: BLACK-HORSES DUP HORSE 2@ x @ y @ 2DROPB ?HORSE-MOVE -CUT CONT ;

\ белый конь может пойти туда?
: ?CAN-WHITE-MOVE-HERE PRO
?CAN-MOVE-HERE
S| NOT: ?IS-ATTACKED-BY-BLACK -NOT CONT ;

\ чёрный конь может пойти туда?
: ?CAN-BLACK-MOVE-HERE PRO
?CAN-MOVE-HERE
S| NOT: ?IS-ATTACKED-BY-WHITE -NOT CONT ;

\ двинуть белого коня под номером i
: MOVE-WHITE-HORSE ( i --> \ <-- i ) PRO LOCAL h DUP
HORSE DUP h ! 2@ HORSE-MOVES ( x y )
?CAN-WHITE-MOVE-HERE  2DUP h @ 2KEEP! CONT ;

\ двинуть чёрного коня под номером i
: MOVE-BLACK-HORSE ( i --> \ <-- i ) PRO LOCAL h DUP
HORSE DUP h ! 2@ HORSE-MOVES ( x y )
?CAN-BLACK-MOVE-HERE  2DUP h @ 2KEEP! CONT ;

\ расставить коней по начальным стойлам
: INIT-POS
LOCAL i

i 0!
START{
WHITE-HORSES
i 1+! i @ OVER 1 SWAP HORSE 2!
}EMERGE

i 0!
START{
BLACK-HORSES
i 1+! i @ OVER H SWAP HORSE 2!
}EMERGE ;

 \ выдать участок памяти куда записано представление текущей позиции доски
: DRAW-BOARD  ( --> addr u \ <-- )
PRO arr{ \ начинаем генерировать массив
BOARD ( y x ) 2DUP 2DROPB SWAP
S| PREDICATE ?IS-WHITE-HERE SUCCEEDS \ если белая лошадка
IF [CHAR] @ ELSE
S| PREDICATE ?IS-BLACK-HERE SUCCEEDS \ если чёрная лошадка
IF [CHAR] # ELSE
   BL       THEN THEN                \ если нету ничего
}arr CONT ;

: PRINT-BOARD ( addr u -- ) \ распечатать представление позиции доски

(: CR ."    " WCOORD DUP . SPACE ;)
BACK EXECUTE TRACKING RESTB EXECUTE
(: CR ."   -" WCOORD ." ---" ;)
BACK EXECUTE TRACKING RESTB EXECUTE

LOCAL i  i 0!
CELL / iterateByCellValues
i @ W /MOD SWAP 0= IF CR [CHAR] A + EMIT ."  |" ELSE DROP THEN
i 1+! DUP EMIT ."  |" ;

: SHOW-BOARD ( -- ) DRAW-BOARD PRINT-BOARD ;

INIT-POS ( 1 c   1 BLACK HORSE 2! ) \ SHOW-BOARD \EOF
\ DRAW-BOARD DUMP

\ Эти 2 определения равнозначны

: ?ARE-WE-DONE-YET ( -- f ) \ суммирующее определение
&{ BLACK-HORSES DUP HORSE 2@ ( x y ) NIP 1 = }& \ AND(y(все чёрные лошадки)=1)
&{ WHITE-HORSES DUP HORSE 2@ ( x y ) NIP H = }& \ AND(y(все белые  лошадки)=h)
AND ;

: ?ARE-WE-DONE-YET ( -- f ) PREDICATE \ определение квантором отрицания
S| NOT: BLACK-HORSES DUP HORSE 2@ ( x y ) NIP 1 = ONFALSE -NOT \ НЕТ таких БЕЛЫХ  ЛОШАДОК у которых игрек НЕ РАВЕН 1
S| NOT: WHITE-HORSES DUP HORSE 2@ ( x y ) NIP H = ONFALSE -NOT \ НЕТ таких ЧЁРНЫХ ЛОШАДОК у которых игрек НЕ РАВЕН H
SUCCEEDS ;

: ?ODD ( n -- f )  1 AND ;

:NONAME

LOCAL moves \ переменная хода

LOCAL cur-board
LOCAL cur-board#

LOCAL boards \ список позиций
boards 0!

LOCAL i

moves 0!

START{ \ главный цикл перебора
BEGIN
boards @ \ старое значение списка сохраняем

START{ \ цикл определения уникальности позиции
DRAW-BOARD cur-board# ! cur-board !
S| NOT:
boards list=> DROPB \ цикл по списку позиций
DUP board-moves @ ?ODD moves @ ?ODD = ONTRUE \ 
DUP board-moves @ moves @ > ONFALSE \ только среди позиций возникших в ранних ходах
DUP board-addr @ cur-board# @ cur-board @ cur-board# @ COMPARE 0= ONTRUE \ сравниваем позиции на равенство
-NOT \ нет позиций в списке, совпадающих с текущей
\ это значит что позиция уникальна, и надо

\ записывать новый элемент списка
board-elem ALLOCATE THROW >R \ создали элемент
cur-board @ cur-board# @ HEAP-COPY \ DRAW-BOARD снимает "свой" участок памяти из кучи, поэтому копируем явно
DUP R@ board-addr ! \ записываем в поле доску
moves @ CELLS LAST-BOARDS + ! \ также копию текущей доски пишем в историю текущего решения
moves @ R@ board-moves ! \ записываем текущий ход
R> boards list+

}EMERGE

boards @ = ONFALSE \ новая ли позиция? Определяется по изменению списка boards

?ARE-WE-DONE-YET IF \ сложилась ли у нас нужная позиция на доске?
CR CR DEPTH ." S: " . ."  R: " RP@ R0 @ - ABS CELL / . \ интересу ради печатаем глубину стеков
START{ i 0! \ начинаем цикл печати позиций этого решения
LAST-BOARDS moves @ iterateByCellValues DUP cur-board# @
CR CR i 1+! ." Move:" i @ . PRINT-BOARD }EMERGE
THEN

moves @ ?ODD                  IF
WHITE-HORSES MOVE-WHITE-HORSE ELSE \ чётное значение "хода" -- ходят белые
BLACK-HORSES MOVE-BLACK-HORSE THEN \ нечётное -- чёрные
moves KEEP moves 1+! \ переменную хода увеличиваем (KEEP её откатывает)

moves @ MAX-MOVES > ONFALSE \ ограничиваем перебор максимальной глубиной
AGAIN \ идти до упора -- пока весь перебор не исчерпает себя
}EMERGE

CR ." Maximum move: " MAX-MOVES .
CR ." Positions processed: "

+{ boards list=> FREE THROW  1 }+ .
; STARTLOG EXECUTE