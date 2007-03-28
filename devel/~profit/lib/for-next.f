\ ÷икл FOR ... NEXT. »меет только одну переменную цикла,
\ котора€ от начального значени€ снижаетс€ к нулю и потом выходит

REQUIRE /TEST ~profit/lib/testing.f

: FOR POSTPONE >R HERE ;  IMMEDIATE

: NEXT  ?COMP
POSTPONE R> POSTPONE 1- POSTPONE >R
POSTPONE R@ POSTPONE 0= ?BRANCH,
POSTPONE RDROP
;  IMMEDIATE
DECIMAL

/TEST
: r 10 FOR R@ . NEXT ;

REQUIRE SEE lib/ext/disasm.f
SEE r

r