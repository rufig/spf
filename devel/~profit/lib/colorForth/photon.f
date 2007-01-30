\ colorlessForth без цвета. Идеи -- Chuck Moore и Terry Loveall.
\ На этот раз для обозначения режима используются разметка и 
\ отступы (при этом отступы работают также визуально видимым
\ control-flow стеком).

\ Интерпретация идёт построчно. Если строка начинается с пробела,
\ значит её нужно исполнить. Если строка начинается с табуляции,
\ то компилируем и выполняем действия из массива табуляций.
\ Во всех остальных случаях строки считаются определением, тогда
\ из строки берётся первое слово и создаётся для него словарная 
\ статья, прочая часть строки игнорируется.

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

\ TODO: Cascading definitions (использовать векторный SHEADER и
\ векторный SFIND использования хэшей как словарей)
\ BUG: Почему return компилируется?.. В _начало_ определений?..

REQUIRE >L ~profit/lib/lstack.f

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
2DUP > 0= WHILE
DUP @ EXECUTE
['] NOOP OVER !
CELL-
REPEAT
2DROP ;

: setTab ( xt i -- )  CELLS tabsArr + ! ;

: OnTabulation ( -- flag ) GetChar SWAP 9 = AND ;

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


:NONAME [COMPILE] IF DROP >L ;
:NONAME L> 1 [COMPILE] THEN ;
control-flow if

:NONAME RET, ;
:NONAME ;
control-flow return

:NONAME ( -- )
OnTabulation   IF tabsCount DUP curTab ! flushTabs [COMPILE] ] INTERPRET_ EXIT THEN
OnDelimiter    IF [COMPILE] [ INTERPRET_ EXIT THEN
CREATE [COMPILE] \ DOES> EXECUTE ;
CONSTANT photonInterpreter

;MODULE

photonInterpreter &INTERPRET !

 \ Лёгким движением руки Форт превращается...
 \ Превращается Форт... Форт превращается... 
 \ В изящный типо-Питон!..

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

1-10. ( -- )                    Напечатать числа от 1 до 10-и
	10 0 do			Цикл от одного до десяти
		I 2 MOD 0= if	Чёт-нечёт
				I .
	return

 CR .( 1-10. ) 1-10.

 \EOF

array                DOES>-действие для массивов
	R>
	return

Arr ( -- arr )       Покажем, как обходятся в colorForth'ах без DOES>
	array  \ <-- Это и есть DOES>-действие
 11 , 22 , 33 , 44 , 55 ,

getArr ( i -- arr[i] )
	1- CELLS  Arr 1 +
	return

 1 getArr .
 SEE array
 SEE Arr