\ simple bnf-sorta parser

\ ¬ыражение типа  16  0 <DIGITS>  значит что
\ позици€ парсинга переместитс€ вправо на столько символов, сколько
\ их будет соответствовать цифрам (в данном случае), но не меньше 0
\ в данном случае и не больше 16 (если больше 16, парсер просто дальше не
\ пойдет)

\ —двинуть позицию в строке вправо на число присутствующих символов, но не
\ больше чем MIN(u, max)

\ ≈сли сдвигов было меньше чем min то выдаем 0, иначе -1.

: CHECK-SET ( addr u max min addr2 u2 -- addr2 u2 bool )
    >R >R >R OVER MIN >R SWAP R>
    0 >R \ D: addr u1 R: u2 addr2 min 0
    BEGIN
      DUP R@ >
    WHILE
      OVER R@ + C@
      2 CELLS RP+@
      3 CELLS RP+@       
      ROT 
      >R RP@ 1 SEARCH RDROP NIP NIP
      0= IF     \ первый несовпавший символ
           DROP SWAP
           R@ - SWAP R@ + SWAP 
           2R> 1+ < RDROP RDROP EXIT
         THEN
      R> 1+ >R
    REPEAT
    + SWAP R@ -
    2R> 1+ < RDROP RDROP
;

: <SIGN> ( addr u max min -- addr2 u2 bool )
    S" -+" CHECK-SET
;

: <EXP> ( addr u max min -- addr2 u2 bool )
    S" EeDd" CHECK-SET
;

: <DOT> ( addr u max min -- addr2 u2 bool )
    S" ." CHECK-SET
;

: <DIGITS> ( addr u max min -- addr2 u2 bool )
    S" 0123456789" CHECK-SET
;

\ example
\ проверка строки-числа на флоатость :)

: ?FLOAT ( addr u -- bool )
    1   0 <SIGN>    >R
    16  0 <DIGITS>  >R
    1   0 <DOT>     >R
    16  0 <DIGITS>  >R
    1   1 <EXP>     >R
    1   0 <SIGN>    >R
    4   0 <DIGITS>  >R
    NIP 0= \ ѕосле всего этого должен быть конец строки - если нет значит error
    2R> 2R> 2R> R> AND
    AND AND AND AND AND
    AND
;

