( 12.10.1999 Черезов А. )
( модификация 25.12.2000 )

( Простое расширение СП-Форта операциями над динамическими
  строками произвольной длины. Эти процедуры сделаны в стиле
  Perl или PHP, но синтаксис и другие детали сделаны более
  соответствующими Форт-стилю, нежели Perl'у.

  Создание строк: 

  " текст строки"

  Или:

  " многострочный
    текст
    строки"

  В строку можно включать вычисляемые выражения, которые
  должны вернуть строку [два числа - addr u] или число. Поскольку
  Форт оставлен бестиповым языком, то единственный способ, по
  которому реализованные здесь библиотеки могут узнать, чтО
  возвращено - это измерение изменения глубины стека. Если
  добавилось два числа, считаем это адресом и длиной строки,
  если одно, то считаем это числом. Возвращенная строка вставляется
  в то место исходной строки, откуда вызывалось вычисление. Если
  вернули число, то оно преобразуется в строку в десятичной системе 
  счисления. Пример:

  : text S" текст" ;
  " многострочный
    {text}
    строки"

  Создаст ту же строку, что и предыдущий пример.

  Слово " [кавычка] возвращает строку не в виде addr u, а в виде
  одного числа s, которое можно преобразовать в addr u с помощью
  слова

  STR@ [ s -- addr u ]

  Если слово " используется внутри компилируемого определения, то
  строка компилируется в исходном невычисленном виде, и будет вычислена
  при выполнении скомпилированного определения. Например:

  : TEST " многострочный
    {text}
    строки" ;

  При выполнении TEST получится такая же строка, как в предыдущем
  примере.

  При вычислении выражения в {} всегда используется десятичная
  система счисления.

  Все операции со строками выполняются в динамической памяти,
  каждое s, возвращенное словом " , необходимо после использования
  удалять из памяти словом

  STRFREE [ s -- ]

  Все операции помещают ноль в конце строки, поэтому возвращаемое
  по STR@ значение строки можно смело использовать в функциях Windows,
  требующих ASCIIZ-строк.

  Создание пустой строки:

  ""  [ -- s ]

  Добавление строки addr u в конец строки s:

  STR+ [ addr u s -- ]

  Добавление строки s1 в конец строки s2 с удалением s1:

  S+ [ s1 s2 -- ]

  Если внутри строки, создаваемой кавычкой, требуется вставить кавычку,
  можно это сделать с помощью {''}, а конец строки - {CRLF}. Например:

  " многострочный{CRLF}{text}
    строки"

  вернет ту же строку, что и в предыдущем примере.

  Если при вычислении выражения в {} происходит ошибка [throw], то
  значением выражения, вставляемым в строку, будет "Error: код_ошибки".

  Особый вариант вычисления выражения {} используется в случае, если
  внутри {} используются имена локальных для текущей компилируемой
  процедуры переменных. Эти имена существуют только в момент компиляции,
  а в момент выполнения процедуры, когда вычисляется {} - нет. Поэтому
  будет возникать ошибка. Для предотвращения такого исхода и сохранения
  возможности использования локальных переменных внутри строк принят
  следующий синтаксис использования локальной переменной внутри строки:
  {$имя_переменной}. Например:

  : TEST { \ t }
    " abcd" -> t
    " 123{$t}123" STYPE
  ;

  Выполнение слова TEST напечатает 123abcd123.
  Последовательности вида {$имя} обрабатываются в момент компиляции
  и заменяются последовательностью {число RP@ + @ STR@}, где "число" -
  смещение локальной перемеменной в стеке.

  Если локальную переменную нужно вставить в строку как числовое 
  значение, то используется {#имя_переменной}.

  Для работы со строковыми литералами внутри {} можно использовать
  слово S', являющееся аналогом S", но использующее одинарную кавычку
  при парсинге.

  Для вставки содержимого файла в строку можно использовать слово 
  FILE [ addr u -- addr1 u1 ], здесь addr u - имя файла, а addr1 u1 -
  его содержимое. Например:

  " text1{S' filename.txt' FILE}text2"

  EVAL-FILE делает то же самое, но вычисляет выражения в {} внутри файла.
  EVAL-FILE можно использовать и внутри файлов, включаемых по EVAL-FILE.
  Это фактически аналог слова INCLUDED, но интерпретирующий только
  выражения внутри {}, и возвращающий строку как результат.

  Описанных выше слов " "" STR+ STR@ STRFREE CRLF '' FILE EVAL-FILE
  достаточно для использования этой библиотеки. Рекомендуется не использовать
  другие определенные в реализации слова чтобы не потерять 
  совместимость с будущими версиями.

  Потенциально узкое место - если в процессе "роста" строка становится
  длиннее 4Кб, производится выделение нового буфера, при его исчерпании -
  следующего, и т.д. Все старые буферы кроме самого первого размером 4Кб
  автоматически освобождаются. В служебных структурах первого буфера
  делаются необходимые "редиректы". Исходный указатель на строку - s -
  продолжает оставаться валидным для всех описанных операций. А вот
  сохранять во внешних переменных указатели на addr u не рекомендуется,
  т.к по мере роста указатель addr может измениться при описанном
  перевыделении буфера. Лучше работать с указателем вида s, и, когда
  необходимо, получать строку в виде addr u операцией STR@.

  Скомпилированный размер библиотеки - около 7Кб.

  25.12.2000
  Добавлена спец-обработка случаев {n} и {s}. Если они встречаются
  в разбираемой строке, то значения для вставки берутся не из переменных
  и не из EVALUATE, а со стека - то что там лежало до ". n - просто число,
  s - строка addr u.
)
REQUIRE { ~ac/lib/locals.f
REQUIRE MEM ~ac/lib/memory/heap_enum.f
0
4 -- sType
4 -- sAsize
4 -- sSize
4 -- sState
4 -- sNewBuff
4 -- sWriteH
4 -- sReadH
CONSTANT /sHeader

: SALLOCATE
  ALLOCATE
;

USER STR-ID

: sAddr ( s -- addr )
  DUP sNewBuff @ ?DUP IF NIP EXIT THEN
  /sHeader +
;
: STR@ ( s -- addr u )
  DUP sAddr SWAP sSize @
;
: STRHERE ( s -- addr )
  STR@ +
;
: STRALLOT ( n s -- addr )
  { n s \ size a u ob -- addr }
  s STR@ NIP n + DUP
  /sHeader +  s sAsize @ <
  0= IF -> size
        size 2000 + SALLOCATE THROW
        s STR@ -> u -> a
        s sNewBuff @ -> ob
        DUP s sNewBuff !
        a u ROT SWAP MOVE
        ob ?DUP IF FREE THROW THEN
        size 2000 + s sAsize !
        size
     THEN
  s STRHERE
  SWAP s sSize !
  0 s STRHERE C!
;
: STR+ ( addr u s -- )
  { a u s -- }
  a u s STRALLOT u MOVE
;
: STR! ( addr u s -- )
  0 OVER sSize ! STR+
;
: STRBUF ( -- s )
  { \ s }
  4000 /sHeader + DUP SALLOCATE THROW -> s
  s OVER ERASE
  s sAsize !
  S" " s STR!
  s
;
: "" ( -- s )
  STRBUF
;
: STRFREE ( s -- )
  DUP sNewBuff @ ?DUP IF FREE THROW THEN
  FREE THROW
;
: STR_EVAL ( addr u s -- )
  { \ s sp tib >in #tib so si }
  -> s
  DUP 1 = \ варианты {s} {n}
  IF OVER C@ [CHAR] n = IF 2DROP 0 <# #S #> s STR+ EXIT THEN
     OVER C@ [CHAR] s = IF 2DROP s STR+ EXIT THEN
  THEN
  SP@ -> sp
  TIB -> tib  >IN @ -> >in  #TIB @ -> #tib SOURCE-ID -> so STR-ID -> si
  s STR-ID !
  \ при сбое в EVALUATE он сам не сможет восстановить наш TIB, поэтому сохраняем
  ['] EVALUATE CATCH ?DUP
  IF NIP NIP S" (Error: " s STR+
     ABS 0 <# [CHAR] ) HOLD #S #>  s STR+
     tib TO TIB  >in >IN !  #tib #TIB ! so TO SOURCE-ID
  ELSE
     SP@ sp -
     \ разница=0, если возвращены два числа - адрес и длина строки
     IF 0 <# #S #> THEN
     s STR+
  THEN
  si STR-ID !
  sp SP! 2DROP
;
: (") ( addr u -- s )
  { \ tib >in #tib s sp base }
  TIB -> tib #TIB @ -> #tib >IN @ -> >in BASE @ -> base
  #TIB ! TO TIB >IN 0! DECIMAL
  STRBUF -> s
  BEGIN
    >IN @ #TIB @ <
  WHILE
    [CHAR] { PARSE
    s STR+
    [CHAR] } PARSE ?DUP
    IF s STR_EVAL
    ELSE DROP THEN
  REPEAT
  >in >IN ! #tib #TIB ! tib TO TIB base BASE !
  s
;
: _STRLITERAL ( -- s )
  R> DUP CELL+ SWAP @ 2DUP + CHAR+ >R
  (")
;
USER STRBUF_

: STRLITERAL ( addr u -- )
  \ похоже на SLITERAL, но длина строки не ограничена 255
  \ и компилируемая строка при выполнении "разворачивается" по (")
  STATE @ IF
             ['] _STRLITERAL COMPILE,
             DUP ,
             HERE SWAP DUP ALLOT MOVE 0 C,
             STRBUF_ @ STRFREE
          ELSE
             (")
          THEN
; IMMEDIATE

: CRLF
  LT 2
;
CREATE _S""" CHAR " C,
: ''
  _S""" 1
;

HEX
0BC ( 90, 98 в старых locals) CONSTANT LOCALS_STACK_OFFSET
\ смещение первой локальной переменной в стеке ( в старом locals)
\ смещение фрейма (в новом locals)
\ на момент выполнения слова (") внутри скомпилированного определения
DECIMAL

: STR@LOCAL ( addr u -- addr u )
  { \ tib >in #tib s sp }
  TIB -> tib #TIB @ -> #tib >IN @ -> >in
  #TIB ! TO TIB >IN 0!
  STRBUF -> s
  BEGIN
    >IN @ #TIB @ <
  WHILE
    [CHAR] { PARSE
    s STR+
    [CHAR] } PARSE ?DUP
    IF OVER C@ [CHAR] $ =
       IF 1- SWAP 1+ SWAP CONTEXT @ SEARCH-WORDLIST
          IF >BODY @ [ ALSO vocLocalsSupport ] LocalOffs [ PREVIOUS ] LOCALS_STACK_OFFSET +
             0 <# #S [CHAR] { HOLD #> s STR+
             S"  RP+@ STR@}" s STR+
          THEN
       ELSE OVER C@ [CHAR] # =
            IF 1- SWAP 1+ SWAP CONTEXT @ SEARCH-WORDLIST
               IF >BODY @ [ ALSO vocLocalsSupport ] LocalOffs [ PREVIOUS ] LOCALS_STACK_OFFSET +
                  0 <# #S [CHAR] { HOLD #> s STR+
                  S"  RP+@}" s STR+
               THEN
            ELSE S" {" s STR+ s STR+ S" }" s STR+ THEN
       THEN
    ELSE DROP THEN
  REPEAT
  TIB /sHeader - STRFREE
  >in >IN ! #tib #TIB ! tib TO TIB
  s DUP STRBUF_ ! STR@
;
: PARSE"
  { \ s a u }
  [CHAR] " PARSE
  2DUP + C@ [CHAR] " = 
  IF "" -> s s STR! s STR@ STR@LOCAL EXIT THEN \ весь литерал на одной строке
  \ иначе читаем построчно и ищем кавычку
  SOURCE-ID ?DUP
  IF FILE-SIZE THROW D>S ELSE 10000 THEN 
  DUP SALLOCATE THROW -> s
  s OVER ERASE
  s sAsize !
  s STR! CRLF s STR+
  BEGIN
    REFILL
  WHILE
    SOURCE '' SEARCH
    IF -> u -> a
       SOURCE u - s STR+
       SOURCE NIP u - CHAR+ >IN !
       s STR@ STR@LOCAL EXIT
    ELSE s STR+ CRLF s STR+ THEN
  REPEAT
  s STR@ STR@LOCAL
;
: " ( "ccc" -- )
  PARSE" POSTPONE STRLITERAL
; IMMEDIATE

: STYPE
  DUP STR@ TYPE
  STRFREE
;
: FILE ( addr u -- addr1 u1 )
  { \ f mem }
  R/O OPEN-FILE-SHARED IF DROP S" " EXIT THEN
   -> f
  f FILE-SIZE THROW D>S DUP SALLOCATE THROW -> mem
  mem SWAP f READ-FILE THROW
  f CLOSE-FILE THROW
  mem SWAP
;
: S'
  [CHAR] ' PARSE [COMPILE] SLITERAL
; IMMEDIATE

: EVAL-FILE ( addr u -- addr1 u1 )
  FILE (") STR@
;
: S! ( addr u var_addr -- )
  "" DUP ROT ! STR+
;
: S+
  OVER STR@ ROT STR+ STRFREE
;
: FREESTR1
  DUP CELL+ @ 4032 =
  IF
    DUP
    @ @ ['] SALLOCATE - 5 = IF ." *****" @ CELL+ DUP . FREE THROW ELSE ." =====" DROP THEN
  ELSE DROP THEN
;
: FREESTR
  ['] FREESTR1 THREAD-HEAP @ HeapEnum
;

(
\ : TEST { a b c } " 777{RP@ 180 DUMP HERE 0}888" STYPE ;
\ HEX 77 88 99 TEST

\ Тесты:

: TEST S" test" ;
" abc{TEST}123 5+5={5 5 +} Ok" STYPE CR

: TEST2 " abc{TEST}123 5+5={5 5 +} Ok {ZZZ} OK!" STYPE CR ;
TEST2

" 
  abc
  def
  {TEST}
  123
" 
STYPE

: TEST3  { \ n t k }
  9 -> n
  " abcd" -> t
  3 -> k
  " |123|{$t}|123|{#n}|123|{#k}|{S' file1.txt' EVAL-FILE}<End of file>" STYPE
;
TEST3
)