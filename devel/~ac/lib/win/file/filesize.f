REQUIRE FIND-FILES       ~ac/lib/win/file/findfile.f

: FILE-SIZEA { addr u \ data id -- ud ior }
\ ud - размер в символах файла, идентифицируемом именем addr u.
\ ior - определенный реализацией код результата ввода/вывода.
\ Эта операция не влияет на значение, возвращаемое FILE-POSITION.
\ ud неопределен, если ior не ноль.

  0 addr u + C!
  /WIN32_FIND_DATA ALLOCATE THROW -> data
  data /WIN32_FIND_DATA ERASE
  data addr FindFirstFileA -> id
  id -1 = IF data FREE DROP 0 0 GetLastError EXIT THEN
  data nFileSizeLow @ data nFileSizeHigh @ 0
  id FindClose DROP
  data FREE DROP
;
: FILENAME-SIZE ( addr u -- ud )
  FILE-SIZEA THROW
;