( Простая библиотека для преобразования строки параметров
  в список пар параметр-значение. Например, выполнение
  S" error_code=10060&from=http://10.1.1.11/" GetParamsFromString
  приведет к тому, что в динамическом списке, на который
  указывает переменная PARAMS, появятся элементы с именами
  error_code и from, с которыми связаны значения-строки addr u
  Основные слова - GetParam, SetParam, IsSet, примеры см. в конце.
)
REQUIRE {             ~ac/lib/locals.f
REQUIRE "             ~ac/lib/str2.f
REQUIRE COMPARE-U     ~ac/lib/string/compare-u.f

: CONVERT { a u c1 c2 -- }
  u 0 ?DO a I + C@ c1 = IF c2 a I + C! THEN LOOP
;
: CONVERT% { a u \ a2 u2 i -- a2 u2 }
  a u [CHAR] + BL CONVERT
\  a u [CHAR] & 1  CONVERT
\  a u [CHAR] = BL CONVERT
  u ALLOCATE THROW -> a2
  0 -> u2  0 -> i  HEX
  BEGIN
    i u U<
  WHILE
    a i + C@ DUP [CHAR] % =
    IF DROP 0 0 a i + CHAR+ 2 >NUMBER 2DROP D>S i 2+ -> i THEN
    a2 u2 + C!
    i 1+ -> i
    u2 1+ -> u2
  REPEAT DECIMAL
  a2 u2
;

USER PARAMS

: SetParam1 ( va vu na nu -- ) { \ mem }
  3 CELLS ALLOCATE THROW -> mem
  PARAMS @ mem !
  mem CELL+ S!
  mem CELL+ CELL+ S!
  mem PARAMS !
;
: STRING:
  1 PARSE 1 PARSE 2SWAP SetParam1
;
: Name:Value
  2DUP [CHAR] = 1 CONVERT
  CONVERT%
  ['] STRING: EVALUATE-WITH
;
: AllocParams
  PARAMS 0!
  BEGIN
    1 PARSE DUP
  WHILE
    Name:Value
  REPEAT 2DROP
;
: GetParamsFromString ( addr u -- )
  2DUP [CHAR] & 1  CONVERT
  ( CONVERT%) ['] AllocParams EVALUATE-WITH
;
: ForEachParam { xt \ a -- }
  PARAMS @
  BEGIN
    DUP
  WHILE
    -> a
    a CELL+ @ STR@
    a CELL+ CELL+ @ STR@
    xt EXECUTE
    a @
  REPEAT DROP
;
: DumpParam { na nu va vu -- }
  na nu TYPE ." =="
  [CHAR] " EMIT va vu TYPE [CHAR] " EMIT CR CR
;
: DumpParams
  ['] DumpParam ForEachParam
;
: SearchParam { na nu \ a -- a true  | false }
  PARAMS @
  BEGIN
    DUP 
  WHILE
    -> a
    a CELL+ @ STR@ na nu COMPARE-U 0=
    IF a TRUE EXIT THEN
    a @
  REPEAT
;
: IsSet ( addr u -- flag )
  SearchParam
  IF DROP TRUE ELSE FALSE THEN
;
: SetParam { va vu na nu -- }
  na nu SearchParam
  IF va vu ROT CELL+ CELL+ S!
  ELSE va vu na nu SetParam1 ( " {s} {s}" STR@ Name:Value) THEN
;
: GetParam { na nu -- va vu }
  na nu SearchParam
  IF CELL+ CELL+ @ STR@
  ELSE S" " THEN
;

(
  S" error_code=10060&from=http://10.1.1.11/" GetParamsFromString
  DumpParams
  S" Andrey" S" name" SetParam
  S" 10065" S" error_code" SetParam
  DumpParams
  S" name" GetParam TYPE S" test" GetParam TYPE
)
