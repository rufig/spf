\ Слова:
\ seq{ ... }seq (генерация списка-итератора с последовательным доступом)
\ и
\ arr{ ... }arr (генерация массива)

\ {#} ( list-xt -- u ) выдаёт длину списка-итератора.

\ {seq} ( -- list-xt ) выдача промежуточного списка, генерируемого в данный 
\ момент.

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
\ итератор, брать их пересечение и т.д. (см. слова union , cross ).

\ Следует понимать что эти генерируемые итераторы не являются полноценными
\ структурами данных, так как позволяют только последовательный доступ к данным
\ не говоря уже о невозможности менять их значения.

\ Как вариант, можно использовать их как промежуточный этап, после получения
\ такого итератора можно получив кол-во занесённых в него элементов, брать 
\ из памяти сплошной участок кода. Так работает arr{ ... }arr который
\ снимает проблемы списков-итераторов.

\ arr{ ... }arr оставляет на стеке адрес начала массива и его длину (в байтах).
\ Массив сгенерирован из верхних значений остающихся на стеке после каждого 
\ успеха итераторов между скобками. При откате этот массив снимается.

\ Как внутри seq{ }seq так и внутри arr{ }arr работает слово {seq} которое
\ выдаёт промежуточное значение формируемого списка. {seq} всегда выдаёт
\ список-итератор (внутри arr{ }arr -- тоже).

\ TODO: На данный момент реализация {seq} позволяет использовать его
\ только непосредственно внутри скобок arr/seq, пока не допуская
\ вкладывания его в другие структуры.

\ {seq} {#} будет выдавать текущий номер итерации, считая от нуля.

\ REQUIRE MemReport ~day/lib/memreport.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE __ ~profit/lib/cellfield.f
REQUIRE writeCell ~profit/lib/fetchWrite.f
REQUIRE (: ~yz/lib/inline.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE CREATE-VC ~profit/lib/compile2Heap.f
REQUIRE FREEB ~profit/lib/bac4th-mem.f

MODULE: bac4th-sequence

: RET,-1ALLOT  0xC3 DP @ C! ; \ установка шлагбаума для кода, чтобы не лез куда не надо
\ шлагбаум "автоматически" сломается при попытке преодолеть его (читай: компиляции)

0
1 -- rlit
__ handle  \ поле виртуального кодофайла (он одновременно представляет собой и исполняемый адрес)
1 -- ret
__ALIGN
__ counter \ счётчик кол-ва введённых ячеек
CONSTANT seq-struct \ дополнительная структура

:NONAME
seq-struct ALLOCATE THROW >R
CREATE-VC
START{ DUP VC- RET,-1ALLOT }EMERGE
R@ handle ! R@ counter 0!
0x68 R@ rlit C!  0xC3 R@ ret C!
R> ; CONSTANT (seq{) \ процедура инициализации seq{


:NONAME
PRO LOCAL t @ t !
['] RDROP
t @ handle @ VC-COMPILE,
t @ handle @ VC-RET, \ закрываем итератор
t @ CONT \ делаем нырок
t @ handle @ DESTROY-VC
t @ FREE THROW \ снимаем и дополнительную структуру
; CONSTANT (}seq) \ процедура успеха }seq

EXPORT

\ Общая открывающая скобка для генерации всех видов списков-итераторов
: seq{ ( -- ) ?COMP (seq{) COMPILE, agg{ ; IMMEDIATE

\ Закрывающая скобка для генерации списков-итераторов одинарных значений
: }seq ( n -- list-xt ) ?COMP (: @
DUP counter 1+!
handle @ VC-
DUP LIT,
R@ENTER, POSTPONE DROP
RET,-1ALLOT ;) (}seq) }agg ; IMMEDIATE

\ Закрывающая скобка для двойных значений
: }seq2 ( n -- list-xt ) ?COMP (: @
DUP counter 1+!
handle @ VC-
2DUP DLIT,
R@ENTER, POSTPONE 2DROP
RET,-1ALLOT ;) (}seq) }agg ; IMMEDIATE

\ Закрывающая скобка для тройных значений
: }seq3 ( n -- list-xt ) ?COMP (: @
DUP counter 1+!
handle @ VC-
ROT DUP LIT, -ROT 2DUP DLIT,
R@ENTER, POSTPONE 2DROP POSTPONE DROP
RET,-1ALLOT ;) (}seq) }agg ; IMMEDIATE

\ Закрывающая скобка для квартетов значений
: }seq4 ( n -- list-xt ) ?COMP (: @
DUP counter 1+!
handle @ VC-
2OVER DLIT, 2DUP DLIT,
R@ENTER, POSTPONE 2DROP POSTPONE 2DROP
RET,-1ALLOT ;) (}seq) }agg ; IMMEDIATE

: {seq} ( -- list-xt ) ?COMP (: ;) {agg} ; IMMEDIATE

