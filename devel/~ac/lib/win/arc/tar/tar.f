\ $Id$ ~ac
\ Чтение файлов формата TAR, извлечение файлов из TAR-архивов.

REQUIRE UNIXTIME>FILETIME  ~ac/lib/win/date/unixtime.f 
REQUIRE FILETIME>TIME&DATE ~ac/lib/win/file/filetime.f 
REQUIRE CREATE-FILE-PATH   ~ac/lib/win/file/utils.f 

  0
100 -- tar.FileName
  8 -- tar.FileMode
  8 -- tar.OwnerID
  8 -- tar.GroupID
 12 -- tar.FileSize
 12 -- tar.LastModTime \ in numeric Unix time format
  8 -- tar.HdrChecksum
  1 -- tar.FileType
100 -- tar.LinkName
DROP 512 CONSTANT /TarHeader

USER-CREATE TARHDR /TarHeader USER-ALLOT

: TarGetFileSize
  BASE @ >R 8 BASE ! SOURCE EVALUATE R> BASE !
;
: TarGetModTime
  BASE @ >R 8 BASE ! SOURCE EVALUATE R> BASE !
;
: ListTarFile ( addr u -- )
\ Показать список файлов, содержащихся в TAR-архиве в файле с именем addr u.
( просто чтобы убедиться, что наша читалка справляется с этим конкретно файлом :)

  R/O OPEN-FILE THROW >R
  BEGIN
    TARHDR /TarHeader R@ READ-FILE THROW /TarHeader =
    IF TARHDR tar.FileName ASCIIZ> NIP ELSE FALSE THEN
  WHILE
    R@
    TARHDR tar.FileType C@ EMIT SPACE
    TARHDR tar.FileName ASCIIZ> TYPE SPACE
\    TARHDR tar.FileMode 8 DUMP CR
\    TARHDR tar.OwnerID 8 DUMP CR
\    TARHDR tar.GroupID 8 DUMP CR
    TARHDR tar.FileSize ." size=" 12 ['] TarGetFileSize EVALUATE-WITH DUP . >R
    TARHDR tar.LastModTime ." mod-time=" 12 ['] TarGetModTime EVALUATE-WITH
UNIXTIME>FILETIME ( 2DUP UTC>LOCAL  FILETIME>TIME&DATE . . . . . .) FILETIME-DD.MM.YYYY-HH:MM:SS TYPE
 \ UTimeStr TYPE SPACE
\    TARHDR tar.HdrChecksum 8 DUMP CR
\    TARHDR tar.LinkName ASCIIZ> TYPE CR
    R> 511 + 512 /
    0 ?DO DUP PAD 512 ROT READ-FILE THROW DROP LOOP DROP
    CR
  REPEAT
  R> CLOSE-FILE THROW
;

: ListTarMem { addr u \ size -- }
  BEGIN
    /TarHeader u <
    IF addr tar.FileName ASCIIZ> NIP ELSE FALSE THEN
  WHILE
    addr tar.FileType C@ EMIT SPACE
    addr tar.FileName ASCIIZ> TYPE SPACE
    addr tar.FileSize ." size=" 12 ['] TarGetFileSize EVALUATE-WITH DUP . -> size
    addr tar.LastModTime ." mod-time=" 12 ['] TarGetModTime EVALUATE-WITH
    UNIXTIME>FILETIME FILETIME-DD.MM.YYYY-HH:MM:SS TYPE
    addr /TarHeader + -> addr
    size 511 + 512 / 512 * u OVER - -> u addr + -> addr
    CR
  REPEAT
;
WINAPI: SetFileTime KERNEL32.DLL

: ExtractTarMemTo { addr u dira diru \ size h ft1 ft2 -- }
\ Извлечь файлы из области памяти addr u (в TAR-формате)
\ в каталог dira diru.
  BEGIN
    /TarHeader u <
    IF addr tar.FileName ASCIIZ> NIP ELSE FALSE THEN
  WHILE
    addr tar.FileType C@
    0=
    IF
      addr tar.FileName ASCIIZ> 2DUP TYPE SPACE
      dira diru " {s}/{s}" STR@
      R/W CREATE-FILE-PATH THROW -> h
      addr tar.FileSize ." size=" 12 ['] TarGetFileSize EVALUATE-WITH DUP . -> size
      addr tar.LastModTime ." mod-time=" 12 ['] TarGetModTime EVALUATE-WITH
      UNIXTIME>FILETIME 2DUP -> ft1 -> ft2 FILETIME-DD.MM.YYYY-HH:MM:SS TYPE
      addr /TarHeader + -> addr  u 512 - -> u
      addr size h WRITE-FILE THROW
      ft1 ft2 SP@ DUP DUP h SetFileTime DROP 2DROP
      h CLOSE-FILE THROW
      size 511 + 512 / 512 * u OVER - -> u addr + -> addr
      CR
    ELSE addr /TarHeader + -> addr  u 512 - -> u THEN
  REPEAT
;

\ REQUIRE ReadPng ~ac/lib/lin/zlib/png.f
\ S" spf4.tar.png" ReadPng S" test" ExtractTarMemTo
