\ RipDLL 1.00	7.04.2003
\ Взять из предоставленной динамической библиотеки имена всех 
\ экспортируемых функций и сохранить их в формате .names для 
\ дальнейшего применения с USEDLL
\ Ю. Жиловец, http://www.forth.org.ru/~yz
\ ------------------------------------------
REQUIRE "        ~yz/lib/common.f
REQUIRE )>       ~yz/lib/format.f
REQUIRE MAP-OPEN ~yz/lib/mapfile.f
REQUIRE {        lib/ext/locals.f

\ ------------------------------------------
CREATE input-file  256 ALLOT
CREATE output-file 256 ALLOT

\ ------------------------------------------

: err  ." RIPDLL: " .ASCIIZ CR BYE ;
: ?err ( ? z --) SWAP IF err ELSE DROP THEN ;

: my-error ( ERR-NUM -> ) \ показать расшифровку ошибки
  DUP -2 = IF DROP 
                ER-A @ ER-U @ PAD CZMOVE PAD err
           THEN
  >R <( R> DUP " Ошибка ~N (0x~06H)" )> err ;
\ ------------------------------------------

0 VALUE mapin
0 VALUE base
0 VALUE /dosheader

: offset ( n -- n ) base + ;
: file@ ( n -- n) offset @ ;
: filew@ ( n -- w) offset W@ ;
: --> ( n -- ) file@ offset ;

: open-input-file 
  input-file ASCIIZ> MAP-OPEN DUP 0= " Не могу открыть входной файл" ?err
  DUP @ TO base TO mapin
  0 offset W@ 0x5A4D <> " Файл не является исполняемым" ?err
  0x3C --> DUP @ 0x4550 <> " Файл не в формате Portable Executable" ?err
  0x3C file@ TO /dosheader
  TO base \ с этого момента смещения в файле начинаем отмерять от нового заголовка PE
  0x16 file@ 0x2000 AND 0= " Файл не является динамической библиотекой" ?err
;

\ --------------------------------

0 VALUE out

: open-output-file 
  output-file ASCIIZ> W/O CREATE-FILE 
  " Не могу создать выходной файл" ?err TO out ;

: (write) ( a n -- ) out WRITE-FILE " Ошибка записи" ?err ;

: write ( z -- ) ASCIIZ> 1+ (write) ;
: write-cell ( n -- ) HERE ! HERE 4 (write) ;
: write-byte ( c -- ) HERE C! HERE 1 (write) ;

: seek ( d -- ) out REPOSITION-FILE " Не могу переместить файловый указатель" ?err ;

\ ------------------------------------------

: close-all
  out CLOSE-FILE DROP 
  mapin MAP-CLOSE ;

\ ------------------------------------------
\ Находим секцию, к которой относится таблица экспорта
\ и устанавливаем base таким образом, чтобы он отмерял смещения
\ от начала образа исполняемого файла, то есть пересчитывал 
\ RVA нашей секции в адреса отображаемого файла.
: find-export-section ( -- exportRVA)
  0x78 file@ \ RVA таблицы экспорта
  \ находим начало таблицы секций: она идет сразу после заголовка файла
  0x74 file@ 2* CELLS 0x78 + 0x6 filew@ ( число секций) 
  10 CELLS ( размер описателя секции) * OVER + SWAP DO
    DUP I 0x0C + file@ ( RVA секции)
    DUP I 0x08 + ( размер секции) file@ + WITHIN IF 
      I 0x14 + ( смещение секции в файле) file@ I 0x0C + file@  - 
      base + /dosheader - TO base
      UNLOOP EXIT
    THEN
  10 CELLS ( размер описателя секции) +LOOP
  " Входной файл испорчен: таблица экспорта не содержится ни в какой секции" err
;

VARIABLE ptr

: word1 ( n -- z) 10 MOD 1 = IF " ое" ELSE " ых" THEN ;
: word2 ( n -- z)
  DUP 100 MOD 11 20 WITHIN IF 
    DROP " ен"
  ELSE
    10 MOD CASE
    1 OF " я" ENDOF
    DUP 2 5 WITHIN =OF " ени" ENDOF
    DROP " ен"
    END-CASE
  THEN ;

: rip-names { \ export name# libname stable names -- }
  find-export-section TO export
  export 0x18 + file@ TO name#
  export 0x0C + --> TO libname
  export 0x20 + file@ TO names
  <( libname name# DUP word1 OVER word2 " ~Z: ~N экспортируем~Z им~Z~/" )> .ASCIIZ
  name# CELLS GETMEM TO stable
  out FILE-POSITION " Не могу определить положение файлового указателя" ?err
  3 name# + CELLS S>D D+ seek
  3 name# + CELLS ptr !
  name# 0 ?DO
    ptr @ I CELLS stable + !
    -1 write-cell
    ptr CELL+!
    I CELLS names + --> ASCIIZ> DUP 2+ ptr +!
    DUP write-byte (write)
    0 write-byte
  LOOP
  0 write-cell
  libname write
  0. seek
  CELL" NAME" write-cell
  ptr @ write-cell name# write-cell
  stable name# CELLS (write)
  stable FREEMEM
;

\ ------------------------------------------
: ?next ( "name" или name<BL> -- a # / 0)
  PeekChar c: " = IF c: " ELSE BL THEN WORD
  DUP C@ 0= IF DROP 0 EXIT THEN
  COUNT OVER C@ c: " = IF 2 - SWAP 1+ SWAP THEN ( убрал кавычки, если есть)
;

: -ext { a n -- a #1 }
  a n + 1-
  BEGIN DUP a < NOT WHILE
    DUP C@ c: . = IF a - a SWAP EXIT THEN
    1-
  REPEAT DROP a n ;

: +ext ( a # -- a1 #1)
  -ext
  DUP >R PAD SWAP CMOVE R> PAD + 
  S" .names" ROT 2DUP + 1+ >R CZMOVE
  PAD R> OVER - ;

: RUN
  ['] my-error TO ERROR
  -1 TO SOURCE-ID 
  GetCommandLineA ASCIIZ> SOURCE!
  ?next 2DROP  \ убрали имя файла
  ?next
  ?DUP 0= IF
    ." RIPDLL 1.00  Извлекает из динамической библиотеки имена функций." CR
    ." Вызов: RIPDLL вхфайл [выхфайл]" CR
    BYE
  THEN
  ( a #) input-file CZMOVE
  ?next 2DUP TYPE ?DUP 0= IF input-file ASCIIZ> +ext THEN output-file CZMOVE 
  open-input-file
  open-output-file
  rip-names
  close-all
  BYE ;

 0 TO SPF-INIT?
 ' RUN MAINX !
 S" ripdll.exe" SAVE  
BYE
