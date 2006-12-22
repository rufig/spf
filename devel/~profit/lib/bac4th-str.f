\ Работа со строками, которые автоматически переносятся в кучу, 
\ и автоматически (при откате) с неё снимаются
\ bac4th strings AKA "бэкфортовы шнуры". Без понимания работ ~mlg по бэктрекингу лучше и не соваться
\ см. http://fforum.winglion.ru/viewtopic.php?t=167

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE FREEB ~profit/lib/bac4th-mem.f
REQUIRE compiledCode ~profit/lib/bac4th-closures.f
REQUIRE STR@ ~ac/lib/str4.f

MODULE: bac4th-str

: ?PAIRS <> ABORT" unpaired" ;
: >RESOLVE2 ( dest -- ) HERE SWAP ! ;


: >STR ( a u -- s ) "" DUP >R STR+ R> ;

0 VALUE previousAddress

: concat-sum ( addr u var -- ) @ STR+ ;
: concat-suc ( var <--> s ) @  R> ENTER  STRFREE ;

EXPORT

: copy ( a u i l <--> s1  ) \ l=-1 ?
PRO { a u i l \ e t -- }
a u + TO e
a i + e MIN TO t
t l + e MIN
t - t SWAP
>STR CONT STRFREE ;

: byChar ( c <--> xt )  PRO S" LITERAL =" compiledCode CONT ;
\ : byRows ( <--> xt ) PRO S" 2* 23 - ABS 3 ="  compiledCode CONT ;
\ : byRows ( -- xt ) (: 2* 23 - ABS 3 = ;) ;
:NONAME 2* 23 - ABS 3 = ; \ 13 или 10
CONSTANT byRows 

: find ( a u c <--> a1 )
\ находит в строке a u все символы c и генерирует вызовы для каждого символа
PRO { a u c -- }
a u + a ?DO I C@ c EXECUTE IF I CONT DROP THEN LOOP ;

: divide ( a u c <--> s1 )
\ разбивает строку a u первым символом c и генерирует два вызова со строками
\ перед символом и после с автоматическим выделением и снятием памяти
PRO { a u c -- }
a u c PREDICATE find SUCCEEDS IF \ если есть искомый символ, то генерируем две строки
DUP a - a SWAP >STR CONT STRFREE
1+ a u + OVER - >STR CONT STRFREE
ELSE a u >STR CONT STRFREE THEN ; \ если нету -- одну

: split-patch ( a u c <--> addr u  )
\ разбивает строку a u символами c и генерирует вызов для каждого
\ *отрезка* в строке a u
PRO { a u c -- }
a TO previousAddress
a u + a u c
START{
find
DUP previousAddress - previousAddress SWAP CONT 2DROP
DUP 1+ TO previousAddress }EMERGE
previousAddress - previousAddress SWAP CONT 2DROP \ обработаем и последний отрезок, не кончающийся на char
;

: split ( a u c <--> s1  )
\ разбивает строку a u символами c и генерирует вызов для каждой последовательности
\ между этими символами с автоматическим выделением и снятием памяти
PRO split-patch 2DUP >STR CONT STRFREE ;

: notEmpty ( s <--> s ) PRO DUP STR@ NIP ONTRUE CONT ; \ отфильтровывает пустые строки

\ конструкция ... concat{ генератор-строк ( addr u ) }concat ( s <-> s ) ...
: concat{  ?COMP POSTPONE "" agg{ ; IMMEDIATE
: }concat  ?COMP ['] concat-sum ['] concat-suc }agg ; IMMEDIATE

: load-file ( addr u <--> addr1 u1 ) \ загружаем файл
PRO FILE CONT DROP FREE THROW ;

: iterateStrings ( addr u <--> s ) PRO \ пускаем цикл по строкам файла
load-file 2DUP byRows ( функция проверки на перевод строки)
split notEmpty CONT ;

;MODULE

/TEST
: e S" forth" 3 2 copy DUP STR@ TYPE ; CR e

: r S" mary has sheep" [CHAR] a byChar find DUP C@ EMIT ;
\ находим все символы 'a'
\ CR r

: r2 S"  mary  has a  sheep" BL byChar split notEmpty ."  [" DUP STR@ TYPE ." ]" ;
\ делим на слова. Каждое слово -- не отрезок из главной строки, он перенесён в кучу 
\ и автоматически при отходе назад из кучи снимается
\ вывод: [mary] [has] [a] [sheep]
 CR r2

: r3 S" antigua labrador abracadabra"  BL byChar split DUP STR@ [CHAR] a byChar split notEmpty ."  [" DUP STR@ TYPE ." ]" ;
\ делим на слова и на отрезки между буквам 'a' в словах.
\ вывод: [ntigu] [l] [br] [dor] [br] [c] [d] [br]
CR r3

: r4 S" antigua labrador abracadabra"  BL byChar CUT: split -CUT ."  [" DUP STR@ TYPE ." ]" ;
\ только первая сгенерированная последовательность
\ вывод: [antigua]
\ внимание, в этом примере на стеке остаётся мусор, не говоря уже о том что он протекает по памяти
\ так как CUT убирает освобождение памяти занятой внутри split со стека возвратов
\ CR r4

: r7 concat{ *> concat{ *> S" 2" <*> S" *2" <* }concat DUP STR@ <*> S" =4" <*> S" ?" <* }concat DUP STR@ TYPE ;
CR r7

\ вывод: 2*2=4?

: r8 concat{ S"     mary  has  a  sheep" BL byChar split notEmpty DUP STR@ }concat ."  [" DUP STR@ TYPE ." ]" ;
\ убирает все пробелы в строке
\ вывод: [maryhasasheep]
 CR r8

: r9 S" a1=123==456" [CHAR] = byChar divide DUP ."  [" STR@ TYPE ." ]" ;
\ разбивает строку на две части
\ вывод: [a1] [123==456]
\ и снова CUT оставляет мусор
\ CR r9

: printFile  S" C:\lang\spf\devel\~profit\lib\bac4th-str.f" iterateStrings DUP STR@ CR TYPE ;
\ вывод файла на печать