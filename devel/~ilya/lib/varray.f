\ varray.f - работа с 2-х мерными массивами 
\ Абдрахимов Илья 11.01.2007г.
\ Особенности: 
\ 1. "автоматическое" освобождение памяти при удалении массива
\ 2. "автоматическое" освобождение памяти при замене значения
 
\ Использование:
\
\ NEW-ARRAY  ( col row -- arr ) - Создать массив 
\ Где: col - количество полей (колонок), row - кол-во записей (строк),
\ arr - указатель на массив
\
\ DEL-ARRAY ( arr -- ) - "полностью" освобождаем память выделенную под массив
\ Где: arr - указатель полученный при создании массива
\
\ PUT-CELL ( val col row arr -- ) - поместить в массив arr, по адресу col row значение val
\
\ PUT-DOUBLE ( ud col row arr -- ) - поместить в массив arr, по адресу col row значение ud (двойной длины)
\
\ PUT-STRING ( adr n col row arr -- ) - поместить в массив строку
\
\ GET-CELL ( col row arr -- var ) - получить из массива arr, по адресу col row значение val
\
\ GET-DOUBLE ( col row arr -- ud ) - получить из массива arr, по адресу col row значение ud (двойной длины)
\
\ GET-STRING ( col row arr -- adr ) - получить из массива arr, по адресу col row строку adr n
\ !!! если случайно в данной ячейке содержится не строка, то получим строку нулевой длины
\
\ MOVE-ALLEND-REC ( n1 n2 arr -- ) - переместить в n2 все последние записи начиная с n1
\ при этом в замещяемой производится "автоматическое" освобождение памяти

