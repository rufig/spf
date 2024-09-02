\ 94 STRING

\ NB: the word /STRING is in the kernel now.

: BLANK ( c-addr u -- ) \ 94 STRING
\ Если u больше нуля, записать пробелы в u символьных позиций, начинающихся
\ с адреса c-addr.
  BL FILL
;
