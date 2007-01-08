REQUIRE FileLines=> ~ygrek/lib/filelines.f
REQUIRE S>STR ~profit/lib/bac4th-str.f
REQUIRE restOfString ~profit/lib/strings.f 
REQUIRE seq{ ~profit/lib/bac4th-sequence.f


VARIABLE section
"" section !

VARIABLE isComment

: __ CELL -- ;

0
__ secName
__ commentFlag
__ setting
__ value
CONSTANT record

: r ( a u -- )
arr{
FileLines=> ( s )
notEmpty
DUP STR@  ( s addr u )
firstChar [CHAR] [ = IF
[CHAR] ] byChar first-patch restOfString S> section !
EXIT \ FALSE ONTRUE
THEN

firstChar [CHAR] ; = DUP isComment !
IF restOfString THEN

[CHAR] = byChar divide-patch

                       *> \ последовательно подаём:
section @       DROPB <*> \ сначала название секции,
isComment @     DROPB <*> \ потом коментарийность,
S>              DROPB <*> \ потом имя значения,
restOfString S> DROPB <*  \ потом -- значение.

}arr ( addr u ) \ массив из record
record iterateBy
DUP commentFlag @ CR IF ." ;" THEN
DUP secName @ STR@ TYPE
DUP setting @ SPACE STR@ TYPE
DUP value @ DUP STR@ NIP IF ." =" STR@ TYPE THEN
;

 S" C:\Program Files\Opera\defaults\standard_voice.ini" r
\ S" C:\Lang\spf\devel\~profit\prog\opera inn\main.ini" r