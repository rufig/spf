\ 02-05-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ макросы для поддержания псевдоассемблера

 REQUIRE ?DEFINED   devel\~moleg\lib\util\ifdef.f
 REQUIRE ASSEMBLER  lib\ext\spf-asm.f
 REQUIRE psevdoregs devel\~mOleg\lib\asm\registers.f

CREATE psevdoasm

: -CELL CELL NEGATE ;
: param  NextWord EVALUATE ;

\ выход из ассемблерного примитива.
MACRO: exit RET ENDM

\ -- работа со стеками ------------------------------------------------------

\ сместить указатель стека данных на указанное кол-во байт
MACRO: dheave LEA top , [top] ENDM

\ сместить указатель стека возвратов на указанное кол-во байт
MACRO: rheave LEA rtop , [rtop] ENDM

\ положить содержимое указанного регистра на вершину стека данных
MACRO: dpush  dheave -CELL  MOV subtop , ENDM
\ загрузить указанный регистр содержимым подвершины стека данных
MACRO: dpop   MOV param , subtop dheave CELL  ENDM

\ извлечь содержимое вершины стека возвратов в указанный регистр
MACRO: rpop   POP  ENDM
\ запомнить содержимое указанного регистра на вершине стека возвратов
MACRO: rpush  PUSH ENDM

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{

  S" passed" TYPE
}test
