\ открытие файла в таком режиме позволяет переименовывать
\ и даже удалять этот открытый файл. Реальное удаление
\ произойдет после закрытия всех хэндлов.
\ работает только в WinNT*

REQUIRE WinNT? ~ac/lib/win/winver.f

: OPEN-FILE-SHARED-DELETE ( c-addr u fam -- fileid ior )
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  OPEN_EXISTING
  SA ( secur )
  WinNT? IF 7 ( share read/write/delete ) ELSE 3 THEN
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
: CREATE-FILE-SHARED-DELETE ( c-addr u fam -- fileid ior )
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  CREATE_ALWAYS
  SA ( secur )
  WinNT? IF 7 ( share read/write/delete ) ELSE 3 THEN
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;

0x04000000 CONSTANT FILE_FLAG_DELETE_ON_CLOSE

: CREATE-FILE-SHARED-DELETE-ON-CLOSE ( c-addr u fam -- fileid ior )
\ В отличие от предыдущей функции здесь не просто разрешается
\ удаление открытого файла, но и указывается на необходимость его
\ автоматического удаления при закрытии всех его хэндлов.
\ Это похоже на CREATE-FILE-SHARED-DELETE+(сразу)DELETE-FILE при
\ создании файла-флага, но позволяет работать с этим смертником (читать-писать).

  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
    FILE_FLAG_DELETE_ON_CLOSE OR
  CREATE_ALWAYS
  SA ( secur )
  WinNT? IF 7 ( share read/write/delete ) ELSE 3 THEN
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
