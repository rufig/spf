REQUIRE {               ~ac/lib/locals.f
REQUIRE />\             ~ac/lib/string/conv.f
REQUIRE STR@            ~ac/lib/str5.f
REQUIRE DLOPEN          ~ac/lib/ns/dlopen.f 
REQUIRE LoadInitLibrary ~ac/lib/win/dll/load_lib.f 
REQUIRE replace-str     ~pinka/samples/2005/lib/replace-str.f 
REQUIRE COMPARE-U       ~ac/lib/string/compare-u.f
REQUIRE WinNT?          ~ac/lib/win/winver.f
REQUIRE OPEN-FILE-SHARED-DELETE ~ac/lib/win/file/share-delete.f
REQUIRE FIND-FILES-R    ~ac/lib/win/file/findfile-r.f 

WINAPI: CreateDirectoryA     KERNEL32.DLL
WINAPI: RemoveDirectoryA     KERNEL32.DLL
WINAPI: GetCurrentDirectoryA KERNEL32.DLL

WINAPI: CopyFileA KERNEL32.DLL
WINAPI: MoveFileA KERNEL32.DLL
WINAPI: MoveFileExA  KERNEL32.DLL

1 CONSTANT MOVEFILE_REPLACE_EXISTING
2 CONSTANT MOVEFILE_COPY_ALLOWED

: IsDirectory ( addr u -- flag )
  DROP GetFileAttributesA DUP FILE_ATTRIBUTE_DIRECTORY AND
  0<> SWAP -1 <> AND
;
: DIRECTORY-EXISTS ( addr u -- flag ) IsDirectory ;
: PATH-EXISTS      ( addr u -- flag ) FILE-EXIST ;

: CREATE-DIRECTORY ( addr u -- ior )
  DROP 0 SWAP
  CreateDirectoryA ERR
;
: DELETE-DIRECTORY ( addr u -- ior )
  DROP
  RemoveDirectoryA ERR
;
: RENAME-FILE-OVER ( addr-old u-old adr-new u-new -- ior )
  DROP NIP SWAP MOVEFILE_REPLACE_EXISTING MOVEFILE_COPY_ALLOWED OR
  ROT ROT MoveFileExA ERR
;
: CREATE-FILE-PATH1
  BEGIN
    [CHAR] \ DUP SKIP PARSE 2DROP ( WORD DROP) >IN @ #TIB @ <
  WHILE
    0 TIB >IN @ + 1- C!
    0 TIB CreateDirectoryA DROP
    [CHAR] \ TIB >IN @ + 1- C!
  REPEAT
;
: CREATE-FILE-PATH ( addr u io -- handle ior )
  { a u i }
  0 a u + C!
  a u i CREATE-FILE
  IF DROP a u />\
     a u ['] CREATE-FILE-PATH1 EVALUATE-WITH
     a u i CREATE-FILE
  ELSE 0 THEN
;
: EndsWith.BL/ ( addr u -- flag )
\ имена файлов в acTCP не должны заканчиваться пробелами и точками,
\ а должны быть "нормализованы", т.к. Windows не делает различий
\ и позволяет открывать файлы с несуществующими именами - с лишними 
\ пробелами и точками, открывая простор злоупотреблениям и ошибкам.

  DUP 1 < IF 2DROP FALSE EXIT THEN
  + 1- C@ >R
  R@ [CHAR] . =
  R@ [CHAR] / = OR
  R@ [CHAR] \ = OR
  R> BL = OR
;
: __FileExists ( addr u -- flag )
  2DUP EndsWith.BL/ IF 2DROP FALSE EXIT THEN
  R/O OPEN-FILE-SHARED ?DUP
  IF NIP DUP 2 =
        OVER 3 = OR
        OVER 206 = OR 
        SWAP 123 = OR
        0=
  ELSE CLOSE-FILE THROW TRUE
  THEN
;
: FileExists
  2DUP EndsWith.BL/ IF 2DROP FALSE EXIT THEN
  FILE-EXIST
;


: ;>_ ( addr u -- )
  0 ?DO DUP C@ [CHAR] ; = IF [CHAR] _ OVER C! THEN 1+ LOOP DROP
;

\ ======== ~pig 20.11.2004,26.12.2007 ========
\ нормализация пути к файлу
\ путь вида \dir1\dir2\..\dir3 приводится к виду \dir1\dir3
\ алгоритм заимствован из acWEB/src/proto/http/isapi.f (~ac)
: NormalizePath ( addr u -- addr 1 u1 )
  2DUP S" \.." SEARCH ?DUP 0=			\ есть что нормализовать?
  IF S" /.." SEARCH THEN 0=
  IF 2DROP EXIT THEN				\ нет - оставить как есть
  OVER 3 + C@ is_path_delimiter 0=		\ за точками должен быть ещё один разделитель
  IF 2DROP EXIT THEN				\ нет - оставить как есть (что-то в пути ненормальное, лучше не трогать)
  ( \dir1\dir2\..\dir3    \..\dir3 )
  SWAP >R DUP >R				\ запомнить положение остатка
  ( \dir1\dir2\..\dir3   u   R: a u )
  -						\ отрезать остаток
  ( \dir1\dir2   R: a u )
  BEGIN
    2DUP + 1- C@ is_path_delimiter 0= OVER 0 > AND	\ убрать остающийся каталог
  WHILE
    1-
  REPEAT
  2DUP +					\ указатель на точку сращивания
  ( \dir1\  \dir1\^   R: a u )
  R> 4 -					\ отрезали \..\
  ( \dir1\  \dir1\^  u-4  R: a )
  R> 4 + SWAP
  ( \dir1\  \dir1\^  dir3 )
  DUP >R					\ длина ещё пригодится
  ( \dir1\  \dir1\^  dir3  R: u-4)
  ROT SWAP MOVE					\ собрать строку заново
  ( \dir1\dir3    R: u-4)
  R> +						\ длина новой строки
  2DUP + 0 SWAP C!				\ поставить терминатор на всякий случай
  RECURSE					\ повторить, поскольку может быть несколько вхождений
;

\ уровень вложения действующего EXE относительно EXE серверов
\ строка вида "..\"
\ задается один раз при запуске приложения
\ для серверов можно не задавать, он и так пустой
\ для fs.exe - задается где-нибудь в fs.ini
\ (хорошо бы в настроечном файле, который лежит
\ в одном каталоге с fs.exe и подгружается всегда)
VARIABLE $ModuleDirLevel
: ModuleDirLevel ( -- addr u ) $ModuleDirLevel @ STR@ ;
: SetModuleDirLevel ( addr u -- ) $ModuleDirLevel S! ;

USER MFNR_str

: MakeFullNameRaw ( a u -- a1 u1 )
\ Если [a u] - относительное имя файла(каталога),
\ то, считая его расположение относительно exe-файлов серверов,
\ дать его полное имя с учетом ModuleDirLevel;
\ Если [a u] - имя с путем от корня, то вернуть имя с буквой диска,
\ где расположены exe-файлы серверов.
\ Иначе вернуть [a u].

  MFNR_str 0!
  DUP 2 < IF EXIT THEN				\ слишком короткий путь - вернуть как есть
  OVER DUP C@ is_path_delimiter SWAP CHAR+ C@ is_path_delimiter AND	\ это UNC-путь (\\server\share)?
  IF EXIT THEN					\ да - вернуть как есть
  OVER CHAR+ C@ [CHAR] : = IF EXIT THEN		\ присутствует буква диска - полный путь
  ModuleDirName					\ путь к нашему EXE
  2OVER DROP C@ is_path_delimiter		\ путь начинается с разделителя?
  IF DROP 2 " {s}{s}" DUP MFNR_str ! STR@ EXIT THEN		\ да - оставить от пути к EXE только букву диска
  " {s}{ModuleDirLevel}{s}" STR@		\ собрать путь
;
: MakeFullName ( a u -- a1 u1 ) >STR STR@ MakeFullNameRaw NormalizePath ;

VARIABLE CurDir

: CurrentDirectory ( -- addr u )
  CurDir @ ?DUP IF ASCIIZ> EXIT
                ELSE 5000 ALLOCATE THROW CurDir ! THEN
  CurDir @ 5000 GetCurrentDirectoryA >R
  0 CurDir @ R@ + C!
  CurDir @ R>
;

: \file ( addr u -- addr2 u2 )
\ Отрезать от пути\имени_файла только имя_файла
  DUP 0 ?DO
    2DUP + I - 1- C@ DUP [CHAR] \ = SWAP [CHAR] / = OR
    IF + I - I UNLOOP EXIT THEN
  LOOP
;
VARIABLE DLOPEN_DEBUG
: DLL?
  DLOPEN_DEBUG @ 0= IF FALSE EXIT THEN
  2DUP S" dll" SEARCH NIP NIP IF TRUE EXIT THEN
  2DUP S" DLL" SEARCH NIP NIP IF TRUE EXIT THEN
  FALSE
;
: FileExists1
  DLL? >R
  R@ IF 2DUP TYPE SPACE THEN
  FileExists
  R> IF DUP . CR THEN
;
: (DLOPEN_ext)
  2DUP FileExists1 IF DLOPEN EXIT THEN

  2DUP ModuleDirName " {s}{s}" DUP >R STR@ FileExists1 R> STRFREE 
  IF DLOPEN EXIT THEN

  2DUP ModuleDirName " {s}ext\{s}" DUP >R STR@ 2DUP FileExists1
  IF 2SWAP 2DROP LoadInitLibrary R> STRFREE THROW EXIT THEN
  2DROP R> STRFREE 

  2DUP ModuleDirName " {s}..\ext\{s}" DUP >R STR@ 2DUP FileExists1
  IF 2SWAP 2DROP LoadInitLibrary R> STRFREE THROW EXIT THEN
  2DROP R> STRFREE 

  2DUP ModuleDirName " {s}..\..\ext\{s}" DUP >R STR@ 2DUP FileExists1
  IF 2SWAP 2DROP LoadInitLibrary R> STRFREE THROW EXIT THEN
  2DROP R> STRFREE 

  LoadInitLibrary THROW
\  2DROP 0
;
: DLOPEN_ext
  ['] (DLOPEN_ext) CATCH IF 2DROP 0 THEN \ DLOPEN не вызывает THROW
;

: ">Q ( addr u -- addr2 u2 )
  2DUP S' "' SEARCH NIP NIP 0= IF EXIT THEN
  " {s}" DUP " {''}" " &quot;" replace-str- STR@
;

\ ~pig 17.03.2008, 
\ ~ruv 10.06.2008 переименовано CONTAINS->CONTAINS-WORD

\ CONTAINS-WORD проверяет вхождение слова в строку
\ в отличие от SEARCH проверяется вхождение не подстроки, а именно слова
\ местонахождение не возвращается
\ CONTAINS-WORD-U - аналогично, но сравнение регистронезависимое

: (CONTAINS-WORD) ( "string" S" word" -- flag )
  2>R						\ запомнить указатель на искомое слово
  BEGIN
    NextWord DUP				\ выбрать очередное слово
  WHILE
    2R@ COMPARE 0=				\ это искомое слово?
    IF RDROP RDROP TRUE EXIT THEN		\ да - дальше не искать
  REPEAT
  2DROP RDROP RDROP FALSE			\ не нашлось
;
: CONTAINS-WORD ( S" string" S" word" -- flag ) 2SWAP ['] (CONTAINS-WORD) EVALUATE-WITH ;

: (CONTAINS-WORD-U) ( "string" S" word" -- flag )
  2>R						\ запомнить указатель на искомое слово
  BEGIN
    NextWord DUP				\ выбрать очередное слово
  WHILE
    2R@ COMPARE-U 0=				\ это искомое слово?
    IF RDROP RDROP TRUE EXIT THEN		\ да - дальше не искать
  REPEAT
  2DROP RDROP RDROP FALSE			\ не нашлось
;
: CONTAINS-WORD-U ( S" string" S" word" -- flag ) 2SWAP ['] (CONTAINS-WORD-U) EVALUATE-WITH ;

: CREATE-FILE-SHARED-NI ( c-addr u fam -- fileid ior )
\ shared, но без наследования
  NIP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  CREATE_ALWAYS
  0 ( secur )
  3 ( share )  
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
: OPEN-FILE-SHARED-DELETE-NI ( c-addr u fam -- fileid ior )
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  OPEN_EXISTING
  0 ( secur )
  WinNT? IF 7 ( share read/write/delete ) ELSE 3 THEN
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
: CREATE-FILE-SHARED-DELETE-NI ( c-addr u fam -- fileid ior )
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
  CREATE_ALWAYS
  0 ( secur )
  WinNT? IF 7 ( share read/write/delete ) ELSE 3 THEN
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;

: CREATE-FILE-SHARED-DELETE-ON-CLOSE-NI ( c-addr u fam -- fileid ior )
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
    FILE_FLAG_DELETE_ON_CLOSE OR
  CREATE_ALWAYS
  0 ( secur )
  WinNT? IF 7 ( share read/write/delete ) ELSE 3 THEN
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
: CREATE-FILE-RSHARED-DELETE-ON-CLOSE-NI ( c-addr u fam -- fileid ior )
  SWAP DROP SWAP >R >R
  0 FILE_ATTRIBUTE_ARCHIVE ( template attrs )
    FILE_FLAG_DELETE_ON_CLOSE OR
  CREATE_ALWAYS
  0 ( secur )
  1 ( share read )
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
;
: DELETE-FD ( addr u data flag -- )
  NIP
  IF DELETE-DIRECTORY THROW
  ELSE DELETE-FILE THROW THEN
;
: (DELETE-DIRECTORY-R) ( addr u -- )
  ['] DELETE-FD FIND-FILES-R
;
: DELETE-DIRECTORY-R { addr u -- ior }
\ рекурсивно удалить каталог
  addr u ['] (DELETE-DIRECTORY-R) CATCH ?DUP
  IF NIP NIP
  ELSE addr u DELETE-DIRECTORY THEN
;
