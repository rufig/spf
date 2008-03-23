( Трансляция исходных текстов программ.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

USER S0   \ адрес дна стека данных
USER R0   \ адрес дна стека возвратов
USER WARNING
USER STATE ( -- a-addr ) \ 94
     \ a-addr - адрес ячейки, содержащей флажок "состояние компиляции".
     \ STATE "истина" в режиме компиляции, иначе "ложь".
     \ Изменяют STATE только следующие стандартные слова:
     \ : ; [ ] ABORT QUIT :NONAME
USER BLK

VECT OK
VECT <MAIN>
VECT ?LITERAL
VECT ?SLITERAL

: DEPTH ( -- +n ) \ 94
\ +n - число одинарных ячеек, находящихся на стеке данных перед
\ тем как туда было помещено +n.
  SP@ S0 @ - NEGATE 4 U/
;
: ?STACK ( -> ) \ выдать ошибку "исчерпание стека", если он более чем пуст
  SP@ S0 @ SWAP U< IF S0 @ SP! -4 THROW THEN
;

: ?COMP ( -> )
  STATE @ 0= IF -312 THROW THEN ( Только для режима компиляции )
;

: WORD ( char "<chars>ccc<char>" -- c-addr ) \ 94
\ Пропустить ведущие разделители. Выбрать символы, ограниченные
\ разделителем char.
\ Исключительная ситуация возникает, если длина извлеченной строки
\ больше максимальной длины строки со счетчиком.
\ c-addr - адрес переменной области, содержащей извлеченное слово
\ в виде строки со счетчиком.
\ Если разбираемая область пуста или содержит только разделители,
\ результирующая строка имеет нулевую длину.
\ В конец строки помещается пробел, не включаемый в длину строки.
\ Программа может изменять символы в строке.
  DUP SKIP PARSE 255 MIN
  DUP SYSTEM-PAD C! SYSTEM-PAD CHAR+ SWAP CMOVE
  0 SYSTEM-PAD COUNT CHARS + C!
  SYSTEM-PAD
;

: ' ( "<spaces>name" -- xt ) \ 94
\ Пропустить ведущие пробелы. Выделить name, ограниченное пробелом. Найти name 
\ и вернуть xt, выполнимый токен для name. Неопределенная ситуация возникает, 
\ если name не найдено.
\ Во время интерпретации  ' name EXECUTE  равносильно  name.
  ALSO NON-OPT-WL CONTEXT !
  PARSE-NAME SFIND 0= PREVIOUS
  IF -321 THROW THEN (  -? )
;

: CHAR ( "<spaces>name" -- char ) \ 94
\ Пропустить ведущие разделители. Выделить имя, органиченное пробелами.
\ Положить код его первого символа на стек.
  PARSE-NAME DROP C@
;

: BYE ( -- ) \ 94 TOOLS EXT
\ Вернуть управление операционной системе, если она есть.
  0 
  HALT
;

: EVAL-WORD ( a u -- )
\ интерпретировать ( транслировать) слово с именем  a u
    SFIND ?DUP    IF
    STATE @ =  IF 
    COMPILE,   ELSE 
    EXECUTE    THEN
                  ELSE
    -2003 THROW THEN
;

: NOTFOUND ( a u -- )
\ обращение к словам в словарях в виде  vocname1::wordname
\ или vocname1::vocname2::wordname и т.п.
\ или vocname1:: wordname
  2DUP 2>R ['] ?SLITERAL CATCH ?DUP IF NIP NIP 2R>
  2DUP S" ::" SEARCH 0= IF 2DROP 2DROP THROW  THEN \ Вообще есть :: ?
  2DROP ROT DROP
  GET-ORDER  N>R
                         BEGIN ( a u )
    2DUP S" ::" SEARCH   WHILE ( a1 u1 a3 u3 )
    2 -2 D+ ( пропуск разделителя :: )  2>R
    R@ - 2 - SFIND              IF
    SP@ >R
    ALSO EXECUTE SP@ R> - 0=
    IF CONTEXT ! THEN
                                ELSE  ( a1 u' )
    RDROP RDROP
    NR>  SET-ORDER
    -2011 THROW                 THEN
    2R>                  REPEAT
  NIP 0= IF 2DROP PARSE-NAME THEN
  ['] EVAL-WORD CATCH
  NR> SET-ORDER THROW
 ELSE RDROP RDROP THEN
;

: INTERPRET_ ( -> ) \ интерпретировать входной поток
  BEGIN
    PARSE-NAME DUP
  WHILE
    SFIND ?DUP
    IF
         STATE @ =
         IF COMPILE, ELSE EXECUTE THEN
    ELSE
         S" NOTFOUND" SFIND 
         IF EXECUTE
         ELSE 2DROP ?SLITERAL THEN
    THEN
    ?STACK
  REPEAT 2DROP
;

VARIABLE   &INTERPRET

' INTERPRET_ ' &INTERPRET TC-ADDR!

: INTERPRET &INTERPRET @ EXECUTE ;


: #(SIGNED) ( d1 -- d2 )
  [CHAR] ) HOLD DUP >R DABS #S R> SIGN [CHAR] ( HOLD
;

: .SN ( n --)
\ Распечатать n верхних элементов стека
   >R BEGIN
         R@
      WHILE
        SP@ R@ 1- CELLS + @ DUP 0< 
        IF DUP U>D (D.) TYPE <# S>D #(SIGNED) #> TYPE SPACE
        ELSE . THEN
        R> 1- >R
      REPEAT RDROP
;

: OK1
  STATE @ 0=
  IF
    DEPTH 6 U< IF
                 DEPTH IF ."  Ok ( " DEPTH .SN  ." )" CR
                       ELSE ."  Ok" CR
                       THEN
               ELSE ."  Ok ( [" DEPTH 0 <# #S #> TYPE ." ].. "
                    5 .SN ." )" CR
               THEN
  THEN
;

: [   \ 94 CORE
\ Интерпретация: семантика неопределена.
\ Компиляция: Выполнить семантику выполнения, данную ниже.
\ Выполнение: ( -- )
\ Установить состояние интерпретации. [ слово немедленного выполнения.
  STATE 0!
; IMMEDIATE


: ] ( -- ) \ 94 CORE
\ Установить состояние компиляции.
  TRUE STATE !
;

: MAIN1 ( -- )
  BEGIN
    REFILL
  WHILE
    INTERPRET OK
  REPEAT BYE
;

: QUIT ( -- ) ( R: i*x ) \ CORE 94
\ Сбросить стек возвратов, записать ноль в SOURCE-ID.
\ Установить стандартный входной поток и состояние интерпретации.
\ Не выводить сообщений. Повторять следующее:
\ - Принять строку из входного потока во входной буфер, обнулить >IN
\   и интепретировать.
\ - Вывести зависящее от реализации системное приглашение, если
\   система находится в состоянии интерпретации, все процессы завершены,
\   и нет неоднозначных ситуаций.
  BEGIN
    CONSOLE-HANDLES
    0 TO SOURCE-ID
    0 TO SOURCE-ID-XT
    [COMPILE] [
    ['] MAIN1 CATCH
    ['] ERROR CATCH DROP
 (  R0 @ RP! \ стек не сбрасываем, т.к. это за нас делает CATCH :)
    S0 @ SP! \ стек    сбрасываем, т.к. OPTIONS может оставить значения :(
  AGAIN
;

: SAVE-SOURCE ( -- i*x i )
  SOURCE-ID-XT  SOURCE-ID   >IN @   SOURCE   CURSTR @   6
;

: RESTORE-SOURCE ( i*x i  -- )
  6 <> IF ABORT THEN
  CURSTR !    SOURCE!  >IN !  TO SOURCE-ID   TO SOURCE-ID-XT
;

: EVALUATE-WITH ( ( i*x c-addr u xt -- j*x )
\ Считая c-addr u входным потоком, вычислить её интерпретатором xt.
  SAVE-SOURCE N>R 
  >R  SOURCE!  -1 TO SOURCE-ID
  R> ( ['] INTERPRET) CATCH
  NR> RESTORE-SOURCE
  THROW
;

: EVALUATE ( i*x c-addr u -- j*x ) \ 94
\ Сохраняет текущие спецификации входного потока.
\ Записывает -1 в SOURCE-ID. Делает строку, заданную c-addr u,
\ входным потоком и входным буфером, устанавливает >IN в 0
\ и интерпретирует. Когда строка разобрана до конца - восстанавливает
\ спецификации предыдущего входного потока.
\ Другие изменения стека определяются выполняемыми по EVALUATE словами.
  ['] INTERPRET EVALUATE-WITH
;


VECT PROCESS-ERR ( ior -- ior ) \ обработать ошибку трансляции (файла).

: PROCESS-ERR1 ( ior -- ior )  \ тут проверка на ior=0 тоже нужна.
  DUP IF SEEN-ERR? IF DUP SAVE-ERR THEN THEN
;
' PROCESS-ERR1 ' PROCESS-ERR TC-VECT!

: RECEIVE-WITH-XT  ( i*x source source-xt xt -- j*x ior )
\ сохранить спецификации входного потока
\ установить входной поток на source, слово для чтения строки в source-xt
\ выполнить xt
\ восстановить спецификации входного потока
  SAVE-SOURCE N>R
  C/L 2+ ALLOCATE THROW DUP >R  0 SOURCE!  CURSTR 0!
  SWAP TO SOURCE-ID-XT
  SWAP TO SOURCE-ID
  CATCH  DUP IF PROCESS-ERR ( err -- err ) THEN
  R> FREE THROW
  NR> RESTORE-SOURCE
;

: RECEIVE-WITH  ( i*x source xt -- j*x ior )
\ сохранить спецификации входного потока
\ установить входной поток на source, выполнить xt
\ восстановить спецификации входного потока
  0 SWAP RECEIVE-WITH-XT
;

: HEAP-COPY ( addr u -- addr1 )
\ скопировать строку в хип и вернуть её адрес в хипе
  DUP 0< IF 8 THROW THEN
  DUP CHAR+ ALLOCATE THROW DUP >R
  SWAP DUP >R CHARS MOVE
  0 R> R@ + C! R>
;

VECT FIND-FULLNAME \ найти указанный файл и вернуть его с полным путем

: FIND-FULLNAME1 ( a1 u1 -- a u )
  2DUP FILE-EXIST IF EXIT THEN
  2DUP +LibraryDirName  2DUP FILE-EXIST IF 2SWAP 2DROP EXIT THEN 2DROP
  2DUP +ModuleDirName   2DUP FILE-EXIST IF 2SWAP 2DROP EXIT THEN 2DROP
  2 ( ERROR_FILE_NOT_FOUND ) THROW
;
' FIND-FULLNAME1 ' FIND-FULLNAME TC-VECT!


: TranslateFlow ( -- )
  BEGIN REFILL WHILE INTERPRET REPEAT
;

: INCLUDE-FILE ( i*x fileid -- j*x ) \ 94 FILE
\ Убрать fileid со стека. Сохранить текущие спецификации входного потока,
\ включая текущее значение SOURCE-ID. Записать fileid в SOURCE-ID.
\ Сделать файл, заданный fileid, входным потоком. Записать 0 в BLK.
\ Другие изменения стека определяются словами из включенного файла.
\ Повторять до конца файла: прочесть строку из файла, заполнить входной
\ буфер содержимым этой строки, установить >IN в ноль и интерпретировать.
\ Интерпретация текста начинается с позиции, с которой должно происходить
\ дальнейшее чтение файла.
\ Когда достигнут конец файла, закрыть файл и восстановить спецификации
\ входного потока к их сохраненным значениям.
\ Неопределенная ситуация возникает, если fileid неверен, если возникают
\ исключительные ситуации ввода-вывода по мере чтения fileid, или
\ возникают исключительная ситуация при закрытии файла. Когда имеет
\ место неопределенная ситуация, статус (открыт или закрыт) любых
\ интерпретируемых файлов зависит от реализации.
  BLK 0!
  DUP >R  
  ['] TranslateFlow RECEIVE-WITH
  R> CLOSE-FILE THROW
  THROW
;

: INCLUDE-PROBE ( addr u -- ... 0 | ior )
  R/O OPEN-FILE-SHARED ?DUP
  IF NIP EXIT THEN
  INCLUDE-FILE 0
;

VECT (INCLUDED)

: (INCLUDED1) ( i*x a u -- j*x )
  R/O OPEN-FILE-SHARED THROW
  INCLUDE-FILE
;
' (INCLUDED1) ' (INCLUDED) TC-VECT!

USER INCLUDE-DEPTH

: INCLUDED_STD ( i*x c-addr u -- j*x )
  CURFILE @ >R
  2DUP HEAP-COPY CURFILE !
  
  INCLUDE-DEPTH 1+!
  INCLUDE-DEPTH @ 64 > IF -27 THROW THEN
  ['] (INCLUDED) CATCH
  INCLUDE-DEPTH @ 1- 0 MAX 
  INCLUDE-DEPTH !
  
  CURFILE @ FREE THROW
  R> CURFILE !
  THROW
;

: INCLUDED ( i*x c-addr u -- j*x ) \ 94 FILE
\ Убрать c-addr u со стека. Сохранить текущие спецификации входного потока,
\ включая текущее значение SOURCE-ID. Открыть файл, заданный c-addr u,
\ записать полученный fileid в SOURCE-ID и сделать его входным потоком.
\ Записать 0 в BLK.
\ Другие изменения стека определяются словами из включенного файла.
\ Повторять до конца файла: прочесть строку из файла, заполнить входной
\ буфер содержимым этой строки, установить >IN в ноль и интерпретировать.
\ Интерпретация текста начинается с позиции, с которой должно происходить
\ дальнейшее чтение файла.
\ Когда достигнут конец файла, закрыть файл и восстановить спецификации
\ входного потока к их сохраненным значениям.
\ Неопределенная ситуация возникает, если fileid неверен, если возникают
\ исключительные ситуации ввода-вывода по мере чтения fileid, или
\ возникают исключительная ситуация при закрытии файла. Когда имеет
\ место неопределенная ситуация, статус (открыт или закрыт) любых
\ интерпретируемых файлов зависит от реализации.
  FIND-FULLNAME INCLUDED_STD
;
: REQUIRED ( waddr wu laddr lu -- )
  2SWAP SFIND
  IF DROP 2DROP
  ELSE 2DROP INCLUDED THEN
;
: REQUIRE ( "word" "libpath" -- )
  PARSE-NAME PARSE-NAME 2DUP + 0 SWAP C!
  REQUIRED
;
