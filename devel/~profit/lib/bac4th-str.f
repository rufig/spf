\ Работа со строками, которые автоматически переносятся в кучу,
\ и автоматически (при откате) с неё снимаются
\ bac4th strings AKA "бэкфортовы шнуры". Без понимания работ
\ ~mlg по бэктрекингу лучше и не соваться
\ см. http://fforum.winglion.ru/viewtopic.php?t=167

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE FREEB ~profit/lib/bac4th-mem.f
REQUIRE iterateByBytes ~profit/lib/bac4th-iterators.f
REQUIRE compiledCode ~profit/lib/bac4th-closures.f
REQUIRE STR@ ~ac/lib/str4.f
REQUIRE { ~ac/lib/locals.f
REQUIRE LOCAL ~profit/lib/static.f

MODULE: bac4th-str

: ?PAIRS <> ABORT" unpaired" ;
: >RESOLVE2 ( dest -- ) HERE SWAP ! ;


: concat-sum ( addr u var -- ) @ STR+ ;
: concat-suc ( var <--> s ) @  R> ENTER  STRFREE ;

EXPORT

: S> ( a u -- s ) "" DUP >R STR+ R> ;
: S>STR ( a u --> s \ <-- s ) PRO S> CONT STRFREE ;
: S>STR2 ( a u --> s \ <-- )  PRO S> BACK STRFREE TRACKING RESTB CONT ;

: copy-patch { a u i l \ e t -- a+i l }
a u + TO e
a i + e MIN TO t
t l + e MIN
t - t SWAP ;

: copy ( a u i l --> s \ <-- s ) PRO copy-patch S>STR CONT ;

\ Генерирует функцию сравнивающую на равенство с числом
: byChar ( c <--> xt )  PRO S" C@ LITERAL =" compiledCode CONT ;
\ Обратите внимание -----------^
\ Взятие символа переносится в генерируемый код снаружи функций find , split и прочих
\ Таким образом, становится возможным использовать их не только для работы с массивом 
\ однобайтных символов но и, с допустим, с текстом в UTF-8... Э-э-э, а iterateByBytes ?.!. Хм...
\ Облом... Надо подумать.

\ Функция сравнения символа на перевод строки
\ : byRows ( <--> xt ) PRO S" 2* 23 - ABS 3 ="  compiledCode CONT ;
\ : byRows ( -- xt ) (: 2* 23 - ABS 3 = ;) ;
:NONAME C@ 2* 23 - ABS 3 = ; \ 13 или 10
CONSTANT byRows

\ Функция сравнения символа на "пустоту", т. е. или пробел, или табуляция или ещё что...
:NONAME C@ 33 < ; \ Меньше или равно 32-м, то есть если символ -- разделитель.
CONSTANT byWhites

\ Функция сравнения символа на не-"пустоту"
:NONAME C@ 32 > ; \ Больше 32-х, то есть если символ не является разделителем.
CONSTANT byNotWhites

: find ( a u f <--> a1 )
\ находит в строке a u все символы, на которых функция f даст TRUE и генерирует вызовы для каждого символа
\ Функция f ( с -- 0|-1 ) получает на входе значение символа и выводит логическое значение
PRO LOCAL f f !
iterateByBytes DUP f @ EXECUTE IF CONT THEN ;

: split-patch ( a u f <--> addr u  )
\ разбивает строку a u символами, на которых функция f даст TRUE и генерирует 
\ вызов для каждого *отрезка* в строке a u
PRO LOCAL f f !
OVER LOCAL p p ! \ p -- пред. отметка, перед запуском цикла равна началу строки
2DUP + LOCAL e e ! \ последний символ, для передачи последнего отрезка
START{
f @ find ( addr ) \ получаем адреса где искомые символы
DUP p @ -  p @ SWAP CONT 2DROP \ от предыдущего до текущего найденного символа строку выводим
DUP 1+ p ! }EMERGE

p @  e @ p @ - CONT 2DROP \ обработаем и последний отрезок, не кончающийся на char
;

: first-patch ( a u f <--> addr u ) LOCAL f f !
LOCAL len  DUP len !
LOCAL start  OVER start !
START{
S| CUT: f @ split-patch len ! start ! -CUT
}EMERGE
2DROP      \ S| восстанавливает два значения на стеке, как было до запуска S| , нужно их убрать
start @ len @ ; \ чтобы вытащить из "глубины" взятые нами значения
\ заметьте: это слово не является генератором, это обычное слово

: first ( a u f <--> s ) PRO first-patch S>STR CONT ;

: divide-patch ( a u f -- addr1 u1 addr2 u2 )     \ Первая строка -- отрезок *после* первого символа на котором сработает f
OVER >R first-patch 2DUP + OVER R> SWAP - 2SWAP ; \ Вторая -- до. Этот "обратный" порядок нужен для того чтобы,
                                                  \ как правило обрабатываемое первым значение *до* было выше на стеке.

: divide ( a u f --> s1 s2 \ <-- s1 s2 ) PRO LOCAL start LOCAL len
divide-patch 2SWAP len ! start !  S>STR  start @ len @ S>STR CONT ;

: split ( a u f <--> s1  )
\ разбивает строку a u символами, на которых функция f даст TRUE и генерирует вызов для 
\ каждой последовательности между этими символами с автоматическим выделением и снятием памяти
PRO split-patch 2DUP S>STR CONT ;

: last-patch ( a u f <--> addr u ) PRO LOCAL a LOCAL len
START{ split-patch DUP len ! OVER a ! }EMERGE a @ len @ CONT 2DROP ;

: last ( a u f <--> s1  )
PRO last-patch 2DUP S>STR CONT ;

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
: copy3-2 3 2 copy DUP STR@ TYPE ;
>> S" forth" copy3-2

: r S" mary has sheep" [CHAR] a byChar find DUP C@ EMIT ;
\ находим все символы 'a'
\ CR r

: split2Words BL byChar split notEmpty ."  [" DUP STR@ TYPE ." ]" ;
\ делим на слова. Каждое слово -- не отрезок из главной строки, он перенесён в кучу 
\ и автоматически при отходе назад из кучи снимается
\ вывод: [mary] [has] [a] [sheep]
>> S"  mary  has a  sheep" split2Words

: split2WordsAndByA BL byChar split DUP STR@ [CHAR] a byChar split notEmpty ."  [" DUP STR@ TYPE ." ]" ;
\ делим на слова и на отрезки между буквам 'a' в словах.
\ вывод: [ntigu] [l] [br] [dor] [br] [c] [d] [br]
>> S" antigua labrador abracadabra" split2WordsAndByA

: firstWord BL 2DROPB DROPB S|  CUT: byChar split -CUT ."  [" DUP STR@ TYPE ." ]" ;
\ только первая сгенерированная последовательность
\ вывод: [antigua]
\ внимание, в этом примере на стеке остаётся мусор, не говоря уже о том что он протекает по памяти
\ так как CUT убирает освобождение памяти занятой внутри split со стека возвратов
\ Мусор убираем стековым контролем: 2DROPB DROPB S|
>> S" antigua labrador abracadabra" firstWord

: "2"+"*2"+"=4"+"?" concat{ *> concat{ *> S" 2" <*> S" *2" <* }concat DUP STR@ <*> S" =4" <*> S" ?" <* }concat DUP STR@ TYPE ;
>> "2"+"*2"+"=4"+"?"

\ вывод: 2*2=4?

: splitNmerge concat{ BL byChar split notEmpty DUP STR@ }concat ."  [" DUP STR@ TYPE ." ]" ;
\ убирает все пробелы в строке
\ вывод: [maryhasasheep]
>> S"   mary   has  a  sheep" splitNmerge

: divideBy= [CHAR] = byChar divide-patch 2SWAP TYPE SPACE TYPE ;
\ разбивает строку на две части
\ вывод: [a1] [123==456]
>> S" a1=123==456" divideBy=

: printFile  S" C:\lang\spf\devel\~profit\lib\bac4th-str.f" iterateStrings DUP STR@ CR TYPE ;
\ вывод файла на печать