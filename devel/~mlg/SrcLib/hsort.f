REQUIRE DEFER ~mlg/SrcLib/compat.f

\ HeapSort in Forth assuming zero-based indexing -- v.1.0.1
\ Complexity: O(n*log(n))
\ (p) M.L.Gassanenko, 2000
\ Review and testing: Ruvim Pinka
\ Public domain, NO WARRANTY
\ "HeapSort" in Russian is called "pyramidal sort".
\ -------------------------------------------------------------
\ To sort an array (assuming zero-based indexing),
\ 1) specify:
\	its size -- store to PyrN		( # of items in the array )
\	what "less than" means -- store to []<[]	( i j -- i j f )
\	how to exchange items -- store to []exch[]	( i j -- i j )
\    where 0<=i<PyrN, 0<=j<PyrN
\ 2) call the main word
\	HeapSort ( -- )
\ -------------------------------------------------------------
\ Changes:
\ 01.07.2000 - v 1.0.1 corrected the error in
\ the stack comment of TopGoesDown
\ 02.07.2000 - v 1.0.2 ": ConstrPyr PyrN 0 DO" replaced
\ with ": ConstrPyr PyrN 1 DO" (this *was* so in the very first
\ version, but somehow got lost -- thank you, Ruvim)
\ -------------------------------------------------------------
\ (Rus) KOMMEHTAPuu HA PYCCKOM - B TPETbEu 4ACTu

\ array size and access
0 VALUE PyrN				\ # elements in the array
DEFER []<[]	( i j -- i j f )	\ true if i-th < j-th
DEFER []exch[]	( i j -- i j )		\ exchange i-th and j-th

\ --- internals ---

: above 1+ 2/ 1- ;			( i -- i.a )
: leftrightbelow 1+ 2* 1- DUP 1+ ;	( i -- i.lb i.rb )

: [min]exch[MAX]n? ( i j -- i j ~f ) \ ~f == true if not exchanged
	[]<[] ?DUP IF EXIT THEN []exch[] FALSE
;
: chooseMAX ( i j -- k )
	[]<[] IF SWAP THEN DROP
;
: AddToPyr ( i -- )
    DUP 			BEGIN		( i-old i )
	DUP			      WHILE	( i-old i )
	NIP DUP above				( i i.a )
	[min]exch[MAX]n?	UNTIL THEN	( i i.a )
    2DROP
;
: ConstrPyr ( -- )
	PyrN 1 DO I AddToPyr LOOP
;
: TopGoesDown ( m -- m )
    >R 0 DUP				BEGIN		( i i.old ) ( R: m )
	DROP DUP leftrightbelow DUP R@ <      WHILE	( i i.lb i.rb )
	chooseMAX SWAP					( i.b i )
	[min]exch[MAX]n?		UNTIL ELSE
      R@ =				IF		( i i.lb )
      SWAP [min]exch[MAX]n? DROP	THEN  THEN	( i.lb i )
    2DROP R>
;
: SortPyr ( -- )
    PyrN ( m0)
	PyrN 1 DO  ( m) 1- ( m) 0 []exch[] DROP ( m) TopGoesDown ( m) LOOP
    DROP
;
\ --- the main word ---

: HeapSort ( -- ) \ Uses: []<[] []exch[] PyrN
    PyrN 1 > IF  ConstrPyr SortPyr  THEN
;

\ ---- only comments now ------------------------------------------------------
\
\ A pyramid is an array viewed like the following
\ (digits show item numbers, not items!):
\
\         0
\     1       2
\   3   4   5   6
\  7 8 9 a b c d e
\
\ that is, the 0-th item is above the 1-st and 2-nd ones,
\ the 1-st item is above 3-rd and 4-th, etc.
\
\ Definition. An array is pyramidally ordered if each item is
\ greater than or equal to the two items below it
\ (if there are items below it, of course).
\
\ Key to stack comments:
\ i j k -- element #s
\ i.a -- the element above i in the pyramid
\ i.rb -- the right item below i in the pyramid
\ i.lb -- the left item below i in the pyramid
\ m -- # items in the yet unsorted part (m-th is the first in the sorted part)
\ i.old -- i from the previous iteration
\
\ The main idea.
\ The pyramidal sort two times "bubble-sorts" each path from the "basement"
\ to the "top". Each such step brings only one item to its place, but the
\ number of items involved is at most [log2(n)] -- it's the number of layers.
\
\
\ Definition: a "bubble run" is a series of exchanges of the sort
\ this:=first; that:=nextto(this);
\ while that<=last do
\	if elem[this]<elem[that] then exchange(this,that) fi;
\	// calculate new this and that
\	this:=that; that:=nextto(this);
\ od
\
\ Properties:
\ 1. a basement-to-top bubble-run brings the maximal element to the top
\ 2. a top-to-basement bubble-run brings the minimal element to the basement
\ 3. n-1 bubble-runs sort n elements (this is "bubble sort")
\ 4. one bubble-run sorts n elements of which (n-1) are sorted and 1 is unsorted
\ 5. if the pyramidal order is broken by a single non-maximal element
\ placed at the top, the order may be restored by a single top-to-basement
\ bubble-run, provided that the mentioned non-maximal element is always
\ exchanged with the maximal element of the two below elements.
\
\ --- Words: ---
\
\ AddToPyr ( i -- ) a basement-to-top bubble-run, brings the currently last
\ (i-th) item to its place and brings the maximal item to the top.
\ [Log2(n)] exchanges.
\
\ ConstrPyr ( -- ) N basement-to-top bubble-runs build a pyramid
\
\ TopGoesDown ( m -- m ) a top-to-basement bubble-run brings the unsorted item
\ from the top to its place. Since the above element is always exchanged
\ with the *maximal* below element, the pyramid order is restored.
\
\ SortPyr ( -- ) assuming initial pyramidal ordering, sort the array
\ N-1 times {
\	move the top item to where it must be in the sorted array and
\	move the item that was on that place to the top
\	(exchange the top (maximal) element with the last unsorted element);
\	[the item(s) that are where they must be in the sorted array
\	are not touched during bubble-runs anymore;]
\	a top-to-basement bubble-run brings the unsorted item from
\	the top to its place, and brings the next maximal item to the top
\ }
\ It is easy to see that after N-1 iterations each item,
\ after visiting the top place, will be where it must be in the sorted array.
\
\ HeapSort ( -- ) The main word. Set PyrN to the number of elements,
\ set []<[] and []exch[] to the functions that compare and exchange
\ the array elements, and invoke HeapSort.


