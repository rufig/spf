\ Компиляция в кучу. Память добирается кусками по мере компиляции.
\ Куски сцепляются jmp'ами.

\ Создание виртуального кодофайла:
\ <размер-кусков> _CREATE-VC ( n -- v_codefile )

\ Или со значением по-умолчанию (по 4Кб):
\ CREATE-VC ( -- v_codefile )

\ VC-, VC-COMPILE, VC-LIT, VC-RET, аналогичны
\ ,    COMPILE,    LIT,    RET,
\ только требуют дополнительный параметр -- cp

\ Кроме того, слово VC- ( vc -- ) переключает все компилирующие 
\ слова, идущие после него, на виртуальный кодофайл vc в пределах определения

\ Все куски развязываются и освобождаются DESTROY-VC ( vc -- )


\ REQUIRE MemReport ~day/lib/memreport.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE CONT ~profit/lib/bac4th.f

MODULE: codepatches
30 CONSTANT luft  \ сколько байт допуска

: __ CELL -- ;

0
__ block      \ размер кусков, которыми надо брать память для кода
__ there      \ сохраняемый HERE в этом виртуальном кодофайле
__ firstBlock \ первый кусок занятой под кодофайл памяти
__ lastBlock  \ последний кусок
__ limit      \ временная переменная, куда записывается граничный
              \ адрес, после пересечения которого надо начинать новый кусок
CONSTANT codePatches

VARIABLE counter
counter 0!

: allocatePatch ( vc -- ) >R R@ block @ ALLOCATE THROW
\ counter 1+!  counter @ CR . \ для контроля забора и отдачи памяти
DUP 0! DUP R@ lastBlock !
CELL+ DUP R@ there ! 
R@ block @ + luft - R@ limit ! RDROP ;

: HERE DP @ ; \ HERE из системы -- не то же самое что и DP @ 
              \ кроме взятия значения DP также отграничивается
              \ текущим адресом оптимизатор что для этого 
              \ применения нежелательно


EXPORT
: _CREATE-VC ( blockSize -- vc )
codePatches ALLOCATE THROW >R
R@ block !
R@ allocatePatch
R@ lastBlock @ R@ firstBlock !
R> ;

: CREATE-VC (  -- vc ) 1 12 LSHIFT _CREATE-VC ; \ по-умолчанию куски по 4Кб

: DESTROY-VC ( vc -- )
DUP firstBlock @ SWAP FREE THROW
BEGIN DUP @ 
SWAP FREE THROW
\ -1 counter +!  counter @ CR . \ для контроля забора и отдачи памяти
DUP 0= UNTIL DROP ;

: XT-VC ( vc -- xt ) firstBlock @ CELL+ ;

: VC- ( ... vc -- ) PRO LOCAL vc vc !
LOCAL savedHere HERE savedHere !
vc @ there @ DP !
CONT
HERE vc @ there !
HERE vc @ limit @ >  IF
vc @ lastBlock @
vc @ allocatePatch
vc @ lastBlock @ SWAP !
vc @ there @ BRANCH, THEN
savedHere @ DP ! ;

: VC-COMPILE, ( xt vc -- ) VC- COMPILE, ;
: VC-, ( n vc -- ) VC- , ;
: VC-LIT, ( n vc -- ) VC- LIT, ;
: VC-DLIT, ( du vc -- ) >R SWAP R@ VC-LIT, R> VC-LIT, ;
: VC-RET, ( vc -- ) VC- RET, ;
\ компиляция команд в виде строки в кучу:
: VC-COMPILED ( addr u cp -- ) VC- TRUE STATE B! EVALUATE ;
;MODULE

\EOF
REQUIRE SEE lib/ext/disasm.f
0 VALUE t
: r 
1000 CELLS CREATE-VC TO t
0 t VC-LIT,
4 0 DO ['] 1+ t VC-COMPILE, LOOP
['] . t VC-COMPILE,
S" dfdsdfdf" t VC-DLIT,
['] CR t VC-COMPILE,
['] TYPE t VC-COMPILE,
['] CR t VC-COMPILE,
S" 1 1 + ." t VC-COMPILED
t VC-RET,
t XT-VC REST ;

r
t DESTROY-VC
\ MemReport