( Парсер строки с исходным текстом программы на Форте.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Сентябрь 1999: PARSE и SKIP преобразованы из CODE
  в высокоуровневые определения. Переменные преобразованы в USER.
)

USER #TIB ( -- a-addr ) \ 94 CORE EXT
\ a-addr - адрес ячейки, содержащей число символов в буфере TIB.

USER >IN ( -- a-addr ) \ 94
\ a-addr - адрес ячейки, содержащей смещение очередной литеры во входном
\ текстовом буфере.

512  VALUE  C/L \ максимальный размер строки, которую можно ввести в TIB

USER-VALUE  TIB ( -- c-addr ) \ 94 CORE EXT
\ Адрес терминального входного буфера.

USER-CREATE ATIB
\ исходное значение TIB
1024 TC-USER-ALLOT

: SOURCE ( -- c-addr u ) \ 94
\ c-addr - адрес входного буфера. u - количество символов в нем.
  TIB #TIB @
;

: EndOfChunk ( -- flag )
  >IN @ SOURCE NIP < 0=        \ >IN не меньше, чем длина чанка
;

: CharAddr ( -- c-addr )
  SOURCE DROP >IN @ +
;

: PeekChar ( -- char )
  CharAddr C@       \ символ из текущего значения >IN
;

: IsDelimiter ( char -- flag )
  BL 1+ <
;

: GetChar ( -- char flag )
  EndOfChunk
  IF 0 FALSE
  ELSE PeekChar TRUE THEN
;

: OnDelimiter ( -- flag )
  GetChar SWAP IsDelimiter AND
;

: SkipDelimiters ( -- ) \ пропустить пробельные символы
  BEGIN
    OnDelimiter
  WHILE
    >IN 1+!
  REPEAT
;

: OnNotDelimiter ( -- flag )
  GetChar SWAP IsDelimiter 0= AND
;

: SkipWord ( -- ) \ пропустить непробельные символы
  BEGIN
    OnNotDelimiter
  WHILE
    >IN 1+!
  REPEAT
;
: SkipUpTo ( char -- ) \ пропустить до символа char
  BEGIN
    DUP GetChar >R <> R> AND
  WHILE
    >IN 1+!
  REPEAT DROP
;

: ParseWord ( -- c-addr u )
  CharAddr >IN @
  SkipWord
  >IN @ SWAP -
;

: NextWord ( -- c-addr u )
  \ это слово теперь будем использовать в INTERPRET
  \ - удобнее: не использует WORD и, соответственно, не мусорит в HERE;
  \ и разделителями считает все что <=BL, в том числе TAB и CRLF
  SkipDelimiters ParseWord
\  >IN 1+! \ пропустили разделитель за словом
  >IN @ 1+ #TIB @ MIN >IN !   \ для совместимости с spf3.16
;

: PARSE ( char "ccc<char>" -- c-addr u ) \ 94 CORE EXT
\ Выделить ccc, ограниченное символом char.
\ c-addr - адрес (внутри входного буфера), и u - длина выделенной строки.
\ Если разбираемая область была пуста, результирующая строка имеет нулевую
\ длину.
  CharAddr >IN @
  ROT SkipUpTo
  >IN @ SWAP -
  >IN 1+!
;

: SKIP ( char "ccc<char>" -- )
\ Пропустить разделители char.
  BEGIN
    DUP GetChar >R = R> AND
  WHILE
    >IN 1+!
  REPEAT DROP
;

\ PARSE и SKIP оставлены для совместимости, больше не используются
\ при трансляции исходного текста
