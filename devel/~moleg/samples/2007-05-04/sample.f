\ 05-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ решение задачи с конкурса открытого на форуме
\ (http://fforum.winglion.ru/viewtopic.php?p=7274#7274)

\ -- просто набор необходимых слов ------------------------------------------

\ слово откатывает >IN назад, на начало непонятого слова
: <back ( ASC # --> ) DROP TIB - >IN ! ;

\ добавить пробел в PAD - работает в пределах <# #>
: BLANK  ( --> ) BL HOLD ;

\ добавить указанное кол-во пробелов в PAD
: BLANKS ( n --> ) BEGIN DUP WHILE BLANK 1 - REPEAT DROP ;

\ добавить число к находящемуся на стеке возвратов
: R+ ( r: a d: b --> r: a+b ) 2R> -ROT + >R >R ;

\ вернуть TRUE если выполняется условие a < или = b, иначе FALSE
: >= ( a b --> flag ) < 0= ;

\ возвращает адрес и длинну строки, содержащей символ(ы) перевода строки
: nl ( --> asc # ) LT LTL @ ;

\ -- формирование результирующей строки -------------------------------------

        USER-VALUE buffer \ адрес временного буфера
        USER-VALUE out>   \ позиция с которой можно добавлять данные в буфер

\ добавление в буфер строки asc # к уже имеющимся
: >out ( asc # --> ) out> SWAP 2DUP + TO out> CMOVE ;

\ добавление строки с добавлением перевода строки
: save-result ( asc # --> ) >out nl >out ;

\ получить адрес и длинну собранной в буфере строки
: result> ( --> asc # ) buffer out> OVER - ;

\ освобождение буфера
: free-result ( --> ) buffer IF buffer FREE THROW 0 TO buffer THEN ;

\ инициализация буфера
: init-buffer ( # --> )
              free-result
              CELLS ALLOCATE THROW
              DUP TO buffer TO out> ;

\ -- собственно само решение ------------------------------------------------

        USER-VALUE regular  \ кол-во необходимых пробелов между словами
        USER-VALUE addons   \ кол-во дополнительных пробелов

\ добавить необходимое кол-во пробельных символов между слов
\ стратегии добавления пробелов могут быть различны.
: add-blanks ( --> )
             addons IF BLANK addons 1 - TO addons THEN
             regular BLANKS ;

\ сформировать строку из n строк, вставив между каждой строкой необходимое
\ количество пробельных символов.
: prepare ( [ asc # ] n str# p --> asc # )
          SWAP - OVER 1 = IF 2DROP EXIT THEN     \ если слово одно в строке

          OVER 1 - /MOD 1 + TO regular TO addons \ считаем необходимые пробелы

          >R <# BEGIN R@ WHILE   \ пока есть слова
                      HOLDS
                   -1 R+
                      R@ WHILE   \ если слово не последнее в строке
                      add-blanks
                  REPEAT
                THEN
          R@ R> #> ;

        USER words# \ счетчик слов для текущей строки

\ собрать слова для одной строки
: collect ( asc # p --> [ asc # ] n str# p )
          >R DUP >R  1 words# !
          BEGIN NextWord DUP WHILE  \ пока есть слова во входном потоке
                DUP 1 + 2R@ ROT +
                TUCK >= WHILE       \ пока длина суммы слов короче p
                RDROP >R
                words# 1+!
              REPEAT
                DROP <back          \ если взято лишнее слово - откат
                words# @ R> R> EXIT
          THEN
          2DROP words# @ R> RDROP DUP ;

\ форматировать поток, результат сохраняется в buffer
: format-stream ( p --> )
                >R BEGIN NextWord DUP WHILE
                      R@ collect prepare
                      save-result
                   REPEAT 2DROP
                RDROP ;

\ форматировать текст
: format-text ( asc # p --> asc # )
              SAVE-SOURCE N>R
               >R DUP init-buffer SOURCE!
               R> format-stream
              NR> RESTORE-SOURCE
              result> ;

\ EOF -- test sectin --------------------------------------------------------

: ~- ( n --> ) BEGIN DUP WHILE ." -" 1 - REPEAT DROP CR ;

\ это простой пример форматирования текста.
: ft S" simple sample string with the simple sample text." 20
     DUP ~- format-text TYPE
     S" inside string can contain_very_long words larger than 'p' " 13
     DUP ~- format-text TYPE
     ;

\ загрузить содержимое файла в буффер
: source ( FileName # --> addr # )
         R/O OPEN-FILE THROW >R
           R@ FILE-SIZE THROW DROP
              DUP ALLOCATE THROW
           TUCK SWAP R@ READ-FILE THROW
         R> CLOSE-FILE THROW ;

S" test.txt" source 60 format-text TYPE

CR
ft
