\ открытие файла в таком режиме позволяет переименовывать
\ и даже удалять этот открытый файл. Реальное удаление
\ произойдет после закрытия всех хэндлов.

: OPEN-FILE-SHARED-DELETE ( c-addr u fam -- fileid ior )
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  OPEN_EXISTING
  SA ( secur )
  7 ( share read/write/delete )  
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
: CREATE-FILE-SHARED-DELETE ( c-addr u fam -- fileid ior )
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  CREATE_ALWAYS
  SA ( secur )
  7 ( share )  
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
