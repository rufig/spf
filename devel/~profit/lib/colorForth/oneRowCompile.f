REQUIRE /TEST ~profit/lib/testing.f
\ Однострочная компиляция, мусорит в кодофайле

: INTERPRET_ONE_ROW ( -> )
HERE
] INTERPRET_
RET, EXECUTE ;

' INTERPRET_ONE_ROW  &INTERPRET !

/TEST

." 1-10: "
10 0 DO I . LOOP