\ colorlessForth без цвета. Идеи -- Chuck Moore и Terry Loveall.
\ На этот раз для обозначения режима используются разметка и 
\ отступы (при этом отступы работают также визуально видимым
\ control-flow стеком).

\ По поводу colorforth'а вообще см. студенческую статью:
\ http://forth.org.ru/~profit/COLOR4th.pdf

\ Данная работа переносит следующие особенности оригинальной
\ системы Мура в SPF:
\ 1. Отделение словаря от кодофайла (~profit/lib/colorForth/cascaded.f)
\ 2. Оптимизация хвостовой рекурсии
\ 3. Определение режима интерпретации/компиляции по оформлению (в данном
\ случае -- через текстовую разметку)

\ 4. Также бонусом добавлено отступное оформление структурных операторов
\ (у Мура этого не было).
\ 5. Введены понятия внешних слов и внутренних слов (меток).

\ Интерпретация идёт построчно.

\ Если строка начинается с пробела, значит её нужно исполнить.

\ Если строка начинается с табуляции, то компилируем её и выполняем 
\ действия из массива табуляций для соответствующей позиции.
\ Выполненные действия с массива снимаются.
\ Если табуляторов нет, то выполняем все действия в массиве.
\ Если есть один -- то все, кроме первого, если два -- то все,
\ кроме первого и второго и т.д.

\ Действия в массив табуляций записывают control-flow слова
\ они выолняеют своё действие "до" и ставят на текущую позицию
\ массива табуляций своё действие "после".

\ Во всех остальных случаях строки считаются определением, тогда
\ из строки берётся первое слово и создаётся для него словарная 
\ статья, прочая часть строки игнорируется.

\ При этом определения различаются стояла ли перед ним пустая 
\ строка. Если была, значит это -- "внешнее" слово, оно пойдёт в
\ словарь. Если не было, то это слово "внутреннее" (метка), и 
\ запишется оно в словарь innerWords, который при начале определения
\ следующего "внешнего" слова будет затёрт. Заодно и предупреждаются
\ коллизии имён "внутренних" и "внешних" слов.

\ Сделано оно это для более лёгкого "мимолётного" чтения текста,
\ когда к левому краю всегда прижимаются только имена определений
\ а все структуры управления (включая сами определения) имеют 
\ подчёркнуто отступно-коробчатый вид.

\ Кстати, мне самому смотреть такой код не очень нравится... Вид у
\ кода какой-то жидкий становится, редкие-редкие такие островки
\ буквочек "на белой простыне" (с)...

\ Вопрос: возможно, режим непосредственного исполнения стоит задать
\ более видно... Например, указав # вначале строки (если уж добиваемся
\ Питонообразия, то гулять-так-гулять...).

\ Комментарии. Пока в их отбражении разброд и шатание, так как
\ я могу злоупотреблять тем что control-flow автоматически делают
\ оставшуюся после себя строку комментарием

\ TODO: Сделать определение хвостовой оптимизации более надёжным
\ TODO: Сделать взаимное беспроблемное подключение кода SPF и Photon'а
\ TODO: Нужна ли поддержка WARNING ?
\ TODO: Текущая реализация затирает innerWords при любой пустой строке
\ Из-за этого внутри слова не могут быть пустые строки (если конечно,
\ мы хотим работать с метками). Исправлять ли это?..

REQUIRE >L ~profit/lib/lstack.f
REQUIRE NOT ~profit/lib/logic.f
REQUIRE FOR ~profit/lib/for-next.f
REQUIRE cascaded ~profit/lib/colorForth/cascaded.f


MODULE: photon

40 CONSTANT maxTabs
CREATE tabsArr \ массив действий табуляции
maxTabs CELLS ALLOT

