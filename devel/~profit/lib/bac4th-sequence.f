\ Слова:
\ seq{ ... }seq
\ и
\ arr{ ... }arr


\ seq{ ... }seq оставляет на стеке xt -- адрес участка кода, который генерирует
\ те же значения что и итераторы между скобками seq{ ... }seq
\ То есть, результат вычисления итератора как бы копируется, "затвердевает"
\ в другом, выходном скомпилированном итераторе.

\ Это должно, по идее, решать несколько проблем:

\ При достаточно сложном подсчёте итератора второй (n-й) раз его вызывать
\ для получения тех же данных не резон, лучше записать полученные в первый
\ раз значения в какую-нибудь структуру. Скомпилированный итератор, по сути,
\ и будет такой промежуточной структурой. Только исполняемой стуктурой, в 
\ виде участка кода.

\ Опять же, если итератор более-менее сложный то в процессе промежуточных
\ вычислений стек итератора может принимать произвольную глубину. Пример:
\ 1 iterator ( 1 ... x )
\ Даже если мы знаем что iterator отправляет на успех только одно значение
\ на стеке могут быть ещё также быть промежуточные значения вычислений 
\ итератора, и достать единицу в примере не полагаясь на внутренние
\ детали реализации iterator , мы не можем.
\ В случае же копирования итератора никаких промежуточных значений на стеке
\ не будет так как скомпилированный итератор будет отправлять на успех только
\ сохранённые результаты подсчёта.

\ Кроме того, над полученными таким образом итераторами становится возможно
\ выполнять некие действия, например объединять их значения в один список-
\ итератор, брать их пересечение и т.д. (см. слова union , cross )

\ Следует понимать что эти генерируемые итераторы не являются полноценными
\ структурами данных, так как позволяют только последовательный доступ к данным.
\ Как вариант, можно использовать их как промежуточный этап, после получения
\ такого итератора можно получив кол-во занесённых в него элементов, можно
\ брать из памяти сплошной участок кода. Так работает arr{ ... }arr

\ arr{ ... }arr оставляет на стеке адрес начала массива и его длину.
\ Массив сгенерирован из верхних значений остающихся на стеке после 
\ каждого успеха итераторов между скобками. При откате этот массив
\ снимается.

\ REQUIRE MemReport ~day/lib/memreport.f
REQUIRE (: ~yz/lib/inline.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE FREEB ~profit/lib/bac4th-mem.f
REQUIRE CREATE-VC ~profit/lib/compile2Heap.f

MODULE: bac4th-sequence

:NONAME PRO LOCAL t
@ t !
\ ['] RDROP t @ VC-COMPILE,  t @ VC-RET, ( \ или так,
START{ t @ VC- POSTPONE RDROP RET, }EMERGE \ или так )
t @ XT-VC CONT
t @ DESTROY-VC
;
CONSTANT (}seq) \ процедура успеха }seq

EXPORT

: seq{ ( -- ) ?COMP POSTPONE CREATE-VC agg{ ; IMMEDIATE

: }seq ( n -- xt ) ?COMP (: @ VC-
DUP LIT,
R@ENTER, POSTPONE DROP ;) (}seq) }agg ; IMMEDIATE

: }seq2 ( n -- xt ) ?COMP (: @ VC-
2DUP DLIT,
R@ENTER, POSTPONE 2DROP ;) (}seq) }agg ; IMMEDIATE

: }seq3 ( n -- xt ) ?COMP (: @ VC-
ROT DUP LIT, -ROT 2DUP DLIT,
R@ENTER, POSTPONE 2DROP POSTPONE DROP ;) (}seq) }agg ; IMMEDIATE

: }seq4 ( n -- xt ) ?COMP (: @ VC-
2OVER DLIT, 2DUP DLIT,
R@ENTER, POSTPONE 2DROP POSTPONE 2DROP ;) (}seq) }agg ; IMMEDIATE

DEFINITIONS

: __ CELL -- ;

0
__ handle  \ поле виртуального кодофайла
__ counter \ счётчик кол-ва введённых ячеек
CONSTANT arr-struct \ дополнительная структура


:NONAME PRO LOCAL t LOCAL array LOCAL runner
@ t !

START{ t @ handle @ VC- POSTPONE RDROP RET, }EMERGE

t @ counter @ \ теперь мы знаем длину данных
CELLS ALLOCATE THROW DUP array ! \ берём под них цельный массив
runner ! \ ставим бегунок на начало массива

START{
t @ handle @ XT-VC ENTER \ выполняем готовый итератор
DUP runner @ ! CELL runner +! \ переносим по одному данные из итератора в массив
}EMERGE

t @ handle @ DESTROY-VC \ итератор после выполнения и переноса его данных в массив больше не нужен
array @  t @ counter @ CELLS ( addr u )

t @ FREE THROW \ снимаем и дополнительную структуру
( addr u ) CONT \ делаем нырок
array @ FREE THROW \ освобождаем сгенерированный массив
;
CONSTANT (}arr) \ процедура успеха }arr

EXPORT

