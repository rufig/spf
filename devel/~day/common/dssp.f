\ Управляющие конструкции в стиле DSSP.
\ Повышает структурированность и 'прозрачность' программы
\ То что в DSSP - стандарт - на форте можно реализовать очень просто
\ Значит DSSP - частный случай форта :)
\ Но в DSSP не учли человеческий фактор (как часто у нас бывает)
\ а форт на этом самом факторе базируется

\ Если число на стеке не 0 то выполняется следующее слово
\ Только для режима компиляции!

: IFN ( "word" -- )
  STATE @
  IF
    HERE ?BRANCH, >MARK
    ' COMPILE,
    >RESOLVE1
  ELSE -312 THROW 
  THEN
; IMMEDIATE


\ Аналогично для режима интерпретации - входное слово - вся строка
\ Пример - DEBUG @ IFDEF S" Warning! Debug mode."

: IFDEF
  STATE @ 0=
  IF
    1 PARSE ROT
    IF
       EVALUATE
    ELSE
       2DROP
    THEN
  ELSE DROP
  THEN
; IMMEDIATE


( \ ex:

: TEST ." IFN is Ok" ;
: TEST2 IFN TEST ;

-1 TEST2
0 TEST2
)