: clearTabs  tabsArr maxTabs CELLS OVER + SWAP DO
['] NOOP I ! \ это массив векторов, т.е. адресов процедур
CELL +LOOP ;
clearTabs

: flushTabs ( i -- )
CELLS tabsArr +  tabsArr maxTabs CELLS +  ( tabsArr[i] end )
BEGIN
2DUP <= WHILE
DUP @ EXECUTE
['] NOOP OVER !
CELL-
REPEAT
2DROP ;

: setTab ( xt i -- )  CELLS tabsArr + ! ;

: OnTabulation ( -- flag ) GetChar SWAP 9 = AND ;
: OnBlank ( -- flag ) EndOfChunk ;

VARIABLE curTab
curTab 0!

: tabsCount ( -- n ) 0  BEGIN OnTabulation WHILE 1+  1 >IN +! REPEAT ;

: control-flow ( xt-before xt-after -- )
\ компиляция: ( -- xt-after )
CREATE IMMEDIATE
SWAP , ,
DOES> [COMPILE] \ 2@ EXECUTE curTab @ setTab ;

EXPORT

:NONAME [COMPILE] DO >L >L  ;
:NONAME L> L> [COMPILE] LOOP ;
control-flow do

:NONAME [COMPILE] FOR >L ;
:NONAME L> [COMPILE] NEXT ;
control-flow for


:NONAME [COMPILE] IF DROP >L ;
:NONAME L> 1 [COMPILE] THEN ;
control-flow if

:NONAME HERE 5 - C@ 0xE8 = IF 0xE9 HERE 5 - C! \ заменяем CALL на JMP
ELSE RET, \ или обычный EXIT
THEN ; 
:NONAME ;
control-flow return



ALSO cascaded
\ режим каскадных определений выкидывает словарные структуры
\ из кодофайла

NEW: photonWords
\ заводим общий словарь для слов Photon'а
PREVIOUS

DEFINITIONS

ALSO cascaded NEW: innerWords
\ заводим словарь для "внутренних" слов (не путать со словарём macro,
\ тем более что у меня macro нет)
PREVIOUS

' innerWords >BODY @ CONSTANT innerWid

VARIABLE savedWid

: saveWid   GET-CURRENT DUP innerWid <> IF savedWid ! ELSE DROP THEN ;
: restoreWid  savedWid @ SET-CURRENT ;

{{ dontHide \ чтобы подключить нужный :

:NONAME ( -- )
OnBlank        IF innerWid FORGET-ALL  restoreWid  EXIT THEN
OnTabulation   IF tabsCount DUP curTab ! flushTabs [COMPILE] ] INTERPRET_ EXIT THEN
OnDelimiter    IF [COMPILE] [ INTERPRET_ EXIT THEN
[COMPILE] : \ двоеточие из словаря dontHide
saveWid
innerWid SET-CURRENT
[COMPILE] \ ;
CONSTANT photonInterpreter \ xt нового интерпретатора
}}

EXPORT

: startPhoton
ALSO photonWords DEFINITIONS \ включаем каскадные определения, основной словарь
saveWid  ALSO innerWords \ словарь меток
photonInterpreter &INTERPRET ! \ включаем собственный интерпретатор
;

;MODULE


/TEST
REQUIRE SEE lib/ext/disasm.f
startPhoton
 \ Лёгким движением руки Форт превращается...
 \ Превращается Форт... Форт превращается... 
 \ В изящный типо-Питон!..
 \ ====================== Здесь начинается код =====================

2x2.
	2 2 * . return      Обратите внимание что после слов control-flow можно писать всё что угодно...

 CR .( 2x2. ) 2x2.


test
	DUP 2 MOD 0= if    Чётные числа выводим, нечётные -- пропускаем
			DUP .
	DROP
	return

 CR .( 1 test ) 1 test
 CR .( 2 test ) 2 test

5stars ( -- )                   Напечатать пять звёздочек
	5 for			Повторить 5 раз
		." *"
	return

 CR .( 5stars ) 5stars


1-10. ( -- )                    Напечатать числа от 1 до 10-и
	10 0 do			Цикл от одного до десяти
		I 2 MOD 0= if	Чёт-нечёт
				I .
	return

 CR .( 1-10. ) 1-10.

 \ Рекурсивный вариант:
fact ( n -- fact(n)
	?DUP 0= if
		1 return
	DUP 1- fact * return

 CR 5 DUP .  .( fact=) fact .

 \ Факториал на цикле. Хотя в colorForth'ах циклы 
 \ вырождаются в сочетание if'а (даже без else),
 \ хвостовой оптимизации (она же -- GOTO) и
 \ каскадных определений (они же -- метки).
 \ Эдакое назад в будущее...

fact ( n -- fact(n)
	1 SWAP                \  Ставим аккумулятор на стек внутренней функции
$0 ( acc n )                  метка
	?DUP 0= if            Краевой случай "рекурсии" (он же условие выхода из цикла)
		return
	TUCK * SWAP 1-
	$0 return             Это GOTO $0 , по-сути

 SEE fact

 CR 6 DUP .  .( fact=) fact .

array                DOES>-действие для массивов
	R>
	return

Arr ( -- arr )       Покажем, как обходятся в colorForth'ах без DOES>
	array  \ <-- Это и есть DOES>-действие
 11 , 22 , 33 , 44 , 55 ,

 \ То есть: ...-CODE-действия мы компилируем вручную

getArr ( i -- arr[i] )
	1- CELLS  Arr +
	return

 CR 4 DUP . .( arr=) getArr @ .