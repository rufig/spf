\ Подготовка к разбору строк

: PARSE... ( z -- ... )
  >R SAVE-SOURCE R>
  ASCIIZ> SOURCE!
  -1 TO SOURCE-ID
;

: SPARSE... ( a n -- ... )
  2>R SAVE-SOURCE 2R>
  SOURCE!
  -1 TO SOURCE-ID
;

: ...PARSE ( x1 x2 -- )
  RESTORE-SOURCE ;
