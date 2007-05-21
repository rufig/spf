\ 18-05-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ решение задачи с конкурса открытого на форуме
\ преобазование символов табуляций в пробелы и обратно

\ -- полезные слова ---------------------------------------------------------

\ добавить число к находящемуся на стеке возвратов
: R+ ( r: a d: b --> r: a+b ) 2R> -ROT + >R >R ;

\ резервировать на HERE n байт памяти, заполнить их байтом char »
: ALLOTFILL ( n char --> ) HERE OVER ALLOT -ROT FILL ;

\ выравнять число base на указанное значение n »
\ граница выравнивания произвольная.
\ выравнивание производится в большую сторону
: ROUND ( n base --> n ) TUCK 1 - + OVER / * ;



   0x09 CONSTANT tab_  \ код символа табуляции

\ -- формирование результирующей строки -------------------------------------

        USER-VALUE buffer  \ адрес временного буфера
        USER-VALUE out>    \ позиция с которой можно добавлять данные в буфер

     20 CONSTANT tab-limit \ предельный размер табуляции

   CREATE spaces_ tab-limit BL ALLOTFILL \ строка пробелов

\ добавление в буфер строки asc # к уже имеющимся
: >out ( asc # --> ) DUP IF out> SWAP 2DUP + TO out> CMOVE ELSE 2DROP THEN ;
: c>out ( char --> ) out> TUCK C! 1 CHARS + TO out> ;

\ вывести в буфер указанное кол-во пробелов
: gap ( # --> ) spaces_ SWAP tab-limit UMIN >out ;

\ получить адрес и длинну собранной в буфере строки
: result> ( --> asc # ) buffer out> OVER - ;

\ освобождение буфера
: free-result ( --> ) buffer IF buffer FREE THROW 0 TO buffer THEN ;

\ инициализация буфера
: init-buffer ( # --> )
              free-result
              CELLS ALLOCATE THROW
              DUP TO buffer TO out> ;

\ -- преобразование табуляций в пробелы -------------------------------------

\ посчитать количество пробелов на одну табуляцию для указаной позиции
: space# ( pos tab# --> spaces )
         TUCK OVER >R ROUND R> -
         DUP IF NIP ELSE DROP THEN ;

\ выделить из строки подстроку, оканчивающуюся указанным символом
: piece ( src # char --> res # )
        >R OVER + OVER
        BEGIN 2DUP <> WHILE       \ пока есть символы в строке
              DUP C@ R@ <> WHILE  \ пока символ не найден
            1 CHARS +
          REPEAT
        THEN RDROP NIP OVER - ;

\ разделить строку на две подстроки по символу char
: split ( src # char --> rest # res # )
        >R 2DUP R> piece TUCK 2>R - NIP 2R@ + SWAP 2R> ;

\ позиция последнего символа в выходном буфере
: pos ( --> u ) out> buffer - ;

\ преобразовать одиночную строку,
\ содержащую символы табуляции в строку с пробелами
: tabs>spaces ( src # tab# --> res # )
              OVER init-buffer >R
              BEGIN tab_ split >out  DUP WHILE
                    pos R@ space# gap
                  SKIP1
              REPEAT RDROP 2DROP result> ;

\ -- преобразование пробелов в табуляции ------------------------------------

        USER inpos \ текущая позиция

\ посчитать количество пробелов от начала строки
: count-spaces ( asc # --> res # n )
               0 >R OVER + SWAP
               BEGIN 2DUP <> WHILE     \ пока не конец строки
                     DUP C@ BL = WHILE \ пока пробелы
                   1 R+ 1 CHARS +
                 REPEAT
               THEN TUCK - R> ;

\ преобразовать пробелы, если возможно в табуляции
: convert-spaces ( pos n tab# --> )
                 >R BEGIN DUP WHILE
                          OVER R@ space#  2DUP < 0= WHILE
                          DUP inpos +!
                          TUCK - >R + R>
                        tab_ c>out
                      REPEAT SWAP DUP inpos +! gap
                    THEN RDROP 2DROP ;

\ преобразовать одиночную строку src #, содержащую пробелы
\ в строку содержащую табуляции вместо подходящих длинных
\ последовательностей пробелов.
: spaces>tabs ( src # tab# --> res # )
              OVER init-buffer >R  0 inpos !
              BEGIN BL split DUP inpos +! >out  DUP WHILE
                    count-spaces inpos @
                    SWAP R@ convert-spaces
              REPEAT RDROP 2DROP result> ;

\ EOF -- тестовая секция ----------------------------------------------------

\ загрузить содержимое файла в буффер
: source ( FileName # --> addr # )
         R/O OPEN-FILE THROW >R
           R@ FILE-SIZE THROW DROP
              DUP ALLOCATE THROW
           TUCK SWAP R@ READ-FILE THROW
         R> CLOSE-FILE THROW ;

S" sample.txt" source
              2DUP TYPE 2DUP DUMP CR
8 tabs>spaces 2DUP TYPE 2DUP DUMP CR
8 spaces>tabs 2DUP TYPE DUMP CR

