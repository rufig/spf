( Windows-константы, необходимые при в/в.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  –евизи€ - сент€брь 1999
)

HEX

  40 CONSTANT PAGE_EXECUTE_READWRITE
1000 CONSTANT MEM_COMMIT
2000 CONSTANT MEM_RESERVE
  -1 CONSTANT INVALID_HANDLE_VALUE
  20 CONSTANT FILE_ATTRIBUTE_ARCHIVE
   2 CONSTANT CREATE_ALWAYS
   3 CONSTANT OPEN_EXISTING
   0 CONSTANT FILE_BEGIN
   1 CONSTANT FILE_CURRENT

80000000 CONSTANT R/O ( -- fam ) \ 94 FILE
\ fam - определенное реализацией значение дл€ выбора метода доступа
\ к файлу "только дл€ чтени€"

40000000 CONSTANT W/O ( -- fam ) \ 94 FILE
\ fam - определенное реализацией значение дл€ выбора метода доступа
\ к файлу "только дл€ записи"

C0000000 CONSTANT R/W ( -- fam ) \ 94 FILE
\ fam - определенное реализацией значение дл€ выбора метода доступа
\ к файлу "чтение/запись"

DECIMAL