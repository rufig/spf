REQUIRE /TEST ~profit/lib/testing.f

\ : NOT IF FALSE ELSE TRUE THEN ; ( \ вариант для пуристов
: NOT  0= ;                         \ вариант для нормальных пацанов )
: <=   > NOT ;
: >=   < NOT ;

/TEST

REQUIRE SEE lib/ext/disasm.f
$> :NONAME CR DUP . NOT IF ." noo!" ELSE ." yay!" THEN ; TRUE OVER EXECUTE  FALSE OVER EXECUTE REST
$> :NONAME CR DUP . IF ." yay!" ELSE ." noo!" THEN ; TRUE OVER EXECUTE  FALSE OVER EXECUTE REST