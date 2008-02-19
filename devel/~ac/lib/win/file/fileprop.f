( Получение WIN32_FIND_DATA для заданного файла или каталога.

  Filetime.f для получения времени модификации файла требует хэндл
  файла, что "дорого" и исключает возможность работы с каталогами.
  Данная библиотека устраняет неудобство - позволяет достать filetime
  и для каталогов, равно как и для файлов, без их открытия. А функции
  конвертации дат/времен подойдут из filetime.f, cм. примеры ниже.

)

REQUIRE ftLastWriteTime ~ac/lib/win/file/findfile-r.f 

: FOR-FILE1-PROPS ( addr u xt -- )

\ addr u - имя файла или каталога
\ xt ( addr u data -- ) - процедура вызываемая для 
\                         обработки данных файла/каталога
\ Обрабатывается только один файл, явно заданный по addr u.

  NIP SWAP
  /WIN32_FIND_DATA RALLOT >R
  R@ SWAP FindFirstFileA ( xt id )
  DUP -1 = IF 2DROP ELSE FindClose DROP ( xt )
  R@ cFileName ASCIIZ> ( xt a u ) ROT R@ SWAP EXECUTE
  THEN RDROP
  /WIN32_FIND_DATA RFREE
; 
: (GET-FILETIME-WRITE-S) ( 0 0 addr u data -- filetime )
  ftLastWriteTime 2@ SWAP 2>R
  2DROP 2DROP ( убрали addr u и 0 0 )
  2R>
;
: GET-FILETIME-WRITE-S  ( addr u -- filetime ) \ UTC
  0 0 2SWAP ['] (GET-FILETIME-WRITE-S) FOR-FILE1-PROPS
;

\EOF
filetime.f
S" ." GET-FILETIME-WRITE-S UTC>LOCAL FILETIME>TIME&DATE . . . . . . CR
S" fileprop.f" GET-FILETIME-WRITE-S UTC>LOCAL FILETIME>TIME&DATE . . . . . . CR
S" fileprop.f" R/O OPEN-FILE-SHARED THROW GET-FILETIME-WRITE UTC>LOCAL FILETIME>TIME&DATE . . . . . . CR
