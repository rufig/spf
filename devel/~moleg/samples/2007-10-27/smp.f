\ 24-10-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ задачка с конкурса форума http://fforum.winglion.ru/index.php
\ http://fforum.winglion.ru/viewtopic.php?t=994

\ В верхнем контекстном словаре (CONTEXT) словаре найти все имена
\ слов, отличающиеся в одной букве (то есть похожие слова). Cлова
\ могут отличаться по длинне (на один символ) либо по содержимому
\ (в одной символьной позиции).

\ удалить с вершины стека указанное число параметров
\ если нужен контроль переопустошения стека раскоментировать содержимое скобок
: nDrop ( [ .. ] n --> ) 1 + CELLS SP@ + ( S0 @ MIN) SP! ;

\ добавить указанное число, к находящемуся на вершине стека возвратов
: R+ ( r: a d: b --> r: a+b ) 2R> -ROT + >R >R ;

\ сравнить два символа, находящихся по указанным адресам
\ вернуть указатели, смещенные на один символ вправо, и флаг
: (comp) ( 'asc1 'asc2 --> 'asc1++ 'asc2++ flag )
         2DUP 1 1 D+
         2SWAP C@ SWAP C@ = ;

\ сравнить две строки одинаковой длины,
\ выдать true, если различие не более, чем в один символ
: ?like ( asc1 asc2 # --> flag )
        >R BEGIN R@ WHILE
                 -1 R+
                 (comp) WHILE
             REPEAT
               BEGIN R@ WHILE   \ чтобы не возиться со счетчиком несовпадений
                     -1 R+
                     (comp) WHILE
                 REPEAT
                   RDROP 2DROP FALSE EXIT
               THEN
           THEN
        RDROP 2DROP TRUE ;

\ содержит ли длинная строка короткую как подстроку?
: ?substr ( asc1 asc2 #2 #1 --> flag )
          2DUP < IF -ROT ELSE -ROT 2SWAP THEN
          SEARCH NIP NIP ;

\ сравнить две строки на похожесть
: ?resemble ( asc1 # asc2 # --> flag )
            ROT 2DUP - DUP
            IF -1 2 WITHIN
               IF ?substr
                ELSE 4 nDrop FALSE
               THEN
             ELSE 2DROP ?like
            THEN ;

\ для заданного слова asc # найти все слова в верхнем контекстном
\ словаре, отличающиеся от заданного слова в одной символьной
\ позиции. Результат вывести на экран.
: similar ( asc # --> )
          CONTEXT @ @ >R
          BEGIN R@ WHILE
                2DUP R@ COUNT ?resemble
                IF R@ ID. SPACE THEN
            R> CDR >R
          REPEAT RDROP 2DROP ;

S" LOOP" similar \ пример использования

: alll ( --> )
       CONTEXT @ @ >R
       BEGIN R@ WHILE
             CR R@ COUNT similar
         R> CDR >R
       REPEAT RDROP ;

\ для получения всех подобий в словаре FORTH наберите к командной строке
\ spf4.exe smp.f alll BYE >smp.log
