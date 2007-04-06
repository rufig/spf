\ Статические переменные, хранящиеся непосредственно в шитом
\ коде определения.
\ В комбинации с словом B! или KEEP (слово LOCAL, см. пример
\ внизу) можно использовать как полностью bac4th-совместимые
\ локальные переменные.
\ Описание и обсуждение: http://fforum.winglion.ru/viewtopic.php?t=409

\ При использовании в bac4th-словах, LOCAL надо размещать
\ *после* PRO

\ STATIC и LOCAL выставляют переменные в ноль

\ TODO: Сделать запись значений переменных группами а не по одному

REQUIRE KEEP ~profit/lib/bac4th.f
REQUIRE NOT ~profit/lib/logic.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: static

USER widLocals
widLocals 0!

USER widHere
USER widCurrent

: ADD-ORDER ( wid -- ) ALSO CONTEXT ! ;

: END-STATIC widLocals @  IF \ Проверка на наличие локального словаря сделана на всякий пожарный (мало ли?)
HERE PREVIOUS widCurrent @ SET-CURRENT \ Восстанавливаем стек словарей и CURRENT
widLocals @ FREE-WORDLIST
DP ! widLocals 0!         THEN ;

: (;) ?COMP END-STATIC S" ;" EVAL-WORD ;

: CREATE-LOCAL-WORDLIST ( -- )      \ Создаём словарь локальных переменных
GET-CURRENT widCurrent !            \ Запоминаем CURRENT
TEMP-WORDLIST ADD-ORDER DEFINITIONS \ Создаём временным словарь, делаем его текущим
S" ;" CREATED IMMEDIATE             \ Вписываем в словарь слово ; которое будет заканчивать работу лок. переменных
DOES> DROP (;) ;

: LOCAL-WORDLIST widLocals @ NOT IF     \ Переходим во временный словарь лок. переменных.
CREATE-LOCAL-WORDLIST                  \ Если в первый раз, то он создаётся и устанавливается как текущий
CONTEXT @ widLocals !            ELSE
widHere @ DP !  DEFINITIONS      THEN ; \ Если словарь уже создан, то возрашаем тамошний HERE и начинаем опять писать в него слова


: STATIC=>
HERE LATEST NAME> =                \ мы находимся в слове, в котором ещё ничего не компилировалось 
IF R> EXECUTE HERE LATEST NAME>C ! \ пишем ячейку, сдвигаем поле кода
ELSE                               \ шитый код уже есть, тогда ячейку внедряем
0 BRANCH, >MARK                    \ jmp HERE+ячейка , перескакиваем ячейку 
R> EXECUTE                         \ здесь делаем компиляцию переменной (-ых)
1 >RESOLVE THEN                    \ ставим ссылку jmp на сюда 
LAST @ HERE                        \ отмечаем HERE внутри определения, сохраняем LAST
CURRENT @  WARNING @  WARNING 0!   \ конфликты по именам игнорируем 
LOCAL-WORDLIST                     \ создаём или переходим во временный словарь локальных переменных 
CREATE IMMEDIATE                   \ создаём в временном словаре имя локальной переменной 
WARNING !
OVER CELL - ,                      \ присваиваем слову временного словаря ячейку 
HERE widHere !                     \ отмечаем HERE внутри словаря 
SET-CURRENT 
DP ! LAST !                        \ возращаем HERE внутри определения, восстанавливаем LAST
DOES> @ LIT, ;

VARIABLE staticLen

: >numb 0. 2SWAP >NUMBER 2DROP D>S ;

: lastLocal  ( -- xt ) widLocals @ @ NAME>  ;

EXPORT
: STATIC ( "name -- ) ?COMP 
STATIC=>
\ ALIGN                          \ дизассемблеру это может не понравится, хотя работать будет... 
0 ,                              \ сама ячейка, пишем ноль 
; IMMEDIATE

: STATIC# ( len "name -- ) ?COMP
NextWord >numb staticLen !  \ запоминаем длину статического массива (в ячейках!)
STATIC=> staticLen @ 0 DO 0 , LOOP \ записываем ячейки
; IMMEDIATE


: LOCAL ( "name -- ) [COMPILE] STATIC
lastLocal EXECUTE
POSTPONE KEEP ; IMMEDIATE

: LPARAMETER ( "name -- ) [COMPILE] STATIC
lastLocal EXECUTE
POSTPONE KEEP
lastLocal EXECUTE
POSTPONE ! ; IMMEDIATE

;MODULE

/TEST
: previousValue
STATIC a
a @
SWAP a ! ;

REQUIRE SEE lib/ext/disasm.f
$> SEE previousValue

\ 559330 E904000000       JMP     559339  ( previousValue+9  )
\ 559335 0000             ADD     [EAX] , AL
\ 559337 0000             ADD     [EAX] , AL
\ 559339 8BD0             MOV     EDX , EAX
\ 55933B A135935500       MOV     EAX , 559335  ( previousValue+5  )
\ 559340 891535935500     MOV     559335  ( previousValue+5  ) , EDX
\ 559346 C3               RET     NEAR

$> 1 previousValue .
$> 2 previousValue .
$> 3 previousValue .
$> 10 previousValue .

: fact ( n -- n! ) \ Не самый удачный пример, согласен.
DUP 0=      IF     \ Но тем не менее показывает как сохраняются локальные
DROP 1      ELSE   \ значения в статических переменных
LOCAL n            \ Тоже самое что и STATIC n  n KEEP
DUP n !
1- RECURSE
n @ *       THEN ;

$> 10 fact .

\ Упрощённое создание локальных аргументов,
\ "Обёртка" для LOCAL par par !
\ Как и LOCAL -- обёртка для STATIC# 1 par par KEEP
: localsTest ( a b -- sum )
LPARAMETER b  LPARAMETER a \ в противоположном к стековой нотации порядке
\ то есть согласно расположению на стеке
a @ 0= IF 0 EXIT THEN
a @ b @ 0 0 RECURSE + + . ;
$> 3 4 localsTest
SEE localsTest

0
CELL -- a
CELL -- b
CELL -- c
DROP

: sum ( a b -- )
STATIC# 3 s \ занимаем в шитом коде пространство в 3 ячейки и 
\ даём ей имя s

s a ! s b !

s a @
s b @ + 
s c !
s c @ ;

$> 1 3 sum .