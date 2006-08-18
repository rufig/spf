(
Цифровая обработка матриц
планируется:
  - преобразования Фурье по столбцам, по строкам, двумерное { для размерностей
  2**N };
  - фильтры синтезированные и по Фурье-гармоникам;
)
~diver\matrix\matrix_ext.f
HERE
c:\temp\diver\forth\fsl\complex.seq
c:\temp\diver\forth\fsl\cmath.fth
c:\temp\diver\forth\fsl\ffourier.seq
HERE SWAP - SPACE . .( bytes)
\ представленные здесь операции работают с числами с плавающей точкой

HERE

 Private:

\ будем иметь два динамических массива на всякий случай: для реальной и для мнимой части чисел
\ для организации обработки матриц: фурье спектры, фильтры, вычисление спец. функций
8 DARRAY real{  \ динамический массив для реальных чисел
8 DARRAY imm{   \ динамический массив для мнимых чисел
( требуются - float, complex, complex_ext, fsl, dynmem, matrix, ... )
USER-VALUE direction \ 1 прямое преобразование, -1 обратное

 Public:

USER-VECT }}БПФ
' FFT2-2T TO }}БПФ \ 5ms 16x16

: степень2 ( 2**N -- 2**N 2 ) 
DUP 0 SWAP BEGIN 2/ SWAP 1+ SWAP DUP 1 = UNTIL DROP
;
: преобразование_по_столбцам ( id_real id_imm -- )
   ТекущаяМатр2 ТекущаяМатр1
    смещение DUP & real{ set_cell  & imm{ set_cell \ установили cell массивов
    & real{ Строк1 }malloc   & imm{ Строк1 }malloc \ выделили памяти
  Столбцов1 0 ?DO
    I НачалоМатр1 real{ Столбец_В_Вектор \ скопировали действ. и
    I НачалоМатр2  imm{ Столбец_В_Вектор \ мнимую части сигнала
    real{ imm{ Строк1 степень2 direction }}БПФ
      direction 1 = IF 
        real{ Строк1 }FFT-Normalize
         imm{ Строк1 }FFT-Normalize
      THEN
    real{ I НачалоМатр1 Вектор_В_Столбец \ записали действ. и
     imm{ I НачалоМатр2 Вектор_В_Столбец \ мнимую части спектра
  LOOP
  & real{ }free & imm{ }free \ освободили память
;
: преобразование_по_строкам ( id_real id_imm -- ) 
   ТекущаяМатр2 ТекущаяМатр1
    смещение DUP & real{ set_cell  & imm{ set_cell \ установили cell массивов
    & real{ Строк1 }malloc   & imm{ Строк1 }malloc \ выделили памяти
  Строк1 0 ?DO
    I НачалоМатр1 real{ Строку_В_Вектор \ скопировали действ. и
    I НачалоМатр2  imm{ Строку_В_Вектор \ мнимую части сигнала
    real{ imm{ Столбцов1 степень2 direction }}БПФ
      direction 1 = IF 
        real{ Столбцов1 }FFT-Normalize
         imm{ Столбцов1 }FFT-Normalize
      THEN
    real{ I НачалоМатр1 Вектор_В_Строку \ записали действ. и
     imm{ I НачалоМатр2 Вектор_В_Строку \ мнимую части спектра
  LOOP
  & real{ }free & imm{ }free \ освободили память
;
: 2-х_БПФ ( id_real id_imm direction -- )
\ двумерное преобразование Фурье - для матриц размера 2**N X 2**M
  TO direction
  2DUP преобразование_по_столбцам
  преобразование_по_строкам
;
: действ-компл ( id -- id_real id_imm )     \ id-действ. матрица
\ дает комплексный вид действительной матрицы
  DUP НоваяМатр >R ноль R@ Инициализировать \ -- id  r: id_imm
  DUP НоваяМатр 2DUP КопироватьМатр NIP     \ -- id_real  r: id_imm
  R>                                        \ -- id_real id_imm
;
: амплитуда,фаза ( id_real id_imm -- ) \
\ преобразует спектр вида [Действ.] [Мним.] в [Ампл.] [Фаза.]
ТекущаяМатр2 ТекущаяМатр1
  Строк1 0 ?DO
    Столбцов1 0 ?DO
    J I НачалоМатр2 ВзятьЭлемент \ f: -- y x
    J I НачалоМатр1 ВзятьЭлемент \
    F2DUP FDUP F* FSWAP FDUP F* F+ FSQRT \  f: -- y x r
    J I НачалоМатр1 ДатьЭлемент  \ амплитуда
    F/ FATAN
    J I НачалоМатр2 ДатьЭлемент  \ фаза ( в радианах)
    LOOP
  LOOP
;

Reset_Search_Order

HERE SWAP -
  CR .( 2D DSP            V1.00          10 November 2002   --  ) . .( bytes)
  CR
\ EOF тестирование

флоаты

  0 VALUE M1
(
4 4 НеименМатр TO M1
M1 Формировать
1.e m, 0.e m, 1.e m, 0.e m,
0.e m, 1.e m, 0.e m, 1.e m,
1.e m, 0.e m, 1.e m, 0.e m,
0.e m, 1.e m, 0.e m, 1.e m,
Закончить
 )

 WINAPI: GetTickCount KERNEL32.DLL
 16 16 НеименМатр TO M1
: TEST
\ 16 16 НеименМатр TO M1
 S" matrix_test" M1 Инициализировать_из_Файла
M1 
." ___________" CR
DUP ПечататьМатрицу
." ___________" CR
действ-компл
2DUP 1 
GetTickCount >R
2-х_БПФ
GetTickCount >R
SWAP 
2DUP
ПечататьМатрицу CR ПечататьМатрицу
Освободить Освободить
M1 Освободить
R> R> - CR . ." - ms processing"
;

STARTLOG
 TEST
ENDLOG \ BYE