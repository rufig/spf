\ Статические переменные, хранящиеся непосредственно в шитом
\ коде определения.
\ В комбинации с словом B! или KEEP (слово LOCAL, см. пример
\ внизу) можно использовать как полностью bac4th-совместимые
\ локальные переменные.

MODULE: static
\ также определено в ~profit/lib/bac4th.f
\ см. ~mlg/BacFORTH-88/BF-Diplom.html и/или
\ http://fforum.winglion.ru/viewtopic.php?p=2151#2151
: KEEP ( addr --> / <-- ) R> SWAP DUP @  2>R EXECUTE 2R> SWAP ! ;

USER widLocals
widLocals 0!

USER widHere

: ADD-ORDER ( wid -- ) ALSO CONTEXT ! ;

: END-STATIC widLocals @  IF \ Проверка на наличие локального словаря сделана на всякий пожарный (мало ли?)
HERE PREVIOUS DEFINITIONS
widLocals @ FREE-WORDLIST
DP ! widLocals 0!         THEN ;

: (;) ?COMP END-STATIC S" ;" EVAL-WORD ;

: CREATE-LOCAL-WORDLIST ( -- )      \ Создаём словарь локальных переменных
TEMP-WORDLIST ADD-ORDER DEFINITIONS \ Создаём временным словарь, делаем его текущим
S" ;" CREATED IMMEDIATE             \ Вписываем в словарь слово ; которое будет заканчивать работу лок. переменных
DOES> DROP (;) ;

: LOCAL-WORDLIST widLocals @ 0= IF     \ Переходим во временный словарь лок. переменных.
CREATE-LOCAL-WORDLIST                  \ Если в первый раз, то он создаётся и устанавливается как текущий
CONTEXT @ widLocals !           ELSE
widHere @ DP !  DEFINITIONS     THEN ; \ Если словарь уже создан, то возрашаем тамошний HERE и начинаем опять писать в него слова

EXPORT
: STATIC ( "name -- ) ?COMP 
HERE LAST @ NAME> =              \ еще ничего не компилировалось 
IF  0 , HERE LAST @ NAME>C !     \ пишем ячейку, сдвигаем поле кода
ELSE                             \ шитый код уже есть, поэтому ячейку внедряем
0 BRANCH, >MARK                  \ jmp HERE+ячейка , перескакиваем ячейку 
\ ALIGN                          \ дизассемблеру это может не понравится, хотя работать будет... 
0 ,                              \ сама ячейка, пишем ноль 
1 >RESOLVE                       \ ставим ссылку jmp на сюда 
THEN 

LAST @ HERE                      \ отмечаем HERE внутри определения, сохраняем LAST
CURRENT @  WARNING @  WARNING 0! \ конфликты по именам игнорируем 
LOCAL-WORDLIST                   \ создаём или переходим во временный словарь локальных переменных 
CREATE IMMEDIATE                 \ создаём в временном словаре имя локальной переменной 
WARNING ! 
OVER CELL - ,                    \ присваиваем слову временного словаря ячейку 
HERE widHere !                   \ отмечаем HERE внутри словаря 
SET-CURRENT 
DP ! LAST !                      \ возращаем HERE внутри определения, восстанавливаем LAST
DOES> @ LIT, ; IMMEDIATE

: LOCAL ( "name -- ) [COMPILE] STATIC
widLocals @ @ NAME> EXECUTE
POSTPONE KEEP ; IMMEDIATE

;MODULE

\EOF
: previousValue
STATIC a
a @
SWAP a ! ;

REQUIRE SEE lib/ext/disasm.f
SEE previousValue

\ 559330 E904000000       JMP     559339  ( previousValue+9  )
\ 559335 0000             ADD     [EAX] , AL
\ 559337 0000             ADD     [EAX] , AL
\ 559339 8BD0             MOV     EDX , EAX
\ 55933B A135935500       MOV     EAX , 559335  ( previousValue+5  )
\ 559340 891535935500     MOV     559335  ( previousValue+5  ) , EDX
\ 559346 C3               RET     NEAR

1 previousValue .
2 previousValue .
3 previousValue .

: sum ( a b -- )
STATIC a
STATIC b
a ! b !

a @ b @ +

STATIC c c !
c @ ;

: fact ( n -- n! ) \ Не самый удачный пример, согласен.
DUP 0=      IF     \ Но тем не менее показывает как сохраняются локальные
DROP 1      ELSE   \ значения в статических переменных
LOCAL n            \ Тоже самое что и STATIC n  n KEEP
DUP n !
1- RECURSE
n @ *       THEN ;