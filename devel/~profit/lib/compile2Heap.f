\ Компиляция кода в кучу. Память добирается кусками по мере компиляции.
\ Куски сцепляются jmp'ами. "Системный" кодофайл никак не задевается.

\ Создание виртуального кодофайла:
\ <действие-по-окончании-кодофайла> <размер-кусков> _CREATE-VC ( xt n -- v_codefile )
\ где <действие-по-окончании-кодофайла> выполняется после того как выполнятся 
\ все куски кода

\ v_codefile -- адрес "виртуального кодофайла", в дальнейшем просто vc

\ Если вы явно скомпилируете в кодофайл RET или другую аналогичную команду
\ выхода из определения то <действие-по-окончании-кодофайла> не выполнится.

\ Создание кодофайла со значениями по-умолчанию (рекомендуется):
\ CREATE-VC ( -- vc )
\ Размер ставится в зависимости от настроек системы, обычно 4кб
\ Действие по окончании -- NOOP

\ VC-, VC-COMPILE, VC-LIT, VC-RET, аналогичны
\ ,    COMPILE,    LIT,    RET,
\ только требуют дополнительный параметр -- vc
\ , то есть кодофайл куда идёт компиляция

\ Есть также слово VC-COMPILED ( addr u vc -- )
\ Которое _компилирует_ команды форта в виде строки addr u
\ в кодофайл vc.
\ Режим ставится на время компиляции и восстанавливается.

\ ВНИМАНИЕ: "рвать" куски определения со структурами
\ управления не получится, то есть например, сначала написать:
\ S" BEGIN ... WHILE " vc VC-COMPILED 
\ а потом:
\ S" ... REPEAT" vc VC-COMPILED
\ Так как стек структур управления не сохраняется.

\ TODO: Сохранять стек структур управления (control-flow stack)
\ отдельно для каждого кодофайла

\ TODO: CASE ... ENDCASE ?


\ Слово VC- ( vc --> \ <-- ) переключает все компилирующие слова,
\ идущие после него, на виртуальный кодофайл vc в пределах определения

\ Вызывать скомпилированный в кодофайл код можно так:
\ vc XT-VC EXECUTE

\ либо, что проще:
\ vc EXECUTE

\ vc одновременно со всем прочим представляет собой указатель 
\ на код где первым идёт абсолютный безусловный переход на 
\ адрес vc XT-VC

\ Поэтому если нужно посмотреть (SEE) код то смотреть надо его так
\ vc XT-VC REST
\ Впрочем, запускать vc EXECUTE проще.

\ После каждой компиляции в vc , его можно сразу запускать без 
\ дополнительных обработок. То есть:
\ CREATE-VC VALUE vc
\ 1 vc VC-LIT,
\ vc EXECUTE .
\ Вывод: 1
\ ' 1+ vc VC-COMPILE,
\ vc EXECUTE .
\ Вывод: 2

\ Все куски развязываются и освобождаются DESTROY-VC ( vc -- )

\ REQUIRE MemReport ~day/lib/memreport.f
REQUIRE PageSize ~profit/lib/get-system-info.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE __ ~profit/lib/cellfield.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE NO-INLINE=> ~profit/lib/no-inline.f
REQUIRE SET-DP-HOOK ~profit/lib/dp-hook.f

MODULE: codepatches

PageSize CELL - CONSTANT MEM-PAGE

MM_SIZE 32 MAX 2* CONSTANT luft  \ сколько байт допуска

0
1 -- rlit     \ инструкция PUSH (0x68)
__ firstBlock \ первый блок занятый под кодофайл памяти
1 -- ret      \ инструкция RET (0xC3)
__ALIGN       \ выравниваем по ячейке
__ block      \ размер блоков, которыми надо брать память для кода
__ there      \ сохраняемый HERE в этом виртуальном кодофайле
__ lastBlock  \ последний кусок
__ limit      \ временная переменная, куда записывается граничный
              \ адрес, после пересечения которого надо начинать новый блок
__ end-vc     \ действие, выполняемое после обработки всех блоков vc
CONSTANT codePatches

\ Поле firstBlock структуры виртуального кодофайла указывает на
\ другой, связанный список блоков кода. Каждый из них имеет в
\ начале структуру:
\ ---------------- начало блока
\ размер блока
\ ----------------
\ ... здесь идёт код блока
\ ... NOP'ы-заглушки
\ ---------------- отсюда начинается конечная структура в конце блока
\ 0x68 маш. команда PUSH
\ nextBlock -- поле хранящее адрес следующего блока
\ 0xС3 маш. команда RET
\ ---------------- конец блока

0
__ blockSize   \ размер блока
__ blocks'Code \ отсюда начинается код и идёт вплоть end-struc
DROP

0
1 -- rlit0     \ инструкция PUSH (0x68)
__ nextBlock0  \ след. кусок кодофайла, поле связи
1 -- ret0      \ инструкция RET (0xC3)
CONSTANT end-struc

VARIABLE vc \ текущий виртуальный кодофайл

: end-struct-addr ( addr1 -- addr2 ) DUP blockSize @ + end-struc - ;

: rlit1 ( addr1 -- addr2 ) end-struct-addr rlit0 ;
: ret1 ( addr1 -- addr2 ) end-struct-addr ret0 ;
: nextBlock ( addr1 -- addr2 ) end-struct-addr nextBlock0 ;

