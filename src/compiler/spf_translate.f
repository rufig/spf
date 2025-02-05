( Трансляция исходных текстов программ.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

USER S0   \ адрес дна стека данных
USER R0   \ адрес дна стека возвратов
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
  SP@ S0 @ - NEGATE  1 CELLS /
\ значение может быть отрицательным, поэтому '>CELLS' вместо '/' нельзя
;
: ?STACK ( -> ) \ выдать ошибку "исчерпание стека", если он более чем пуст
  SP@ S0 @ SWAP U< IF S0 @ SP! -4 THROW THEN
;

: COMPILATION ( -- flag ) STATE @ 0<> ;
: ENTER-COMPILATION ( -- ; Compilation: flag -- true  ) TRUE  STATE ! ;
: LEAVE-COMPILATION ( -- ; Compilation: flag -- false ) FALSE STATE ! ;

: EXECUTE-COMPILING ( any1 xt -- any2 )
  \ ( Compilation: false -- false  |  Compilation: true -- flag )
  \ xt ( any1 -- any2 ; Compilation: true -- flag )
  COMPILATION IF  EXECUTE EXIT  THEN
  ENTER-COMPILATION  EXECUTE  LEAVE-COMPILATION
;

: ?COMP ( -> )
  STATE @ 0= IF -312 THROW THEN ( Только для режима компиляции )
;


\ Regarding `TRANSLATE-NAME`, see:
\ - A comp.lang.forth message on 2020-10-23 22:21:23 UTC
\     Subject: "ANN: STATE-smartness: Applications, Pitfalls, Alternatives"
\     Message-Id: <rn0333$ice$1@dont-email.me>
\     <https://groups.google.com/g/comp.lang.forth/c/GyzL0wIENUw/m/A0IsgKU9AgAJ>
\ - A comp.lang.forth discussion on 2023-11-15
\     on the topic "WINTERPRET":
\     <https://groups.google.com/g/comp.lang.forth/c/y-HGlOTpf48/m/O0RVTnz0BgAJ>

: COMPILE-LIT ( x -- ) LIT, ;
: COMPILE-XT ( xt -- ) COMPILE, ;

: TRANSLATE-LIT ( x -- x ; Compilation: false ;  |  x -- ; Compilation: true )
  \ If interpretation, do nothing.
  \ Otherwise, perfrom the compilation semantics of `LITERAL`.
  COMPILATION IF  COMPILE-LIT  THEN
;

: TRANSLATE-XT ( any xt -- any ; Compilation: false -- flag ;  |  xt -- ; Compilation: true )
  \ If interpretation, perform the execution semantics identified by xt.
  \ Otherwise, append the execution semantics identified by xt to the current definition.
  COMPILATION IF  COMPILE-XT  EXIT THEN  EXECUTE
;

: TRANSLATE-WORD ( any xt flag.imm -- any )
  IF  EXECUTE EXIT  THEN  TRANSLATE-XT
;

: TRANSLATE-NAME ( any nt -- any )
  \ If interpretation, perform the interpretation semantics of the word identified by nt.
  \ Otherwise, perform the compilation semantics of the word identified by nt.
  DUP NAME> SWAP ( xt nt ) IS-NAME-IMMEDIATE  TRANSLATE-WORD
;

: COMPILE-NAME ( any nt -- any )
  \ ( Compilation: false -- false  |  Compilation: true -- flag )
  \ Perform the compilation semantics of the word identified by nt.
  ['] TRANSLATE-NAME EXECUTE-COMPILING
;

: (POSTPONE-WORD) ( xt flag.imm -- )
  SWAP LIT,
  IF  ['] EXECUTE-COMPILING  ELSE  ['] COMPILE,  THEN
  COMPILE,
;

: POSTPONE-NAME ( nt -- )
  \ Append the compilation semantics of the word identified by nt to the current definition.
  DUP NAME> ( nt xt ) SWAP IS-NAME-IMMEDIATE  (POSTPONE-WORD)
  \ An alternative implementation (shorter but slightly less efficient):
  \   LIT,  ['] COMPILE-NAME COMPILE, \ append the nt compilation semantics
;


: TAKE-NAME ( "<space>name" -- nt )
  TAKE-LEXEME FIND-NAME ?FOUND
;

: ' ( "<spaces>name" -- xt ) \ 94
\ Пропустить ведущие пробелы. Выделить name, ограниченное пробелом. Найти name
\ и вернуть xt, выполнимый токен для name. Неопределенная ситуация возникает,
\ если name не найдено.
\ Во время интерпретации  ' name EXECUTE  равносильно  name.
  TAKE-LEXEME
  SFIND ?FOUND DROP \ use `SFIND` for backward compatibility
  \ `SFIND` uses the vector `SEARCH-WORDLIST` (that can change)
;

: CHAR ( "<spaces>name" -- char ) \ 94
\ Пропустить ведущие разделители. Выделить имя, органиченное пробелами.
\ Положить код его первого символа на стек.
  TAKE-LEXEME DROP C@
;

: BYE ( -- never ) \ 94 TOOLS EXT
\ Вернуть управление операционной системе, если она есть.
  0
  HALT
;

: EVAL-WORD ( any sd.lexeme -- any )
\ Translate a word whose name matches the string sd.lexeme
\ Note: a changed `SEARCH-WORDLIST` (if any) is not taken into account
  FIND-NAME ?FOUND TRANSLATE-NAME
;

: NOTFOUND ( any sd.lexeme -- any )
\ обращение к словам в словарях в виде  vocname1::wordname
\ или vocname1::vocname2::wordname и т.п.
\ или vocname1:: wordname
\ Слово wordname транслируется в модифицированном контексте (!)

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
    IF SET-ORDER-TOP THEN
                                ELSE  ( a1 u' )
    RDROP RDROP
    NR>  SET-ORDER
    -2011 THROW                 THEN
    2R>                  REPEAT
  NIP 0= IF 2DROP TAKE-LEXEME THEN
  ['] EVAL-WORD CATCH
  NR> SET-ORDER THROW
 ELSE RDROP RDROP THEN
;

: TRANSLATE-NOTFOUND ( any sd.lexeme -- any )
  S" NOTFOUND" SFIND IF EXECUTE EXIT THEN 2DROP
  ?SLITERAL
;

: FIND-NAME? ( sd.lexeme -- nt true | sd.lexeme false )
  2DUP FIND-NAME DUP IF  NIP NIP  TRUE THEN
;

: TRANSLATE-LEXEME ( any sd.lexeme -- any )
  FIND-NAME? IF  TRANSLATE-NAME  EXIT THEN
  TRANSLATE-NOTFOUND
;

: TRANSLATE-LEXEME-SWL ( any sd.lexeme -- any )
  \ Note: some extensions extend the behavior of `search-wordlist`,
  \ so the system should continue to use it (via `sfind`) in `interpret`
  \ for backward compatibility.
  SFIND DUP IF  -1 <>  TRANSLATE-WORD  EXIT THEN  DROP
  TRANSLATE-NOTFOUND
;

: INTERPRET_ ( any -- any ) \ interpret (translate) the parse area of the input buffer
  BEGIN
    PLUCK-LEXEME DUP
  WHILE
    TRANSLATE-LEXEME-SWL
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
               ELSE ."  Ok ( [" DEPTH S>D (D.) TYPE ." ].. "
                    5 .SN ." )" CR
               THEN
  THEN
;

: [   \ 94 CORE
\ Интерпретация: семантика неопределена.
\ Компиляция: Выполнить семантику выполнения, данную ниже.
\ Выполнение: ( -- )
\ Установить состояние интерпретации. [ слово немедленного выполнения.
  LEAVE-COMPILATION
; IMMEDIATE


: ] ( -- ) \ 94 CORE
\ Установить состояние компиляции.
  ENTER-COMPILATION
;

: MAIN1 ( any -- never )
  BEGIN
    REFILL
  WHILE
    INTERPRET OK
  REPEAT BYE
;

: QUIT ( any -- never ; R: i*x -- ) \ CORE 94
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
    ATIB 0 SOURCE! \ на случай, если QUIT вызыван из EVALUATE
    \ SOURCE! устанавливает так же #TIB и >IN
    \ А иначе, при неуспешном чтении они останутся без изменений и будут указывать на мусор
    LEAVE-COMPILATION \ (if any)
    ['] MAIN1 CATCH         DUP SOURCE NIP 2>R
    ['] ERROR CATCH DROP    2R> 0= IF HALT THEN DROP
    \ Пустой входной буфер здесь говорит о том, что исключение произошло
    \ при выполении REFILL (а не INTERPRET). Чтобы избежать бесконечного цикла,
    \ в этой ситуации делается завершение процесса с кодом исключения.
    \ testcase: H-STDIN CLOSE-FILE . CR
 (  R0 @ RP! \ стек не сбрасываем, т.к. это за нас делает CATCH :)
    S0 @ SP! \ стек    сбрасываем, т.к. OPTIONS может оставить значения :(
  AGAIN
;

: SAVE-SOURCE ( -- i*x u.i )
  SOURCE-ID-XT  SOURCE-ID   >IN @   SOURCE   CURSTR @   6
;

: RESTORE-SOURCE ( i*x u.i  -- )
  6 <> IF ABORT THEN
  CURSTR !    SOURCE!  >IN !  TO SOURCE-ID   TO SOURCE-ID-XT
;

: EVALUATE-WITH ( i*x c-addr u xt -- j*x )
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

: RECEIVE-WITH-XT  ( i*x fileid.source 0|xt.readline xt.translate -- j*x ior )
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

: RECEIVE-WITH  ( i*x fileid.source xt.translate -- j*x ior )
\ сохранить спецификации входного потока
\ установить входной поток на source, выполнить xt
\ восстановить спецификации входного потока
  0 SWAP RECEIVE-WITH-XT
;

: ALLOCATE-STRING ( sd1 -- sd2 0 | sd1 ior\0 )
  \ A character string sd2 is a copy of sd1.
  \ sd2 is followed by a null-character in memory.
  \ sd2 can be deallocated by applying FREE to its start address.
  \ Rationale: it should return an ior, similar to other ALLOCATE* words.
  DUP CHAR+ ALLOCATE DUP IF NIP EXIT THEN DROP
  SWAP 2DUP 2>R MOVE 2R>
  2DUP + 0 SWAP C!  0 \ return ior=0
;

: HEAP-COPY ( addr u -- addr1 )
\ скопировать строку в хип и вернуть её адрес в хипе
  DUP 0< IF 8 THROW THEN
  ALLOCATE-STRING THROW DROP
;

VECT FIND-FULLNAME \ найти указанный файл и вернуть его с полным путем

: FIND-FULLNAME1 ( a1 u1 -- a u )
  2DUP FILE-EXISTS IF EXIT THEN
  2DUP +LibraryDirName  2DUP FILE-EXISTS IF 2SWAP 2DROP EXIT THEN 2DROP
  2DUP +ModuleDirName   2DUP FILE-EXISTS IF 2SWAP 2DROP EXIT THEN 2DROP
  2 ( ERROR_FILE_NOT_FOUND ) THROW
;
' FIND-FULLNAME1 ' FIND-FULLNAME TC-VECT!


: SkipBomUtf8 ( -- )
  \ Если по текущему месту разбора есть UTF-8 BOM, то пропустить его,
  \ сдвинув >IN на 3 байта; иначе ничего не изменять.
  SOURCE  OVER >IN @ + >R  +  R> ( addr9 addr1 )
  TUCK 3 ( CHARS ) + U< IF DROP EXIT THEN
  ( addr1 )
  DUP C@ 0xEF = IF 1+ ( CHAR+ )
  DUP C@ 0xBB = IF 1+ ( CHAR+ )
  DUP C@ 0xBF = IF
    3 ( CHARS ) >IN +!
  THEN THEN THEN DROP
  \ CHARS не используется, т.к. в UTF-8 размер символа 8 бит = address unit
;

: TranslateFlow ( -- )
  REFILL 0= IF EXIT THEN SkipBomUtf8 INTERPRET
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
: REQUIRED ( sd.wordname sd.filename -- )
  2SWAP SFIND
  IF DROP 2DROP
  ELSE 2DROP INCLUDED THEN
;
: REQUIRE ( "word" "libpath" -- )
  TAKE-LEXEME TAKE-LEXEME 2DUP + 0 SWAP C!
  REQUIRED
;

\ The words `REQUIRED` and `REQUIRE` in spf4 (since 2001) conflict
\ with `REQUIRED` and `REQUIRE` in Forth Standard (since 2012).
\ The synonyms for spf4 words allow new programs to comply with the standard.
SYNONYM REQUIRED-WORD     REQUIRED
SYNONYM REQUIRE-WORD      REQUIRE


: INCLUDED-EXISTING ( i*x  sd.filename -- j*x true | i*x  sd.filename  false )
  2DUP FILE-EXISTS IF INCLUDED TRUE ELSE FALSE THEN
;
