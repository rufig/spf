\ 20.Dec.2008

REQUIRE preemptNOTFOUND ~pinka/spf/notfound-ext.f

REQUIRE AsQName ~pinka/samples/2006/syntax/qname.f


: I-QWord ( a-text u-text -- xt true | a u false )
\ интерпретирует text как маскированное тиком слово "'word" (quoted word)
\ дает xt при успехе.
  DUP 2 CHARS U< IF FALSE EXIT THEN
  OVER C@  [CHAR] ' <> IF FALSE EXIT THEN
  2DUP TAIL SFIND IF NIP NIP TRUE EXIT THEN
  2DROP FALSE
;
: AsQWord ( a-text u-text -- i*x true | a u false )  \ T-QWord
  I-QWord IF T-LIT TRUE EXIT THEN FALSE
;

: I-QChar ( a-text u-text -- c true | a u false )
\ интерпретирует text как маскированный тиком символ 'c' (quoted char)
\ дает char при успехе.
  DUP 3 CHARS <> IF FALSE EXIT THEN
  OVER C@  [CHAR] ' <> IF FALSE EXIT THEN
  OVER 2 CHARS + C@ [CHAR] ' <> IF FALSE EXIT THEN
  DROP CHAR+ C@ TRUE
;
: AsQChar ( a-text u-text -- i*x true | a u false )  \ T-QChar
  I-QChar IF T-LIT TRUE EXIT THEN FALSE
;


' AsQWord preemptNOTFOUND
' AsQChar preemptNOTFOUND

\EOF

 'A'    --> 65
 'DUP   --> 5579552
 `abc   --> 3355361 3
