\ поиск файлов по шаблону и выполнение групповых действий
\ над файлами

REQUIRE { ~ac/lib/locals.f

WINAPI: FindFirstFileA       KERNEL32.DLL
WINAPI: FindNextFileA        KERNEL32.DLL
WINAPI: FindClose            KERNEL32.DLL

16 CONSTANT FILE_ATTRIBUTE_DIRECTORY

  0
  4 -- dwFileAttributes
  8 -- ftCreationTime
  8 -- ftLastAccessTime
  8 -- ftLastWriteTime
  4 -- nFileSizeHigh
  4 -- nFileSizeLow
  4 -- dwReserved0
  4 -- dwReserved1
256 -- cFileName          \ [ MAX_PATH ]
 14 -- cAlternateFileName \ [ 14 ]
100 + CONSTANT /WIN32_FIND_DATA

: FIND-FILES ( addr u xt -- )
\ addr u - имя искомого файла или шаблон
\ xt ( addr u -- ) - процедура вызываемая для каждого файла
  { addr u xt \ data id }

  0 addr u + C!
  /WIN32_FIND_DATA ALLOCATE THROW -> data
  data /WIN32_FIND_DATA ERASE
  data addr FindFirstFileA -> id
  id -1 = IF data FREE DROP EXIT THEN
  data cFileName ASCIIZ> xt EXECUTE
  BEGIN
    data id FindNextFileA
  WHILE
    data cFileName ASCIIZ> xt EXECUTE
  REPEAT
  id FindClose DROP
  data FREE DROP
;

\ : TT TYPE CR ;
\ : T S" d:\cherezov\news\*.*" ['] TT FIND-FILES ;
