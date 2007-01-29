REQUIRE SEE lib/ext/disasm.f
\ Стековый оптимизатор, работающий со стековыми комбинациями, через
\ приведение стековых комбинаций к подстановкам и их, в свою очередь,
\ -- к циклам и последовательности DROP'ов.

\ Изначальной позицией считается n ... 3 2 1
\ Обсуждение: http://fforum.winglion.ru/viewtopic.php?p=3479#3479 и
\ http://fforum.winglion.ru//viewtopic.php?p=4136#4136

\ Стековые комбинации -- формальное обозначение операций на стеке.
\ Представляет собой вид стека после выполнения операций при начальном
\ его состоянии (вершина -- справа, стек углубляется влево):
\ ... 5 4 3 2 1
\ Первым элементом комбинации считается самый правый её элемент и так
\ далее, двигаясь влево.

\ Конечные элементы -- все элементы которые есть в комбинации.
\ Удаляемые элементы -- элементы которых в комбинации нет.
\ Длина комбинации -- кол-во конечных элементов.
\ Глубина комбинации -- максимальный номер элемента, то есть номер
\ самого глубокого элемента задеваемого этой комбинацией.

\ Например операции 2DROP 2DROP 2DROP соответствует комбинация 7.
\ Конечный элемент -- 7. Удаляемые элементы -- 123456.
\ Длина комбинации равна 1. А глубина равна 7-и.

\ Для наиболее эффективной реализации стековых операций, покажем
\ как соответствующие им комбинации раскладываются в циклы:

