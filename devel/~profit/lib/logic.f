\ ƒополнительные слова дл€ логических выражений
\ которых нет в коробке SPF.
\ „исто красоты дл€.

REQUIRE /TEST ~profit/lib/testing.f

\ : NOT IF FALSE ELSE TRUE THEN ; ( \ вариант дл€ пуристов
: NOT  0= ;                         \ вариант дл€ нормальных пацанов )
: <=   > NOT ;
: >=   < NOT ;

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f
TESTCASES logic

(( TRUE  NOT -> FALSE ))
(( FALSE NOT -> TRUE  ))
(( 3 3 >=    -> TRUE  ))
(( 3 4 >=    -> FALSE ))
(( 4 3 >=    -> TRUE  ))
(( 3 3 <=    -> TRUE  ))
(( 3 4 <=    -> TRUE  ))
(( 4 3 <=    -> FALSE ))
(( TRUE NOT NOT -> TRUE ))
(( FALSE NOT NOT -> FALSE ))

END-TESTCASES

\EOF
REQUIRE REST lib/ext/disasm.f

:NONAME 3 4 >= IF ." 3>=4" ELSE ." 3<4" THEN ; REST