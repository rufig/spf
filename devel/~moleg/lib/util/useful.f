\ 2006-12-09 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ набор часто используемых и просто удобных слов

 REQUIRE COMPILE  devel\~mOleg\lib\util\compile.f
 REQUIRE SeeForw  devel\~mOleg\lib\util\parser.f

\ -- константы ----------------------------------------------------------------

?DEFINED char  1 CHARS CONSTANT char

\ -- коментарии ---------------------------------------------------------------

\ для вывода сообщения о подключаемой секции
\ удобно использовать в начале файла
: \. ( --> ) 0x0A PARSE CR TYPE ;

\ коментарий до конца строки (для временного коментирования кусков кода)
: \? ( --> ) [COMPILE] \ ; IMMEDIATE

FALSE WARNING !

\ Заканчивает трансляцию текущего потока »
\ в отличие от родного слова СПФ упоминание в консоли приводит к
\ окончанию текущего потока, а упоминание в подключаемом файле
\ переводит указатель позиции чтения файла в конец файла.
\ Таким образом трансляция файла завершается быстро и естественно.
: \EOF  ( --> )
        SOURCE-ID DUP IF ELSE TERMINATE THEN
        >R 2 SP@ -2 CELLS + 0 R> SetFilePointer DROP
        [COMPILE] \ ;

TRUE WARNING !

\  -- словари ------------------------------------------------------------------

\ оставить в контексте только самый верхний словарь
: SEAL ( --> ) CONTEXT @ ONLY CONTEXT ! ;

\ заменить верхний контекстный словарь указанным
: WITH ( vid --> ) >R GET-ORDER NIP R> SWAP SET-ORDER ;

\ удалить верхний словарь с вершины контекста, следующий за ним
\ сделать текущим.
: RECENT ( --> )
         GET-ORDER 1 -
           DUP IF NIP OVER SET-CURRENT SET-ORDER
                ELSE DROP
               THEN ;

\ перенести vid словаря с вершины контекста в CURRENT
: THIS ( --> ) CONTEXT @ SET-CURRENT PREVIOUS ;

\ поменять местами два словаря на вершине контекста
: UNDER ( --> ) GET-ORDER DUP 1 - IF >R SWAP R> THEN SET-ORDER ;


\ -- распределение пространства форт системы ----------------------------------

\ резервировать на HERE n байт памяти, заполнить их байтом char
: AllotFill  ( char n --> ) HERE OVER ALLOT -ROT FILL ;

\ резервировать на HERE n байт памяти, заполнить их нулями
: AllotErase ( n --> ) 0 SWAP AllotFill ;

\ -----------------------------------------------------------------------------

\ применить действие funct к каждому из значений namea .. namen,
\ перечисленных до конца строки, например: ToAll VARIABLE aaa bbb ccc
: ToAll ( / funct namea ... namen --> )
        ' >R BEGIN SeeForw WHILE DROP
                   R@ EXECUTE
             REPEAT DROP RDROP ;

\ вернуть флаг TRUE , если выбрана клавиша ESC
\ при нажатии любой другой клавиши начать ожидание нажатия следующей
\ если нажата отличная от ESC клавиша - вернуть FALSE инача TRUE
: ?PAUSE ( --> flag )
         KEY? IF KEY 0x1B =
                 IF TRUE EXIT
                  ELSE KEY 0x1B =
                    IF TRUE EXIT THEN
                 THEN
              THEN FALSE ;

\ выполнять слово до тех пор, пока не будет нажата любая клавиша
\ пример использования: : test ." ." ; PROCESS test
: PROCESS ( / name --> )
          ' >R BEGIN ?PAUSE WHILENOT
                     R@ EXECUTE
               REPEAT
            RDROP ;

\ выполнить следующее слово при выходе из определения
: GoAfter ( --> ) ' [COMPILE] LITERAL COMPILE >R ; IMMEDIATE

\ то же что и : только имя приходит на вершине стека данных
\ в виде строки со счетчиком. Пример:  S" name" S: код слова ;
?DEFINED S: : S: ( asc # --> ) SHEADER ] HIDE ;

\ вызвать ошибку вместе со следующим сообщением
?DEFINED SERROR : SERROR ( asc # --> ) ER-U ! ER-A ! -2 THROW ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ тут просто проверка на собираемость.
  S" passed" TYPE
}test
