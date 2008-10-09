( 12.10.1999 Черезов А. )
( модификация 25.12.2000-07.02.2007 )

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

  08.09.2007
  Добавлена спец-обработка случая {c} - вставка символа по его коду со стека.
  [по пожеланию из бага SF#1785461]

  26.12.2007
  Добавлена спец-обработка случая {m} - вставка числа со знаком.
  [вместо неработающего "-n" в mlogc из Eserv]

  12.03.2008
  {m} [вставка числа со знаком] заменено на {-} из-за конфликта {m} с
  большим объемом старого кода, где {m} обозначает месяц.
)


REQUIRE { lib/ext/locals.f

USER STRLAST

: XCOUNT ( xs -- addr1 u1 )
\ получить строку addr1 u1 из строки со счетчиком xs
\ счетчик - ячейчка, а не байт, в отличие от обычного COUNT
  DUP @ SWAP CELL+ SWAP
\ DEBUG @ IF 2DUP TYPE CR THEN
;
: S'
  [CHAR] ' PARSE [COMPILE] SLITERAL
; IMMEDIATE

: SALLOT ( addr u -- xs )
  DUP 9 + ALLOCATE THROW >R
  DUP R@ ! R@ CELL+ SWAP CMOVE R>
  0 OVER XCOUNT + C!
;
: sALLOT
  SALLOT CELL ALLOCATE THROW DUP >R ! R>
;
: s@ ( s -- xs )
  @
;
: s! ( xs s -- )
  !
;
: STR@ ( s -- addr u )
  s@ XCOUNT
\  DEBUG @ IF ." STR@:" 2DUP TYPE ." |" VTH CR THEN
;
: STRFREE ( s -- )
  DUP STRLAST @ = IF STRLAST 0! THEN
  DUP s@ FREE THROW FREE THROW
;
: STYPE ( s -- )
  DUP STR@ TYPE
  STRFREE
;
: STR+ { addr u s -- }
\ DEBUG @ IF ." STR+:" addr u TYPE CR THEN
  u 0 < IF 0xC000000D THROW THEN
  u 0= IF EXIT THEN \ оптимизация :)
  s s@ DUP @
  u + 9 + RESIZE THROW DUP DUP s s!
  XCOUNT + addr SWAP u CMOVE
  u SWAP +!
  0 s STR@ + C!
;
: STR! { addr u s -- }
  s s@
  u 5 + RESIZE THROW DUP s s!
  addr OVER CELL+ u CMOVE
  u SWAP !
  0 s STR@ + C!
;
: S+ ( s1 s -- )
  OVER STR@ ROT STR+ STRFREE
;
: "" ( -- s )
  S" " sALLOT
;

VECT {NOTFOUND} ' LAST-WORD TO {NOTFOUND}

: LSTRFREE1 ( -- )
  STRLAST @ ?DUP IF STRFREE STRLAST 0! THEN
;
VECT LSTRFREE ' LSTRFREE1 TO LSTRFREE