\ VARIABLE counter counter 0!

\ Взятие в кодофайл нового куска кода
: allocatePatch ( vc -- block ) >R
R@ block @ ALLOCATE THROW ( адрес-куска R: адрес-структуры-кодофайла )
\ counter 1+!  counter @ CR .  \ для контроля забора и отдачи памяти
DUP R@ lastBlock !             \ в структуре кодофайла указываем новый последний кусок кода
DUP R@ block @ 0x90 FILL       \ заполняем весь кусок маш. командами NOP
R@ block @ OVER blockSize !    \ у нового блока прописываем его размер
0x68 OVER rlit1 C!             \ вставляем в паз нужную маш. команду
0xC3 OVER ret1 C!              \ вставляем в паз нужную маш. команду
R@ end-vc @ OVER nextBlock !   \ последний кусок кода всегда указывает на конечное значение
DUP blocks'Code R@ there !     \ продвигаем локальный HERE кодофайла на начало нового куска кода
DUP R@ block @ + luft -        \ вычисляем конце нового блока в памяти и вводим некий "допуск", люфт
R@ limit !                     \ установка границы текущего блока кодофайла
RDROP ;

:NONAME  ( -- )       \ Обработчик компиляции
HERE vc @ limit @ < IF EXIT THEN \ Проверка на выход за границы текущего блока кодофайла
HERE OP0 @ <> IF EXIT THEN       \ если мы находимся в середине маш. команды -- уходить
\ Если две пред. проверки ещё не выкинули нас, то нужно добавлять ещё кусок кода
vc @ lastBlock @                 \ запоминаем текущий блок в который компилировали
vc @ allocatePatch ( block )     \ берём из кучи новый блок
blocks'Code SWAP nextBlock !     \ связываем новый блок кода с предыдущим
vc @ there @ DP !
; CONSTANT VC-CHECK

: firstBlock! ( xt vc -- ) SWAP blocks'Code SWAP firstBlock ! ;
: firstBlock@ ( vc -- xt ) firstBlock @ 0 blocks'Code - ;

EXPORT

: _CREATE-VC ( end-vc blockSize -- vc )
codePatches ALLOCATE THROW >R
0x68 R@ rlit C!
0xC3 R@ ret C!
R@ block !
R@ end-vc !
R@ allocatePatch R@ firstBlock!
R> ;

: CREATE-VC (  -- vc ) ['] NOOP MEM-PAGE _CREATE-VC ; \ по-умолчанию блоки по размеру памяти минимально забираемой из кучи

: DESTROY-VC ( vc -- )
DUP end-vc @ SWAP DUP firstBlock@ blocks'Code ( end-vc vc xt )
SWAP FREE THROW \ освобождаем управляющую структуру кодофайла
BEGIN
0 blocks'Code - \ от xt переходим к адресу блока кода, для этого отходим назад
DUP nextBlock @
SWAP FREE THROW
\ -1 counter +!  counter @ CR . \ для контроля забора и отдачи памяти
2DUP = UNTIL 2DROP ;


: XT-VC ( vc -- xt ) firstBlock@ blocks'Code ;
\ : XT-VC ( vc -- xt ) ; \ можно и так, но дизассемблер будет показывать тогда только переход...


: VC- ( ... vc --> \ <-- ) PRO
DUP vc B! \ сохраняем текущий вирт. кодофайл в глобальной скрытой переменной
there @ DP B! \ запись в переменную DP с восстановлением при откате
ClearJpBuff \ так как мы теперь находимся уже в другом кодофайле, то
\ переходы старого нам не нужны ("исправление" для J_@ которое не
\ учитывает возможность переключения DP )
\ ещё немножко придушим оптимизатор:
10 0 DO SetOP LOOP HERE DUP TO LAST-HERE DUP TO :-SET TO J-SET
VC-CHECK SET-DP-HOOK \ включаем контроль компиляции на время активности виртуального кодофайла
NO-INLINE=>  \ окончательно глушим оптимизатор, запрещая ему инлайн
CONT \ нырок
HERE vc @ there ! ; \ сохранение HERE виртуального кодофайла после
\ компиляции в него

: VC-COMPILE, ( xt vc -- ) VC- COMPILE, ;
: VC-POSTPONE ( vc "word" -- ) ?COMP ' LIT, POSTPONE SWAP POSTPONE VC-COMPILE, ; IMMEDIATE
: VC-, ( n vc -- ) VC- , ;
: VC-LIT, ( n vc -- ) VC- LIT, ;
: VC-DLIT, ( du vc -- ) >R SWAP R@ VC-LIT, R> VC-LIT, ;
: VC-RET, ( vc -- ) VC- RET, ;

\ Компиляция команд в виде строки в кучу:
: VC-COMPILED ( addr u vc -- ) VC- TRUE STATE B! EVALUATE ;

;MODULE


/TEST


REQUIRE SEE lib/ext/disasm.f
0 VALUE t

: r 
CREATE-VC TO t
100 0 DO
S" 10 1 DO I 1 + . LOOP" t VC-COMPILED
LOOP t VC-RET,
t ( XT-VC ) EXECUTE
;

$> r

t DESTROY-VC
\ MemReport