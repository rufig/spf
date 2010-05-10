\ http://code.sixapart.com/svn/memcached/trunk/server/doc/protocol.txt

REQUIRE fgets ~ac/lib/win/winsock/psocket.f 

: McConnect ( -- sl )
  " 127.0.0.1" 11211 fsockopen
;
: Mc! ( va vu na nu -- )
  McConnect >R
  2>R DUP 2R>
  " set {s} 10 0 {n}
{s}
" R@ fputs
  R@ fgets DROP \ STR@ S" STORED" COMPARE 0= IF ." ok" ELSE ." err" THEN
  R> fclose
;
: (Mc@g) { so \ s n -- a u }
  NextWord S" VALUE" COMPARE IF POSTPONE \ S" " EXIT THEN
  "" -> s
  NextWord 2DROP ( name) NextWord 2DROP ( flags)
  0 0 NextWord >NUMBER 2DROP D>S -> n
  BEGIN
    n
  WHILE
    so fgets DUP STRLEN 2 + n SWAP - 0 MAX -> n
    s S+
  REPEAT
  so fgets STR@ S" END" COMPARE 0=
  IF s STR@ ELSE S" " ( ошибка) THEN
;
: (Mc@) { na nu so -- va vu }
  na nu " get {s}
" so fputs
  so fgets STR@
  2DUP S" END" COMPARE 0= IF 2DROP S" " ( отсутствует) EXIT THEN
  so ROT ROT ['] (Mc@g) EVALUATE-WITH
;
: Mc@ { na nu \ so -- va vu }
  McConnect -> so
  na nu so (Mc@)
  so fclose
;

\EOF

: TEST { \ so }
  SocketsStartup DROP
  S" aaa" S" bbb" Mc!
  McConnect -> so
  100 0 DO S" bbb" so (Mc@) TYPE SPACE LOOP
  so fclose
;
TEST


