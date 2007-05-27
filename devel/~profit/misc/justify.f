\   конкурсу решени€ задач на форте (http://fforum.winglion.ru/viewtopic.php?p=7274#7274)

\ ¬ыравнивание по ширине текста.
\ ѕервый пример (см. после слова /TEST ) -- просто строка
\ ¬торой -- требует наличи€ текстового файла in.txt с текстом


\ ƒл€ запуска нужен дистрибутив SPF:
\ http://sourceforge.net/project/showfiles.php?group_id=17919

\ » апрельское обновление:
\ http://sourceforge.net/project/shownotes.php?release_id=497972&group_id=17919

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE split ~profit/lib/bac4th-str.f
REQUIRE arr{ ~profit/lib/bac4th-sequence.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE __ ~profit/lib/cellfield.f

: TAKE-THREE PRO *> <*> BSWAP <*> ROT BACK -ROT TRACKING <* CONT ;

0
__ wordsInLine
__ spacesBetween
__ lastSpace
CONSTANT elem

: format-text ( addr u w --> addr u \ <-- ) PRO
LOCAL charsInLine
DUP charsInLine !
LOCAL charsLeft
1+ charsLeft !

LOCAL wordsEntered
concat{ byRows split DUP STR@
charsLeft KEEP
wordsEntered 0!
arr{
*>
2DUP BL byChar split notEmpty \ DUP STR@ TYPE KEY DROP
DUP STR@ NIP DUP 1+ DROPB NEGATE charsLeft +!
\ charsLeft @ CR ." {" .
wordsEntered 1+!
charsLeft @ 0< ONTRUE BACK
1 wordsEntered !
charsInLine @ OVER - \ DUP . ." ^^" 
charsLeft !        TRACKING

-1 wordsEntered +!

charsLeft @ OVER + 1+ wordsEntered @ 1- \ CR 2DUP . .
DUP IF
/MOD TUCK + SWAP \ ." :" 2DUP . . 
ELSE 2DROP 0. THEN 2DROPB

wordsEntered @ DROPB
TAKE-THREE <*>
0. 2DROPB 1000000 DROPB TAKE-THREE <* \ добавл€ем elem в массив дл€ не успевшей обработатьс€ строки
}arr
\ 2DUP DUMP EXIT
DROP

LOCAL runner \ бегунок
runner !

concat{ BL byChar split notEmpty DUP STR@
*> <*>
-1 runner @ wordsInLine +! BACK
runner @ wordsInLine @
0= IF elem runner +! THEN  TRACKING

START{ PRO

runner @ wordsInLine @ 1 = IF
runner @ lastSpace @       ELSE
runner @ spacesBetween @   THEN

runner @ wordsInLine @ IF
-1 ?DO S"  " CONT LOOP ELSE
DROP BACK \ S" |" CONT
LT LTL @ CONT TRACKING THEN

}EMERGE <* }concat
DUP STR@ *> <*> LT LTL @ <* }concat DUP STR@ CONT ;

/TEST

$> S" A large flying craft moved swiftly across the surface of an astoundingly beautiful sea." 11 format-text CR TYPE

CR CR .( Input from 'in.txt'. Press any key) KEY DROP 
$> S" in.txt" FILE 24 format-text TYPE