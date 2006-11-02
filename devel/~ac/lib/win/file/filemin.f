\ FILEMIN ( addr u -- n ) возвращает число минут, прошедших с момента 
\ последней записи в файл. Для свежесозданного - 0. Для несуществующего = -1.

REQUIRE FIND-FILES-R       ~ac/lib/win/file/findfile.f 
REQUIRE FILETIME>TIME&DATE ~ac/lib/win/file/filetime.f 

WINAPI: GetFileAttributesExA KERNEL32.DLL

600000000 CONSTANT nMINUTES

: FILEMIN  { addr u \ data id -- n }

  0 addr u + C!
  /WIN32_FIND_DATA ALLOCATE THROW -> data
  data /WIN32_FIND_DATA ERASE
  data 0 addr GetFileAttributesExA
  IF
    data ftLastWriteTime 2@ SWAP
    data FREE DROP
    UTC>LOCAL NOW-FILETIME D- DNEGATE nMINUTES UM/MOD NIP
  ELSE
    data FREE DROP
    -1
  THEN
;
\ S" C:\spf4\devel\~ac\lib\win\file\filemin.f" FILEMIN .

