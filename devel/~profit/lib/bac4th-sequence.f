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

\ Недостаток тут в том что для записи пусть и временно но используется кодофайл
\ Так что особо не разгуляешься с большими списками...
\ Э-э-э, нет. Можно же компилировать операции (благо их немного совсем) сразу
\ в кучу, беря память кусками, по мере того как заканчивается память в пред-м
\ и соединять кусочки jmp'ами. С другой стороны также придётся код успеха тоже
\ генерировать чтобы снимать память занимаемую всеми кусками.

REQUIRE (: ~yz/lib/inline.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE FREEB ~profit/lib/bac4th-mem.f

BASE @ HEX 
: R@ENTER, FF C, 14 C, 24 C, ; \ CALL [ESP]
\ По идее, тоже самое что и POSTPONE R@ POSTPONE EXECUTE, но в слове }seq на это лезет глюк,
\ что включай оптимизатор, что выключай.
BASE !

:NONAME PRO POSTPONE RDROP RET, HERE SWAP @ DUP DP ! TUCK - HEAP-COPY FREEB CONT ;
CONSTANT (}seq)

: seq{ ( n -- xt ) ?COMP POSTPONE HERE agg{ ; IMMEDIATE

: }seq ( n -- xt ) ?COMP (: DROP
DUP LIT,
R@ENTER, POSTPONE DROP ;) (}seq) }agg ; IMMEDIATE

: }seq2 ( n -- xt ) ?COMP (: DROP
2DUP DLIT,
R@ENTER, POSTPONE 2DROP ;) (}seq) }agg ; IMMEDIATE

: }seq3 ( n -- xt ) ?COMP (: DROP
ROT DUP LIT, -ROT 2DUP DLIT,
R@ENTER, POSTPONE 2DROP POSTPONE DROP ;) (}seq) }agg ; IMMEDIATE

: }seq4 ( n -- xt ) ?COMP (: DROP
2OVER DLIT, 2DUP DLIT,
R@ENTER, POSTPONE 2DROP POSTPONE 2DROP ;) (}seq) }agg ; IMMEDIATE

\EOF
: INTSTO PRO 0 DO I CONT DROP LOOP ;
: INTSFROMTO PRO SWAP 1+ SWAP DO I CONT DROP LOOP ;

REQUIRE SEE lib/ext/disasm.f
: r seq{ 10 INTSTO }seq ( xt ) ." generated code:" DUP REST CR ." execute:" EXECUTE DUP . ;
r

REQUIRE LOCAL ~profit/lib/static.f
: s PRO BACK SP! TRACKING SP@ BDROP CONT ; \ Восстановление стека

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
: subtr PRO a s NOT: b 2DUP = ONTRUE -NOT CONT ; \ Вычитание? (забыл как правильно)

: 4ops
START{ CR ." a="   a     DUP . }EMERGE
START{ CR ." b="   b     DUP . }EMERGE
START{ CR ." a+b=" union DUP . }EMERGE
START{ CR ." axb=" cross DUP . }EMERGE
START{ CR ." a-b=" subtr DUP . }EMERGE ;
4ops CR

 \ Объединение, но теперь можно задавать аргументы, говоря какие множества надо объединять 
: union ( a b -- a+b ) PRO LOCAL b b ! LOCAL a a !
 *> a @ EXECUTE
<*> b @ EXECUTE
<*  CONT ;

: cross ( a b f -- axb ) PRO LOCAL f f ! LOCAL b b ! LOCAL a a !
a @ EXECUTE b @ EXECUTE f @ EXECUTE ONTRUE CONT ;
\ Операцию сравнения двух значений выносим в аргумент тоже, причём со стеком 
\ пусть она сама разбирается: f ( ... -- 0|-1 )
: cross-number ( a b -- axb ) PRO (: 2DUP = ;) cross CONT ;

: subtr ( a b f -- a-b ) PRO LOCAL f f ! LOCAL b b ! LOCAL a a !
a @ EXECUTE
s NOT: b @ EXECUTE f @ EXECUTE ONTRUE -NOT CONT ;
: subtr-number PRO (: 2DUP = ;) subtr CONT ;

: seq4ops LOCAL 0..4 LOCAL 2..5

seq{ 4 INTSTO }seq 0..4 ! \ от 0 до 4-х
seq{ 5 2 INTSFROMTO }seq 2..5 ! \ "от двух до пяти" (с)

CR ." [0..4]=" START{ 0..4 @ EXECUTE DUP . }EMERGE
CR ." [2..5]=" START{ 2..5 @ EXECUTE DUP . }EMERGE

START{
seq{ 0..4 @  2..5 @ union }seq
CR ." [0..4]+[2..5]="
EXECUTE DUP . }EMERGE

START{
seq{ 0..4 @  2..5 @ cross-number }seq
CR ." [0..4]x[2..5]="
EXECUTE DUP . }EMERGE

START{ seq{ 0..4 @  2..5 @ subtr-number }seq
CR ." [0..4]-[2..5]=" EXECUTE DUP . }EMERGE

START{ seq{
seq{ 0..4 @  2..5 @ subtr-number }seq  seq{ 0..4 @  2..5 @ cross-number }seq
union }seq
CR ." [0..4]-[2..5] + [0..4]x[2..5]=" EXECUTE DUP . }EMERGE ;
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
