\ 13-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ различные математические операции, отсутсвующие в СПФ

 REQUIRE ?DEFINED  devel\~moleg\lib\util\ifdef.f
 REQUIRE dpush     devel\~mOleg\lib\asm\psevdoasm.f

\ разделить двойное положительное число на одинарное с получением двойного »
\ результата.
CODE UD/ ( ud un --> ud )
         XOR EDX, EDX
         MOV ESI, EAX
         dpop EAX
         DIV ESI
         MOV EBX, EAX
         dpop EAX
         DIV ESI
         dpush EAX
         MOV EAX, EBX
       RET
    END-CODE

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{

  S" passed" TYPE
}test