: {eval} ( ... s -- s ) { s \ sp base state }
  SP@ -> sp
  BASE @ -> base DECIMAL
  STATE @ -> state STATE 0!
  STRLAST 0!
  ['] INTERPRET CATCH
  ?DUP IF DUP -2003 = IF {NOTFOUND} THEN
          DUP -2 = ER-U @ 0<> AND
          IF DROP ER-A @ ER-U @ s STR+
          ELSE
            S" (Error: " s STR+
            ABS 0 <# [CHAR] ) HOLD #S #> s STR+
          THEN
          base BASE !
          state STATE !
          s EXIT
       THEN
  base BASE !
  state STATE !
  sp SP@ - 
  DUP 12 = IF DROP s STR+ s DUP STRLAST @ <> IF LSTRFREE THEN EXIT THEN
  DUP  8 = IF DROP 0 <# #S #> s STR+ s EXIT THEN
  DUP  4 = IF DROP s EXIT THEN
  DROP
  S" (Error: 2020)" s STR+
  sp SP!
  s
;
: {sn} ( ... s -- s ) { s }
  TIB C@ [CHAR] s = IF s STR+ s EXIT THEN
  TIB C@ [CHAR] n = IF 0 <# #S #> s STR+ s EXIT THEN
  TIB C@ [CHAR] - = IF S>D DUP >R DABS <# #S R> SIGN #> s STR+ s EXIT THEN
  TIB C@ [CHAR] c = IF SP@ 1 s STR+ DROP s EXIT THEN
  s {eval}
;
: ({...}) ( -- s ) { \ s }
  "" -> s
  #TIB @ 1 = IF s {sn} EXIT THEN
  s {eval}
;
: {...} ( addr u -- ... )
  ['] ({...}) EVALUATE-WITH
;
CHAR { VALUE [CHAR]{
CHAR } VALUE [CHAR]}

: S"{" ( -- addr u )
  S" {" OVER [CHAR]{ SWAP C!
;
: S"}" ( -- addr u )
  S" }" OVER [CHAR]} SWAP C!
;
: "delimiters ( addr 2 -- )
  DROP DUP C@ TO [CHAR]{ CHAR+ C@ TO [CHAR]}
;
: "delimiters: ( -- )
  NextWord "delimiters
;

: ((")) ( -- s ) { \ s }
  "" -> s
  BEGIN
    >IN @ #TIB @ <
  WHILE
    [CHAR]{ PARSE
    s STR+
    [CHAR]} PARSE ?DUP
    IF {...} s S+
    ELSE DROP THEN
  REPEAT
  s DUP STRLAST !
;


100 VALUE STR_DEEP_MAX

USER _STR_DEEP

: (") ( addr u -- s ) { \ c }
  [CHAR]{ -> c
  2DUP ^ c 1 SEARCH NIP NIP
  IF
    _STR_DEEP @ STR_DEEP_MAX  U< IF
      1  _STR_DEEP +!
      ['] ((")) EVALUATE-WITH
      -1 _STR_DEEP +!
      EXIT
    THEN
    2DROP S" (Error: STR TOO DEEP)"
  THEN
  sALLOT DUP STRLAST !
;

( вечная слава Андрею Филаткину: )
S" {R0 @ RP@ -}" (") DUP
STR@ ?SLITERAL
R0 @ RP@ - - 4 + CONSTANT LOCALS_STACK_OFFSET
STRFREE

: {STR@LOCAL} ( addr u s -- ) { s \ base }
  BASE @ -> base
  OVER C@ [CHAR] $ =
       IF 1- SWAP 1+ SWAP CONTEXT @ SEARCH-WORDLIST
          IF >BODY @ [ ALSO vocLocalsSupport ] LocalOffs [ PREVIOUS ] LOCALS_STACK_OFFSET +
             0 <# #S [CHAR]{ HOLD #> s STR+
             S"  RP+@ STR@" s STR+ S"}" s STR+
          THEN
       ELSE OVER C@ [CHAR] # =
            IF 1- SWAP 1+ SWAP CONTEXT @ SEARCH-WORDLIST
               IF >BODY @ [ ALSO vocLocalsSupport ] LocalOffs [ PREVIOUS ] LOCALS_STACK_OFFSET +
                  0 <# #S [CHAR]{ HOLD #> s STR+
                  S"  RP+@" s STR+ S"}" s STR+
               THEN
            ELSE S"{" s STR+ s STR+ S"}" s STR+ THEN
       THEN
  base BASE !
;
: (STR@LOCAL) ( -- s ) { \ s }
  "" -> s
  BEGIN
    >IN @ #TIB @ <
  WHILE
    [CHAR]{ PARSE
    s STR+
    [CHAR]} PARSE ?DUP
    IF s {STR@LOCAL}
    ELSE DROP THEN
  REPEAT
  s
;

: STR@LOCALs ( addr u -- s )
  ['] (STR@LOCAL) EVALUATE-WITH
;                                  

: _STRLITERAL ( -- s )
  R> XCOUNT 2DUP + CHAR+ >R
  (")
;
\ : S, ( addr u -- )
\   HERE SWAP DUP ALLOT CMOVE
\ ;
: STRLITERAL ( addr u -- )
  \ похоже на SLITERAL, но длина строки не ограничена 255
  \ и компилируемая строка при выполнении "разворачивается" по (")
  STATE @ IF
             ['] _STRLITERAL COMPILE,
             DUP , S, 0 C,
          ELSE
             (")
          THEN
; IMMEDIATE

CREATE strCRLF 13 C, 10 C,

: CRLF
  strCRLF 2
;
CREATE _S""" CHAR " C,
: ''
  _S""" 1
;

USER _PARSED"
USER _STR_LOCAL

: PARSE" { \ s c -- addr u }
  "" -> s
  BEGIN
    [CHAR] " PARSE
    2DUP + C@ [CHAR] " <>
  WHILE
    s STR+
    CRLF s STR+
    REFILL 0= THROW
  REPEAT
  s STR+
  s STR@
  s _PARSED" !
  [CHAR]{ -> c
  2DUP ^ c 1 SEARCH NIP NIP
  IF STR@LOCALs DUP _STR_LOCAL ! STR@ THEN
;

: " ( "ccc" -- )
  PARSE" POSTPONE STRLITERAL
  \ STATE @ IF _PARSED" @ ?DUP IF STRFREE _PARSED" 0! THEN  THEN
  _PARSED" @ ?DUP IF STRFREE _PARSED" 0! THEN
  _STR_LOCAL @ ?DUP IF STRFREE _STR_LOCAL 0! THEN
; IMMEDIATE

USER _LASTFILE 
USER _LASTFILESIZE

: LastFileFree _LASTFILE @ ?DUP IF FREE THROW _LASTFILE 0! THEN ;
: LastFileSize _LASTFILESIZE @ ;

: FILE ( addr u -- addr1 u1 )
  { \ f mem }
  R/O OPEN-FILE-SHARED IF DROP 0 ALLOCATE THROW DUP _LASTFILE ! 0 EXIT THEN
   -> f
  f FILE-SIZE THROW D>S DUP _LASTFILESIZE !
  DUP CELL+ ALLOCATE THROW -> mem
  mem SWAP f READ-FILE THROW
  f CLOSE-FILE THROW
  mem SWAP
  DUP IF OVER _LASTFILE ! THEN
;
: FILEFREE ( a -- ) FREE THROW ;

: S@ ( addr u -- addr2 u2 )
\ вычислить {} в строке
\ ValidateThreadHeap<
  (") STR@
\ ValidateThreadHeap>
;
: EVAL-FILE ( addr u -- addr1 u1 )
  FILE S@
;
: S! ( addr u var_addr -- )
\ ValidateThreadHeap<
  "" DUP ROT ! STR+
\ ValidateThreadHeap>
;
\ ~ygrek:
: >STR ( addr u -- str ) "" >R R@ STR+ R> ;
: STRLEN STR@ NIP ;
: STRA STR@ DROP ;

(

S" test1" sALLOT STYPE CR
"" VALUE TEST1 S" test2" TEST1 STR+ TEST1 STYPE CR

PARSE" test3" TYPE CR

PARSE" test4
test4" TYPE CR

: TEST5 " test5" ; TEST5 STYPE CR

: TEST6 " test6
test6
test6" ; TEST6 STYPE CR

S" test7" 7  " test7__{n}{s}__test7" STYPE CR

" test8_{5}__{S' test8'}_|{ \ nothing }|__{1 2 3}__" STYPE CR

: TEST9 { \ str nn } " string" -> str 55 -> nn " __{$str}__{#nn}__" STYPE CR ;
 TEST9

: TEST { \ s } " zzz1" -> s S" test0" s STR! s STYPE CR ; TEST


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

\ TEST4:
S" aaa" 15 CHAR z " char by code={c}=, number {n} and string:{s} - OK!" STYPE CR

-5 DUP " {n} : {m}" STYPE
)
