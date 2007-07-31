\ Набросок/эскиз для "трафаретной" компиляции:
\ прямое копирование кода с исправлением только 
\ отдельных, определённых мест. Под "отдельными"
\ местами понимаются например LITERAL в коде:
\ S" LITERAL LITERAL + LITERAL *" axt=>
\ То есть задав этой последовательности стек на входе
\ 10 3 5 мы должны получить на выходе xt процедуры
\ с кодом "10 3 + 5 *"

REQUIRE correct-jumps ~profit/misc/movecode2.f
REQUIRE CREATE-VC ~profit/lib/compile2Heap.f

\ Первый шаг реализации синтаксической конструкции
\ Делаем вручную то что должно делать у нас будущая конструкция
\ чтобы понять что нам надо и где будут косяки

VARIABLE n1
VARIABLE n2
VARIABLE n3

OPT? DIS-OPT \ Отключаем оптимизацию -- сюрпризы не нужны

: expr [ HERE ] 0 [ HERE ] 0 + [ HERE ] 0 * ; \ определение трафарета
\ заполняемые места помечают HERE

\ их месторасположения запоминается:
' expr - 4 + n3 !
' expr - 4 + n2 !
' expr - 4 + n1 !

TO OPT?

\ SEE expr

: }expr{ ( n1 n2 n3 -- xt ) HERE >R
['] expr COPY-CODE RET,
R@ n3 @ + !
R@ n2 @ + !
R@ n1 @ + !
R> ;

1 2 3 }expr{ REST

\ Так, работает. Теперь мы понимаем что должно делаться на этапе run-time
\ Осталось определиться с compile-time, каким образом организовать перенос
\ адресов заглушек?..

64334 CONSTANT dumm4 \ константа-определитель синтаксической конструкции

: dummy ( -- ) ?COMP
OPT? DIS-OPT \ отключаем оптимизацию: нужно сохранить литералы, чтобы было что заменять
CREATE-VC    \ создаёт виртуальный кодофайл куда будем писать операции по записыванию данных в заглушки
0 BRANCH, >MARK \ переход на ссылку вперёд
HERE -ROT \ отметку кода после перехода вперёд
dumm4 ; IMMEDIATE

\ На CS-стеке в compile-time образовывается такая последовательность:
\ ... opt here vc source dumm4 ... 

: l ?COMP DEPTH 1- 0 DO \ цикл по всему CS-стеку, чтобы допустить вложенность в другие структуры
I PICK dumm4 = IF \ когда находим dumm4
I 4 + PICK TO OPT? \ сохранённое значение OPT?
I 2 + PICK DUP HERE 4 + SWAP VC-LIT,
['] ! SWAP VC-COMPILE,
DIS-OPT
0 LIT,
UNLOOP EXIT THEN LOOP
-2007 THROW \ если dumm4 не нашли, то выдавать ошибку компиляции
; IMMEDIATE

: end ( --) ?COMP
dumm4 <> IF -2007 THROW THEN
RET, >RESOLVE1
DUP XT-VC \ начало кода в vc
OVER START{ VC- HERE }EMERGE \ текущий HERE в vc
( vc-xt vc-here ) COPY-CODE-END \ тут мы полагаемся на то что vc не разорван и там только одна полоса
\ TODO: переносить код из _всех_ кусочков vc в текущий кодофайл
DESTROY-VC \ DROP
[COMPILE] LITERAL
TO OPT? ; IMMEDIATE

: r dummy l l + end ;
SEE r
3 10 r REST

\ Пока что мы получили конструкцию dummy ... l  ... end
\ которая позволяет нам получать код процедуры между dummy и end
\ при этом каждый l превращается в число взятое из стека в run-time
\ Копирования кода нет, то есть заменяется всегда только в одном и
\ том же отрезке кода



\ И сейчас уже можно попробовать подобрать имена для конструкции:

\ слегка меняем порядок следования значений на CS-стеке (для более
\ прямолинейной обработки в конечной стадии -- "}template" ):
\ ... vc here opt source dumm4 ...

: template{ ( -- ) ?COMP
CREATE-VC    \ создаёт виртуальный кодофайл куда будем писать операции по записыванию данных в заглушки
OPT? DIS-OPT \ отключаем оптимизацию: нужно сохранить литералы, чтобы было что заменять
0 BRANCH, >MARK \ переход на ссылку вперёд
HERE -ROT \ отметку кода после перехода вперёд
dumm4 ; IMMEDIATE


: }{ ?COMP DEPTH 1- 0 DO \ цикл по всему CS-стеку, чтобы допустить вложенность в другие структуры
I PICK dumm4 = IF \ когда находим dumm4
I 4 + PICK \ промежуточный vc структуры
HERE \ адрес ячейки где будет хранится литерал в трафаретном коде (почему это он равен HERE а не HERE+4 ???)
I 3 + PICK - \ вычисляем смещение от начала трафаретного кода
I 2 + PICK TO OPT? \ сохранённое значение OPT?
OVER VC-LIT, \ записываем его
['] R@ OVER VC-COMPILE,
['] + OVER VC-COMPILE,
['] ! SWAP VC-COMPILE,
DIS-OPT
0 LIT, \ делаем литерал
UNLOOP EXIT THEN LOOP
-2007 THROW \ если dumm4 не нашли, то выдавать ошибку компиляции
; IMMEDIATE

: }template ( --) ?COMP
dumm4 <> IF -2007 THROW THEN
RET, >RESOLVE1 \ закрываем код-"трафарет"
TO OPT? \ ставим оптимизатор как было
HERE SWAP ( ... end begin )
2DUP - LIT, \ скомпилировали число -- длина трафарета
POSTPONE ALLOCATE POSTPONE THROW POSTPONE >R \ компилируем действие создания на куче места под код
DUP LIT,
POSTPONE R@
2DUP - LIT,
POSTPONE CMOVE \ переносим код из трафарета в кучу
LIT, LIT,
POSTPONE R@ POSTPONE correct-jumps \ исправляем маш. команды переходов

\ Теперь скомпилированные в vc операции подстановки значений в "гнёзда"
DUP XT-VC \ начало кода в vc
OVER START{ VC- HERE }EMERGE \ текущий HERE в vc
( ... vc-xt vc-here )
2DUP <> IF COPY-CODE-END \ тут мы полагаемся на то что vc не разорван и там только одна полоса 
ELSE 2DROP THEN 
\ TODO: переносить код из _всех_ кусочков vc в текущий кодофайл
DESTROY-VC \ DROP
POSTPONE R>
; IMMEDIATE

: r2 template{ }{ }{ * }template EXECUTE ;
' r2 HERE REST-AREA

12 10 r2 \ это не самый сложный в мире способ перемножить два числа, но к тому близко...