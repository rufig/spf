\ Компиляция в кучу. Память добирается кусками по мере компиляции.
\ Куски сцепляются jmp'ами.

\ Создание виртуального кодофайла:
\ <размер-кусков> _CREATE-CP ( n -- cp )

\ Или со значением по-умолчанию (по 4Кб):
\ CREATE-CP ( -- cp )

\ CP-, CP-COMPILE, CP-LIT, CP-RET, аналогичны
\ ,    COMPILE,    LIT,    RET,
\ только требуют дополнительный параметр -- cp

\ Кроме того, слово CP- ( cp -- ) переключает все компилирующие 
\ слова, идущие после него, на виртуальный кодофайл cp в пределах определения

\ Все куски развязываются и освобождаются DESTROY-CP ( cp -- )


\ REQUIRE MemReport ~day/lib/memreport.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE CONT ~profit/lib/bac4th.f

MODULE: codepatches
20 CONSTANT luft  \ сколько байт допуска

: __ CELL -- ;

0
__ block      \ размер кусков, которыми надо брать память для кода
__ there      \ сохраняемый HERE в этом виртуальном кодофайле
__ firstBlock \ первый кусок занятой под кодофайл памяти
__ lastBlock  \ последний кусок
__ limit      \ временная переменная, куда записывается граничный
              \ адрес, после пересечения которого надо начинать новый кусок
CONSTANT codePatches

: allocatePatch ( cp -- ) >R R@ block @ ALLOCATE THROW
DUP 0! DUP R@ lastBlock !
CELL+ DUP R@ there ! 
R@ block @ + luft - R@ limit ! RDROP ;

: HERE DP @ ; \ HERE из системы -- не то же самое что и DP @ 
              \ кроме взятия значения DP также отграничивается
              \ текущим адресом оптимизатор что для этого 
              \ применения нежелательно

EXPORT
: _CREATE-CP ( blockSize -- cp )
codePatches ALLOCATE THROW >R
R@ block !
R@ allocatePatch
R@ lastBlock @ R@ firstBlock !
R> ;

: CREATE-CP (  -- cp ) 1024 CELLS _CREATE-CP ; \ по-умолчанию куски по 4Кб

: DESTROY-CP ( cp -- )
DUP firstBlock @ SWAP FREE THROW
BEGIN DUP @ 
SWAP FREE THROW
DUP 0= UNTIL DROP ;

: XT-CP ( cp -- xt ) firstBlock @ CELL+ ;

: CP- ( ... cp -- ) PRO LOCAL cp cp !
LOCAL savedHere HERE savedHere !
cp @ there @ DP !
CONT
HERE cp @ there !
HERE cp @ limit @ >  IF
cp @ lastBlock @
cp @ allocatePatch
cp @ lastBlock @ SWAP !
cp @ there @ BRANCH, THEN
savedHere @ DP ! ;

: CP-COMPILE, ( xt cp -- ) CP- COMPILE, ;
: CP-, ( n cp -- ) CP- , ;
: CP-LIT, ( n cp -- ) CP- LIT, ;
: CP-DLIT, ( du cp -- ) >R SWAP R@ CP-LIT, R> CP-LIT, ;
: CP-RET, ( cp -- ) CP- RET, ;
\ компиляция команд в виде строки в кучу:
: CP-COMPILED ( addr u cp -- ) CP- TRUE STATE B! EVALUATE ;
;MODULE

\EOF
REQUIRE SEE lib/ext/disasm.f
0 VALUE t
: r 
1000 CELLS CREATE-CP TO t
0 t CP-LIT,
4 0 DO ['] 1+ t CP-COMPILE, LOOP
['] . t CP-COMPILE,
S" dfdsdfdf" t CP-DLIT,
['] CR t CP-COMPILE,
['] TYPE t CP-COMPILE,
['] CR t CP-COMPILE,
S" 1 1 + ." t CP-COMPILED
t CP-RET,
t XT-CP REST ;

r
t DESTROY-CP
\ MemReport