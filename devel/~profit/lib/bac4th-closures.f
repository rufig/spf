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