: {#} ( list-xt -- u ) counter @ ;

\ Перенос значений списка-итератора в последовательный массив в памяти
: seq>arr ( list-xt -- addr u ) LOCAL arr LOCAL runner
DUP {#} CELLS ALLOCATE THROW DUP arr ! runner !
START{ ( list-xt ) ENTER
DUP runner writeCell }EMERGE
arr @ runner @ OVER - ;

: arr{
(: 2 CELLS ALLOCATE THROW ;) COMPILE,
agg{
[COMPILE] seq{
; IMMEDIATE

: }arr
[COMPILE] }seq
(: @ SWAP seq>arr ROT 2! ;)
(: PRO @ DUP 2@ ROT FREE THROW SWAP FREEB SWAP CONT ;)
}agg ; IMMEDIATE

;MODULE

/TEST
: INTSTO PRO 0 DO I CONT DROP LOOP ;
: INTSFROMTO PRO SWAP 1+ SWAP DO I CONT DROP LOOP ;

: list. ( list-xt -- ) ENTER DUP . ;

: list-xt-generated seq{ 5 INTSTO }seq ( list-xt ) DUP {#} ." length: " . CR ." execute:" list. ;
$> list-xt-generated

: intermediate seq{ 5 INTSTO  CR {seq} list.  }seq ( xt ) ENTER ;
$> intermediate

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

: number= ( a b -- a b f ) 2DUP = ;

: union PRO *> a <*> b <* CONT ; \ Объединение (скорее -- конкатенация)
: cross PRO a b number= ONTRUE CONT ; \ Пересечение
: subtr PRO a S| NOT: b number= ONTRUE -NOT CONT ; \ Вычитание? (забыл как правильно)

: 4ops
START{ CR ." a="   a     DUP . }EMERGE
START{ CR ." b="   b     DUP . }EMERGE
START{ CR ." a+b=" union DUP . }EMERGE
START{ CR ." axb=" cross DUP . }EMERGE
START{ CR ." a-b=" subtr DUP . }EMERGE ;
CR $> 4ops

 \ Объединение, но теперь можно задавать аргументы, говоря какие множества надо объединять 
: union ( a b -- a+b ) PRO LOCAL b b ! LOCAL a a !
 *> a @ ENTER
<*> b @ ENTER
<*  CONT ;

: cross ( a b f -- axb ) PRO LOCAL f f ! LOCAL b b ! LOCAL a a !
a @ ENTER b @ ENTER f @ ENTER ONTRUE CONT ;
\ Операцию сравнения двух значений выносим в аргумент тоже, причём со стеком 
\ пусть она сама разбирается: f ( ... -- 0|-1 )
: cross-number ( a b -- axb ) PRO ['] number=  cross CONT ;

: not-in ( a b f --> \ <-- ) PRO LOCAL f f ! LOCAL b b !
S| NOT: b @ ENTER f @ ENTER ONTRUE -NOT CONT ;

: subtr ( a b f -- a-b ) PRO LOCAL f f ! LOCAL b b !
ENTER b @ f @ not-in CONT ;

: subtr-number PRO ['] number= subtr CONT ;

: head ( a -- ... ) CUT: ENTER -CUT ;
: tail ( a -- ... a' ) CUT: ENTER R@ -CUT ;

: seq4ops LOCAL 0..4 LOCAL 2..5

seq{ 4 INTSTO }seq 0..4 ! \ от 0 до 4-х
seq{ 5 2 INTSFROMTO }seq 2..5 ! \ "от двух до пяти" (с)

CR ." [0..4]=" 0..4 @ list.
CR ." [2..5]=" 2..5 @ list.

CR ." head[0..4]=" 0..4 @ head . \ выводим только одно, первое значение
CR ." tail[0..4]=" 0..4 @ tail list.

START{
seq{ 0..4 @  2..5 @ union }seq
CR ." [0..4]+[2..5]="
list. }EMERGE

START{
seq{ 0..4 @  2..5 @ cross-number }seq
CR ." [0..4]x[2..5]="
list. }EMERGE

START{ seq{ 0..4 @  2..5 @ subtr-number }seq
CR ." [0..4]-[2..5]=" ENTER DUP . }EMERGE

START{ seq{
seq{ 0..4 @  2..5 @ cross-number }seq
seq{ 0..4 @  2..5 @ subtr-number }seq
union }seq
CR ." [0..4]x[2..5] + [0..4]-[2..5]=" list. }EMERGE ;
$> seq4ops

REQUIRE split-patch ~profit/lib/bac4th-str.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f

:NONAME ( d1 d2 -- d1 d2 f ) 2OVER 2OVER COMPARE-U 0= ; CONSTANT str=

: cross-str PRO str= cross CONT ;

: commonWord ( addr1 u1 addr2 u2 -- )
seq{ BL byChar split-patch }seq2 ( list-xt1 ) -ROT
seq{ BL byChar split-patch }seq2 ( list-xt1 list-xt2 )
cross-str 2DUP TYPE SPACE ;

CR $> S" peach cherry lemon kiwi feyhoa" S" kiwi apple lemon orange" commonWord
\ должно выйти: kiwi lemon
: dump-arr arr{ a }arr DUMP ;
CR $> dump-arr

: uniq  POSTPONE {seq} POSTPONE SWAP POSTPONE not-in ; IMMEDIATE

: uniqueSeq seq{
BL byChar split-patch \ делим на слова-отрезки
str= uniq
}seq2 ENTER 2DUP CR TYPE ;

$> S" kiwi apple lemon apple lemon kiwi orange" uniqueSeq
\ MemReport

REQUIRE iterateBy ~profit/lib/bac4th-iterators.f

: TAKE-TWO PRO *> <*> BSWAP <* CONT ;

: arr-test arr{
BL byChar split-patch \ делим на слова-отрезки
( addr u )
TAKE-TWO          \ "удвоение" успехов, то есть: посылаем }arr оба числа на стеке
}arr
( addr u )   \ теперь у нас массив двойных значений
2 CELLS iterateBy \ делаем по нему проход, прыгая по две ячейки зараз
DUP 2@ CR TYPE ;

CR $> S" ac day mlg pinka profit" arr-test