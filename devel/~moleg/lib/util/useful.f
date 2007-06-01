\ 2006-12-09 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ набор часто используемых и просто удобных слов

REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
REQUIRE ADDR     devel\~moleg\lib\util\addr.f
REQUIRE COMPILE  devel\~mOleg\lib\util\compile.f
REQUIRE WHILENOT devel\~mOleg\lib\util\ifnot.f

FALSE WARNING !

\ -- константы ----------------------------------------------------------------

        1 CHARS CONSTANT char
        0x0D    CONSTANT cr_
        0x0A    CONSTANT lf_
        0x09    CONSTANT tab_

\ -- коментарии ---------------------------------------------------------------

\ для вывода сообщения о подключаемой секции
\ удобно использовать в начале файла
: \. ( --> ) 0x0A PARSE CR TYPE ;

\ коментарий до конца строки (для временного коментирования кусков кода)
: \? ( --> ) [COMPILE] \ ; IMMEDIATE

\ Заканчивает трансляцию текущего потока »
\ в отличие от родного слова СПФ упоминание в консоли приводит к
\ окончанию текущего потока, а упоминание в подключаемом файле
\ переводит указатель позиции чтения файла в конец файла.
\ Таким образом трансляция файла завершается быстро и естественно.
: \EOF  ( --> )
        SOURCE-ID DUP IF ELSE TERMINATE THEN
        >R 2 SP@ -2 CELLS + 0 R> SetFilePointer DROP
        [COMPILE] \ ;

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

\ -- стековые манипуляции -----------------------------------------------------

\ поменять значения данных на вершине стека со значением переменной
: change ( n addr --> [addr] ) DUP @ -ROT ! ;

\ вычислить границы массива заданного своим адресом и длинной
: bounds ( addr # --> up low ) OVER + SWAP ;

\ опустить три значения со стека данных
: 3DROP ( a b c --> ) 2DROP DROP ;

\ копировать три верхних элемента на стеке возвратов
: 3DUP ( a b c --> a b c a b c ) >R 2DUP R@ -ROT R> ;

\ удалить с вершины стека указанное число параметров
: nDROP ( [ .. ] n --> ) 1 + CELLS SP@ + SP! ;

\ удалить нижнее двойное значение
: 2NIP ( da db --> db ) 2SWAP 2DROP ;

\ добавить число к находящемуся на стеке возвратов
: R+ ( r: a d: b --> r: a+b ) 2R> -ROT + >R >R ;

\ упорядочить значения по возрастанию
: RANKING ( a b --> a b ) 2DUP MIN -ROT MAX ;

\ выравнять число base на указанное значение n »
\ граница выравнивания произвольная.
\ выравнивание производится в большую сторону
: ROUND ( n base --> n ) TUCK 1 - + OVER / * ;


\ -- логические операции ------------------------------------------------------

\ Получить по номеру бита его маску
: ?BIT  ( N --> mask ) 1  SWAP LSHIFT ;

\ получить по номеру бита его инверсную маску
: N?BIT ( N --> mask ) ?BIT INVERT ;

\ вернуть TRUE если выполняется условие a < или = b, иначе FALSE
: >= ( a b --> flag ) < 0= ;

\ -- парсер -------------------------------------------------------------------

\ слово откатывает >IN назад, на начало непонятого слова asc #
: <back ( asc # --> ) DROP TIB - >IN ! ;

\ пропустить один символ во входном потоке
: SkipChar ( --> )  >IN @ char + >IN ! ;

\ взять очередной символ из входного потока
: NextChar ( --> char flag ) EndOfChunk PeekChar SWAP SkipChar ;

\ вернуть адрес и длинну еще не проинтерпретированной части входного буфера.
: REST ( --> asc # ) SOURCE >IN @ DUP NEGATE D+ 0 MAX ;

\ слово берет очередную лексему из входного потока до тех пор, пока он
\ не исчерпается.
: NEXT-WORD ( --> asc # | asc 0 )
            BEGIN NextWord DUP WHILENOT
                  DROP REFILL DUP WHILE
                  2DROP
               REPEAT
            THEN ;

\ вернуть строку нулевой длинны
: EMPTY" ( --> asc # ) S" " ;

\ заглянуть вперед во входном потоке
: SeeForw ( --> asc # ) >IN @ NextWord ROT >IN ! ;

\ преобразовать символ в строку, содержащую один символ
: Char>Asc ( char --> asc # ) SYSTEM-PAD TUCK C! 0 OVER char + C! char ;

\ укоротить строку asc # на u символов от начала
: SKIPn ( asc # u --> asc+u #-u ) OVER MIN TUCK - >R + R> ;

\ из входного потока выкусить имя файла
: ParseFileName ( --> asc # )
                PeekChar [CHAR] " =
                IF [CHAR] " SkipChar
                 ELSE BL
                THEN PARSE
                2DUP + 0 SWAP C! ;

\ установить SOURCE на строку параметров »
: cmdline> ( --> )
           -1 TO SOURCE-ID
           GetCommandLineA ASCIIZ> SOURCE!
           ParseFileName 2DROP ;

\ -- работа с буфером pad -----------------------------------------------------

\ преобразовать число в символ
: >DIGIT ( N --> Char ) DUP 0x0A > IF 0x07 + THEN 0x30 + ;

\ добавить пробел в PAD
: BLANK ( --> ) BL HOLD ;

\ добавить указанное кол-во пробелов в PAD
: BLANKS ( n --> ) 0 MAX BEGIN DUP WHILE BLANK 1 - REPEAT DROP ;

\ инициализация буфера прямого преобразования »
: <| ( --> ) SYSTEM-PAD HLD A! ;

\ добавить символ в буфер PAD »
\ отличие от HOLD в том, что символ добавляется в конец формируемой строки
\ а не в ее начало.
: KEEP ( char --> ) HLD A@ C! char HLD +! ;

\ вернуть сформированную строку »
: |> ( --> asc # ) 0 KEEP SYSTEM-PAD HLD A@ OVER - char - ;

\ добавить строку в буфер PAD »
\ действие аналогично HOLDS за исключением того, что строка добавляется
\ в конец формируемой строки, а не в ее начало.
: KEEPS ( asc # --> ) HLD A@ OVER HLD +! SWAP CMOVE ;

\ -- распределение пространства форт системы ----------------------------------

\ резервировать на HERE n байт памяти, заполнить их байтом char
: AllotFill  ( n char --> ) HERE OVER ALLOT -ROT FILL ;

\ резервировать на HERE n байт памяти, заполнить их нулями
: AllotErase ( n --> ) 0 AllotFill ;

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

TRUE WARNING !

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ тут просто проверка на собираемость.
  S" passed" TYPE
}test
