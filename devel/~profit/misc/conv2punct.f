\ Преобразователь обычной фортовой программы в colorlessForth:
\ ~profit/lib/colorForth/colorSP4th.f

\ TODO:
\ 1. Комментарии
\ 2. По возможности сделать менее текстовым, более двоичным
\ 3. Делать ли преобразование DUP ; --> DUP. ?
\ 4. Преобразования вообще. Например: ['] DUP --> DUP';
\    Или: [CHAR] a EMIT --> CHAR a ; EMIT,
\ 5. S" и вообще слова с собственным анализом исходного текста

\ Возможно, через ловлю в PARSE каждую букву выводить из текста
\ и просто перемежать с цветовыми окончаниям.

REQUIRE /TEST ~profit/lib/testing.f

VECT conv ( addr u -- )

: convWord ( addr u -- )
DUP 1 = IF OVER C@ [CHAR] : = IF 2DROP S" "  THEN THEN
DUP 1 = IF OVER C@ [CHAR] ; = IF 2DROP S" ." THEN THEN
conv ;

: convNumber ( addr u -- )
BASE @ 10 = IF S" #" conv THEN
BASE @ 16 = IF S" $" conv THEN
STATE @ IF S" ;" conv THEN 
S"  " conv ;

: conv2punct_INTERPRET ( -> ) \ интерпретировать входной поток
  BEGIN
    PARSE-NAME 2DUP convWord DUP
  WHILE
    SFIND ?DUP
    IF
         STATE @ =
         IF S" , " conv COMPILE, ELSE S"  " conv EXECUTE THEN
    ELSE
         S" NOTFOUND" SFIND 
         IF EXECUTE
         ELSE 2DROP ?SLITERAL THEN
    THEN
    ?STACK
  REPEAT 2DROP
;

:NONAME ( addr u -- ) 
2DUP convNumber
[ ' ?SLITERAL BEHAVIOR COMPILE, ]
; TO ?SLITERAL

:NONAME ( -- ) 
LT LTL @ conv
[ ' REFILL BEHAVIOR COMPILE, ]
; TO REFILL

WARNING @ WARNING 0!
: :
>IN @ NextWord conv >IN !
S" : " conv :
; WARNING !


/TEST

' TYPE TO conv
' conv2punct_INTERPRET &INTERPRET !

$> : r [ HEX ] 12 DUP ;

S" ~profit/lib/logic.f" INCLUDED