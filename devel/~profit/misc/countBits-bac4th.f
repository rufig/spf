\ http://fforum.winglion.ru//viewtopic.php?t=465
\ Подсчет кол-ва битов в слов, проверка bac4th'ом

REQUIRE +{ ~profit/lib/bac4th.f
REQUIRE iterateBy ~profit/lib/bac4th-iterators.f
REQUIRE arr{ ~profit/lib/bac4th-sequence.f
REQUIRE time-reset ~af/lib/elapse.f
REQUIRE GENRAND ~ygrek/lib/neilbawd/mersenne.f
REQUIRE memoize: ~ygrek/lib/fun/memoize.f
REQUIRE CODE lib/ext/spf-asm-tmp.f

GetTickCount SGENRAND \ заряжаем рулетку

: countBitsInBytes ( byte -- un ) \ ~af
0      OVER     1 AND IF 1+ THEN
       OVER     2 AND IF 1+ THEN
       OVER     4 AND IF 1+ THEN
       OVER     8 AND IF 1+ THEN
       OVER    16 AND IF 1+ THEN
       OVER    32 AND IF 1+ THEN
       OVER    64 AND IF 1+ THEN
       SWAP   128 AND IF 1+ THEN ;

: countBitsInCell ( cell -- un ) \ ~mak
   DUP 0x55555555 AND SWAP 0xAAAAAAAA AND 1 RSHIFT + 
   DUP 0x33333333 AND SWAP 0xCCCCCCCC AND 2 RSHIFT + 
   DUP 0x0F0F0F0F AND SWAP 0xF0F0F0F0 AND 4 RSHIFT + 
   DUP 0x00FF00FF AND SWAP 0xFF00FF00 AND 8 RSHIFT + 
   DUP 0x0000FFFF AND SWAP 0xFFFF0000 AND 16 RSHIFT + ;

: BITS-WORD ( w -- un ) \ chess
DUP 0x5555 AND SWAP 0xAAAA AND 1 RSHIFT + 
DUP 0x3333 AND SWAP 0xCCCC AND 2 RSHIFT + 
DUP 0x0F0F AND SWAP 0xF0F0 AND 4 RSHIFT + 
DUP 0x00FF AND SWAP 0xFF00 AND 8 RSHIFT + ;

CODE ?bits ( cell -- un )  \ mOleg
           XOR EBX, EBX 
      @@1: OR EAX, EAX 
           JZ @@2
           MOV EDX, EAX 
           AND EDX, # 1 
           ADD EBX, EDX 
           SHR EAX, # 1 
           JMP @@1
      @@2: MOV EAX, EBX 
           RET
END-CODE

: bc ( n — c ) \ forther
    -1 0 DO
        DUP 0= IF DROP I LEAVE THEN 
        DUP 1- AND 
    LOOP ;

\ ----- Testing ------ 
    1024 CONSTANT KB 
 KB KB * CONSTANT MB 

10 MB * CONSTANT BytesInArray \ 10 Мб, если хотите -- ставьте больше

\ Выделение тестового масиива 
USER Array
BytesInArray ALLOCATE THROW Array !

: arr Array @ BytesInArray ;

: fillArray arr  1 iterateBy  256 GENRANDMAX OVER C! ;
fillArray
.( Array allocated and filled) CR

\ Побайтовое простое вычисление суммы битов
: af     ( addr u -- un ) +{    1 iterateBy DUP C@ countBitsInBytes }+ ;

\ Пословное простое вычисление суммы битов
: chess  ( addr u -- un ) +{    2 iterateBy DUP W@ BITS-WORD        }+ ;

\ Простое вычисление суммы битов по ячейкам (вариант Михаила на форте)
: mak    ( addr u -- un ) +{ CELL iterateBy DUP @  countBitsInCell  }+ ;

\ Простое вычисление суммы битов по ячейкам (вариант Олега на ассемблере)
: mOleg  ( addr u -- un ) +{ CELL iterateBy DUP @  ?bits            }+ ;

: forther ( addr u -- un ) +{ CELL iterateBy DUP @  bc            }+ ;

\ Сумма битов с использованием промежуточного массива всех байтовых результатов
: af-arr ( addr u -- un ) LOCAL f
arr{ 0 256 1 iterateBy DUP countBitsInBytes DROPB }arr \ генерируем массив результатов для всех байтовых значений
DROP
" CELLS LITERAL + @ " STRcompiledCode  f ! \ генерируем функцию доступа к массиву сохранённых результатов
+{    1 iterateBy DUP C@ f @ ENTER }+ ; \ само вычисление, собственно

\ Сумма битов с использованием промежуточного массива всех двубайтовых результатов
: chess-arr ( addr u -- un ) LOCAL f
arr{ 0 256 DUP * 1 iterateBy DUP BITS-WORD DROPB }arr \ генерируем массив результатов для всех двубайтовых значений
DROP
time-reset \ Генерация массива с 64 тысячами ячеек может занять некоторое время, поэтому честнее его не считать
\ В самой программе генерация промежуточного массива конечно, должна быть отделена..
" CELLS LITERAL + @ " STRcompiledCode  f ! \ генерируем функцию доступа к массиву сохранённых результатов
+{    2 iterateBy DUP W@ f @ ENTER }+ ; \ само вычисление, собственно

CR CR
.(         -={ Let Mortal Kombat begin!! }=-) CR

time-reset .( af:        ) arr af        . .elapsed CR
time-reset .( chess:     ) arr chess     . .elapsed CR
time-reset .( mak:       ) arr mak       . .elapsed CR
time-reset .( mOleg:     ) arr mOleg     . .elapsed CR
time-reset .( forther:   ) arr forther   . .elapsed CR
time-reset .( af-arr:    ) arr af-arr    . .elapsed CR
time-reset .( chess-arr: ) arr chess-arr . .elapsed CR

WARNING @ WARNING 0!
memoize: countBitsInBytes \ Мемуазированная функция на хэшах
: af-mmz ( addr u -- un ) +{    1 iterateBy DUP C@ countBitsInBytes }+ ;
time-reset .( af-mmz:    ) arr af-mmz    . .elapsed CR
WARNING !

\ memoize: countBitsInBytes
\ memoize: BITS-WORD
\ \ memoize: countBitsInCell \ Ой, этого делать никак не следовало...

\ memoize тут только тормозит дело... Видимо, от того что сами функции
\ недостаточно сложны и "ленивое" сохранение их результатов и забор
\ их из хэша занимает больше времени, нежели "энергичное", простое,
\ вычисление впрямую.