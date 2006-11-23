( Поиск слов в словарях и управление порядком поиска.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

VECT FIND

VECT SEARCH-WORDLIST ( c-addr u wid -- 0 | xt 1 | xt -1 ) \ 94 SEARCH
\ Найти определение, заданное строкой c-addr u в списке слов, идентифицируемом 
\ wid. Если определение не найдено, вернуть ноль.
\ Если определение найдено, вернуть выполнимый токен xt и единицу (1), если 
\ определение немедленного исполнения, иначе минус единицу (-1).

\ Оптимизировано by day (29.10.2000)
\ Оптимизировано by mak July 26th, 2001 - 15:45

CODE CDR-BY-NAME ( c-addr u nfa1|0 -- c-addr u nfa1|nfa2|0 )
\ тоже, что и CDR (см. в spf_wordlist.f), но кроме конца списка стопором является и заданное имя.
\ Код наследован от SEARCH-WORDLIST, by ~ygrek Nov.2006
      PUSH EDI

      MOV EDX, [EBP]                \ длина (счетчик)
      OR EDX, EDX 		    
      JZ SHORT @@2                  \ если длина ноль - сразу на выход 

      MOV ESI, EAX                  \ вход в список
      MOV EDI, 4 [EBP]              \ искомое слово в ES:DI

      A;  0xBB C, -1 W, 0 W, \    MOV EBX, # FFFF
      CMP EDX, # 3
      JB  SHORT @@8
      A;  0xBB C,  -1 DUP W, W, \   MOV  EBX, # FFFFFFFF
@@8:   MOV EAX, [EDI]
      SHL EAX, # 8
      OR  EDX, EAX
      AND EDX, EBX
      MOV AL, # 0
      A;  0x25 C, 0xFF C, 0 C, 0 W, \       AND EAX, # FF
      JMP @@1
@@3:
      A;  0x25 C, 0xFF C, 0 C, 0 W, \       AND EAX, # FF
      MOV ESI, 1 [ESI] [EAX]
@@1:   OR ESI, ESI
      JZ SHORT @@2                   \ конец поиска
      MOV EAX, [ESI]
      AND EAX, EBX
      CMP EAX, EDX
      JNZ SHORT @@3              \ длины не равны - идем дальше
\ проверить всю строку
      INC ESI
      CLD
      XOR ECX, ECX
      MOV CL, DL
      PUSH ESI
      PUSH EDI                  \ сохраняем адрес начала искомого слова
      REPZ CMPS BYTE
      POP EDI
      JZ SHORT @@5
      POP EAX                   \ значение esi не интересует в случае неудачи
      MOV ESI, [ESI] [ECX]
      JMP SHORT @@1
@@2:
      XOR EAX, EAX
      JMP SHORT @@7                  \ выход с "не найдено"

@@5:  
      POP ESI
      DEC ESI               \   передвигаемся от начала строки к NFA
      MOV EAX, ESI
@@7:
      POP EDI
      RET
END-CODE

\ форт-реализация:
\ : CDR-BY-NAME ( a u nfa1|0 -- a u nfa2|0 )
\  BEGIN  ( a u NFA | a u 0 )
\    DUP
\  WHILE  ( a u NFA )
\    >R 2DUP R@ COUNT COMPARE R> SWAP
\  WHILE
\    CDR  ( a u NFA2 )
\  REPEAT THEN 
\ ;

: SEARCH-WORDLIST-NFA ( c-addr u wid -- 0 | nfa -1 )
   @ CDR-BY-NAME NIP NIP ?DUP 0<>
;

: SEARCH-WORDLIST1
   SEARCH-WORDLIST-NFA 0= IF 0 EXIT THEN
   DUP NAME>
   SWAP ?IMMEDIATE IF 1 EXIT THEN -1
;

' SEARCH-WORDLIST1 (TO) SEARCH-WORDLIST


USER-CREATE S-O 16 CELLS TC-USER-ALLOT \ порядок поиска
USER-VALUE CONTEXT    \ CONTEXT @ дает wid1

: SFIND ( addr u -- addr u 0 | xt 1 | xt -1 ) \ 94 SEARCH
\ Расширить семантику CORE FIND следующим:
\ Искать определение с именем, заданным строкой addr u.
\ Если определение не найдено после просмотра всех списков в порядке поиска,
\ возвратить addr u и ноль. Если определение найдено, возвратить xt.
\ Если определение немедленного исполнения, вернуть также единицу (1);
\ иначе также вернуть минус единицу (-1). Для данной строки, значения,
\ возвращаемые FIND во время компиляции, могут отличаться от значений,
\ возвращаемых не в режиме компиляции.
  S-O 1- CONTEXT
  DO
   2DUP I @ SEARCH-WORDLIST
    DUP IF 2SWAP 2DROP UNLOOP EXIT THEN DROP
   I S-O = IF LEAVE THEN
   1 CELLS NEGATE
  +LOOP
  0
;

: FIND1 ( c-addr -- c-addr 0 | xt 1 | xt -1 ) \ 94 SEARCH
\ Расширить семантику CORE FIND следующим:
\ Искать определение с именем, заданным строкой со счетчиком c-addr.
\ Если определение не найдено после просмотра всех списков в порядке поиска,
\ возвратить c-addr и ноль. Если определение найдено, возвратить xt.
\ Если определение немедленного исполнения, вернуть также единицу (1);
\ иначе также вернуть минус единицу (-1). Для данной строки, значения,
\ возвращаемые FIND во время компиляции, могут отличаться от значений,
\ возвращаемых не в режиме компиляции.
  DUP >R COUNT SFIND
  DUP 0= IF NIP NIP R> SWAP ELSE RDROP THEN
;

: DEFINITIONS ( -- ) \ 94 SEARCH
\ Сделать списком компиляции тот же список слов, что и первый список в порядке 
\ поиска. Имена последующих определений будут помещаться в список компиляции.
\ Последующие изменения порядка поиска не влияют на список компиляции.
  CONTEXT @ SET-CURRENT
;

: GET-ORDER ( -- widn ... wid1 n ) \ 94 SEARCH
\ Возвращает количество списков слов в порядке поиска - n и идентификаторы 
\ widn ... wid1, идентифицирующие эти списки слов. wid1 - идентифицирует список 
\ слов, который просматривается первым, и widn - список слов, просматриваемый 
\ последним. Порядок поиска не изменяется.
  CONTEXT 1+ S-O DO I @ 1 CELLS +LOOP
  CONTEXT S-O - 1 CELLS / 1+
;

: FORTH ( -- ) \ 94 SEARCH EXT
\ Преобразовать порядок поиска, состоящий из widn, ...wid2, wid1 (где wid1 
\ просматривается первым) в widn,... wid2, widFORTH-WORDLIST.
  FORTH-WORDLIST CONTEXT !
;

: ONLY ( -- ) \ 94 SEARCH EXT
\ Установить список поиска на зависящий от реализации минимальный список поиска.
\ Минимальный список поиска должен включать слова FORTH-WORDLIST и SET-ORDER.
  S-O TO CONTEXT
  FORTH
;

: SET-ORDER ( widn ... wid1 n -- ) \ 94 SEARCH
\ Установить порядок поиска на списки, идентифицируемые widn ... wid1.
\ Далее список слов wid1 будет просматриваться первым, и список слов widn
\ - последним. Если n ноль - очистить порядок поиска. Если минус единица,
\ установить порядок поиска на зависящий от реализации минимальный список
\ поиска.
\ Минимальный список поиска должен включать слова FORTH-WORDLIST и SET-ORDER.
\ Система должна допускать значения n как минимум 8.
   DUP IF DUP -1 = IF DROP ONLY EXIT THEN
          DUP 1- CELLS S-O + TO CONTEXT
          0 DO CONTEXT I CELLS - ! LOOP
       ELSE DROP S-O TO CONTEXT  CONTEXT 0! THEN
;


: ALSO ( -- ) \ 94 SEARCH EXT
\ Преобразовать порядок поиска, состоящий из widn, ...wid2, wid1 (где wid1 
\ просматривается первым) в widn,... wid2, wid1, wid1. Неопределенная ситуация 
\ возникает, если в порядке поиска слишком много списков.
  GET-ORDER 1+ OVER SWAP SET-ORDER
;
: PREVIOUS ( -- ) \ 94 SEARCH EXT
\ Преобразовать порядок поиска, состоящий из widn, ...wid2, wid1 (где wid1 
\ просматривается первым) в widn,... wid2. Неопределенная ситуация возникает,
\ если порядок поиска был пуст перед выполнением PREVIOUS.
  CONTEXT 1 CELLS - S-O MAX TO CONTEXT
;

: VOC-NAME. ( wid -- ) \ напечатать имя списка слов, если он именован
  DUP FORTH-WORDLIST = IF DROP ." FORTH" EXIT THEN
  DUP CELL+ @ DUP IF ID. DROP ELSE DROP ." <NONAME>:" U. THEN
;

: ORDER ( -- ) \ 94 SEARCH EXT
\ Показать списки в порядке поиска, от первого просматриваемого списка до 
\ последнего. Также показать список слов, куда помещаются новые определения.
\ Формат изображения зависит от реализации.
\ ORDER может быть реализован с использованием слов форматного преобразования
\ чисел. Следовательно он может разрушить перемещаемую область, 
\ идентифицируемую #>.
  GET-ORDER ." Context: "
  0 ?DO ( DUP .) VOC-NAME. SPACE LOOP CR
  ." Current: " GET-CURRENT VOC-NAME. CR
;

: LATEST ( -> NFA )
  CURRENT @ @
;
