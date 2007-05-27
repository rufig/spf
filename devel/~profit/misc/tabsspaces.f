\   конкурсу решени€ задач на форте (http://fforum.winglion.ru/viewtopic.php?p=7587#7587)

\ «амена табул€торов на пробелы
\ ѕервый пример (см. после слова /TEST ) -- просто строка
\ ¬торой -- требует наличи€ текстового файла in.txt с текстом


\ ƒл€ запуска нужен дистрибутив SPF:
\ http://sourceforge.net/project/showfiles.php?group_id=17919

\ » апрельское обновление:
\ http://sourceforge.net/project/shownotes.php?release_id=497972&group_id=17919

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE HEAP-COPY ~ac/lib/ns/heap-copy.f
REQUIRE FILE ~ac/lib/str5.f
REQUIRE split ~profit/lib/bac4th-str.f
REQUIRE LOCAL ~profit/lib/static.f

: COPY-ARR ( addr1 u1 -- addr2 u2 ) DUP >R HEAP-COPY R> ; 


: tabs>spaces ( addr1 u1 n -- addr2 u2 )
LOCAL tabs tabs !
LOCAL res-addr
LOCAL res-len

START{
concat{ byRows split notEmpty DUP STR@ \ режем строку по переводам строки
concat{ 9 byChar split \ режем строку по табул€торам
*> <*> \ оператор "вилка" -- сначала подаЄт одну строку отрезанную по табул€торам
\ а потом подаЄт строку составленную из пробелов нужных дл€ доведени€ до позиции табул€ции
concat{ \ цикл конкатенации нужного кол-ва пробелов
START{ PRO DUP STR@ NIP \ длина только что данной строки отрезанной по табул€торам
tabs @ MOD tabs @ SWAP - \ определ€ем нужное кол-во пробелов
0 ?DO S"  " CONT LOOP }EMERGE \ генерируем пробелы столько-то раз
}concat \ все пробелы слили в одну строку
<* DUP STR@ ( addr u ) }concat DUP STR@ \ обработали одну строку: сцепили все куски: отрезок-пробелы-отрезок-пробелы-...
\ и снова вилка: сначала подаЄм строку, потом -- перевод строки
*> <*> LT LTL @ <* }concat DUP STR@ \ сцепл€ем всЄ вместе
COPY-ARR res-len ! res-addr ! }EMERGE \ копируем в кучу
\  онструкци€ concat{  }concat по окончании работы убирает лишние отрезки пам€ти, поэтому копировать нужно €вно
res-addr @ res-len @ ;

\ »значальный код без комментариев:
\ : tabs>spaces ( addr1 u1 n -- addr2 u2 )
\ LOCAL tabs tabs !
\ LOCAL res-addr
\ LOCAL res-len

\ START{
\ concat{ byRows split notEmpty DUP STR@
\ concat{ 9 byChar split
\ *> <*>
\ concat{ START{ PRO DUP STR@ NIP tabs @ MOD tabs @ SWAP - 0 ?DO S"  " CONT LOOP }EMERGE }concat
\ <* DUP STR@ ( addr u ) }concat DUP STR@ *> <*> LT LTL @ <* }concat DUP STR@
\ COPY-ARR res-len ! res-addr ! }EMERGE
\ res-addr @ res-len @ ;

/TEST
" 	ab	beac	core d
	def	eres	f"
STR@ 7 tabs>spaces TYPE

CR CR

S" in.txt" FILE 7 tabs>spaces TYPE