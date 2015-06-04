\ Dec.2006 ruvim@forth.org.ru
\ $Id$
( Исправление ошибки SPF4, связанной с неверной трансляцией текста из пайпов.
  Испытание реализации буферезированного чтения входного потока минуя READ-LINE
  [обсуждалось еще в 2000-ом :]

  Дает убыстрение загрузки 8-13% для кэшированных системой файлов
  [последнее при включенном QuickSWL]

  Побочный эффект - после REFILL позиция чтения файла не обязательно будет 
  в точности указывать не следующую строку.  Это несовместимо с программами, 
  которые читают из входного потока бинарные данные в перемешку со строками текста.

  Для прозрачного чтения бинарных данных из входного потока 
  здесь определено слово READOUT-SOURCE [ addr u1 -- addr u2 ]

  Поддерживает 0A в качестве разделителя строки, когда 0D0A не найден.

  Данная реализация несовместима с редко используемым механизмом SAVE-INPUT [который в core-ext.f]

  Есть маленькое отличие в поведении ACCEPT - оно затирает PARSE-AREA когда SOURCE-ID нулевой.
)

REQUIRE REPLACE-WORD lib/ext/patch.f
REQUIRE SPLIT- ~pinka/samples/2005/lib/split.f
REQUIRE UNBROKEN ~pinka/samples/2005/lib/split-white.f

REQUIRE Included ~pinka/lib/ext/requ.f

REQUIRE READOUT-FILE ~pinka/lib/files-ext.f

: LINE-TERM ( -- addr u )
  LT LTL @
;

: SPLIT-LINE ( a u -- a1 u1 a2 u2 true | a u false )
  LINE-TERM SPLIT DUP IF EXIT THEN DROP
  LINE-TERM 2 CHARS <> IF DROP FALSE EXIT THEN
  CHAR+ 1 CHARS SPLIT \ support of 0x0A as line terminator
;

WARNING @  WARNING 0!

S" fix-accept.f" Included

S" fix-receive.f" Included

WARNING !