( слова организации для интерфейса со словами библиотек FSL
Калачев А.В. 8.11.2002 diver@forth.org.ru
динамические массивы и матрицы
используется совместно с matrix2_1.f и matrix_3d.f
  слова:
      Столбец_В_Вектор  Строку_В_Вектор  Вектор_В_Столбец  Вектор_В_Строку
      Колонка_В_Вектор  Вектор_В_Колонку
осуществляют обмен данными между матрицей и динамическим одномерным массивом,
в формате fsl-util.f . происходит выделение сигнала из столбца/строки матрицы,
загрузка его в динамичкский массив, где он доступен для дальнейшей обработки,
и выгрузка его на место сделано преимущественно для совместимости с математичес-
кой библиотекой Forth Sietific Library { FSL }, для ее интеграции в SPF

  важно!!!: необходимо следить за переключением типов данных в программе,
  размерность {cell} динамического массива устанавливается set_cell
)

S" fsl-util" SFIND 0= [IF] 2DROP
~diver\fsl-util.f    \ файл "согласования" с FSL
~diver\dynmem.f      \ выделение памяти под дин. массивы
[ELSE] DROP [THEN]

S" НеименМатр" SFIND 0= [IF] 2DROP ~diver\matrix\matrix2_1.f [ELSE] DROP [THEN]
S" НеименМассив" SFIND 0= [IF] 2DROP ~diver\matrix\matrix_3d.f [ELSE] DROP [THEN]

HERE

: set_cell ( new_cell_of_array addr -- ) \ sample: cell & real{ set_cell  
>BODY CELL+ !
;
: Столбец_В_Вектор ( col id addr -- )   \ номер столбца, id-матрицы, адрес массива-получателя
addr ! ТекущаяМатр3 TO col              \ sample: 5 matr1 real{ Столбец_В_Вектор  
Строк3 0 ?DO
I col НачалоМатр3 ВзятьЭлемент addr @ I } запомнить 
LOOP
;
: Строку_В_Вектор ( col id addr -- )   \ номер столбца, id-матрицы, адрес массива-получателя
addr ! ТекущаяМатр3 TO row
Столбцов3 0 ?DO
row I НачалоМатр3 ВзятьЭлемент addr @ I } запомнить
LOOP
;
: Вектор_В_Столбец ( addr col id -- )   \ номер столбца, id-матрицы, адрес массива-получателя
ТекущаяМатр3 TO col addr !              \ sample: real{ 5 matr1 Вектор_В_Столбец  
Строк3 0 ?DO
addr @ I } взять I col НачалоМатр3 ДатьЭлемент
LOOP
;
: Вектор_В_Строку ( addr col id -- )    \ номер столбца, id-матрицы, адрес массива-получателя
ТекущаяМатр3 TO row addr !              \ sample: real{ 5 matr1 Вектор_В_Строку  
Столбцов3 0 ?DO
addr @ I } взять row I НачалоМатр3 ДатьЭлемент
LOOP
;
: Колонка_В_Вектор ( row col id addr -- )
addr ! -ROT TO col TO row 
DUP W@ OVER 2+ W@ * OVER CELL+ + 
SWAP W@ 0 2SWAP ( sm 0 addr2 addr1 )
 CELL+ DO addr @ OVER } TO Временная 
    row col I ВзятьЭлемент Временная запомнить
    1+ OVER
 +LOOP 2DROP
;
: Вектор_В_Колонку ( addr row col id -- )
2SWAP SWAP addr ! TO row SWAP TO col
DUP W@ OVER 2+ W@ * OVER CELL+ + 
SWAP W@ 0 2SWAP ( sm 0 addr2 addr1 )
 CELL+ DO addr @ OVER } взять 
    row col I ДатьЭлемент
    1+ OVER
 +LOOP 2DROP
;
HERE SWAP -
CR .( MATRIX <=> ARRAYS V1.00          08 November 2002   --  ) . .( bytes) 

\EOF тестирование
CR
флоаты
  0 VALUE M1
4 4 НеименМатр TO M1
M1 Формировать
1.e m, 1.e m, 1.e m, 1.e m,
0.e m, 0.e m, 0.e m, 0.e m,
0.e m, 0.e m, 0.e m, 0.e m,
0.e m, 0.e m, 0.e m, 0.e m,
Закончить

8 DARRAY real{  \ динамический массив для реальных чисел
8 DARRAY imm{   \ динамический массив для мнимых чисел

 & real{ 100 }malloc
 2 M1 real{ Столбец_В_Вектор
4 real{ }fprint