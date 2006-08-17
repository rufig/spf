\ Ядро Deleter-а

S" ~ac/lib/win/file/findfile.f" INCLUDED
REQUIRE DATE&TIME lib/include/facil.f
REQUIRE WTHROW lib/win/winerr.f

CREATE FileName 256 ALLOT
\ имя файла

0 VALUE PathU
0 VALUE PathAddr
\ путь к файлу

: +Path ( addr u -- )
\ добавление пути PathAddr PathU к имени файла addr u
\ в качестве буфера используется FileName
  SWAP OVER
  PathAddr FileName PathU MOVE
  FileName PathU + SWAP MOVE
  PathU +
  FileName SWAP
  2DUP + 0 SWAP C!
;

: AllFiles ( -- addr u )
\ маска "все файлы" в каталоге PathAddr PathU
  S" *.*" +Path
;

: ._or_.. ( addr u -- f )
\ возвращает TRUE, если строка addr u равна "." или ".."
  2DUP S" ." COMPARE IF
    S" .." COMPARE IF
      FALSE
    ELSE
      TRUE
    THEN
  ELSE
    2DROP
    TRUE
  THEN
;

: Delete ( addr u -- )
\ удалить файл addr u в каталоге PathAddr PathU
  2DUP ._or_.. IF
    2DROP
  ELSE
    +Path
    DELETE-FILE DROP
  THEN
;

: DeleteFromDir ( addr u -- )
\ удалить файлы из каталога addr u
  TO PathU TO PathAddr
  AllFiles ['] Delete FIND-FILES
;

: Append ( addr u -- id )
\ открыть файл addr u на добавление
  R/W OPEN-FILE THROW
  DUP >R FILE-SIZE THROW ( ud )
  R@ REPOSITION-FILE THROW
  R>
;

1024 CONSTANT /CopyBuffer
CREATE CopyBuffer /CopyBuffer ALLOT
\ буфер копирования

: Copy ( f1 f2 -- )
\ копировать файл f1 в файл f2
  BEGIN
    OVER CopyBuffer /CopyBuffer ROT READ-FILE THROW
    ?DUP
  WHILE
    ( f1 f2 u )
    OVER CopyBuffer ROT ROT WRITE-FILE THROW
  REPEAT
  2DROP
;

: Open ( addr u -- h )
\ открыть файл на чтение
  R/O OPEN-FILE THROW
;

: .. 2 .0 ;
: :: ." :" ;
: // ." /" ;
\ просто красивые слова ;)

WINAPI: GetFileTime kernel32.dll
WINAPI: FileTimeToLocalFileTime kernel32.dll
WINAPI: FileTimeToSystemTime kernel32.dll

CREATE FileTime 2 CELLS ALLOT
CREATE LocalFileTime 2 CELLS ALLOT

: FileCreatedAt ( h -- sec min hr day mt year )
  0 SWAP 0 SWAP FileTime SWAP GetFileTime WTHROW DROP
  LocalFileTime FileTime FileTimeToLocalFileTime WTHROW DROP
  SYSTEMTIME LocalFileTime FileTimeToSystemTime WTHROW DROP
  SYSTEMTIME wSecond W@
  SYSTEMTIME wMinute W@
  SYSTEMTIME wHour W@
  SYSTEMTIME wDay W@
  SYSTEMTIME wMonth W@
  SYSTEMTIME wYear W@
;

: PrintHeader ( h -- )
\ вывод заголовка перед каждым файлом в H-STDOUT
  CR
  80 0 DO ." =" LOOP CR
  FileCreatedAt ( sec min hr day mt year )
  ROT ROT SWAP
  .. // .. // .. SPACE .. :: .. :: .. CR
;

: ArchTo ( addr1 u1 addr2 u2 -- )
\ дописывание файла addr1 u1 в файл addr2 u2 с удалением источника
\ второй файл должен существовать
  2OVER 2SWAP
  Append
  ROT ROT ( f2 addr1 addr1 )
  Open
  SWAP ( f1 f2 )
  H-STDOUT >R
    DUP TO H-STDOUT
    OVER PrintHeader
  R> TO H-STDOUT
  2DUP Copy
  CLOSE-FILE THROW
  CLOSE-FILE THROW
  DELETE-FILE THROW
;

0 VALUE LogAddr
0 VALUE LogU
\ Имя файла, в который будут сбрасываться байлы из каталога

: ArchToLog ( addr u -- )
\ добавление файла addr u в лог
  2DUP ._or_.. IF
    2DROP
  ELSE
    +Path LogAddr LogU ArchTo
  THEN
;

: Arch ( addr u addr-l u-l -- )
\ сброс файлов из директории addr u в файл addr-l u-l
\ файл-приёмник должен существовать
  TO LogU TO LogAddr
  TO PathU TO PathAddr
  AllFiles ['] ArchToLog FIND-FILES
;
