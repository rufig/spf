REQUIRE состояние ~profit/lib/chartable.f
REQUIRE взять-параметр ~profit/lib/parsecommand.f
REQUIRE FILE ~ac/lib/str5.f
REQUIRE 2VARIABLE lib/include/double.f
S" lib/include/ansi-file.f" INCLUDED

состояние сплющивать-переводы

все: символ EMIT ;
перевод-строки: 13 EMIT CR ;

: сплющить-переводы ( addr u -- )
FILE SWAP поставить-курсор
сплющивать-переводы
-символов-обработать ;

VARIABLE задано-параметров
2VARIABLE входной-файл

:NONAME
11 .
начать-обрабатывать-командную-строку
22 .
задано-параметров 0!
33 .
BEGIN
35 .
взять-параметр ( addr u )
2DUP CR TYPE CR
44 .
задано-параметров @ 0= IF
41 .
входной-файл 2!
ELSE
42 .
задано-параметров @ 1 = IF
2DUP ." [" TYPE CR
W/O CREATE-FILE-SHARED THROW TO H-STDLOG

входной-файл 2@  сплющить-переводы
ELSE 43 . 2DROP THEN THEN

45 .
задано-параметров 1+!
55 .
отсюда C@ 0=
UNTIL 66 .
BYE ;
MAINX !  0 TO SPF-INIT?  FALSE TO ?GUI  S" c:\DDA.exe" SAVE \ BYE