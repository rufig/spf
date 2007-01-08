\ colorlessForth без цвета. Идеи -- Chuck Moore и Terry Loveall.
\ Режим компиляции убирается. Остаётся только интерпретация.
\ Что делать со "словом" (точнее говоря строкой), определяется последней буквой
\ См. также ~profit\lib\loveall.f


\ определение:  1d; typeNumber,    <--- CREATE определение 1 LIT, COMPILE .
\ определение2: 2d; typeNumber,    <--- CREATE определение 2 LIT, COMPILE .
\ определение3: 3d; typeNumber.    <--- CREATE определение 3 LIT, COMPILE . RET,

REQUIRE lastChar ~profit/lib/strings.f
REQUIRE number ~profit/lib/number.f
REQUIRE charTable ~profit/lib/chartable-eng.f

charTable colors
: evalWordWithColor ( addr u -- ) lastChar colors processChar ;
: NOTFOUND evalWordWithColor ;

colors
all: CR curChar EMIT ABORT"  нет такого цвета!" ;

: wordCode SFIND 0= IF TYPE ABORT"  слово не найдено!" THEN ;

char: ' wordCode ;
char: , wordCode COMPILE, ;
char: : CREATED DOES> EXECUTE ;
char: . wordCode BRANCH, ;
char: d DECIMAL number ;
char: h HEX number ;
char: ; lastChar colors processChar  LIT, ;
char: | lastChar colors processChar  , ;

: typeNumber . ;
: . RET, ;

\EOF
: interpretWithColor BEGIN \ интерпретировать входной поток со знаками препинания
NextWord DUP         WHILE 
2DUP CR TYPE evalWordWithColor
?STACK               REPEAT 2DROP ;

' interpretWithColor &INTERPRET !