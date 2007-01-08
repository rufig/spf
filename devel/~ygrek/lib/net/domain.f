REQUIRE /STRING lib/include/string.f
REQUIRE /GIVE ~ygrek/lib/parse.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f

\ S" localhost:9050" -> S" localhost" 9050
: domain:port ( a u -- a u1 port )
   2DUP 
   LAMBDA{ BEGIN 1- DUP -1 = IF 2DROP FALSE EXIT THEN 2DUP + C@ [CHAR] : = IF NIP TRUE EXIT THEN AGAIN }
   EXECUTE
   0= IF 0 EXIT THEN
   /GIVE 2SWAP 1 /STRING NUMBER 0= IF 0 THEN ;


\EOF

CR
S" localhost:9050" domain:port CR . TYPE
S" localhost" 9050 CR . TYPE

CR 
0 0 domain:port CR . TYPE
0 0 0 CR . TYPE

CR
S" http://localhost:8118" domain:port CR . TYPE
S" http://localhost" 8118 CR . TYPE

CR
S" forth.org.ru" domain:port CR . TYPE
S" forth.org.ru" 0 CR . TYPE

CR