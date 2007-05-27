REQUIRE /TEST ~profit/lib/testing.f
REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE NOT ~profit/lib/logic.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE fetchCell ~profit/lib/fetchwrite.f
REQUIRE iterateBy ~profit/lib/bac4th-iterators.f
REQUIRE arr{ ~profit/lib/bac4th-sequence.f

\ Перебор комбинации addr u (удобно для организации перебора в ширину)
\ Нужно только сделать соответствие числу A[i] (0..max[i]) из комбинации,
\ альтернативе возникающей на i-м ходу, при том что всего на i-м ходу 
\ кол-во альтернатив равно max[i]

\ addr u -- массив 32-битных значений
\ max -- массив с такой же длиной и ячейками
\ Каждой ячейке массива addr u соответствует ячейка массива max u
\ max определяет максимальные значения в каждом "разряде"-ячейке

\ Генерация каждой новой комбинации происходит так:
\ Нулевая ячейка увеличивается в значении. Если значение стало больше
\ соотв-щего значения max, то оно присваивается нулю и делается переход 
\ к следующей ячейке. Если значение ячейки меньше чем max то генерация
\ новой комбинации закончена.

\ increment сразу генерирует _все_ возможные комбинации для заданных addr u max
\ Чтобы его останавливать используйте S| CUT: ... -CUT (см. пример)
\ u1 -- текущая длина комбинации, то есть "разрядность" которая по мере генерации 
\ новых комбинаций растёт, пока не упирается в u
: incrementMinMax ( addr u max --> addr u1 \ <-- addr u1 ) PRO 2DROPB
LOCAL max  max !
LOCAL lastDigit OVER lastDigit !

BEGIN
OVER lastDigit @ OVER - CELL+ CONT 2DROP
START{ max KEEP
S| CUT:
2DUP CELL iterateBy DUP 1+!
DUP lastDigit !
DUP @ max fetchCell = DUP IF OVER 0! THEN ONFALSE
-CUT }EMERGE AGAIN ;


\ Обёртка для более простого вызова, в том случае если для всех разрядов
\ min и max постоянны
: increment ( addr u maxConst --> addr u1 \ <-- addr u1 ) PRO
LOCAL max  max !
arr{ DUP  times max @ DROPB }arr DROP ( addr u min )
incrementMinMax CONT ;

/TEST

HERE 10 CELLS DUP ALLOT
: combination LITERAL LITERAL SWAP ;
combination ERASE

:NONAME
START{
S| CUT: combination 5 ( addr u max )
increment ( addr u ) \ addr u -- текущая комбинация, u -- текущая длина
2DUP DUMP
DUP 2 CELLS = ONTRUE     \ если длина комбинации достигла уже 2 "разрядов"
OVER CELL+ @ 4 = ONTRUE  \ и если второй разряд равен "4", то...
-CUT                     \ отсекаем, т.е. прекращаем дальнейшую генерацию
}EMERGE
; EXECUTE