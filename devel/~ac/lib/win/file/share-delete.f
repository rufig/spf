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