\ 4312 --> (4) (3) (12) --> (12) --> поменять значениями первый и второй элементы
\ 3412 --> (34) (12) --> XCHG 3, 4; XCHG 1, 2
\ 4123 --> (4) (2) (13) --> (13) --> MOV t, 1; MOV 1, 3; MOV 3, t
\ 563241 --> (56) (342) (1) --> (56) (243) --> XCHG 5, 6;  XCHG 2, 4; XCHG 4, 3;
\ 7 --> 76'5'4'3'2'1' DROP^6 --> (7) (6') (5') (4') (3') (2') (1') DROP^6 --> DROP^6 
\ 23 --> 231' DROP^1 --> (23) (1') DROP^1 --> (23) DROP^1
\ 532 --> 5324'1' DROP^2 --> (5) (34'2) (1') DROP^2 --> (34'2) DROP^2

\ Композиция:
\ DUP SWAP --> 11 12 --> 11
\ DUP OVER --> 11 212 --> 111

\ Перед самой композицией нужно сперва привести глубины
\ комбинаций:
\ SWAP 2SWAP --> 12 2143
\ У 12 глубина меньше чем у 213, поэтому дополняем 12 простой
\ числовой последовательностью начинающейся от её глубины:
\ 12 --> 312 --> 4312
\ Теперь, когда мы свели глубины, собственно делаем композицию:
\ 4312 2143=1243

\ Выводим циклы:
\ 1243 --> (1324)

\ Взять композицию можно и от двух комбинаций с DROP'ом:
\ NIP DROP --> 31 2 --> 312' DROP^1  21' DROP^1
\ Берём кол-во сбросов первой комбинации и сдвигаем вторую
\ комбинацию на это кол-во символов, при этом кол-во сбросов
\ из первой комбинации переносим во вторую с добавлением:
\ 312 32'1' DROP^2 --> 31'2' DROP^2

\ Ещё пример:
\ 2DROP ROT NIP --> 3 213 31 --> 32'1' DROP^2 213 312' DROP^1 -->
\ --> 321 4352'1' DROP^2 312' DROP^1 --> 321 43521 534'2'1' DROP^3
\ Приводим глубины:
\ 54321 43521 534'2'1' DROP^3 --> 4'532'1' DROP^3

\ Для SPF удаление элементов стека нужно делать не с вершины,
\ а со второго элемента (!). Так как вершина кэшируется, то
\ снятие с неё значений требует обращений регистр-стек.

\ Нужно собирать все удаляемые элементы в "зоне удаления"
\ между первым и вторым конечными элементами. Собирать 
\ можно простым обменом значений. После того, как все
\ удаляемые элементы окажутся в этой зоне, удаление
\ производится одной операцией, обозначим её S.

\ 231' DROP^1 --> 21'3 S1 --> (1'23) S1
\ 7 --> 6'5'4'3'2'1'7 S6 --> (1'2'3'4'5'6'7) S6
\ Обмен между двумя удаляемыми значениями упрощается в пользу
\ меньших элементов, поэтому:
\ (1'2'3'4'5'6'7) S6 --> (1'3'4'5'6'7) S6 -->
\ --> (1'4'5'6'7) S6 ... --> (1'7) S6
\ Обмен между удаляемым и окончательным элементом делается
\ в одну сторону то есть становится просто переносом.

\ Преобразование от комбинации с DROP'ами к комбинации с S'ами
\ лучше делать только после окончании всех композиций, так
\ композицию комбинаций с S мне формализовывать было лень.

\ TODO: Разобраться, убрать хаки и утечки из программы.
\ TODO: Сделать переход с DROP на NIP.
\ TODO: Сделать возможность оптимизации циклов и присваиваний
\ с удаляемыми элементами ( (1'2'3'4'5'6'7)-->(1'7) ).
\ TODO: Если в цикле участвует 1 (EAX) то можно, прокрутив цикл
\ и сделав EAX первым элементом в цикле, использовать как EAX 
\ второй временный регистр вместо 101 (EBX или что там сейчас).
\ TODO: DUP OVER TUCK и прочие стековые операции *добавляющие* значения.
\ TODO: Выражения (+ - /MOD). Хм.. Реально ли?

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE __ ~profit/lib/cellfield.f
REQUIRE iterateBy ~profit/lib/bac4th-iterators.f
REQUIRE arr{ ~profit/lib/bac4th-sequence.f
REQUIRE ON lib/ext/onoff.f

MODULE: stackOptimizer

\ Раздел определения структуры данных комбинаций:
\ Вначале явно опишем некоторые из них:

\ Имя       |Len| Подстановка      |Drops|
CREATE swap   2 ,   1 , 2 ,          0 ,
CREATE dup    2 ,   1 , 1 ,          0 ,
CREATE over   3 ,   2 , 1 , 2 ,      0 ,
CREATE rot    3 ,   2 , 1 , 3 ,      0 ,
CREATE -rot   3 ,   1 , 3 , 2 ,      0 ,
CREATE nip    2 ,   3 , 1 ,          0 ,
CREATE drop   1 ,   2 ,              0 ,
CREATE 2drop  1 ,   3 ,              0 ,
CREATE 2swap  4 ,   2 , 1 , 4 , 3 ,  0 ,
CREATE 6drop  1 ,   7 ,              0 ,
CREATE nop    0 ,                    0 ,
CREATE some   2 ,   2 , 4 ,          0 ,

\ Найти адрес i-го (начиная от единицы) элемента в комбинации addr
\ Мы же помним, что комбинации нумеруются от конца?
: i[] ( i addr -- n ) DUP @ CELLS + SWAP 1- CELLS - ;

\ От адреса комбинации в памяти получить адрес ячейки с кол-м DROP'ов
: drops ( comb -- addr ) 0 SWAP i[] ;

\ Итератор проходит от последнего элемента комбинации к первому.
: comb=> ( addr --> n \ <-- ) DUP @ SWAP CELL+ SWAP  RUSH> iterateByCellValues ; \ итератор по комбинациям

\ Преобразование массива чисел в комбинацию (drops приравнивается нулю)
: arr>comb ( addr1 u --> addr2 \ <-- ) PRO
arr{ *> CELL / <*> iterateByCellValues <*> 0 DROPB <* }arr DROP CONT ;

\ Структура комбинаций определена, при изменении их структуры нужно менять только слова выше.

\ Глубина комбинации
: depth ( addr -- u ) MAX{ comb=> DUP }MAX ;

\ Распечатка комбинации
: .comb ( addr -- ) 
DUP START{ comb=> DUP . }EMERGE ."  DROP^" drops @ . ;

\ Расширить комбинацию addr1 числовой последовательностью от start начиня и с длиной в len
\ len может быть отрицательным
\ Делает успех вместе со адресом сцеплённой комбинации addr2
: extend ( addr1 start len --> addr2 \ <-- ) PRO
arr{ *> 1 iterateBy2 <*> comb=> <* }arr
arr>comb CONT ;

\ Простейшая композиция двух подстановок.
\ Работает в случае если у подстановок равны длины
\ И нет удалённых или сдублированных элементов
: composeAligned ( addr1 addr2 --> addr3 \ <-- ) PRO LOCAL a SWAP a !
arr{ comb=> DUP a @ i[] @ DROPB }arr arr>comb CONT ;

\ Композиция с приведением длин.
\ Но удалённые или сдублированные элементы всё ещё не обрабатываются
: composeWithoutDeletions ( addr1 addr2 --> addr3 \ <-- ) PRO 2DUP @ SWAP @ OVER -
DUP 0 > 0= LOCAL dir dir !
2SWAP dir @ IF SWAP THEN 2SWAP
dir @ 0= IF DUP ROT + SWAP NEGATE THEN
extend dir @ IF SWAP THEN composeAligned CONT ;

\ Сравнивалка целочисленных одинарных значений
:NONAME ( a b -- a b f ) 2DUP = ; CONSTANT number=

\ "Нет-в". Если в итераторе b (итераторе!) нет значения a
\ (значения!), то делает успех
: not-in ( a b f --> \ <-- ) PRO LOCAL f f ! LOCAL b b !
S| NOT: b @ ENTER f @ ENTER ONTRUE -NOT CONT ;

\ Устранение удалённых элементов из комбинации путём явного указания
\ их на правой стороне комбинации и комбинирование с нек-м кол-в
\ DROP'ов
: addDeleted ( addr1 -- addr2 ) PRO LOCAL i LOCAL drops2Add
DUP drops @ drops2Add !
arr{ \ массив окончательной сцепки
DUP seq{ comb=> }seq  i ! \ копируем значения в список-итератор
depth \ находим глубину
seq{ \ начинаем формировать список удалённых элементов
DUP NEGATE 1 iterateBy \ генерируем числа от глубины комбинации до 1-го
i @ number= not-in \ если числа нет в комбинации, то заносим его в массив
}seq ( list-xt ) \ имеем список удалённых значений
DUP {#} drops2Add +! \ сколько значений было удалено
\ окончательная сцепка
 *> i @ ENTER \ сначала -- сама комбинация
<*> ENTER \ потом -- удалённые значения
<* }arr arr>comb
drops2Add @ OVER drops ! CONT ;

\ Сдвиг всех элементов комбинации addr1 на число shift
\ Делает успех с адресом выходной комбинации addr2
: shiftComb ( addr1 shift --- addr2 ) PRO LOCAL shift shift !
arr{ comb=> DUP shift @ + DROPB }arr arr>comb CONT ;

\ Композиция с приведением длин и учётом удалённых элементов (без дублированных).
: compose ( a b -- c ) PRO
LOCAL b b !
( a ) addDeleted LOCAL combA+Deleted combA+Deleted !
b @   addDeleted ( combB+Deleted ) DUP b !
combA+Deleted @ drops @ shiftComb
addDeleted ( combB+Deleted+shifted+Deleted )

combA+Deleted @ SWAP composeWithoutDeletions
b @ drops @ combA+Deleted @ drops @ + OVER drops !
CONT ;


\ Комбинацию, перед разложением её в циклы, нужно сначала "вывернуть"
\ (транспонировать?) -- создать такую комбинацию из исходной, где
\ в i-й позиции находится значение равное индексу значения i в исходной
\ комбинации. То есть:
\ 4321 лёгким движением руки превращается в 1423
\ 3124                                      4321
: invertComb ( comb1 --> comb2 \ <-- ) PRO LOCAL c DUP c ! LOCAL len LOCAL res 
arr{ comb=> 0 DROPB }arr DUP len ! arr>comb res !
START{ len @ CELL / 1 SWAP 1 iterateBy
DUP DUP c @ i[] @
res @ i[] !
}EMERGE
res @ CONT ;

\ Выявление одного цикла внутри подстановки
\ comb -- определяет комбинацию
\ i -- индекс с которого цикл начинается
\ touched -- адрес массива флажков, дл пометки уже пройденных элементов
: cycle ( touched comb i --> j \ <-- j ) PRO
LOCAL comb SWAP comb !
LOCAL touched SWAP touched !
BEGIN
DUP 1- CELLS touched @ + DUP @ 0= WHILE
ON
CONT
comb @ i[] @
REPEAT
DROP ;

\ Выявление всех циклов в подстановке.
\ Кол-во успехов соотв-т кол-ву найденных циклов в подстановке
\ Слово отправляет цикл в виде массивов ячеек с их началами и
\ длинами на стеке
: cycles ( addr1 --> addr2 u2 \ <-- ) PRO invertComb
123456789 DROPB SWAP  DROPB S| \ Хак!.. Я так и не нашёл источник утечки стека в этом слове... Может, вы?..

arr{ DUP comb=> 0 DROPB }arr   \ создаём массив отметок (touched)
                               \ с кол-вом элементов таким же как и в комбинации
DROP                           \ длина этого массива не нужна, и так ясно
SWAP ( touched comb )
seq{ seq{ DUP comb=> }seq
ENTER }seq3                    \ Это нужно для изолирования стека.
NIP NIP                        \ Убираем touched и comb: они уже вписаны в итератор

\ Таким образом мы получаем на стеке адрес итератора с
\ тройными значениями:
\ touched comb 1
\ touched comb 2
\ ...
\ touched comb n

ENTER
arr{
2 PICK 2 PICK 2 PICK \ 3DUP
( touched comb i )
cycle
}arr
2DROPB
DUP 2 CELLS < ONFALSE          \ пустые циклы и циклы из одного элемента не нужны
CONT ;

: .cycles ( addr u -- ) ." (" BACK ." ) " TRACKING CELL iterateBy DUP @ . ;


\ Компиляция маш. кода операции присваивания
\ a и b -- коды операндов
\ Если код операнда больше ста, то это временное значение (т. е. регистр)
\ Если меньше, то это номер элемента на стеке (начиная с вершины в виде единицы)
\ Обрабатывается только тот случай когда один операнд является временными 
\ значением и второй будет стековым элементом.
: assign ( a b -- )
DUP 100 < IF \ запись из регистра в стек-й элемент
1-
0x8B C,
DUP 0= IF DROP 100 = IF 0xD0 C, EXIT THEN 0xD8 C, EXIT THEN
SWAP 100 = IF 0x55 ELSE 0x5D THEN C, 1- CELLS C,
ELSE \ запись из стекового элемента в регистр
SWAP 1- SWAP
OVER 0= IF NIP 0x8B C, 100 = IF 0xC2 ELSE 0xC3 THEN C, EXIT THEN
0x89 C,
100 = IF 0x55 ELSE 0x5D THEN C, 1- CELLS C,
THEN ;

(
8BD8             MOV     EBX , EAX
8B5D00           MOV     EBX , 0 [EBP]
8B5D04           MOV     EBX , 4 [EBP]
8B5D08           MOV     EBX , 8 [EBP]

8BC3             MOV     EAX , EBX
895D00           MOV     0 [EBP] , EBX
895D04           MOV     4 [EBP] , EBX
895D08           MOV     8 [EBP] , EBX


8BD0             MOV     EDX , EAX
8B5500           MOV     EDX , 0 [EBP]
8B5504           MOV     EDX , 4 [EBP]
8B5508           MOV     EDX , 8 [EBP]

8BC2             MOV     EAX , EDX
895500           MOV     0 [EBP] , EDX
895504           MOV     4 [EBP] , EDX
895508           MOV     8 [EBP] , EDX
)

: tempInvert 100 = IF 101 ELSE 100 THEN ;

: cycle>assigns ( addr u -- list-xt ) PRO

LOCAL first OVER @ first ! \ первый элемент запоминаем
LOCAL switch 100 switch !  \ переключатель временных переменных

seq{
*>
first @ switch @
<*>
SWAP CELL+ SWAP \ начинаем обход со второго элемента подстановки
CELL / 1-
iterateByCellValues
 *>
switch @ tempInvert switch ! \ переключить переключатель
DUP switch @
<*> switch @ tempInvert OVER
<*
<*> switch @ first @ <*
2DROPB SWAP
}seq2 CONT ;

: .assigns ( list-xt -- )  ENTER 2DUP CR SWAP . ." =" . ;

: compileCycles ( list-xt -- ) cycle>assigns ENTER 2DUP assign ;
: compileComb ( addr -- ) addDeleted BACK 0 ?DO POSTPONE DROP LOOP TRACKING DUP drops @ BDROP cycles compileCycles ;

VARIABLE curComb \ текущая комбинация
nop curComb ! \ пустая комбинация
VARIABLE beforeHere
VARIABLE hereAfter
hereAfter 0!

VARIABLE lastCombStarts


0
__ oldWord
__ combOp
CONSTANT stackWord

: opt ( stackWord  -- )
beforeHere @ hereAfter @ = IF \ если конец кода преды-й операции и 
                              \ начала этой операции -- одинаковы,
                              \ значит это последовательные оп-ции
                              \ и их можно объединять в одну оп-цию.
curComb @
\ CR DUP .comb
SWAP combOp @
\ DUP .comb
CUT: compose -CUT \ чтобы "вытянуть" структуру комбинации "наверх" ПОКА делаю отсечение (и получаю утечку памяти)
\ DUP .comb
DUP curComb !
lastCombStarts @ DP !
compileComb
ELSE combOp @
curComb !  beforeHere @ lastCombStarts ! THEN ;

: str>comb ( addr1 u1 -- addr2 ) PRO
arr{ iterateByByteValues [CHAR] 1 - 1+ }arr
arr>comb addDeleted CONT ;

: OPTIMIZE
' DUP WordByAddr CREATED \ пересоздаём слово
HERE oldWord !  \ сохраняем xt старого слова
NextWord ( addr u ) \ комбинация
CUT: str>comb -CUT \ сохраняем комбинацию в теле слова, одна ячейка (ещё 1 утечка памяти)
\ DUP .comb
HERE combOp !
stackWord ALLOT \ занимаем структуру в словарной статье
IMMEDIATE
DOES>
STATE @ IF \ Компиляция или интерпретация?
HERE beforeHere ! \ Ставим отметку "до"
DUP oldWord @ COMPILE, \ Компилируем слово "по-обычному"
opt \ пытаемся это дело пооптимизировать
HERE hereAfter ! \ Ставим отметку "после"
ELSE
oldWord @ EXECUTE \ В режиме интерпретации не изгаляться -- пускать как есть
THEN ;

EXPORT

OPTIMIZE SWAP 12
OPTIMIZE 2SWAP 2143
OPTIMIZE 2DROP 43
OPTIMIZE NIP 31
OPTIMIZE DROP 2
OPTIMIZE ROT 213
OPTIMIZE -ROT 132

;MODULE

/TEST
ALSO stackOptimizer \ отладка внутренних слов библиотеки

$> :NONAME BACK RET, TRACKING *> 1 <*> 2 <* DROPB *> 100 <*> 101 <* DROPB *> <*> BSWAP <* 2DUP assign ; HERE SWAP EXECUTE REST

$> swap .comb
$> S" 412" str>comb .comb
$> swap rot compose .comb
$> swap rot compose drop compose .comb
$> nip drop compose .comb
$> drop nip compose .comb
$> rot nip compose 2swap compose drop compose .comb
$> \ Check for stack elements' leaking in cycles
$> 40 30 20 10 swap cycles .cycles
: .s. DEPTH .SN S0 @ SP! ;
$> :NONAME 2swap swap compose cycles .cycles ; ENTER .s.
$> swap cycles cycle>assigns .assigns
$> swap rot compose nip compose cycles cycle>assigns .assigns
$> 4 3 2 1 : r  2SWAP SWAP 2SWAP ; r .s. SEE r
$> 4 3 2 1 2SWAP SWAP 2SWAP .s.
$> 5 4 3 2 1 :NONAME SWAP ROT NIP ROT DROP ; ENTER .s.
$> 5 4 3 2 1 SWAP ROT NIP ROT DROP .s.
$> 4 3 2 1 :NONAME 2SWAP SWAP ROT SWAP ; ENTER .s.
$> 4 3 2 1 2SWAP SWAP ROT SWAP .s.
$> 4 3 2 1 :NONAME ROT DROP -ROT ; ENTER .s.
$> 4 3 2 1 ROT DROP -ROT .s.
$> 4 3 2 1 :NONAME 2DROP DROP ; ENTER .s.
$> 4 3 2 1 2DROP DROP .s.