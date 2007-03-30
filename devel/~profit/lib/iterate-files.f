REQUIRE /TEST ~profit/lib/testing.f
REQUIRE FIND-FILES-R ~ac/lib/win/file/findfile-r.f
REQUIRE B! ~profit/lib/bac4th.f

\ Итератор по файлам в папке указанной addr u , максимальная глубина -- depth
: ITERATE-FILES ( addr u depth --> addr1 u1 data flag \ <-- ) R> SWAP FIND-FILES-DEPTH B!  FIND-FILES-R ;
\ При каждой итерации выдаёт:
\ addr u - путь и имя файла или каталога (готово для open-file, etc)
\ flag=true, если каталог, false если файл
\ data - адрес структуры с данными о файле или каталоге
\ поля структуры описаны в ~ac/lib/win/file/findfile.f:
\  0
\  4 -- dwFileAttributes
\  8 -- ftCreationTime
\  8 -- ftLastAccessTime
\  8 -- ftLastWriteTime
\  4 -- nFileSizeHigh
\  4 -- nFileSizeLow
\  4 -- dwReserved0
\  4 -- dwReserved1
\ 256 -- cFileName          \ [ MAX_PATH ]
\  14 -- cAlternateFileName \ [ 14 ]
\ 100 + CONSTANT /WIN32_FIND_DATA

\ После каждой итерации строка addr и структура data освобождаются,
\ поэтому, если эти данные нужно сохранять, их надо копировать.
\ Обратите также внимание на стек: четыре значения от итератора нужно
\ поглотить самому



\ Аналогичное ITERATE-FILES слово, но оно выдаёт только папки 
\ в addr u с заданной глубиной depth. В отличии от ITERATE-FILES 
\ выдаёт три значения вместо четырёх, так как flag при каждой итерации
\ должен быть равен true
: ITERATE-DIRS ( addr u depth --> addr1 u1 data \ <--  ) PRO ITERATE-FILES ONTRUE CONT ;
\ Можно было использовать и готовый FIND-DIRS-R из ~ac/lib/win/file/findfile-r.f ...

/TEST
: allFilesInC S" c:" 1 ITERATE-FILES ( addr u data flag --> \ <-- ) 2DROP CR TYPE ;
allFilesInC