\ Замыкания или частично определённые функции.
\ Функция задаётся строкой, которая компилируется в кучу. 
\ При откате занятая функцией область в куче снимается.

\ S" 2 DUP * ." axt ( xt ) -- выдаст на стек адрес кода
\ который соответсвует коду получившемуся при компиляции
\ строки

\ Взятый таким образом отрезок кода необходимо снимать
\ словом DESTROY-VC (~profit/lib/compile2Heap.f)

\ Чтобы снимать отрезок кода автоматически, при выходе 
\ из текущего определения (или при поднятии "из глубины"
\ bac4th-успеха) можно использовать axt=>
\ S" 2 DUP * ." axt=> ( xt )

\ Возможно также отрезок кода задать в несколько строк
\ через динамические строки ~ac/lib/str5.f
\ (строка со стека освобождается внутри слова):
\ " 2 DUP
\ * . " straxt=> ( xt )

\ При этом в генерируемый отрезок кода кода можно скомпилировывать
\ свои куски, задавая их на стеке или выполняя компилирующие действия
\ IMMEDIATE-словами подобными LITERAL , его можно использовать для
\ передачи числа на стеке в компилируемую функцию:
\ 4 2 1 S" LITERAL LITERAL + LITERAL * ." axt EXECUTE
\ Сформирует код "1 2 + 4 *" и выполнив его, напечатает: "12"