\ REQUIRE MemReport ~day/lib/memreport.f
REQUIRE { lib\ext\locals.f
REQUIRE CASE lib\ext\case.f
REQUIRE S>ZALLOC ~nn/lib/az.f

MODULE: varray
\
\ Структура записи
0 
2		-- fType	\ Тип данных
CELL	-- fSize	\ Размер
CELL	-- fValue	\ Значение
CONSTANT /FSIZE


\ Структура служебки
0
CELL	-- scol		\ количество колонок
CELL	-- srow		\ количество строк
CELL	-- slrow		\ последняя непустая запись
CONSTANT /SYSIZE

EXPORT
\ Типы данных
0 CONSTANT tNull	\ Пусто
1 CONSTANT tCell	\ Обычное значение (ячейка)
2 CONSTANT tString	\ Указатель на нуль строку
3 CONSTANT tDouble	\
4 CONSTANT tFloat	\
5 CONSTANT tArray	\ Произвольные данные

DEFINITIONS


\ Обработчик ошибок
VECT THROW-ARRAY
:NONAME ABORT" Error in varray !" ; TO THROW-ARRAY


\ Проверяем соответствие диапазона
: RANGE-ARRAY? ( col row arr -- f )
>R 0 R@ srow @ 1+ WITHIN
SWAP
0 R> scol @ 1+ WITHIN
AND 
;

\ Вычисляем адрес элемента в массиве
: EL-ADR ( col row arr -- adr )
>R 2DUP R@ RANGE-ARRAY?
	IF 
		R@ scol @ /FSIZE *	\ Байт в записи
		* 
		SWAP ( R@ srow @) /FSIZE *			\ 
		
		+
		/SYSIZE +		\ + размер служебной части
		R> +				\
		
	ELSE
		2DROP 0 RDROP
	THEN 
;

\ Получить адрес записи n (первого поля в записи)
: REC-ADR ( n arr -- adr )
SWAP 0 SWAP ROT EL-ADR
;

\ Получить элемент из массива
: GET-EL { \ adr -- } ( col row arr -- val size type )
EL-ADR ?DUP 
	IF 
		TO adr
		adr fValue @ 
		adr fSize @
		adr fType W@
			
	ELSE 
		tNull tNull tNull
	THEN
;



\ Положить элемент в массив
: PUT-EL { type size val col row arr \ adr -- }
col row arr EL-ADR ?DUP 
	IF 
		TO adr
		val adr fValue ! 
		type adr fType W!
		size adr fSize !
		arr slrow @ row < IF row arr slrow ! THEN
	
	THEN
;


: CHANGE-EL { type size val col row arr \ val1 size1 -- }
col row arr GET-EL >R TO size1 TO val1 R>
	CASE
		tNull	OF type size val col row arr PUT-EL ENDOF
		tCell	OF type size val col row arr PUT-EL ENDOF
		tString	OF 
					val1 FREE THROW-ARRAY
					type size val col row arr PUT-EL 
				ENDOF
		tDouble	OF
					val1 FREE THROW-ARRAY
					type size val col row arr PUT-EL 
				ENDOF
	ENDCASE


;

EXPORT

\ Изменяем вектор обработки ошибок на свой
: CHANGE-THROW-ARRAY ( xt -- )
TO THROW-ARRAY
;

\ Создаём новый массив
: NEW-ARRAY ( col row -- arr ) 
2DUP 
SWAP /FSIZE * * /SYSIZE + \ 16 +
ALLOCATE THROW-ARRAY 
DUP >R srow ! 
R@ scol ! 
0 R@ slrow ! 
R@ /SYSIZE +
R@ srow @
R@ scol @ /FSIZE * * 
ERASE 
R>
;

\ Положить число в массив
: PUT-CELL ( val col row arr -- )
2>R 2>R
tCell 1 2R> 2R> CHANGE-EL
;

\ Положить строку в массив
: PUT-STRING ( adr n col row arr -- )
2>R >R S>SZ tString SWAP ROT R> 2R> CHANGE-EL 
;

\ Положить число двойной длины в массив
: PUT-DOUBLE { v1 v2 col row arr -- }
tDouble ^ v2 2 CELLS  S>ZALLOC 2 CELLS SWAP col row arr CHANGE-EL 
;

\ Получить число из массива
: GET-CELL ( col row arr -- val )
GET-EL 2DROP
;

\ Получить строку из массива
: GET-STRING ( col row arr -- adr n )
GET-EL tString <> IF  2DROP PAD 0 THEN
;
\ Получить число двойной длины
: GET-DOUBLE
GET-EL tDouble <> IF  2DROP 0. ELSE DROP 2@ THEN
;

\ Перемещаем все записи начиная с n1 b до конца массива, в n2
: MOVE-ALLEND-REC { n1 n2 arr -- }
n1 n2 
?DO
	arr scol @ 0
	?DO
		I J	arr GET-EL
		tCell > IF DROP FREE THROW-ARRAY ELSE 2DROP THEN
	LOOP
LOOP

n1 arr REC-ADR		\ adr1
n2 arr REC-ADR		\ adr1 adr2
arr srow @ n1 -
arr scol @ /FSIZE * * \ adr1 adr2 col's
OVER OVER 2>R
MOVE
2R> + arr srow @ DUP n1 n2 - - -
DUP arr srow @ SWAP - arr slrow !	\ 
arr scol @ /FSIZE * * 
ERASE			\ Перемещённый участок зануляем
;

\ Добавить одну запись (с данными) в конец массива.
\ При этом если достигнут конец массива, то происходит освобождение первой записи и смещение
\ оставшихся в начало
\ Входные данные: dat type ... datn typen arr, где dat type ... datn typen - пары значение и тип
\ в количестве соответсвующем количеству полей записи, arr - указатель на массив
: ADD-REC-ARRAY { arr \ cur -- } ( i*x arr -- )
arr srow @ arr slrow @
> IF 
arr slrow @ TO cur
arr scol @ 0 ?DO 
			CASE
				tCell 	OF I cur arr PUT-CELL ENDOF
				tString	OF I cur arr PUT-STRING ENDOF
				tDouble	OF I cur arr PUT-DOUBLE ENDOF
			ENDCASE
			\ cur_rec_array arr rec_adr I CELLS + !
		LOOP
	 arr slrow 1+!
ELSE
1 0 arr MOVE-ALLEND-REC
arr slrow @  TO cur
arr scol @ 0 ?DO 
			CASE
				tCell 	OF I cur arr PUT-CELL ENDOF
				tString	OF I cur arr PUT-STRING ENDOF
				tDouble	OF I cur arr PUT-DOUBLE ENDOF
			ENDCASE
			\ cur_rec_array arr rec_adr I CELLS + !
		LOOP
THEN

;


\ Изничтожаем массив
: DEL-ARRAY { arr -- }
arr slrow @ 0 
	?DO
		arr scol @ 0
			?DO
				I J arr GET-EL 
					tCell >  
						IF DROP FREE THROW-ARRAY ELSE 2DROP THEN
			LOOP
			
	LOOP
arr ?DUP IF FREE THROW-ARRAY THEN
;

;MODULE


\EOF
: test2 { \ ar -- }
2 11 NEW-ARRAY TO ar
7 0 DO
1. 3 2. 3 ar ADD-REC-ARRAY
\ 0x1111 1 0x2222 1 ar ADD-REC-ARRAY
\ 0x1111 1 0x2222 1 ar ADD-REC-ARRAY

\ 0x111 0 0 ar PUT-CELL
\ 0x111 1 0 ar PUT-CELL
\ S" ilya" 0 0 ar PUT-STRING
\ S" Abdrahimov" 1 0 ar PUT-STRING
\ S" Arkadyevich" 2 0 ar PUT-STRING
\ 1 0 ar GET-STRING CR TYPE
\ 0 0 ar GET-STRING CR TYPE
\ 2 0 ar GET-STRING CR TYPE
 LOOP
CR ar 200 DUMP
\ 0 0 ar GET-DOUBLE CR ." val=" D.
ar DEL-ARRAY
;
test2

\EOF
: test { \ va t1 -- }
3 10 NEW-ARRAY TO va
300 ALLOCATE THROW TO t1
t1 300 0x111 FILL

\ DUP >R 0 1 R> RANGE-ARRAY? CR ." fl=" .
\ DUP >R 1 1 R> EL-ADR CR .( adr1=) .
\ DUP >R 1 2 0x1173 0 1 R> PUT-EL

\ 0x1173 2 9 va PUT-CELL
\ 0x2222 2 1 va PUT-CELL
\ 0x1111 0 7 va PUT-CELL
2 9 va GET-CELL CR ." el=" .

\ S" ilya"  0 0 va PUT-STRING 
\ S" ilya"  1 0 va PUT-STRING 
\ S" ilya"  2 0 va PUT-STRING 

1.  0 0 va PUT-DOUBLE 
2.  1 0 va PUT-DOUBLE 
3.  2 0 va PUT-DOUBLE 
va 500 CR DUMP

CR ." first dump" CR
\ 7 2 va MOVE-ALLEND-REC
0 2 va GET-CELL CR ." el=" .
va 500 CR DUMP
0 1 va GET-STRING CR ." str=" TYPE

t1 FREE THROW
va DEL-ARRAY
;
test


\EOF
: test1 { \ ar -- }
3 10 NEW-ARRAY TO ar

10 0 
DO 
	10 0 CR
	DO
		\ I J 10 * + DUP . I J ar PUT-CELL
		 I J 10 * + DUP . S>D I J ar PUT-DOUBLE
		\ S" Test" I J ar PUT-STRING
	LOOP
LOOP
 4 3 ar GET-DOUBLE CR ." str=" D. CR
ar 1200 DUMP CR
\ MemReport
 8 2 ar MOVE-ALLEND-REC
\ MemReport
\ 1 3 ar GET-STRING CR ." str=" TYPE CR
 ar 1200 DUMP

ar DEL-ARRAY
CR ." the end!"
;
test1








\ MemReport


\ MemReport
\ HERE SWAP - CR .( Total Size= ) .