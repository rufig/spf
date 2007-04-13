
\ REQUIRE _LINE_ lib/ext/debug/accert.f

: _LINE_
\ компилирует строковый литерал - u - номер текущей строки
  CURSTR @ 0 <# #S #> [COMPILE] SLITERAL
; IMMEDIATE

: _FILE_
\ компилирует строковый литерал - им€ текущего файла трансл€ции
  CURFILE @ ASCIIZ> [COMPILE] SLITERAL
; IMMEDIATE

: (ENSURE) CR TYPE ." : line " TYPE ."  - ENSURE FAILED !" CR ;

: ENSURE ( ? -- ) S" 0= IF _LINE_ _FILE_ (ENSURE) 12345 THROW THEN" EVALUATE ; IMMEDIATE
