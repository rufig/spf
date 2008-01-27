( Основные низкоуровневые слова "форт-процессора"
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

( Реализация для подпрограммного шитого кода.
  EAX       Top of Stack
  EBP       Data Stack
 [EBP]      Second item on Stack
  ESP       Return Stack
  EDI       Thread data pointer
)

HEX

\ ================================================================
\ Стековые манипуляции

CODE DUP ( x -- x x ) \ 94
\ Продублировать x.
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
     RET
END-CODE

' DUP TO 'DUP_V

CODE 2DUP ( x1 x2 -- x1 x2 x1 x2 ) \ 94
\ Продублировать пару ячеек x1 x2.
     MOV EDX, [EBP]
     MOV -4 [EBP], EAX
     MOV -8 [EBP], EDX
     LEA EBP, -8 [EBP]
     RET
END-CODE

CODE DROP ( x -- ) \ 94
\ Убрать x со стека.
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE
' DROP TO 'DROP_V

CODE MAX ( n1 n2 -- n3 ) \ 94
\ n3 - большее из n1 и n2.
ARCH-P6 [IF]
     MOV     EDX, [EBP]
     CMP     EDX, EAX
     CMOVG   EAX, EDX
[ELSE]     
     CMP     EAX, [EBP]
     JL # ' DROP
[THEN]     
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE MIN ( n1 n2 -- n3 ) \ 94
 \ n3 - меньшее из n1 и n2.
 ARCH-P6 [IF]
     MOV     EDX, [EBP]
     CMP     EDX, EAX
     CMOVL   EAX, EDX
[ELSE]     
     CMP     EAX, [EBP]
     JG # ' DROP
[THEN]     
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE UMAX ( n1 n2 -- n3 ) \ 94
ARCH-P6 [IF]
     MOV     ECX, [EBP]
     CMP     ECX, EAX
     CMOVA   EAX, ECX
[ELSE]
     CMP     EAX, [EBP]
     JB # ' DROP
[THEN]     
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE UMIN ( n1 n2 -- n3 ) \ 94
ARCH-P6 [IF]
     MOV     ECX, [EBP]
     CMP     ECX, EAX
     CMOVB   EAX, ECX
[ELSE]
     CMP     EAX, [EBP]
     JA # ' DROP
[THEN]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE 0MAX       ( N1 -- N2 ) \ return n2 the greater of n1 and zero
     XOR     EDX, EDX
     CMP     EDX, EAX
ARCH-P6 [IF]     
     CMOVG   EAX, EDX
[ELSE]
     JL SHORT @@1
     MOV EAX, EDX
@@1: 
[THEN]
     RET
END-CODE

CODE 2DROP ( x1 x2 -- ) \ 94
\ Убрать со стека пару ячеек x1 x2.
     MOV EAX, 4 [EBP]
     LEA EBP, 8 [EBP]
     RET
END-CODE

CODE SWAP ( x1 x2 -- x2 x1 ) \ 94
\ поменять местами два верхних элемента стека
\     XCHG EAX, [EBP]
     MOV   EDX, [EBP]
     MOV   [EBP], EAX
     MOV   EAX, EDX
     RET
END-CODE

CODE 2SWAP ( x1 x2 x3 x4 -- x3 x4 x1 x2 ) \ 94
\ Поменять местами две верхние пары ячеек.
     MOV ECX, [EBP]
     MOV EDX, 4 [EBP]
     MOV EBX, 8 [EBP]
     MOV 8 [EBP], ECX
     MOV 4 [EBP], EAX
     MOV [EBP], EBX
     MOV EAX, EDX
     RET
END-CODE

CODE OVER ( x1 x2 -- x1 x2 x1 ) \ 94
\ Положить копию x1 на вершину стека.
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
     MOV EAX, 4 [EBP]
     RET
END-CODE

CODE 2OVER ( x1 x2 x3 x4 -- x1 x2 x3 x4 x1 x2 ) \ 94
\ Копировать пару ячеек x1 x2 на вершину стека.
     MOV EDX, 8 [EBP]
     MOV -4 [EBP], EAX
     MOV -8 [EBP], EDX
     MOV EAX, 4 [EBP]
     LEA EBP, -8 [EBP]
     RET
END-CODE

CODE NIP ( x1 x2 -- x2 ) \ 94 CORE EXT
\ Убрать первый элемент под вершиной стека.
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE ROT ( x1 x2 x3 -- x2 x3 x1 ) \ 94
\ Прокрутить три верхних элемента стека.
     MOV  EDX, [EBP]
     MOV  [EBP], EAX
     MOV  EAX, 4 [EBP]
     MOV  4 [EBP], EDX
     RET
END-CODE

CODE -ROT ( x1 x2 x3 -- x3 x1 x2 ) \ 94
\ Прокрутить три верхних элемента стека.
     MOV  EDX, 4 [EBP]
     MOV  4 [EBP], EAX
     MOV  EAX, [EBP]
     MOV  [EBP], EDX
     RET
END-CODE

CODE PICK ( xu ... x1 x0 u -- xu ... x1 x0 xu ) \ 94 CORE EXT
\ Убрать u. Копировать xu на вершину стека. Неопределенная ситуация
\ возникает, если перед выполнением PICK на стеке меньше,
\ чем u+2 элементов.
        MOV     EAX, [EBP] [EAX*4]
     RET
END-CODE

CODE ROLL ( xu xu-1 ... x0 u -- xu-1 ... x0 xu ) \ 94 CORE EXT
\ Убрать u. Повернуть u+1 элемент на вершине стека.
\ Неопределенная ситуация возникает, если перед выполнением ROLL
\ на стеке меньше чем u+2 элементов.
     OR EAX, EAX
     JZ SHORT @@1
     MOV ECX, EAX
     LEA EAX, [EAX*4]
     MOV EDX, EBP
     ADD EDX, EAX
     MOV EBX, [EDX]
@@2: LEA EDX, -4 [EDX]    \  DEC ECX
     MOV EAX, [EDX]       \  MOV EAX, [EDX+ECX*4]
     MOV 4 [EDX], EAX     \  MOV [EDX+ECX*4+4], EAX
     DEC ECX
     JNZ SHORT @@2
     MOV EAX, EBX
     JMP SHORT @@3
@@1: MOV EAX, [EBP]
@@3: LEA EBP, 4 [EBP]
     RET
END-CODE

CODE TUCK ( x1 x2 -- x2 x1 x2 )
\ Copy the first (top) stack item below the second stack item. 
     LEA EBP, -4 [EBP]
     MOV EDX, 4 [EBP]
     MOV 4 [EBP], EAX
     MOV [EBP], EDX
     RET
END-CODE


\ ================================================================
\ Стек возвратов


CODE 2>R   \ 94 CORE EXT
\ Интерпретация: семантика неопределена.
\ Выполнение: ( x1 x2 -- ) ( R: -- x1 x2 )
\ Перенести пару ячеек x1 x2 на стек возвратов. Семантически 
\ эквивалентно SWAP >R >R.
     POP  EBX
     PUSH [EBP]
     PUSH EAX
     LEA EBP, 8 [EBP]
     MOV EAX, -4 [EBP]
     JMP EBX
END-CODE

CODE 2R>  \ 94 CORE EXT
\ Интерпретация: семантика неопределена.
\ Выполнение: ( -- x1 x2 ) ( R: x1 x2 -- )
\ Перенести пару ячеек x1 x2 со стека возвратов. Семантически 
\ эквивалентно R> R> SWAP.
     MOV EBX, [ESP]
     MOV  -4 [EBP], EAX
     MOV ECX, 8 [ESP]
     MOV EAX, 4 [ESP]
     MOV -8 [EBP], ECX
     LEA EBP, -8 [EBP]
     LEA ESP, 0C [ESP]
     JMP EBX
END-CODE

CODE R@ \ 94
\ Исполнение: ( -- x ) ( R: x -- x )
\ Интерпретация: семантика в режиме интерпретации неопределена.
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
     MOV EAX, 4 [ESP]
     RET
END-CODE   

CODE 2R@  \ 94 CORE EXT
\ Интерпретация: семантика неопределена.
\ Выполнение: ( -- x1 x2 ) ( R: x1 x2 -- x1 x2 )
\ Копировать пару ячеек x1 x2 со стека возвратов. Семантически 
\ эквивалентно R> R> 2DUP >R >R SWAP.
     MOV -4 [EBP], EAX
     MOV EAX, 4 [ESP]
     MOV EBX, 8 [ESP]
     MOV -8 [EBP], EBX
     LEA EBP, -8 [EBP]
     RET
END-CODE

\ ================================================================
\ Операции с памятью

CODE @ ( a-addr -- x ) \ 94
\ x - значение по адресу a-addr.
     MOV EAX, [EAX]
     RET
END-CODE

CODE ! ( x a-addr -- ) \ 94
\ Записать x по адресу a-addr.
     MOV EDX, [EBP]
     MOV [EAX], EDX
     MOV EAX, 4 [EBP]
     LEA EBP, 8 [EBP]
     RET
END-CODE

CODE B@ ( c-addr -- char ) \ 94
\ получить байт
\ \ Получить символ по адресу c-addr. Незначащие старшие биты ячейки нулевые.
     MOVZX EAX, BYTE [EAX]
     RET
END-CODE

CODE B! ( char c-addr -- ) \ 94
\ записать байт
\ \ Записать char по адресу a-addr.
     MOV EDX, [EBP]
     MOV BYTE [EAX], DL
     MOV EAX, 4 [EBP]
     LEA EBP, 8 [EBP]
     RET
END-CODE

CODE W@ ( c-addr -- word )
\ Получить word по адресу c-addr. Незначащие старшие биты ячейки нулевые.
     MOVZX EAX, WORD [EAX]
     RET
END-CODE

CODE W! ( word c-addr -- )
\ Записать word по адресу a-addr.
     MOV EDX, [EBP]
     MOV WORD [EAX], DX
     MOV EAX, 4 [EBP]
     LEA EBP, 8 [EBP]
     RET
END-CODE

CODE 2@ ( a-addr -- x1 x2 ) \ 94
\ Получить пару ячеек x1 x2, записанную по адресу a-addr.
\ x2 по адресу a-addr, x1 в следующей ячейке.
\ Равносильно DUP CELL+ @ SWAP @
     MOV EDX, 4 [EAX]
     LEA EBP, -4 [EBP]
     MOV [EBP], EDX
     MOV EAX, [EAX]
     RET
END-CODE

CODE 2! ( x1 x2 a-addr -- ) \ 94
\ Записать пару ячеек x1 x2 по адресу a-addr,
\ x2 по адресу a-addr, x1 в следующую ячейку.
\ Равносильно SWAP OVER ! CELL+ !
     MOV EDX, [EBP]
     MOV [EAX], EDX
     MOV EDX, 4 [EBP]
     MOV 4 [EAX], EDX
     LEA EBP, 0C [EBP]
     MOV EAX, -4 [EBP]
     RET
END-CODE

\ ================================================================
\ Вычисления

CODE 1+ ( n1|u1 -- n2|u2 ) \ 94
\ Прибавить 1 к n1|u1 и получить сумму u2|n2.
     LEA EAX, 1 [EAX]
     RET
END-CODE

CODE 1- ( n1|u1 -- n2|u2 ) \ 94
\ Вычесть 1 из n1|u1 и получить разность n2|u2.
     LEA EAX, -1 [EAX]
     RET
END-CODE

CODE 2+ ( W -> W+2 )
     LEA EAX, 2 [EAX]
     RET
END-CODE

CODE 2- ( W -> W-2 )
     LEA EAX, -2 [EAX]
     RET
END-CODE

CODE 2*
     LEA EAX, [EAX*2]
     RET
END-CODE

CODE + ( n1|u1 n2|u2 -- n3|u3 ) \ 94
\ Сложить n1|u1 и n2|u2 и получить сумму n3|u3.
     ADD EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE CELL+
     LEA EAX, 4 [EAX]
     RET
END-CODE

CODE CELL-
     LEA EAX, -4 [EAX]
     RET
END-CODE

CODE CELLS
     LEA EAX, [EAX*4]
     RET
END-CODE
               
CODE D+ ( d1|ud1 d2|ud2 -- d3|ud3 ) \ 94 DOUBLE
\ Сложить d1|ud1 и d2|ud2 и дать сумму d3|ud3.
     MOV EDX, [EBP]
     ADD 8 [EBP], EDX
     ADC EAX, 4 [EBP]
     LEA EBP, 8 [EBP]
     RET     
END-CODE

CODE D- ( d1|ud1 d2|ud2 -- d3|ud3 ) \ 94 DOUBLE
     MOV EDX, [EBP]
     SUB 8 [EBP], EDX
     SBB 4 [EBP], EAX
     MOV EAX, 4 [EBP]
     LEA EBP, 8 [EBP]
     RET
END-CODE

CODE - ( n1|u1 n2|u2 -- n3|u3 ) \ 94
\ Вычесть n2|u2 из n1|u1 и получить разность n3|u3.
     NEG EAX
     ADD EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE 1+! ( A -> )
     INC DWORD [EAX]
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE 0! ( A -> )
     MOV DWORD [EAX], # 0 
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE COUNT ( c-addr1 -- c-addr2 u ) \ 94
\ Получить строку символов из строки со счетчиком c-addr1.
\ c-addr2 - адрес первого символа за c-addr1.
\ u - содержимое байта c-addr1, являющееся длиной строки символов,
\ начинающейся с адреса c-addr2.
     LEA EBP, -4 [EBP]
     LEA EDX, 1 [EAX]
     MOVZX EAX, BYTE [EAX]
     MOV [EBP], EDX
     RET
END-CODE

CODE * ( n1|u1 n2|u2 -- n3|u3 ) \ 94
\ Перемножить n1|u1 и n2|u2 и получить произведение n3|u3.
     IMUL DWORD [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE AND ( x1 x2 -- x3 ) \ 94
\ x3 - побитовое "И" x1 и x2.
     AND EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE OR ( x1 x2 -- x3 ) \ 94
\ x3 - побитовое "ИЛИ" x1 и x2.
     OR EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE XOR ( x1 x2 -- x3 ) \ 94
\ x3 - побитовое "исключающее ИЛИ" x1 и x2.
     XOR EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE INVERT ( x1 -- x2 ) \ 94
\ Инвертировать все биты x1 и получить логическую инверсию x2.
     NOT EAX
     RET
END-CODE

CODE NEGATE ( n1 -- n2 ) \ 94
\ n2 - арифметическая инверсия n1.
       NEG EAX
       RET
END-CODE

CODE ABS ( n -- u ) \ 94
\ u - абсолютная величина n.
    MOV     ECX, EAX
    SAR     ECX, 1F
    XOR     EAX, ECX
    SUB     EAX, ECX
    RET
END-CODE

CODE DNEGATE ( d1 -- d2 ) \ 94 DOUBLE
\ d2 результат вычитания d1 из нуля.
       NEG     EAX
       NEG     DWORD [EBP]
       SBB     EAX, # 0
       RET
END-CODE

CODE NOOP ( -> )
     RET
END-CODE

CODE S>D ( n -- d ) \ 94
\ Преобразовать число n в двойное число d с тем же числовым значением.
     CDQ
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
     MOV EAX, EDX
     RET
END-CODE

CODE D>S ( d -- n ) \ 94 DOUBLE
\ n - эквивалент d.
\ Исключительная ситуация возникает, если d находится вне диапазона
\ знаковых одинарных чисел.
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE U>D ( U -> D ) \ расширить число до двойной точности нулем
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
     XOR EAX, EAX
     RET
END-CODE

CODE C>S ( c -- n )  \ расширить CHAR
     MOVSX  EAX, AL
     RET
END-CODE

CODE UM* ( u1 u2 -- ud ) \ 94
\ ud - произведение u1 и u2. Все значения и арифметика беззнаковые.
       MUL DWORD [EBP]
       MOV [EBP], EAX
       MOV EAX, EDX
       RET
END-CODE

CODE / ( n1 n2 -- n3 ) \ 94
\ Делить n1 на n2, получить частное n3.
\ Исключительная ситуация возникает, если n2 равен нулю.
\ Если n1 и n2 различаются по знаку - возвращаемый результат зависит от
\ реализации.
       MOV ECX, EAX
       MOV EAX, [EBP]
       CDQ
       IDIV ECX
       LEA EBP, 4 [EBP]
       RET
END-CODE

CODE U/ ( W1, W2 -> W3 ) \ беззнаковое деление W1 на W2
       MOV ECX, EAX
       MOV EAX, [EBP]
       XOR EDX, EDX
       LEA EBP, 4 [EBP]
       DIV ECX
       RET
END-CODE

CODE +! ( n|u a-addr -- ) \ 94
\ Прибавить n|u к одинарному числу по адресу a-addr.
     MOV EDX, [EBP]
     ADD [EAX], EDX
     MOV EAX, 4 [EBP]
     LEA EBP, 8 [EBP]
     RET
END-CODE

CODE MOD ( n1 n2 -- n3 ) \ 94
\ Делить n1 на n2, получить остаток n3.
\ Исключительная ситуация возникает, если n2 равен нулю.
\ Если n1 и n2 различаются по знаку - возвращаемый результат зависит от
\ реализации.
       MOV ECX, EAX
       MOV EAX, [EBP]
       CDQ
       IDIV ECX
       LEA EBP, 4 [EBP]
       MOV EAX, EDX
       RET
END-CODE

CODE /MOD ( n1 n2 -- n3 n4 ) \ 94
\ Делить n1 на n2, дать остаток n3 и частное n4.
\ Неоднозначная ситуация возникает, если n2 нуль.
       MOV ECX, EAX
       MOV EAX, [EBP]
       CDQ
       IDIV ECX
       MOV [EBP], EDX
       RET
END-CODE

CODE UMOD ( W1, W2 -> W3 ) \ остаток от деления W1 на W2
       MOV ECX, EAX
       MOV EAX, [EBP]
       XOR EDX, EDX
       DIV ECX
       LEA EBP, 4 [EBP]
       MOV EAX, EDX
       RET
END-CODE

CODE UM/MOD ( ud u1 -- u2 u3 ) \ 94
\ Делить ud на u1, получить частное u3 и остаток u2.
\ Все значения и арифметика беззнаковые.
\ Исключительная ситуация возникает, если u1 ноль или частное
\ находится вне диапазона одинарных беззнаковых чисел.
       MOV ECX, EAX
       MOV EDX, [EBP]
       MOV EAX, 4 [EBP]
       DIV ECX
       LEA EBP, 4 [EBP]
       MOV [EBP], EDX
       RET
END-CODE

CODE 2/ ( x1 -- x2 ) \ 94
\ x2 - результат сдвига x1 на один бит вправо без изменения старшего бита.
     D1 C, F8 C,  \    SAR EAX, # 1
     RET
END-CODE


CODE U2/        ( N1 -- N2 ) \ unsigned divide n1 by two
     SHR     EAX, # 1
     RET
END-CODE

CODE */MOD ( n1 n2 n3 -- n4 n5 ) \ 94
\ Умножить n1 на n2, получить промежуточный двойной результат d.
\ Разделить d на n3, получить остаток n4 и частное n5.
       MOV     ECX, EAX
       MOV     EAX, [EBP]      \ n2
       IMUL    DWORD 4 [EBP]   \ n1*n2
       IDIV    ECX             \ n1*n2/n3
       MOV     4 [EBP], EDX    \ rem
       LEA EBP, 4 [EBP]
       RET
END-CODE

CODE M* ( n1 n2 -- d ) \ 94
\ d - знаковый результат умножения n1 на n2.
     IMUL DWORD [EBP]
     MOV  [EBP], EAX
     MOV  EAX, EDX 
     RET
END-CODE

CODE LSHIFT ( x1 u -- x2 ) \ 94
\ Сдвинуть x1 на u бит влево. Поместить нули в наименее значимые биты,
\ освобождаемые при сдвиге.
\ Неоднозначная ситуация возникает, если u больше или равно
\ числу бит в ячейке.
     MOV ECX, EAX
     MOV EAX, [EBP]
     SHL EAX, CL
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE RSHIFT ( x1 u -- x2 ) \ 94
\ Сдвинуть x1 на u бит вправо. Поместить нули в наиболее значимые биты,
\ освобождаемые при сдвиге.
\ Неоднозначная ситуация возникает, если u больше или равно
\ числу бит в ячейке.
     MOV ECX, EAX
     MOV EAX, [EBP]
     SHR EAX, CL
     LEA EBP, 4 [EBP]     
     RET
END-CODE

CODE ARSHIFT ( u1 n -- n2 )  \ arithmetic shift u1 right by n bits
     MOV     ECX, EAX
     MOV     EAX, [EBP]
     SAR     EAX, CL
     LEA EBP, 4 [EBP]     
     RET
END-CODE


CODE SM/REM ( d1 n1 -- n2 n3 ) \ 94
\ Разделить d1 на n1, получить симметричное частное n3 и остаток n2.
\ Входные и выходные аргументы знаковые.
\ Неоднозначная ситуация возникает, если n1 ноль, или частное вне
\ диапазона одинарных знаковых чисел.
     MOV ECX, EAX
     MOV EDX, [EBP]
     MOV EAX, 4 [EBP]
     IDIV ECX
     LEA EBP, 4 [EBP]
     MOV [EBP], EDX
     RET
END-CODE

\ From: Serguei V. Jidkov [mailto:jsv@gorod.bryansk.ru]

CODE FM/MOD ( d1 n1 -- n2 n3 ) \ 94
\ Разделить d1 на n1, получить частное n3 и остаток n2.
\ Входные и выходные аргументы знаковые.
\ Неоднозначная ситуация возникает, если n1 ноль, или частное вне
\ диапазона одинарных знаковых чисел.
        MOV ECX, EAX
        MOV EDX, 0 [EBP]
        MOV EBX, EDX
        MOV EAX, 4 [EBP]
        IDIV ECX
        TEST EDX, EDX            \ Остаток-то есть?
        JZ  SHORT @@1
        XOR EBX, ECX             \ А аргументы разного знака?
        JNS SHORT @@1
        DEC EAX
        ADD EDX, ECX
@@1:    LEA EBP, 4 [EBP]
        MOV 0 [EBP], EDX
        RET
END-CODE


CODE DIGIT \ [ C, N1 -> N2, TF / FF ] \ N2 - значение литеры C как
           \ цифры в системе счисления по основанию N1
       MOV ECX, EAX
       MOV EAX, [EBP]
       A;  2C C, 30 C,  \  SUB AL, # 30
       JC SHORT @@1
       A;  3C C, A C,   \  CMP AL, # A
       JNC SHORT @@2
@@3:   CMP AL, CL
       JNC SHORT @@1
       MOV [EBP], EAX
       A; B8 C, TRUE W, TRUE W,  \  MOV EAX, # -1
       RET

@@2:   A;  3C C, 11 C,  \  CMP AL, # 11
       JC SHORT @@1
       A;  2C C, 7 C,   \  SUB AL, # 7
       JMP SHORT @@3

@@1:   LEA EBP, 4 [EBP]
       XOR EAX, EAX
       RET
END-CODE

\ ================================================================
\ Сравнения

CODE = ( x1 x2 -- flag ) \ 94
\ flag "истина" тогда и только тогда, когда x1 побитно равен x2.
     XOR  EAX, [EBP]
     SUB  EAX, # 1
     SBB  EAX, EAX 
     LEA  EBP, 4 [EBP]
     RET
END-CODE

CODE <> ( x1 x2 -- flag ) \ 94 CORE EXT
\ flag "истина" тогда и только тогда, когда x1 не равен x2.
     XOR  EAX, [EBP]
     NEG  EAX
     SBB  EAX, EAX
     LEA  EBP, 4 [EBP]
     RET
END-CODE

CODE < ( n1 n2 -- flag ) \ 94
\ flag "истина" тогда и только тогда, когда n1 меньше n2.
       CMP  EAX, [EBP]
       SETLE AL
       AND  EAX, # 1
       A; 0x48 C, \ DEC  EAX
       LEA  EBP, 4 [EBP]
       RET
END-CODE

CODE > ( n1 n2 -- flag ) \ 94
\ flag "истина" тогда и только тогда, когда n1 больше n2.
       CMP  EAX, [EBP]
       SETGE AL
       AND  EAX,  # 1
       A; 0x48 C, \ DEC  EAX
       LEA  EBP, 4 [EBP]
       RET
END-CODE

CODE WITHIN     ( n1 low high -- f1 ) \ f1=true if ((n1 >= low) & (n1 < high))
      MOV  EDX, 4 [EBP]
      SUB  EAX, [EBP]
      SUB  EDX, [EBP]
      SUB  EDX, EAX
      SBB  EAX, EAX
      LEA  EBP, 8 [EBP]
      RET
END-CODE

CODE D< ( d1 d2 -- flag ) \ DOUBLE
\ flag "истина" тогда и только тогда, когда d1 меньше d2.
     MOV EDX, [EBP]
     CMP 8 [EBP], EDX
     SBB 4 [EBP], EAX
     MOV EAX, # 0
     JGE SHORT @@1
       DEC EAX
@@1: LEA EBP, 0C [EBP]
     RET
END-CODE

CODE D> ( d1 d2 -- flag ) \ DOUBLE
\ flag "истина" тогда и только тогда, когда d1 больше d2.
     MOV EDX, 8 [EBP]
     CMP [EBP], EDX
     SBB EAX, 4 [EBP]
     MOV EAX, # 0
     JGE SHORT @@1
       DEC EAX
@@1: LEA EBP, 0C [EBP]
    RET
END-CODE

CODE U< ( u1 u2 -- flag ) \ 94
\ flag "истина" тогда и только тогда, когда u1 меньше u2.
     CMP  [EBP], EAX
     SBB  EAX, EAX
     LEA  EBP, 4 [EBP]
     RET
END-CODE

CODE U> ( u1 u2 -- flag ) \ 94
\ flag "истина" тогда и только тогда, когда u1 больше u2.
     CMP  EAX, [EBP]
     SBB  EAX, EAX
     LEA  EBP, 4 [EBP]
     RET
END-CODE

CODE 0< ( n -- flag ) \ 94
\ flag "истина" тогда и только тогда, когда n меньше нуля.
    SAR EAX, # 1F
    RET
END-CODE

CODE 0= ( x -- flag ) \ 94
\ flag "истина" тогда и только тогда, когда x равно нулю.
     SUB   EAX, # 1
     SBB   EAX, EAX
     RET
END-CODE

CODE 0<> ( x -- flag ) \ 94 CORE EXT
\ flag "истина" тогда и только тогда, когда x не равно нулю.
     NEG   EAX
     SBB   EAX, EAX
     RET
END-CODE

CODE D0= ( xd -- flag ) \ 94 DOUBLE
\ flag "истина" тогда и только тогда, когда xd равен нулю.
     OR   EAX, [EBP]
     SUB  EAX, # 1
     SBB  EAX, EAX
     LEA  EBP, 4 [EBP]
     RET
END-CODE

CODE  D= ( xd1 xd2 -- flag ) \ 94 DOUBLE
\ flag is true if and only if xd1 is bit-for-bit the same as xd2
     MOV  EDX,   [EBP]
     XOR  EAX, 4 [EBP]
     XOR  EDX, 8 [EBP]
      OR  EAX, EDX
     SUB  EAX, # 1
     SBB  EAX, EAX
     LEA  EBP, 0C [EBP]
     RET
END-CODE

CODE D2* ( xd1 -- xd2 ) \ 94 DOUBLE
\ xd2 is the result of shifting xd1 one bit toward the most-significant
\ bit, filling the vacated least-significant bit with zero     
     D1 C, 65 C, 00 C, \  SHL [EBP], # 1
     D1 C, D0 C, \ RCL EAX, # 1
     RET
END-CODE          

CODE D2/ ( xd1 -- xd2 ) \ 94 DOUBLE
\ xd2 is the result of shifting xd1 one bit toward the least-significant bit,
\ leaving the most-significant bit unchanged
     D1 C, F8 C, \ SAR EAX, # 1
     D1 C, 5D C, 00 C, \  RCR [EBP], # 1
     RET
END-CODE

\ ================================================================
\ Строки

CODE -TRAILING ( c-addr u1 -- c-addr u2 ) \ 94 STRING
\ Если u1 больше нуля, u2 равно u1, уменьшенному на количество пробелов в конце 
\ символьной строки, заданной c-addr и u1. Если u1 ноль или вся строка состоит 
\ из пробелов, u2 ноль.
      OR EAX, EAX
      JZ SHORT @@1
      MOV EDX, EDI
      MOV EDI, [EBP]
      ADD EDI, EAX
      LEA EDI, -1 [EDI]
      MOV ECX, EAX
      A; B0 C, 20 C, \ MOV AL, # 20
      STD
      REPZ SCAS BYTE
      JZ SHORT @@2
      INC ECX
@@2:  MOV EAX, ECX
      MOV EDI, EDX
      CLD
@@1:  RET
END-CODE

CODE COMPARE ( c-addr1 u1 c-addr2 u2 -- n ) \ 94 STRING
\ Сравнить строку, заданную c-addr1 u1, со строкой, заданной c-addr2 u2.
\ Строки сравниваются, начиная с заданных адресов, символ за символом, до длины 
\ наиболее короткой из строк или до нахождения различий. Если две строки 
\ идентичны, n ноль. Если две строки идентичны до длины наиболее короткой из 
\ строк, то n минус единица (-1), если u1 меньше u2, иначе единица (1).
\ Если две строки не идентичны до длины наиболее короткой из строк, то n минус 
\ единица (-1), если первый несовпадающий символ строки, заданной c-addr1 u1
\ имеет меньшее числовое значение, чем соответствующий символ в строке, 
\ заданной c-addr2 u2, и единица в противном случае.
      MOV EDX, EDI
      MOV EDI,   [EBP]
      MOV ECX, 4 [EBP]
      MOV ESI, 8 [EBP]
      LEA EBP, 0C [EBP]  \    ADD EBP, # 0C   ####
      CMP ECX, EAX
      PUSHFD
      JC  SHORT @@1
      MOV ECX, EAX
@@1:  JECXZ @@2
      CLD
      REPZ CMPS BYTE
      JZ  SHORT @@2
      POP EBX
      A;  B8 C, -1 DUP W, W, \  MOV EAX, # -1
      JC  SHORT @@3
      NEG EAX
      JMP SHORT @@3
@@2:  XOR EAX, EAX
      POPFD
      JZ  SHORT @@3
      A;  B8 C, -1 DUP W, W, \  MOV EAX, # -1
      JC  SHORT @@3
      NEG EAX
@@3:  MOV EDI, EDX
      RET
END-CODE

CODE SEARCH ( c-addr1 u1 c-addr2 u2 -- c-addr3 u3 flag ) \ 94 STRING
\ Произвести поиск в строке, заданной c-addr1 u1, строки, заданной c-addr2 u2.
\ Если флаг "истина", совпадение найдено по адресу c-addr3 с оставшимися u3
\ символами. Если флаг "ложь", совпадения не найдено, и c-addr3 есть c-addr1,
\ и u3 есть u1.
      PUSH EDI
      CLD
      MOV EBX,   EAX
      OR EBX, EBX
      JZ SHORT @@5
      MOV EDX, 4 [EBP]
      MOV EDI, 8 [EBP]
      ADD EDX, EDI
@@4:  MOV ESI,   [EBP]
      LODS BYTE
      MOV ECX, EDX
      SUB ECX, EDI
      JECXZ @@1
      REPNZ SCAS BYTE
      JNZ SHORT @@1   \ во всей строке нет первого символа искомой строки
      CMP EBX, # 1
      JZ SHORT @@2   \ искомая строка имела длину 1 и найдена
      MOV ECX, EBX
      LEA ECX, -1 [ECX]
      MOV EAX, EDX
      SUB EAX, EDI
      CMP EAX, ECX
      JC SHORT @@1  \ остаток строки короче искомой строки
      PUSH EDI
      REPZ CMPS BYTE
      POP EDI
      JNZ SHORT @@4
@@2:  DEC EDI           \ нашли полное совпадение
      SUB EDX, EDI
      MOV 8 [EBP], EDI
      MOV 4 [EBP], EDX
@@5:  A;  B8 C, -1 DUP W, W, \  MOV EAX, # -1
      JMP SHORT @@3
@@1:  XOR EAX, EAX
@@3:  LEA EBP, 4 [EBP]
      POP EDI
      RET
END-CODE

CODE CMOVE ( c-addr1 c-addr2 u -- ) \ 94 STRING
\ Если u больше нуля, копировать u последовательных символов из пространства 
\ данных начиная с адреса c-addr1 в c-addr2, символ за символом, начиная с 
\ младших адресов к старшим.
       MOV EDX, EDI
       MOV ECX, EAX
       MOV EDI, [EBP]
       MOV ESI, 4 [EBP]
       CLD
       \ перекрываются ли области данных?
        \ если нет, то можно копировать DWORD
       MOV EBX, EDI
       SUB EBX, ESI
       JG  SHORT @@2
       NEG EBX
@@2:   CMP EBX, EAX
       JL  SHORT @@1
       
       \ если выровняем на 4, то копируется в 3 раза быстрее
       MOV  EBX, EDI
       AND  EBX, # 3
       JZ   SHORT @@3
       MOV  ECX, # 4
       SUB  ECX, EBX
       
       CMP  ECX, EAX
       JL   SHORT @@4
       MOV  ECX, EAX
       JMP  @@1 \ нечего выравнивать
@@4:
       SUB  EAX, ECX                    
       REP  MOVS BYTE
       MOV  ECX, EAX
@@3:       
       SAR ECX, # 2
       \ вот здесь хорошо бы в MMX копировать
       REP MOVS DWORD
       MOV ECX, EAX
       AND ECX, # 3
@@1:       
       REP MOVS BYTE
       LEA EBP, 0C [EBP]
       MOV EAX, -4 [EBP]
       MOV EDI, EDX
       RET
END-CODE

CODE CMOVE> ( c-addr1 c-addr2 u -- ) \ 94 STRING
\ Если u больше нуля, копировать u последовательных символов из пространства 
\ данных начиная с адреса c-addr1 в c-addr2, символ за символом, начиная со
\ старших адресов к младшим.
       MOV EDX, EDI
       MOV ECX, EAX
       MOV EDI, [EBP]
       MOV ESI, 4 [EBP]
       STD
       ADD EDI, ECX
       DEC EDI
       ADD ESI, ECX
       DEC ESI
       REP MOVS BYTE
       CLD
       MOV EDI, EDX
       LEA EBP, 0C [EBP]
       MOV EAX, -4 [EBP]
       RET
END-CODE

CODE FILL ( c-addr u char -- ) \ 94
\ Если u больше нуля, заслать char в u байтов по адресу c-addr.
       MOV EDX, EDI
       MOV ECX, [EBP]
       MOV EDI, 4 [EBP]
       CLD
       \ можем ли заполнять DWORD?
       MOV EBX, ECX
       AND EBX, # 3
       JNZ @@1 \ низя
       \ сформируем DWORD
       MOV EBX, EAX
       SHL EAX, # 8
       OR  EAX, EBX
       SHL EAX, # 8
       OR  EAX, EBX
       SHL EAX, # 8
       OR  EAX, EBX
       MOV EBX, ECX
       
       SAR ECX, # 2
       REP STOS DWORD
       MOV ECX, EBX
       AND ECX, # 3
@@1:       
       REP STOS BYTE
       MOV EDI, EDX
       LEA EBP, 0C [EBP]
       MOV EAX, -4 [EBP]
       RET
END-CODE

CODE ASCIIZ> ( c-addr -- c-addr u )
       LEA  EBP, -4 [EBP]
       MOV  EDX, EAX
@@1:   MOV  CL, [EAX]
       LEA  EAX, 1 [EAX]
       OR   CL, CL
       JNZ  SHORT @@1
       LEA  EAX, -1 [EAX]
       SUB  EAX, EDX
       MOV  [EBP], EDX
       RET
END-CODE

\ ================================================================
\ Указатели стеков

CODE SP! ( A -> )
     LEA EBP,  4 [EAX]
     MOV EAX, -4 [EBP]
     RET
END-CODE

CODE RP! ( A -> )
     POP EBX
     MOV ESP, EAX
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     JMP EBX
END-CODE

CODE SP@ ( -> A )
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
     MOV EAX, EBP
     RET
END-CODE

CODE RP@ ( -- RP )
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
     LEA EAX, 4 [ESP]
     RET
END-CODE

\ ================================================================
\ Регистр потока (задачи внутри форта)

CODE TlsIndex! ( x -- ) \ указатель локального пула потока
     MOV EDI, EAX
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     RET
END-CODE

CODE TlsIndex@ ( -- x )
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
     MOV  EAX, EDI
     RET
END-CODE

CODE FS@ ( addr -- x )
     MOV  EAX, FS: [EAX]
     RET
END-CODE

CODE FS! ( x addr -- )
     MOV  EBX, [EBP]
     MOV  FS: [EAX], EBX
     MOV  EAX, 4 [EBP]
     LEA  EBP, 8 [EBP]
     RET
END-CODE

\ ================================================================
\ Циклы

CODE J   \ 94
\ Интерпретация: семантика неопределена.
\ Выполнение: ( -- n|u ) ( R: loop-sys -- loop-sys )
\ n|u - копия параметра следующего объемлющего цикла.
\ Неоднозначная ситуация возникает, если параметр недоступен.
      LEA EBP, -4 [EBP]
      MOV [EBP], EAX
      MOV EAX, 10 [ESP]
      SUB EAX, 14 [ESP]
      RET
END-CODE

( inline'ы для компиляции циклов )

CODE C-DO
      LEA EBP, 8 [EBP]
      A;  BA C, 0000 W, 8000 W,   \   MOV     EDX , # 80000000
      SUB  EDX, -8 [EBP]
      LEA  EBX,  [EDX] [EAX]
      MOV  EAX, -4 [EBP]
      MOV  EDX, EDX  \ FOR OPT
\      PUSH EDX
\      PUSH EBX
      RET
END-CODE

CODE C-?DO
      CMP  EAX, -8 [EBP]
      JNZ  SHORT @@1
\      SIF  0=
        MOV  EAX, -4 [EBP]
        JMP  EBX
\      STHEN
@@1:  PUSH EBX
      A; BB C, 0000 W, 8000 W,   \   MOV     EBX , # 80000000
      SUB  EBX, -8 [EBP]
      PUSH EBX  \ 80000000h-to
      ADD  EBX, EAX
      PUSH EBX  \ 80000000H-to+from
      MOV  EAX, -4 [EBP]
      RET
END-CODE

CODE  ADD[ESP],EAX 
      ADD [ESP] , EAX 
      RET
END-CODE

CODE C-I
      LEA EBP, -4 [EBP]
      MOV [EBP], EAX
      MOV EAX, [ESP]
      SUB EAX, 4 [ESP]
      RET
END-CODE

CODE C->R     \ 94
     PUSH EAX
     MOV  EAX, [EBP]
     LEA  EBP, 4 [EBP]
     RET
END-CODE

CODE C-R>    \ 94
     LEA  EBP, -4 [EBP]
     MOV  [EBP],  EAX
     POP EAX
     RET
END-CODE

CODE C-RDROP
     ADD  ESP, # 4
     RET
END-CODE

CODE C-?DUP
     OR  EAX, EAX
     JZ SHORT @@1
     LEA EBP, -4 [EBP]
     MOV [EBP], EAX
@@1: RET
END-CODE 

CODE C-EXECUTE ( i*x xt -- j*x ) \ 94
\ Убрать xt со стека и выполнить заданную им семантику.
\ Другие изменения на стеке определяются словом, которое выполняется.
     MOV  EDX, EAX
     MOV  EAX, [EBP]
     LEA  EBP, 4 [EBP]
     CALL EDX
     RET
END-CODE

\ ================================================================
\ Поддержка LOCALS

CODE DRMOVE ( x1 ... xn n*4 -- )
\ перенести n чисел со стека данных на стек возвратов
     POP  EDX \ адрес возврата
     MOV  ESI, EAX
@@1: 
     PUSH -4 [EBP] [ESI] 
     SUB  ESI, # 4
     JNZ  SHORT @@1
     ADD  EBP, EAX
     MOV  EAX, [EBP]
     LEA  EBP, 4 [EBP]
     JMP  EDX
END-CODE

CODE NR> ( R: x1 ... xn n -- D: x1 ... xn n )
\ Перенести n чисел со стека возвратов на стек данных
\ Если n=0 возвратить 0
     POP  EDX \ адрес возврата
     LEA  EBP, -4 [EBP]     
     MOV  [EBP], EAX
     POP  EAX
     OR   EAX, EAX
     JNZ  @@2
     JMP  EDX

@@2: LEA  EAX, [EAX*4]
     MOV  ESI, EAX
@@1: 
     MOV  EBX, EBP
     SUB  EBX, ESI
     POP  [EBX]
     SUB  ESI, # 4
     JNZ  SHORT @@1
     SUB  EBP, EAX
     SAR  EAX, # 2
     JMP  EDX
END-CODE

CODE N>R ( D: x1 ... xn n -- R: x1 ... xn n )
\ перенести n чисел со стека данных на стек возвратов
     LEA  EBP, -4 [EBP]
     MOV  [EBP], EAX
     LEA EAX, 4 [EAX*4]

     POP  EDX \ адрес возврата
     MOV  ESI, EAX
@@1: 
     PUSH -4 [EBP] [ESI] 
     SUB  ESI, # 4
     JNZ  SHORT @@1
     ADD  EBP, EAX
     MOV  EAX, [EBP]
     LEA  EBP, 4 [EBP]
     JMP  EDX
END-CODE

CODE NRCOPY ( D: i*x i -- D: i*x i R: i*x i )
\ скопировать n чисел со стека данных на стек возвратов
     MOV  ECX, EAX
     LEA  ECX, [ECX*4]

     POP  EDX \ адрес возврата
     JECXZ @@2
     MOV  ESI, ECX
@@1: 
     PUSH -4 [ESI] [EBP]
     SUB  ESI, # 4
     JNZ  SHORT @@1
@@2:
     PUSH EAX
     JMP  EDX
END-CODE

CODE RP+@ ( offs -- x )
\ взять число со смещением offs байт от вершины стека возвратов (0 RP+@ == RP@)
     8B C, 44 C, 04 C, 04 C, \ MOV EAX, 4 [EAX] [ESP]
     RET
END-CODE
     
CODE RP+ ( offs -- addr )
\ взять адрес со смещением offs байт от вершины стека возвратов
     8D C, 44 C, 04 C, 04 C, \  LEA EAX, 4 [EAX] [ESP]
     RET
END-CODE

CODE RP+! ( x offs -- )
\ записать число x по смещению offs байт от вершины стека возвратов
     MOV  EBX, [EBP] A;
     89 C, 5C C, 04 C, 04 C, \   MOV  4 [ESP] [EAX], EBX
     LEA  EBP, 8 [EBP]
     MOV  EAX, -4 [EBP]
     RET
END-CODE

CODE RALLOT ( n -- addr )
\ зарезервировать n ячеек на стеке возвратов,
\ сделаем с инициализацией (а то если больше 8К выделим, exception может)
     POP  EDX
     MOV  ECX, EAX
     XOR  EAX, EAX
@@1: PUSH EAX
     DEC  ECX
     JNZ  SHORT @@1
     MOV  EAX, ESP
     JMP  EDX
END-CODE

CODE (RALLOT) ( n -- )
\ зарезервировать n ячеек на стеке возвратов
     POP  EDX
     MOV  ECX, EAX
     XOR  EAX, EAX
@@1: PUSH EAX
     DEC  ECX
     JNZ  SHORT @@1
     MOV  EAX, [EBP]
     LEA  EBP, 4 [EBP]
     JMP  EDX
END-CODE

CODE RFREE ( n -- )
\ вернуть n ячеек стека возвратов
     POP  EDX
     LEA  ESP, [ESP] [EAX*4]
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]
     JMP  EDX
END-CODE

CODE (LocalsExit) ( -- )
\ вернуть память в стек вовратов, число байт лежит на стеке
     POP  EBX
     ADD  ESP, EBX
     RET
END-CODE

CODE TIMER@ ( -- tlo thi ) \ Только для Intel Pentium и выше!!!
\ Возвратить значение таймера процессора как ud
   MOV -4 [EBP], EAX
   RDTSC
   MOV -8 [EBP], EDX
   LEA EBP, -8 [EBP]
   XCHG EAX, [EBP]
   RET
END-CODE

\ Для остальных процессоров раскомментируйте:
\ : TIMER@ 0 GetTickCount ;

CODE TRAP-CODE ( D: j*x u R: i*x i -- i*x u )
\ Вспомогательное слово для восстановления значений, сохраненных
\ перед CATCH на стеке возвратов
     POP  EDX
     POP  ESI
     OR   ESI, ESI
     JZ   @@2
     LEA  ESI, [ESI*4]
     MOV  ECX, ESI
@@1: MOV  EBX, -4 [ESI] [ESP]
     MOV  -4 [ESI] [EBP], EBX
     SUB  ESI, # 4
     JNZ  SHORT @@1
     ADD  ESP, ECX
@@2: JMP  EDX
END-CODE

CODE (ENTER) ( {4*params ret_addr} -- 4*params R: ret_addr ebp ) \ 09.09.2002
\ отодвинуть стек возвратов и сохранить EBP на стеке возвратов.
\ необходимо при ручном кодировании входа в callback, т.к.
\ комбинация SP@ >R портит слово по адресу EBP,
\ а оно может быть нужно вызывающей процедуре :)
     POP  EBX       \ адрес возврата из ENTER
     POP  ESI       \ адрес возврата из CALLBACK/WNDPROC
     MOV  EAX, EBP
     MOV  EBP, ESP

     XOR  EDX, EDX
     MOV  ECX, # 32
@@1: PUSH EDX
     DEC  ECX
     JNZ  @@1

     PUSH ESI
     PUSH EAX
     MOV EAX, [EBP]
     LEA EBP, 4 [EBP]

     JMP  EBX
END-CODE

DECIMAL
