\ ВЫКИНУТЬ

\ Вариант реализации TranslateWord ( А.Ч. 12.01.2001 )

( По аналогии с целевым компилятором от SPF/3.7x будем считать, 
  что сам по себе 'evaluator' форта ничего не знает о компиляции,
  что компиляция это "собственная инициатива" _выполняемых_ слов.
  Транслятор будет просто выполнять каждое найденное слово, не
  глядя на его флаг IMMEDIATE и не глядя на переменную STATE.
  STATE и флаг IMMEDIATE будут влиять на _поиск_ слова [например,
  на контекст поиска], а не на способ обработки полученного при
  поиске xt. В ЦК SPF/3.7x в состоянии компиляции используется
  просто другой контекст [в список словарей добавляются еще два],
  STATE не меняется...
)

: NAME>XT ( nfa -- x xt )
  DUP NAME> SWAP 
  ?IMMEDIATE 0= STATE @ AND 
  IF ['] COMPILE, ELSE ['] EXECUTE THEN
;
: SearchInWordlist ( addr u wid -- x xt flag )
  ROT ROT 2>R
  @
  BEGIN
    DUP
  WHILE
    DUP COUNT 2R@ COMPARE 0= 
        IF NAME>XT TRUE 2R> 2DROP EXIT THEN
    CDR
  REPEAT 2R> 2DROP FALSE
;
: SearchWord ( addr u -- x xt )
  SP@ >R 2>R
  GET-ORDER
  BEGIN
    DUP
  WHILE
    SWAP 2R@ ROT SearchInWordlist
    IF 2R> 2DROP R> ROT ROT 2>R SP! 2DROP 2R> EXIT THEN
    1-
  REPEAT -2 THROW
;
: ExecuteToken EXECUTE ;

: TranslateWord ( addr u -- | ... ) \ throwable
  SearchWord ExecuteToken
;