\ -----------------------------------------------------------------------------
\ Чтобы отсортировать массив (индексы начинаются с 0),
\ 1) укажите:
\	размер -- записать в PyrN		( число элем в массиве )
\	что такое "меньше" -- присвоить []<[]	( i j -- i j f )
\	как обменивать -- присвоить []exch[]	( i j -- i j )
\    здесь 0<=i<PyrN, 0<=j<PyrN
\ 2) вызовите главное слово
\	HeapSort ( -- )
\
\ ---- комментарии ------------------------------------------------------------
\
\ Пирамида -- массив, рассматриваемый как:
\ (цифры - номера элементов, а не элементы!)
\
\         0
\     1       2
\   3   4   5   6
\  7 8 9 a b c d e
\
\ то есть, 0-й элемент находится над 1-ым и 2-ым,
\ 1-й -- над 3-им и 4-ым и т.д.
\
\ Определение. Массив пирамидально упорядочен, если каждый элемент
\ не меньше элементов под ним (если таковые есть, конечно же).
\
\ Расшифровка стековых обозначений:
\ i j k -- номера элементов
\ i.a -- элемент над (above) i в пирамиде
\ i.rb -- правый (right) элемент под (below) i в пирамиде
\ i.lb -- левый (left)  элемент под (below) i в пирамиде
\ m -- число элементов в еще неотстртированной части (m - первый отсортированный)
\ i.old -- старое i
\
\ Главная идея.
\ Пирамидальная сортировка дважды выполняет пузырьковыю сортировку по
\ каждому пути от основания пирамиды до вершины. Каждый раз на свое место
\ ставится только один элемент, но число обменов каждый раз не больше
\ числа уровней [log2(n)].
\
\
\ Определение: "пузырьковый проход" - последовательность обменов типа
\ этот:=первый; тот:=следующий_для(этот);
\ while тот<=последний do
\	if элем[этот]<элем[тот] then обменять(этот, тот) fi;
\	// новые этот и тот
\	этот:=тот; тот:=следующий_для(этот);
\ od
\
\ Свойства:
\ 1. пузырьковый проход от основания к вершине выносит максимальный элемент
\ на вершину.
\ 2. пузырьковый проход от вершины к основанию выносит минимальный элемент
\ в основание.
\ 3. n-1 пузырьковых проходов сортируют n элементов (это пузырьковая сортировка)
\ 4. один пузырьковый проход сортирует n элементов, из которых n-1 уже
\ отсортированы, а один - не на месте.
\ 5. если пирамидальная упорядоченность нарушена только тем, что на вершине
\ стоит "левый" (не максимальный) элемент,
\ то пузырьковый проход от вершины к основанию восстановит пирамидальную
\ упорядоченность, если "левый" элемент обменивать каждый раз с максимальным
\ из нижестоящих элементов.
\
\ --- Слова: ---
\
\ AddToPyr ( i -- ) пузырьковый проход от основания к вершине, ставит
\ i-й (последний) элемент на надлежащее место и выносит максимум на вершину.
\ [Log2(n)] обменов.
\
\ ConstrPyr ( -- ) N пузырьковых проходов от основания к вершине
\ строят пирамиду.
\
\ TopGoesDown ( m -- m ) пузырьковый проход от вершины к основанию ставит
\ стоящий на вершине "левый" элемент на место. Так как верхний элемент всегда
\ меняется с максимальным нижним, пирамидальная упорядоченность
\ восстанавливается.
\
\ SortPyr ( -- ) предполагая, что массив пирамидально упорядочен, отсортировать.
\ N-1 раз {
\  поместить верхний элемент туда, где он должен быть в отсортированном массиве
\  бывший на его месте элемент поместить на вершину
\  (обмен верхнего (max) элемента с последним неотсортированным);
\  [с этих пор уже отсортированный элемент больше не трогаем]
\  пузырьковый проход от вершины к основанию ставит стоящий на вершине
\   "левый" элемент на место и восстанавливает пирамидальность
\ }
\ Ясно, что после N-1 проходов каждый элемент, побывав на вершине,
\ займет надлежащее место в отсортированном массиве.
\
\ HeapSort ( -- ) Главное слово. Присвойте PyrN число элементов,
\ присвойте словам []<[] и []exch[] функции сравнения и обмена элементов,
\ и вызывайте HeapSort.

\ -------------------------------------------------------------
\ Review & testing report
\
\ Ruvim Pinka wrote (Sat, 1 Jul 2000 04:19:43 +0000):
\ Все посмотрел и во все врубился ( белый ящик ;)
\ ошибок не обнаружил.
\ стохастический тест ( случайные входные данные, черный ящик)
\ тоже ошибок не установил.
