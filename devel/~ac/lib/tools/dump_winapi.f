: DUMP-WINAPI
  WINAPLINK @
  BEGIN
    DUP
  WHILE
    DUP CELL- CELL- CELL- @ ASCIIZ> TYPE ." :" \ такое расположение удобно для сортировки
    DUP CELL- CELL- CELL- CELL- @ . ." :"
    DUP CELL- CELL- @ ASCIIZ> TYPE
    CR
    @
  REPEAT DROP
;
\ DUMP-WINAPI
