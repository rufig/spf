MODULE: COFFRESOURCES

0 VALUE h
0 VALUE #sections
0 VALUE start

: lseek ( offset --)
  S>D h REPOSITION-FILE ABORT" Ошибка ввода-вывода" ;
: read ( adr # --)
  h READ-FILE ABORT" Ошибка ввода-вывода" DROP ;
: wordat ( offset -- w)
  lseek 0 >R  RP@ 2 read R> ;
: cellat ( offset -- n)
  lseek 0 >R  RP@ 4 read R> ;

: find-rsrc ( offset -- offset)
  BEGIN #sections WHILE
    DUP cellat 0x7273722E ( .rsr) = OVER CELL+ cellat 0x00000063 ( s\0\0\0) 
    = AND IF EXIT THEN \ нашли секцию
    40 + ( длина заголовка секции) 
    #sections 1- TO #sections
  REPEAT 
  ABORT" В файле отсутствует секция .rsrc" ;

: relocate ( adr xt -- ) 
\ применить ко всем элементам каталога adr слово xt
  >R
  DUP 12 + W@ ( именованные записи) OVER 14 + W@ ( неименованные записи) +
  SWAP 16 + SWAP
  BEGIN ( adr #) DUP WHILE
    OVER CELL+ @ 0x7FFFFFFF AND start + R@ EXECUTE
  SWAP 2 CELLS + ( длина записи) SWAP 1-
  REPEAT 2DROP
  RDROP
;

: relocate3 ( leaf --) RESOURCES-RVA @ SWAP +! ;
: relocate2 ( dir -- ) ['] relocate3 relocate ;
: relocate1 ( dir -- ) ['] relocate2 relocate ;

EXPORT

: COFFRESOURCES: ( ->eol; -- )
  1 WORD COUNT R/O OPEN-FILE ABORT" Файл ресурсов не найден" TO h
  2 wordat TO #sections \ число секций в файле
  20 ( длина заголовка) 16 wordat ( длина вспомогательного заголовка) +
  find-rsrc DUP 20 + cellat ( начало секции в файле) >R
  16 + cellat ( длина секции ресурсов)
  HERE DUP TO start IMAGE-BASE - RESOURCES-RVA ! R> lseek
  DUP ALLOT DUP RESOURCES-SIZE ! start SWAP read
  start ['] relocate1 relocate \ добавить ко всем адресам ресурсов RESOURCES-RVA
  h CLOSE-FILE DROP
;

;MODULE
