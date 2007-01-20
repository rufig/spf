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
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE writeCell ~profit/lib/fetchWrite.f 
REQUIRE (: ~yz/lib/inline.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE BALLOCATE ~profit/lib/bac4th-mem.f
REQUIRE CREATE-VC ~profit/lib/compile2Heap.f

MODULE: bac4th-sequence

:NONAME PRO LOCAL t
@ t !
\ ['] RDROP t @ VC-COMPILE,  t @ VC-RET, ( \ или так,
START{ t @ VC- POSTPONE RDROP RET, }EMERGE \ или так )
t @ XT-VC CONT
t @ DESTROY-VC
; CONSTANT (}seq) \ процедура успеха }seq

: RET,-1ALLOT  0xC3 DP @ C! ; \ установка шлагбаума для кода, чтобы не лез куда не надо
\ шлагбаум "автоматически" сломается при попытке преодолеть его (читай: компиляции)

: __ CELL -- ;
: --ALIGN CELL /MOD SWAP IF 1+ THEN CELL * ;

0
1 -- rlit
__ handle  \ поле виртуального кодофайла
1 -- ret
--ALIGN
__ counter \ счётчик кол-ва введённых ячеек
CONSTANT arr-struct \ дополнительная структура

:NONAME
arr-struct ALLOCATE THROW >R
CREATE-VC
START{ DUP VC- RET,-1ALLOT }EMERGE
R@ handle ! R@ counter 0!
0x68 R@ rlit C!  0xC3 R@ ret C!
R> ; CONSTANT (arr{)

:NONAME
PRO LOCAL t @ t !


['] RDROP
t @ handle @ VC-COMPILE,
t @ handle @ VC-RET, \ закрываем итератор

t @ CONT \ делаем нырок
t @ handle @ DESTROY-VC
t @ FREE THROW \ снимаем и дополнительную структуру
; CONSTANT (}seq) \ процедура успеха }seq


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

: seq{ ( -- ) ?COMP (arr{) COMPILE, agg{ ; IMMEDIATE

: }seq ( n -- xt ) ?COMP (: @
DUP counter 1+!
handle @ VC-
DUP LIT,
R@ENTER, POSTPONE DROP
RET,-1ALLOT ;) (}seq) }agg ; IMMEDIATE

: }seq2 ( n -- xt ) ?COMP (: @
DUP counter 1+!
handle @ VC-
2DUP DLIT,
R@ENTER, POSTPONE 2DROP
RET,-1ALLOT ;) (}seq) }agg ; IMMEDIATE

: }seq3 ( n -- xt ) ?COMP (: @
DUP counter 1+!
handle @ VC-
ROT DUP LIT, -ROT 2DUP DLIT,
R@ENTER, POSTPONE 2DROP POSTPONE DROP
RET,-1ALLOT ;) (}seq) }agg ; IMMEDIATE

: }seq4 ( n -- xt ) ?COMP (: @
DUP counter 1+!
handle @ VC-
2OVER DLIT, 2DUP DLIT,
R@ENTER, POSTPONE 2DROP POSTPONE 2DROP
RET,-1ALLOT ;) (}seq) }agg ; IMMEDIATE

: {seq} ( -- xt ) ?COMP (: ;) {agg} ; IMMEDIATE

: {#} ( xt -- u ) counter @ ;

: seq>arr ( xt --> addr u ) PRO LOCAL arr LOCAL runner
DUP {#} BALLOCATE DUP arr ! runner !
START{ ENTER DUP runner writeCell }EMERGE
arr @ runner @ OVER - CONT ;

;MODULE

/TEST
: INTSTO PRO 0 DO I CONT DROP LOOP ;
: INTSFROMTO PRO SWAP 1+ SWAP DO I CONT DROP LOOP ;

: list-xt-generated seq{ 5 INTSTO }seq ( xt ) DUP {#} ." length: " . CR ." execute:" ENTER DUP . ;
$> list-xt-generated

: intermediate seq{ 5 INTSTO CR {seq} START{ ENTER DUP . }EMERGE }seq ( xt ) ENTER ;
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
$> seq4ops

REQUIRE split-patch ~profit/lib/bac4th-str.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f

: str= ( d1 d2 -- d1 d2 f ) 2OVER 2OVER COMPARE-U 0= ;
: cross-str PRO ['] str= cross CONT ;

: commonWord
seq{ S" kiwi apple lemon orange"
BL byChar split-patch }seq2 ( list-xt1 )
seq{ S" peach cherry lemon kiwi feyhoa"
BL byChar split-patch }seq2 ( list-xt1 list-xt2 )
cross-str 2DUP TYPE SPACE ;

CR $> commonWord
\ должно выйти: kiwi lemon
: dump-arr seq{ a }seq seq>arr DUMP ;
CR $> dump-arr

REQUIRE iterateBy ~profit/lib/bac4th-iterators.f

: TAKE-TWO PRO *> <*> BSWAP <* CONT ;

: arr2 seq{
BL byChar split-patch \ делим на слова-отрезки
( addr u )
0 .
TAKE-TWO          \ "удвоение" успехов, то есть: посылаем }arr оба числа на стеке
1 .
}seq 2 .
seq>arr ( addr u )   \ теперь у нас массив двойных значений
3 .
EXIT
2 CELLS iterateBy \ делаем по нему проход, прыгая по две ячейки зараз
DUP 2@ CR TYPE ;

CR $> S" ac day mlg pinka profit" arr2
\ MemReport
\EOF
: uniqueSeq seq{
BL byChar split-patch \ делим на слова-отрезки
{seq} ['] str= not-in
}seq2 ENTER 2DUP CR TYPE ;

$> S" kiwi apple lemon kiwi apple orange" uniqueSeq