\ Или же можно входить напрямую в режим интерпретации словами [ и ] :
\ ' . S" 3 0 DO I [ COMPILE, ] LOOP " axt EXECUTE
\ выведет 0 1 2
\ Действие для обработки чисел мы задали снаружи замыкания ( ' . )
\ [ COMPILE, ] вкомпилировал xt внутрь генерируемой функции

\ Такая передача значений, внутрь "замыкания", противоречит
\ следующему абзацу пункта 3.2.3.2 ANS-94:

\ "Стек потока-управления, может, но не обязательно, физически 
\ существовать в реализации. Если он существует, то может быть,
\ но не обязательно, реализован с использованием стека данных.
\ Формат стека потока-управления -- определяется  реализацией.
\ Так как стек потока-управления  может быть реализован с 
\ использованием стека данных, элементы, помещенные на стек 
\ данных недоступны для программ после помещения элементов
\ на стек потока-управления, и остаются недоступным до удаления 
\ элементов стека потока-управления."

\ REQUIRE MemReport ~day/lib/memreport.f

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE VC-COMPILED ~profit/lib/compile2Heap.f
REQUIRE A_BEGIN ~mak/lib/a_if.f
REQUIRE STR@ ~ac/lib/str5.f

MODULE: bac4th-closures

\ Используем структуры управления с отдельным control-flow stack
: BEGIN [COMPILE] A_BEGIN ; IMMEDIATE
: WHILE	[COMPILE] A_WHILE ; IMMEDIATE
: AHEAD	[COMPILE] A_AHEAD ; IMMEDIATE
: IF 	[COMPILE] A_IF ; IMMEDIATE
: ELSE	[COMPILE] A_ELSE ; IMMEDIATE
: THEN	[COMPILE] A_THEN ; IMMEDIATE
: AGAIN	[COMPILE] A_AGAIN ; IMMEDIATE
: REPEAT [COMPILE] A_REPEAT ; IMMEDIATE
: UNTIL [COMPILE] A_UNTIL ; IMMEDIATE

\ Создаём отдельные структуры циклов в своём модуле,
\ чтобы они тоже использовали отдельный control-flow stack
: DO    CS-SP>< POSTPONE DO    CS-SP>< ; IMMEDIATE
: ?DO   CS-SP>< POSTPONE ?DO   CS-SP>< ; IMMEDIATE
: LOOP  CS-SP>< POSTPONE LOOP  CS-SP>< ; IMMEDIATE
: +LOOP CS-SP>< POSTPONE +LOOP CS-SP>< ; IMMEDIATE

EXPORT

: axt ( addr u -- xt )
CREATE-VC >R \ создаём виртуальный кодофайл
ALSO bac4th-closures \ подключаем словарь с своими структурами управления
R@ VC-COMPILED \ компилируем строку в виртуальный кодофайл
PREVIOUS \ отключаем его по окончании компиляции
R@ VC-RET, \ ставим команду выхода
R> \ оставляем исполняемый адрес начала кодофайла
;

: axt=> ( addr u --> xt \ <-- ) PRO
axt \ компилируем строку, берём исполняемый адрес кода
BACK DESTROY-VC TRACKING RESTB \ по окончании обработки очистить кодофайл
CONT \ и кидаем его наверх
;

\ То же самое что и compiledCode , но с динамическими строками из ~ac/lib/str5.f
\ Это позволяет писать код в несколько строк
\ Поданая на вход строка сразу после использования освобождается
: straxt=> ( s --> xt \ <-- ) PRO
START{ BACK STRFREE TRACKING RESTB STR@ axt }EMERGE
BACK DESTROY-VC TRACKING RESTB CONT ;

: compiledCode ( addr u --> xt \ <-- ) \ синоним для axt=>
RUSH> axt=> ;

: STRcompiledCode  ( s --> xt \ <-- ) RUSH> straxt=> ;

;MODULE

/TEST
REQUIRE TYPE>STR ~ygrek/lib/typestr.f
REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE MemReport ~day/lib/memreport.f
\ REQUIRE SEE lib/ext/disasm.f

TESTCASES bac4th-closures

\ Переносим данные со стека внутрь генерируемого кода
:NONAME 4 2 1 S" LITERAL LITERAL + LITERAL * ." axt=> EXECUTE ; TYPE>STR
DUP STR@ S" 12 " TEST-ARRAY STRFREE

\ Переносим данные со стека внутрь цикла генерируемого кода
:NONAME 23 100 5 S" 0 BEGIN DUP LITERAL < WHILE LITERAL LITERAL + . 1+ REPEAT DROP " axt=> EXECUTE ; TYPE>STR
DUP STR@ S" 123 123 123 123 123 " TEST-ARRAY STRFREE

\ Переносим данные со стека внутрь цикла генерируемого кода
:NONAME 11 S" 3 0 DO LITERAL . LOOP" axt=> EXECUTE ;  TYPE>STR
DUP STR@ S" 11 11 11 " TEST-ARRAY STRFREE

\ Вписываем код взятый снаружи, "внутрь" замыкания
:NONAME ['] . S" 3 0 DO I [ COMPILE, ] LOOP " axt=> EXECUTE ; TYPE>STR
DUP STR@ S" 0 1 2 " TEST-ARRAY STRFREE

\ Теперь тоже самое только с straxt=>

\ Переносим данные со стека внутрь генерируемого кода
:NONAME 4 2 1 "
LITERAL LITERAL + LITERAL * ." straxt=> EXECUTE ; TYPE>STR
DUP STR@ S" 12 " TEST-ARRAY STRFREE

\ Переносим данные со стека внутрь цикла генерируемого кода
:NONAME 23 100 5 "
0 BEGIN
DUP LITERAL < WHILE
LITERAL LITERAL + . 1+ REPEAT
DROP " straxt=> EXECUTE ; TYPE>STR
DUP STR@ S" 123 123 123 123 123 " TEST-ARRAY STRFREE

\ Переносим данные со стека внутрь цикла генерируемого кода
:NONAME 11 "
3 0 DO
LITERAL .
LOOP" straxt=> EXECUTE ;  TYPE>STR
DUP STR@ S" 11 11 11 " TEST-ARRAY STRFREE

\ Вписываем код взятый снаружи, "внутрь" замыкания
:NONAME ['] . "
3 0 DO
I [ COMPILE, ]
LOOP " straxt=> EXECUTE ; TYPE>STR
DUP STR@ S" 0 1 2 " TEST-ARRAY STRFREE

(( countMem -> 0 0 ))

END-TESTCASES