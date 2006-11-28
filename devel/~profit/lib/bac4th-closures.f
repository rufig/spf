\ Замыкания или частично определённые функции.
\ Функция задаётся строкой, которая компилируется в кучу. 
\ При откате занятая функцией область в куче снимается.

\ Доопределяется функция или IMMEDIATE-словами подобными LITERAL ,
\ нужное для передачи числа на стеке в компилируемую функцию или
\ прямым входом в режим интерпретации словами [ и ]


\ REQUIRE MemReport ~day/lib/memreport.f
REQUIRE CONT ~profit/lib/bac4th.f 
REQUIRE FREEB ~profit/lib/bac4th-mem.f
REQUIRE EVALUATED-HEAP ~profit/lib/evaluated.f

: compiledCode ( addr u -- addr-code )
PRO EVALUATED-HEAP FREEB CONT ;

\EOF
REQUIRE SEE lib/ext/disasm.f

: s ( n -- ) S" LITERAL +" compiledCode REST ;

: r 4 0 DO CR CR I . I s LOOP ;
r

MemReport