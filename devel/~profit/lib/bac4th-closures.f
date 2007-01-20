\ Замыкания или частично определённые функции.
\ Функция задаётся строкой, которая компилируется в кучу. 
\ При откате занятая функцией область в куче снимается.

\ Доопределяется функция или IMMEDIATE-словами подобными LITERAL ,
\ нужное для передачи числа на стеке в компилируемую функцию или
\ прямым входом в режим интерпретации словами [ и ]


\ REQUIRE MemReport ~day/lib/memreport.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE FREEB ~profit/lib/bac4th-mem.f
\ REQUIRE EVALUATED-HEAP ~profit/lib/evaluated.f
REQUIRE VC-COMPILED ~profit/lib/compile2Heap.f
REQUIRE STR@ ~ac/lib/str4.f

: compiledCode ( addr u --> addr-code \ <-- ) PRO LOCAL t
CREATE-VC t !
t @ VC-COMPILED
t @ VC-RET,
t @ XT-VC CONT
t @ DESTROY-VC ;

: STRcompiledCode ( s --> ) PRO LOCAL s DUP s ! STR@ compiledCode s @ STRFREE CONT ;

/TEST
REQUIRE SEE lib/ext/disasm.f

: b HERE 1 2DROP ;

: s ( n -- ) S" b LITERAL + " compiledCode REST CR CR ;

: r 4 0 DO I . I s LOOP ;
r
\ MemReport