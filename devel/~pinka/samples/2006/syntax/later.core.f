\ 13.Feb.2006

REQUIRE SPLIT- ~pinka/samples/2005/lib/split.f

REQUIRE T-SLIT ~pinka\samples\2006\core\trans\common.f 

: I-LaterSintax ( a u -- a2 u2 xt true | a u false )
  \ name1.name2
  DUP 3 CHARS U< IF FALSE EXIT THEN
  S" ." SPLIT- 0= IF FALSE EXIT THEN
  SFIND 0= IF 2SWAP NIP + CHAR+ FALSE EXIT THEN
  TRUE
;

: AsLaterSintax ( i*x a u -- j*x true | a u false )
  I-LaterSintax IF >R T-SLIT R> T-XT TRUE EXIT THEN
  FALSE
;
