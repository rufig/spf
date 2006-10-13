\ ÷икл FOR ... NEXT. »меет только одну переменную цикла,
\ котора€ от начального значени€ снижаетс€ к нулю и потом выходит

REQUIRE /TEST ~profit/lib/testing.f

: FOR POSTPONE >R <MARK ;  IMMEDIATE

: NEXT  ?COMP  0x24 0x0CFF W, C, 
  HERE 2+ - DUP SHORT?   SetOP SetJP
  IF
    0x75 C, C, \ jnz short 
  ELSE
    4 - 0xF85 W, , \ jnz near
  THEN    SetOP
  0x0424648D , \ lea esp, 04 [esp]
;  IMMEDIATE
DECIMAL

/TEST
: r 10 FOR R@ . NEXT ;

REQUIRE SEE lib/ext/disasm.f
SEE r

r