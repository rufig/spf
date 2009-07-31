( Просто чтобы не забыть об еще одной россыпи несметного числа утилит...
  http://library.gnome.org/devel/glib/stable/
)

REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE STR@          ~ac/lib/str5.f

ALSO SO NEW: libglib-2.0-0.dll

:NONAME ( data1 data2 -- res )
  2DUP
  SWAP 50 SWAP 50 COMPARE
; 2 CELLS CALLBACK: GCompareFunc

:NONAME ( data1 data2 -- res )
  2DUP
  ASCIIZ> ROT ASCIIZ> COMPARE
; 2 CELLS CALLBACK: GCompareFuncAsc

:NONAME ( data value key -- flag )
  2DUP
  ASCIIZ> TYPE ." =" ASCIIZ> TYPE CR
  FALSE
; 3 CELLS CALLBACK: GTraverseFunc

: TEST { \ gh key str ch ior line len ar tr }

\ хэш-таблицы
  0 0 2 g_hash_table_new -> gh
  " key1" -> key \ там не строковый хэш, а просто пары чисел
  " value1" key gh 3 g_hash_table_insert DROP \ void
  " value2" 555 gh 3 g_hash_table_insert DROP \ void
  555 gh 2 g_hash_table_lookup STYPE CR
  key gh 2 g_hash_table_lookup STYPE CR

\ динамические строки
  S" string1" SWAP 2 g_string_new_len -> str
  [CHAR] _ str 2 g_string_append_c -> str
  S" string2" SWAP str 3 g_string_append_len -> str
  S" string0" SWAP str 3 g_string_prepend_len -> str
  [CHAR] _ 7 str 3 g_string_insert_c -> str
  777 S" _%d!" DROP str 3 g_string_append_printf DROP \ void
  str @ str CELL+ @ TYPE CR

\ каналы (файлы, сокеты, windows-сообщения)
  ^ ior S" r" DROP S" glib.f" DROP 3 g_io_channel_new_file -> ch
  ^ ior S" CP1251" DROP ch 3 g_io_channel_set_encoding DROP
  \ по умолчанию входной файл имеет кодировку UTF-8,
  \ и чтение дает ошибку, если не указать правильную
  ^ ior 0 ^ len ^ line ch 5 g_io_channel_read_line
  IF line len TYPE THEN \ строка преобразуется в UTF-8!

\ динамические массивы
  5 0 1 3 g_array_new -> ar \ элементы размером 5 байт
  1 S" 12345" DROP ar 3 g_array_append_vals -> ar
  1 S" abcde" DROP ar 3 g_array_append_vals -> ar
  1 S" 06789" DROP ar 3 g_array_append_vals -> ar
  ar @ ar CELL+ @ DUMP
  ['] GCompareFunc ar 2 g_array_sort DROP
  ar @ ar CELL+ @ DUMP
  1 ar 2 g_array_remove_index -> ar
  ar @ ar CELL+ @ DUMP

\ двоичные деревья
  ['] GCompareFuncAsc 1 g_tree_new -> tr \ считаем ключи строками
\ в отличие от хэш-таблиц, здесь ключи и значения копируются (?)
  tr 1 g_tree_nnodes CR .
  S" value1" DROP S" key1" DROP tr 3 g_tree_insert DROP \ void
  S" value2" DROP S" key1" DROP tr 3 g_tree_insert DROP \ под тем же ключом
  S" value3" DROP S" key3" DROP tr 3 g_tree_insert DROP
  S" value0" DROP S" key0" DROP tr 3 g_tree_insert DROP
  tr 1 g_tree_nnodes .
  S" key1" DROP tr 2 g_tree_lookup ASCIIZ> TYPE CR
  0 ['] GTraverseFunc tr 3 g_tree_foreach DROP
;

' glib_major_version >BODY CELL+ @ @ .
' glib_minor_version >BODY CELL+ @ @ . CR
TEST
