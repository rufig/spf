( Получение WIN32_FIND_DATA для заданного файла или каталога.

  Filetime.f для получения времени модификации файла требует хэндл
  файла, что "дорого" и исключает возможность работы с каталогами.
  Данная библиотека устраняет неудобство - позволяет достать filetime
  и для каталогов, равно как и для файлов, без их открытия. А функции
  конвертации дат/времен подойдут из filetime.f, cм. примеры ниже.

)

REQUIRE ftLastWriteTime ~ac/lib/win/file/findfile-r.f 

: GET-FILE-PROPS ( addr u xt -- )

\ addr u - имя файла или каталога
\ xt ( addr u data -- ) - процедура вызываемая для 
\                         обработки данных файла/каталога
\ Обрабатывается только один файл, явно заданный по addr u.

  { addr u xt \ data id }
  /WIN32_FIND_DATA ALLOCATE THROW -> data
  data /WIN32_FIND_DATA ERASE
  data addr FindFirstFileA -> id
  id -1 = IF data FREE DROP EXIT THEN
  data cFileName ASCIIZ>
  data xt EXECUTE
  id FindClose DROP
  data FREE DROP
;
: (GET-FILETIME-WRITE-S) ( 0 0 addr u data -- filetime )
  ftLastWriteTime 2@ SWAP 2>R
  2DROP 2DROP ( убрали addr u и 0 0 )
  2R>
;
: GET-FILETIME-WRITE-S  ( addr u -- filetime ) \ UTC
  0 0 2SWAP ['] (GET-FILETIME-WRITE-S) GET-FILE-PROPS
;

\EOF
filetime.f
S" ." GET-FILETIME-WRITE-S UTC>LOCAL FILETIME>TIME&DATE . . . . . . CR
S" fileprop.f" GET-FILETIME-WRITE-S UTC>LOCAL FILETIME>TIME&DATE . . . . . . CR
S" fileprop.f" R/O OPEN-FILE-SHARED THROW GET-FILETIME-WRITE UTC>LOCAL FILETIME>TIME&DATE . . . . . . CR
