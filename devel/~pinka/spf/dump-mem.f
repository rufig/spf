( Apr.2011 ruv

  Модуль расширения SPF/4.
  Назначение: вывод отчета об используемой  форт-системой памяти под Windows.

  DUMP-MEM -- вывод полного отчета по всем хипам, независимо от потоков.
  Для каждого хипа выводится сумма занятной памяти. Для базовых хипов
  форт-потоков также выводится информация по каждому использованому блоку памяти
  [адрес, размер, точка в объектном коде, название словаря и имя слова].
  Для читабельного вывода предполагается ширина буфера экрана консоли от 110 символов.

  DUMP-HEAP [ heap -- ] -- вывод отчета по заданному хипу.

  ' DUMP-HEAP-SUM ENUM-HEAPS-FORTH -- вывод сумм по базовым хипам.
)

REQUIRE ENUM-HEAPS-FORTH ~pinka/spf/enum-heaps-forth.f
\ REQUIRE U.R              lib/include/core-ext.f

REQUIRE U.RS             ~pinka/lib/print.f

: U.R ( u n -- ) U$R TYPE ;

: (HEAP-SIZE-BUSY) ( sum1 addr u -- sum2 )
  NIP +
;
: HEAP-SIZE-BUSY ( heap -- u )
  0 SWAP
  ['] (HEAP-SIZE-BUSY) FOR-HEAP
;


: DUMP-HEAP-SUM ( heap -- )
  DUP IS-HEAP-FORTH IF S" heap.forth " ELSE S" heap.other " THEN TYPE
  DUP
  10 U.R SPACE

  ." sum   " HEAP-SIZE-BUSY
  0 10 U.R SPACE 
  12 U.RS CR
;
: DUMP-BLOCK-FORTH ( addr u -- )
  ." entry " OVER
  10 U.R SPACE 
  12 U.RS SPACE
  @ DUP 10 U.R SPACE WordByAddr ( d-name )
  FOUND-VOC @ ?DUP IF 
      VOC-NAME. 
      ."  / "
  THEN
  ( d-name ) TYPE
  CR
;
: (DUMP-HEAP-FORTH) ( heap addr u -- heap )
  ."  blk.forth "
  2 PICK
  10 U.R SPACE

  DUMP-BLOCK-FORTH
;
: DUMP-HEAP-FORTH ( heap -- )
  \ DUP . ." forth  " CR
  DUP DUMP-HEAP-SUM
  DUP ['] (DUMP-HEAP-FORTH) FOR-HEAP
  DROP
;

: DUMP-HEAP ( heap -- )
  DUP IS-HEAP-FORTH IF DUMP-HEAP-FORTH ELSE DUMP-HEAP-SUM THEN
;
: DUMP-MEM ( -- )
  ['] DUMP-HEAP ENUM-HEAPS
;
: DUMP-MEM-OTHER ( -- )
  ['] DUMP-HEAP ENUM-HEAPS-OTHER
;
: DUMP-MEM-FORTH ( -- )
  ['] DUMP-HEAP ENUM-HEAPS-FORTH
;

\EOF

 ' DUMP-HEAP-SUM ENUM-HEAPS-FORTH
