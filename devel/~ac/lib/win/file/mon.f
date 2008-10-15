\ Win2000 и выше

REQUIRE UNICODE> ~ac/lib/win/com/com.f 

WINAPI: ReadDirectoryChangesW KERNEL32.DLL

1 CONSTANT FILE_LIST_DIRECTORY \ = FILE_READ_DATA
0x02000000 CONSTANT FILE_FLAG_BACKUP_SEMANTICS

\ actions
0x00000001 CONSTANT FILE_ACTION_ADDED \ The file was added to the directory.
0x00000002 CONSTANT FILE_ACTION_REMOVED \ The file was removed from the directory.
0x00000003 CONSTANT FILE_ACTION_MODIFIED \ The file was modified. This can be a change in the time stamp or attributes.
0x00000004 CONSTANT FILE_ACTION_RENAMED_OLD_NAME \ The file was renamed and this is the old name.
0x00000005 CONSTANT FILE_ACTION_RENAMED_NEW_NAME \ The file was renamed and this is the new name.

: OPEN-DIR ( c-addr u fam -- fileid ior ) \ 94 FILE
\ Открыть каталог с именем, заданным строкой c-addr u, с методом доступа fam.
\ Смысл значения fam определен реализацией.
\ Если каталог успешно открыт, ior ноль, fileid его идентификатор.
\ Иначе ior - определенный реализацией код результата ввода/вывода,
\ и fileid неопределен.
  NIP SWAP >R >R
  0 FILE_FLAG_BACKUP_SEMANTICS ( template attrs )
  OPEN_EXISTING
  SA ( secur )
  3 ( share )  
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;

USER lpBytesReturned
: PrintDirChanges ( addr -- )
  CR lpBytesReturned @ DUP . 0= IF ." ==Overflow!!!!!!!!!!!!!!!==" THEN
  BEGIN
    DUP CELL+ @ .
    DUP CELL+ CELL+ CELL+
    OVER CELL+ CELL+ @ UNICODE> TYPE SPACE
    DUP @ DUP . CR
  WHILE
    DUP @ +
  REPEAT DROP
;
: TEST
  100000 ALLOCATE THROW >R 
   R/O OPEN-DIR THROW >R
  BEGIN
    0 0 lpBytesReturned  0x1FF TRUE 100000 2R@
    ReadDirectoryChangesW
    IF 2R@ DROP PrintDirChanges ELSE GetLastError ." err:" . 200 PAUSE THEN
." d=" DEPTH .
  AGAIN
  R> CLOSE-FILE THROW
  R> FREE THROW
;

\ S" F:\" TEST