: arr{ ( -- ) ?COMP
(: arr-struct ALLOCATE THROW >R CREATE-VC R@ handle ! R@ counter 0! R> ;) \ инициализация доп. структуры
\ INLINE, ( \ или так, то есть применением INLINE, как структурного POSTPONE
COMPILE,  \ или так, что более надёжно, и не конфликтует с MemReport (???) )
agg{ ; IMMEDIATE

: }arr ( n -- xt ) ?COMP (: @ DUP counter 1+!
handle @ VC-
DUP LIT,
R@ENTER, POSTPONE DROP ;) (}arr) }agg ; IMMEDIATE

;MODULE


\EOF
: INTSTO PRO 0 DO I CONT DROP LOOP ;
: INTSFROMTO PRO SWAP 1+ SWAP DO I CONT DROP LOOP ;

REQUIRE SEE lib/ext/disasm.f
: r seq{ 10 INTSTO }seq ( xt ) ." generated code:" DUP REST CR ." execute:" ENTER DUP . ;


: a PRO \ Список чисел
1 CONT DROP
2 CONT DROP
4 CONT DROP
5 CONT DROP
3 CONT DROP ;

: b PRO \ Ещё один список чисел
7 CONT DROP
4 CONT DROP 
6 CONT DROP ;

: union PRO *> a <*> b <* CONT ; \ Объединение (скорее -- конкатенация)
: cross PRO a b 2DUP = ONTRUE CONT ; \ Пересечение
: subtr PRO a S| NOT: b 2DUP = ONTRUE -NOT CONT ; \ Вычитание? (забыл как правильно)

: 4ops
START{ CR ." a="   a     DUP . }EMERGE
START{ CR ." b="   b     DUP . }EMERGE
START{ CR ." a+b=" union DUP . }EMERGE
START{ CR ." axb=" cross DUP . }EMERGE
START{ CR ." a-b=" subtr DUP . }EMERGE ;
4ops CR

 \ Объединение, но теперь можно задавать аргументы, говоря какие множества надо объединять 
: union ( a b -- a+b ) PRO LOCAL b b ! LOCAL a a !
 *> a @ ENTER
<*> b @ ENTER
<*  CONT ;

: cross ( a b f -- axb ) PRO LOCAL f f ! LOCAL b b ! LOCAL a a !
a @ ENTER b @ ENTER f @ ENTER ONTRUE CONT ;
\ Операцию сравнения двух значений выносим в аргумент тоже, причём со стеком 
\ пусть она сама разбирается: f ( ... -- 0|-1 )
: cross-number ( a b -- axb ) PRO (: 2DUP = ;) cross CONT ;

: subtr ( a b f -- a-b ) PRO LOCAL f f ! LOCAL b b ! LOCAL a a !
a @ ENTER
S| NOT: b @ ENTER f @ ENTER ONTRUE -NOT CONT ;
: subtr-number PRO (: 2DUP = ;) subtr CONT ;

: head ( a -- ... ) CUT: ENTER -CUT ;
: tail ( a -- ... a' ) CUT: ENTER R@ -CUT ;

: seq4ops LOCAL 0..4 LOCAL 2..5

seq{ 4 INTSTO }seq 0..4 ! \ от 0 до 4-х
seq{ 5 2 INTSFROMTO }seq 2..5 ! \ "от двух до пяти" (с)

CR ." [0..4]=" START{ 0..4 @ ENTER DUP . }EMERGE
CR ." [2..5]=" START{ 2..5 @ ENTER DUP . }EMERGE

CR ." head[0..4]=" 0..4 @ head . \ выводим только одно, первое значение
CR ." tail[0..4]=" 0..4 @ tail START{ ENTER DUP . }EMERGE

START{
seq{ 0..4 @  2..5 @ union }seq
CR ." [0..4]+[2..5]="
ENTER DUP . }EMERGE

START{
seq{ 0..4 @  2..5 @ cross-number }seq
CR ." [0..4]x[2..5]="
ENTER DUP . }EMERGE

START{ seq{ 0..4 @  2..5 @ subtr-number }seq
CR ." [0..4]-[2..5]=" ENTER DUP . }EMERGE

START{ seq{
seq{ 0..4 @  2..5 @ cross-number }seq
seq{ 0..4 @  2..5 @ subtr-number }seq
union }seq
CR ." [0..4]x[2..5] + [0..4]-[2..5]=" ENTER DUP . }EMERGE ;
seq4ops


REQUIRE split-patch ~profit/lib/bac4th-str.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f

: cross-str PRO (: 2OVER 2OVER COMPARE-U 0= ;) cross CONT ;

: commonWord
seq{ S" kiwi apple lemon orange"
BL byChar split-patch }seq2 ( list-xt1 )
seq{ S" peach cherry lemon kiwi feyhoa"
BL byChar split-patch }seq2 ( list-xt1 list-xt2 )
cross-str 2DUP TYPE SPACE ;

CR commonWord
\ должно выйти: kiwi lemon 

: arr1 arr{ a }arr DUMP ;
arr1

REQUIRE iterateBy ~profit/lib/bac4th-iterators.f

: arr2 arr{
S" ac day mlg pinka profit" BL byChar split-patch \ делим на слова-отрезки
( addr u )
*> <*> BSWAP <*   \ "удвоение" успехов, то есть: посылаем }arr оба числа на стеке
}arr ( addr u )   \ теперь у нас массив двойных значений
2 CELLS iterateBy \ делаем по нему проход, прыгая по две ячейки зараз
DUP 2@ CR TYPE ;
arr2
\ MemReport