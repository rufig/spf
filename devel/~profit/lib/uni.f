\ сравнение и поиск в словарях обычных и широких строк, с учётом регистра и без, в комбинациях
\ примеры внизу
REQUIRE ON lib/ext/onoff.f
REQUIRE NOT ~profit/lib/logic.f
REQUIRE { lib/ext/locals.f
REQUIRE fetchByte ~profit/lib/fetchWrite.f

VARIABLE CASE-INS  : case CASE-INS OFF ;
VARIABLE UNI-STR : not-uni UNI-STR OFF ;
: compareDefaults CASE-INS ON  UNI-STR ON ; compareDefaults

WINAPI: CharLowerA USER32
WINAPI: CharLowerW USER32

VECT A@+
VECT B@+

: MultiCOMPARE { a1 u1 a2 u2 \ [ CELL ] A [ CELL ] B -- f } 
u1 u2 <> IF FALSE EXIT THEN
a2 A !  a1 B ! 
u2 0 DO
A A@+ B B@+ <> IF FALSE UNLOOP EXIT THEN
LOOP
TRUE
;

CREATE generatedCode 100 ALLOT
: generateCode
DP @
generatedCode DP !

['] fetchByte COMPILE,
CASE-INS @ IF ['] CharLowerA COMPILE, THEN
RET,
generatedCode TO A@+

HERE
UNI-STR @ IF ['] fetchWord ELSE ['] fetchByte THEN COMPILE,
CASE-INS @ IF UNI-STR @ IF ['] CharLowerW ELSE ['] CharLowerA THEN COMPILE, THEN
RET,
TO B@+

DP ! ;

: UniCOMPARE ( wa wu a2 u2 -- f )
UNI-STR @ IF ROT 2/ -ROT THEN \ количество байтов в последовательности w приводим к количеству символов
generateCode
MultiCOMPARE
\ compareDefaults
;

: UniSEARCH-WORDLIST ( wa wu wid -- 0 | xt 1 | xt -1 )
  @
  BEGIN
    DUP
  WHILE
    >R 2DUP
    R@ COUNT 
    UniCOMPARE
    IF 2DROP R@ NAME> R> ?IMMEDIATE IF 1 ELSE -1 THEN EXIT THEN
    R> CDR
  REPEAT DROP 2DROP 0
;


: uniNumber { wa wu \ [ CHAR ] B res }
generateCode
0 TO res
wa B !
wu UNI-STR @ IF 2/ THEN 0 DO
B B@+ [CHAR] 0 -
DUP 0 BASE @ WITHIN NOT IF DROP UNLOOP FALSE EXIT THEN
res BASE @ * + TO res
LOOP
res TRUE ;

\EOF
: uni CHAR C, 0 C, ;

CREATE uhtml uni h  uni T  uni m  uni l  0 W,
: Uhtml uhtml 8 ;

CREATE html S" html" S,
: Html html 4 ;

CREATE html2 S" html" S,
: Html2 html2 4 ;

CREATE eleven uni 1  uni 1 0 W,
eleven 4 uniNumber DROP .

Uhtml Html UniCOMPARE .

WORDLIST CONSTANT a
a SET-CURRENT
: htmL ." html " ;
: NOTFOUND  ." nopt " ;
: r ." r " ;

DEFINITIONS

: test CASE-INS ON UNI-STR ON
Uhtml a UniSEARCH-WORDLIST IF EXECUTE THEN
Html2 not-uni a UniSEARCH-WORDLIST IF EXECUTE THEN
; test