\ Вызов внешних функций, экспортированных по c-правилам
\ Безассемблерная версия

: CAPI-CALL ( ... n extern-addr -- x )
\ вызов внешней функции, экспортированной по c-правилам
  SWAP >R
  API-CALL
  R> 0 DO NIP LOOP
;

: CAPI: ( "ИмяПроцедуры" "ИмяБиблиотеки" n -- )
  ( Используется для импорта c-функций.
    Полученное определение будет иметь имя "ИмяПроцедуры".
    Поле address of winproc будет заполнено в момент первого
    выполнения полученной словарной статьи.
    Для вызова полученной "импортной" процедуры параметры
    помещаются на стек данных в порядке, обратном описанному
    в Си-вызове этой процедуры. Результат выполнения функции
    будет положен на стек.
    2 CAPI: strstr msvcrt.dll

    Z" s" Z" asdf" strstr
  )
  >IN @  CREATE  >IN !
  __WIN:
  DOES>
  DUP >R @ DUP 0= IF
    DROP R@ AO_INI ?DUP IF DUP R@ ! ELSE RDROP EXIT THEN
  THEN
  R> 3 CELLS + @ SWAP
  CAPI-CALL
;

: CVAPI: ( "ИмяПроцедуры" "ИмяБиблиотеки" -- )
\ Для функций с переменным числом параметров
\ При вызове после параметров надо указать их число
\ CVAPI: sprintf msvcrt.dll

\ 50 ALLOCATE THROW VALUE buf
\ 10 Z" %d" buf 3 sprintf
  >IN @  CREATE  >IN !
  0 __WIN:
  DOES>
  DUP >R @ DUP 0= IF
    DROP R@ AO_INI ?DUP IF DUP R@ ! ELSE RDROP EXIT THEN
  THEN
  RDROP
  CAPI-CALL
;
