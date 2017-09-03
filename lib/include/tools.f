\ 94 TOOLS

: .S ( -- ) \ 94 TOOLS
\ Скопировать и показать значения, находящиеся на стеке данных. Формат зависит 
\ от реализации.
\ .S может быть реализовано с использованием слов форматного преобразования 
\ чисел. Соответственно, он может испортить перемещаемую область, 
\ идентифицируемую #>.
   DEPTH 0 MAX .SN
;

: ? ( a-addr -- ) \ 94 TOOLS
\ Показать значение, хранящееся по адресу a-addr.
\ ? может быть реализован с использованием слов форматного преобразования 
\ чисел. Соответственно, он может испортить перемещаемую область, 
\ идентифицируемую #>.
  @ .
;
: AHEAD  \ 94 TOOLS EXT
\ Интерпретация: семантика неопределена.
\ Компиляция: ( C: -- orig )
\ Положить место неразрешенной ссылки вперед orig на стек управления.
\ Добавить семантику времени выполнения, данную ниже, к текущему определению.
\ Семантика незавершена до тех пор, пока orig не разрешится (например,
\ по THEN).
\ Время выполнения: ( -- )
\ Продолжить выполнение с позиции, заданной разрешением orig.
  HERE BRANCH, >MARK 2
; IMMEDIATE

: [ELSE]   \ 94 TOOLS EXT
\ Компиляция: Выполнить семантику выполнения, данную ниже.
\ Выполнение: ( "<spaces>name..." -- )
\ Пропустить ведущие пробелы, выделить и отбросить ограниченные пробелами 
\ слова из разбираемой области, включая вложенные [IF]...[THEN] и 
\ [IF]...[ELSE]...[THEN], до выделения и отбрасывания слова [THEN].
\ Если разбираемая область опустошается, она снова заполняется по REFILL.
\ [ELSE] - слово немедленного исполнения.
    1
    BEGIN
      NextWord DUP
      IF  
         2DUP S" [IF]"   COMPARE 0= IF 2DROP 1+                 ELSE 
         2DUP S" [ELSE]" COMPARE 0= IF 2DROP 1- DUP  IF 1+ THEN ELSE 
              S" [THEN]" COMPARE 0= IF       1-                 THEN
                                    THEN  THEN   
      ELSE 2DROP REFILL  AND \   SOURCE TYPE
      THEN DUP 0=
    UNTIL  DROP ;  IMMEDIATE

: [IF] \ 94 TOOLS EXT
\ Компиляция: Выполнить семантику выполнения, данную ниже.
\ Выполнение: ( flag | flag "<spaces>name..." -- )
\ Если флаг "истина", ничего не делать. Иначе, пропустив ведущие пробелы, 
\ выделять и отбрасывать ограниченные пробелами слова из разбираемой области,
\ включая вложенные [IF]...[THEN] и [IF]...[ELSE]...[THEN], до тех пор, пока не 
\ будет выделено и отброшено слово [ELSE] или [THEN].
\ Если разбираемая область опустошается, она снова заполняется по REFILL.
\ [ELSE] - слово немедленного исполнения.
  0= IF POSTPONE [ELSE] THEN
; IMMEDIATE

: [THEN] \ 94 TOOLS EXT
\ Компиляция: Выполнить семантику выполнения, данную ниже.
\ Выполнение: ( -- )
\ Ничего не делать. [THEN] - слово немедленного исполнения.
; IMMEDIATE


: CS-PICK ( C: destu ... orig0|dest0 -- destu ... orig0|dest0 destu ) ( S: u -- ) \ 94 TOOLS EXT
  2* 1+ DUP >R PICK R> PICK
;

: CS-ROLL ( C: origu|destu origu-1|destu-1 ... orig0|dest0 -- origu-1|destu-1 ... orig0|dest0 origu|destu ) ( S: u -- ) \ 94 TOOLS EXT
  2* 1+ DUP >R ROLL R> ROLL
;


: ENROLL-NAME ( xt d-newname -- ) \ basic factor
  \ see also: ~pinka/spf/compiler/native-wordlist.f
  SHEADER LAST-CFA @ !
;
: ENROLL-SYNONYM ( d-oldname d-newname -- ) \ postfix version of SYNONYM
  2>R SFIND DUP 0= IF -321 THROW THEN ( xt -1|1 )
  SWAP 2R> ENROLL-NAME 1 = IF IMMEDIATE THEN
;
: SYNONYM ( "<spaces>newname" "<spaces>oldname" -- ) \ 2012 TOOLS EXT
  PARSE-NAME PARSE-NAME 2SWAP ENROLL-SYNONYM
;

: OS_LINUX ( -- flag )
  PLATFORM S" Linux" COMPARE 0=
;
: OS_WINDOWS ( -- flag )
  OS_LINUX 0=
;

\ Ruvim Pinka additions:

: [DEFINED] ( -- f ) \ "name"
  NextWord  SFIND  IF DROP TRUE ELSE 2DROP FALSE THEN
; IMMEDIATE

: [UNDEFINED]  ( -- f ) \ "name"
  POSTPONE [DEFINED] 0=
; IMMEDIATE

