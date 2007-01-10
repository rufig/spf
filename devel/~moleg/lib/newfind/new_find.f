\ 28-12-2006
\ заменяем неудобный SFIND на более логичный
\ порядок следования параметров теперь будет следующим:
\ ( asc # --> asc # false | wid imm true )
\ то есть всегда возвращаем три числа!
\ либо возвращаем начальную строку с признаком false
\ либо - адрес флаг_immediate true

S" tools.f" INCLUDED  \ можно убрать, но тогда нужно убирать и все [IF]-ы и т.п.

\ в СПФ4 - это слово работает не очень верно - переопределил
: ?IMMEDIATE ( NFA -> F ) NAME>F C@ &IMMEDIATE AND 0<> ;

\ удалить с вершины стека указанное число параметров
: nDROP ( [ .. ] n --> ) 1+ CELLS SP@ + SP! ;

\ ______________________________________________________________________________

\ выдать адрес и длинну идентификатора имени.
\ все мое творчество здесь и далее на нижнем регистре
: id>asc ( NFA --> asc # ) DUP 1+ SWAP C@ ;

\ сравнить полученную лексему с именем слова
\ так проще менять код, если изменится формат словарной статьи
: identify ( asc # nameid --> flag )
           id>asc 2SWAP COMPARE ;

\ заглушка на случай хешированных словарей
\ используя лексему и id словаря найти адрес начала цепочки слов, в которой
\ необходимо искать слова. Убирать смысла не имеет, так как оптимизатор
\ всеравно подставит @ в код.
: hashname ( asc # wid --> asc # link ) @ ;

\ найти слово в указанном словаре
\ тоже меняем порядок параметров, за счет чего сокращается размер слова.
: search-wordlist  ( asc # voc-id -- asc # false | xt imm_flag true )
                   hashname
                   BEGIN DUP WHILE
                         >R 2DUP R@ identify WHILE
                         R> CDR
                   REPEAT
                     2DROP R@ NAME>C @
                           R> ?IMMEDIATE TRUE
                   THEN ;

\ на входе список словарей, в которых нужно вести поиск и их кол-во
\          и строка - идентификатор имени
\ на выходе в случае неуспеха строка и false
\           в случае успеха исполнимый адрес слова и два флага
\           immediate и true
: sfindin ( vidn ... vidb wida #  asc # --> asc # false | xt imm_flag true )
          ROT BEGIN DUP WHILE 1- >R  \ кол-во словарей для просмотра на R
                    ROT search-wordlist 0= WHILE \ лучше бы WHILENOT
                    R>
               REPEAT
                 R> -ROT 2>R nDROP 2R> TRUE
                 \ немного чудес на стеках 8) но тут иначе никак.
              THEN ;
\ sfindin сделан именно для того, чтобы иметь возможность искать в коллекциях
\ словарей, а не только в контексте.

\ найти слово в контексте
: sfind ( addr u -- addr u 0 | xt imm true )
        2>R GET-ORDER 2R> sfindin ;

\ найти адрес слова, представленного строкой в тексте
\ после ' в текущем контексте.
\ Возвращает адрес, в случае ненахождения слова возникает исключение
: ' ( "<spaces>name" -- xt )
    NextWord sfind
    IF DROP           \ признак immediate нам не нужен
     ELSE -321 THROW
    THEN ;

\ найти слово, если операция успешна скомпилировать его адрес в текущее
\ собираемое определение.
: ['] ( name | --> )
      ?COMP ' LIT,
      ; IMMEDIATE

\ выполнить действие, согласно переменной state
: stateact ( xt imm_flag --> )
           STATE @ > IF COMPILE, ELSE EXECUTE THEN ;

\ интерпретировать слово, представленное строкой
\ выполнить действие, согласно состоянию STATE
\ название логично именно такое, так как тут заранее знаем,
\ что ищем именно слово, а не имеем на входе номер.
: eval-name ( asc # --> )
            sfind IF stateact
                   ELSE -2003 THROW
                  THEN ;

\ интерпретировать лексему ( слово или число ) представленное строкой
\ выполнить действие, согласно состоянию STATE
: eval-word ( asc # --> )
            sfind IF stateact
                   ELSE ?SLITERAL
                  THEN ;

\ тут важный вопрос - в СПФ сначала ищется слово, если оно не найдено
\ но найден NOTFOUND, то выполняем его - иначе пытаемся понять число.
\ Это хорошо в случае, если, например числа нам нужно перекрыть, но
\ поиск по notfound может быть достаточно длинным, к тому же в начале
\ стандартного NOTFOUND-а сначала ищется число, лишь затем пытаемся
\ что-то другое подобрать. - так получается быстрее разбор чисел (нет
\ поиска по словарю NOTFOUND-a), но числа, например нельзя запретить
\ или распознать как-то иначе. Для ускорения первого варианта можно
\ для каждого словаря хранить последний определенный NOTFOUND в отдельной
\ ячейке, и @ ?EXECUTE над ней. Беда только в том, что любые исключения
\ нужно обрабатывать, а это загромождает код и вообще плохо потом
\ модифицируется. Так что я за второй вариант, хоть он и менее стандартный.

TRUE [IF] \ это вариант аналогичный стандартному

\ выделил в отдельное слово, почему бы и нет?
\ им можно пользоваться, если заранее известно, что на входе что-то
\ нестандартное либо же число.
: notfound ( asc # --> )
           S" NOTFOUND" sfind
           IF DROP EXECUTE
            ELSE 2DROP ?SLITERAL
           THEN ;

\ интерпретировать входной поток до тех пор, пока он не закончится
\ вообще, если бы не NOTFOUND - то было бы вообще просто и красиво:
\ : interpret  BEGIN NextWord DUP WHILE eval-word ?STACK REPEAT 2DROP ;

: interpret ( -> )
            BEGIN NextWord  DUP WHILE
                  ['] eval-name CATCH
                  IF notfound THEN
                  ?STACK
            REPEAT 2DROP ;


[ELSE] \ это с измененным порядком следования ?sliteral & notfound

: notfound ( asc # --> )
           S" NOTFOUND" sfind
           IF DROP EXECUTE
            ELSE -2003 THROW
           THEN ;

: interpret ( -> )
            BEGIN NextWord DUP WHILE
                  ['] eval-word CATCH \ тут сначала имя или число
                  IF notfound THEN    \ а лишь затем NOTFOUND
                  ?STACK
            REPEAT 2DROP ;
[THEN]

\ EOF совместимость со стандартным СПФом

\ это для совместимости со старым спф
: SEARCH-WORDLIST1 ( asc # voc-id -- asc # false | xt -1/1 )
                   search-wordlist

                   IF IF 1 ELSE -1 THEN \ этот бред есть в любом случае из-за
                    ELSE FALSE          \ того, что флаг сложный получается
                   THEN ;

: SFIND ( --> )
        2>R GET-ORDER 2R> sfindin
        IF IF 1 ELSE -1 THEN        \ то же самое.
         ELSE FALSE
        THEN ;

\ просто мне кажется, что так назвать логичнее
: EVAL-WORD ( asc # --> ) eval-name ;

\EOF тестовая секция

CR CR S" проверка поиска в словаре с помощью search-wordlist" TYPE CR

: ok~ ." успешно" ;

S" adas" 2DUP TYPE FORTH-WORDLIST search-wordlist
    [IF]     S"  найдено" TYPE
      [IF]     S"  imm " TYPE
       [ELSE]  S"  std " TYPE
      [THEN]   EXECUTE CR
     [ELSE] S"  не найдено " TYPE SWAP . SPACE . CR
    [THEN]

S" ok~" 2DUP TYPE FORTH-WORDLIST search-wordlist
    [IF]     S"  найдено" TYPE
      [IF]     S"  imm " TYPE
       [ELSE]  S"  std " TYPE
      [THEN]   EXECUTE CR
     [ELSE] S"  не найдено " TYPE SWAP . SPACE . CR
    [THEN]

IMMEDIATE
S" ok~" 2DUP TYPE FORTH-WORDLIST search-wordlist
    [IF]     S"  найдено" TYPE
      [IF]     S"  imm " TYPE
       [ELSE]  S"  std " TYPE
      [THEN]   EXECUTE CR
     [ELSE] S"  не найдено " TYPE SWAP . SPACE . CR
    [THEN]

S" ok~" 2DUP TYPE sfind
    [IF]     S"  найдено" TYPE
      [IF]     S"  imm " TYPE
       [ELSE]  S"  std " TYPE
      [THEN]   EXECUTE CR
     [ELSE] S"  не найдено " TYPE SWAP . SPACE . CR
    [THEN]

VOCABULARY TEST
           ALSO TEST DEFINITIONS

S" ok~" 2DUP TYPE sfind
    [IF]     S"  найдено" TYPE
      [IF]     S"  imm " TYPE
       [ELSE]  S"  std " TYPE
      [THEN]   EXECUTE CR
     [ELSE] S"  не найдено " TYPE SWAP . SPACE . CR
    [THEN]

S" sdad" 2DUP TYPE sfind
    [IF]     S"  найдено" TYPE
      [IF]     S"  imm " TYPE
       [ELSE]  S"  std " TYPE
      [THEN]   EXECUTE CR
     [ELSE] S"  не найдено " TYPE SWAP . SPACE . CR
    [THEN]

: ~test ." успешно" ;

S" ~test" 2DUP TYPE sfind
    [IF]     S"  найдено" TYPE
      [IF]     S"  imm " TYPE
       [ELSE]  S"  std " TYPE
      [THEN]   EXECUTE CR
     [ELSE] S"  не найдено " TYPE SWAP . SPACE . CR
    [THEN]

S" ' ~test " TYPE ' ~test EXECUTE CR

S" eval-name " TYPE S" ~test" eval-name CR

IMMEDIATE S" eval-name " TYPE S" ~test" eval-name CR

: tev NextWord eval-name ; IMMEDIATE

: ~nott ." nott" ;

S" : test tev ~nott ; " TYPE : test tev ~nott ; CR
S" : testa tev ~test ; " TYPE : testa tev ~test ; CR

S" 12345678 eval-word " TYPE S" 12345678" eval-word . CR


interpret S" interpret " TYPE  ~test CR

\ в основном все работает.



