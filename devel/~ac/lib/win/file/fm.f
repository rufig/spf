\ отображение файлов на выбираемые системой адреса
\ с возможностью разделения файла несколькими процессами

WINAPI: CreateFileMappingA KERNEL32.DLL
WINAPI: MapViewOfFile      KERNEL32.DLL
WINAPI: UnmapViewOfFile    KERNEL32.DLL

DECIMAL
4 CONSTANT PAGE_READWRITE
2 CONSTANT FILE_MAP_WRITE
1 CONSTANT FILE_SHARE_READ
2 CONSTANT FILE_SHARE_WRITE

0 VALUE MAP-BASE

( ниже новые варианты CREATE-FILE и OPEN-FILE с разделением доступа)

: CREATE-FILE ( c-addr u fam -- fileid ior ) \ 94 FILE
\ Создать файл с именем, заданным c-addr u, и открыть его в соответствии
\ с методом доступа fam. Смысл значения fam определен реализацией.
\ Если файл с таким именем уже существует, создать его заново как
\ пустой файл.
\ Если файл был успешно создан и открыт, ior нуль, fileid его идентификатор,
\ и указатель чтения/записи установлен на начало файла.
\ Иначе ior - определенный реализацией код результата ввода/вывода,
\ и fileid неопределен.
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  CREATE_ALWAYS
  0 ( secur )
  FILE_SHARE_READ FILE_SHARE_WRITE OR ( share )  
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
: OPEN-FILE ( c-addr u fam -- fileid ior ) \ 94 FILE
\ Открыть файл с именем, заданным строкой c-addr u, с методом доступа fam.
\ Смысл значения fam определен реализацией.
\ Если файл успешно открыт, ior ноль, fileid его идентификатор, и файл
\ позиционирован на начало.
\ Иначе ior - определенный реализацией код результата ввода/вывода,
\ и fileid неопределен.
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  OPEN_EXISTING
  0 ( secur )
  FILE_SHARE_READ FILE_SHARE_WRITE OR ( share )
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
: MAP-FILE ( size c-addr u -- fileid objid mapbase ior )
\ Отобразить файл с именем c-addr u в адресное пространство процесса
\ начиная с выбранного системой адреса. Берется фрагмент файла
\ со смещения 0 размером size.
\ Возвращается код ошибки ior или ноль, адрес отображения mapbase,
\ хэндлы объекта-отображения и объекта-отображаемого файла.
  OVER >R
  2DUP R/W OPEN-FILE      ( size c-addr u fileid ior )
  IF DROP R/W CREATE-FILE
  ELSE NIP NIP 0 THEN        ( size fileid ior )
  ?DUP IF NIP R> SWAP 0 SWAP EXIT THEN \ не удалось открыть/создать файл
                     ( size fileid )
  R> SWAP >R
  OVER               ( size name size )
  0                  ( size name sizelow sizehigh=0 )
  PAGE_READWRITE     \ protection
  0                  \ security
  R@                 \ fileid
  CreateFileMappingA
  DUP 0= IF R> GetLastError EXIT THEN
                     ( size objid )
  >R                 ( R: fileid objid )
  0 0                \ offset
  FILE_MAP_WRITE     \ access
  R@                 \ objid
  MapViewOfFile DUP TO MAP-BASE
  IF R> R> SWAP 0
  ELSE R> R> GetLastError THEN
  MAP-BASE SWAP
;
: UNMAP-FILE ( fileid objid mapbase -- ior )
\ Завершить отображение файла и закрыть файл.
  UnmapViewOfFile
  0= IF 2DROP GetLastError EXIT THEN
  CLOSE-FILE ?DUP IF NIP EXIT THEN
  CLOSE-FILE
;
( Пример:
  40000 S" TEST.MAP" MAP-FILE THROW
  MAP-BASE 40000 CHAR * FILL  UNMAP-FILE THROW
)