MODULE: RESOURCES

0 VALUE h
0 VALUE start

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

: RESOURCES: ( ->eol; -- )
  1 WORD COUNT R/O OPEN-FILE ABORT" Файл ресурсов не найден" TO h
  512 ALIGN-BYTES ! ALIGN 4 ALIGN-BYTES !
  HERE DUP TO start IMAGE-BASE - RESOURCES-RVA !
  start h FILE-SIZE 2DROP h READ-FILE ABORT" Ошибка чтения"
  DUP ALLOT RESOURCES-SIZE ! 
  start ['] relocate1 relocate \ добавить ко всем адресам ресурсов RESOURCES-RVA
  h CLOSE-FILE DROP
;

;MODULE
