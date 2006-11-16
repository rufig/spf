\ REQUIRE MemReport ~day/lib/memreport.f
REQUIRE CONT ~profit/lib/bac4th-mem.f 
REQUIRE FREEB ~profit/lib/bac4th-mem.f 

: compiledCode ( addr u -- addr-code )  HERE >R
TRUE STATE ! \ включаем компиляцию
EVALUATE \ выполняем строку-параметр
RET, \ заканчиваем определение
STATE 0! \ выключаем компиляцию
HERE \ текущее значение HERE, после компиляции
R@ DP ! \ восстанавливаем HERE к изначальному значению
R@ \ старое значение HERE, перед ней
( новое старое )
- ( новое-старое ) \ подсчитываем длину скомпилированной последовательности
R> OVER ( длина старое длина )
ALLOCATE THROW
DUP >R
( длина старое выделенная-память )
ROT CMOVE R> ( адрес-участка-кода-в-куче ) ;

\EOF
REQUIRE SEE lib/ext/disasm.f

: s ( n -- ) S" LITERAL +" compiledCode FREEB REST ;

: r 4 0 DO CR CR I . I s LOOP ;
r

MemReport