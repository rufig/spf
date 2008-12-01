( Работа с ini-файлами.
  Плюс упрощенный синтаксис Section[key], File.Section[key]
  Плюс исправление ошибок, когда в строчном литерале S" или "
  забывают пробел после кавычки. Примеры см. в конце текста.
  Ограничение: максимальная длина строки задается в IniMaxString, default=4000
  Задействованная память НЕ освобождается до завершения потока.
)

REQUIRE GetIniString ~af/lib/ini.f
REQUIRE STR@         ~ac/lib/str5.f
REQUIRE SYNC-MUTEX   ~ac/lib/win/thread/mutex.f 

VARIABLE INI-MUT		\ для хранения хэндла мутекса

VECT IniS@			\ векторы для встраивания кэширования
VECT IniS!

4000 VALUE IniMaxString		\ максимальная длина строки для считывания

: InitIniFileMutex ( -- ) S" INI-MUT" INI-MUT CREATE-MUTEX-EX ;

: (IniFile@) ( S" key" S" section" S" file"  -- S" value" )
\ получить значение ключа из ini-файла (без раскрытия {})
  { ka ku sa su fa fu \ mem }
  InitIniFileMutex		\ инициализировать мутекс
  IniMaxString ALLOCATE THROW -> mem	\ буфер для считывания строки
  fa IniMaxString mem S" " DROP ka sa	\ параметры запроса на чтение
  ['] GetPrivateProfileStringA INI-MUT SYNC-MUTEX	\ выполнить чтение синхронно
  mem SWAP			\ прочитанная строка
;
: IniFile@ ( S" key" S" section" S" file"  -- S" value" )
\ получить значение ключа из ini-файла
  (IniFile@)			\ получить строку без раскрытия
  OVER >R S@			\ раскрыть макросы в строке
  R> FREE THROW			\ освободить буфер
;
: IniFile! ( S" value" S" key" S" section" S" file" -- ) \ throwable
\ записать значение ключа в ini-файл
  { va vu ka ku sa su fa fu \ mem }
  InitIniFileMutex		\ инициализировать мутекс
  fa va ka sa			\ параметры для записи строки
  ['] WritePrivateProfileStringA INI-MUT SYNC-MUTEX	\ выполнить запись синхронно
  ERR THROW			\ обработать ошибку
;
USER IniEnumXt

: (IniEnum)
  BEGIN
    0 PARSE DUP
  WHILE
    IniEnumXt @ EXECUTE
  REPEAT 2DROP
;
: IniEnum ( a u xt -- ... )
\ выполнить xt для каждой строки в списке a u
\ a u - список asciiz-строк, возвращенных IniFile@ в случае,
\ если запрашивался список, т.е. одно из входных значений было нулевое
  IniEnumXt ! 
  ['] (IniEnum) EVALUATE-WITH
;
: IniFileExists_old ( addr u -- flag )
  R/O OPEN-FILE-SHARED ?DUP
  IF NIP DUP 2 =
        OVER 3 = OR
        OVER 206 = OR 
        SWAP 123 = OR
        0=
  ELSE CLOSE-FILE THROW TRUE
  THEN
;
: IniFileExists ( addr u -- flag )
  FILE-EXIST
;
: IniDefault2
  S" ..\Eserv3.orig.ini"
;
: IniDefault1
  S" ..\Eserv3.ini" 2DUP IniFileExists IF EXIT THEN
  2DROP IniDefault2
;
0 VALUE IniDefault
0 VALUE IniDefaultOrig
' IniDefault1 TO IniDefault
' IniDefault2 TO IniDefaultOrig

: STRNIL
  DUP 0= IF 2DROP 0 0 THEN
;
USER _fskFILE
USER _fskSEC
USER _fskKEY
: SFS! ( s addr -- )
  DUP @ ?DUP IF STRFREE THEN
  !
;
: (File.Section[Key]>)
  { xt \ fa fu s }
  SOURCE S" ." SEARCH NIP SWAP \ flag a
  SOURCE S" [" SEARCH 2DROP \ a2
  U< AND
  IF [CHAR] . PARSE [CHAR] . PARSE 2SWAP   \ " {s}.{s}" STR@ STRNIL
     "" -> s s STR+ S" ." s STR+ s STR+ s STR@ STRNIL s _fskFILE SFS!
  ELSE xt EXECUTE THEN
  -> fu -> fa
  [CHAR] [ PARSE ( " {s}") sALLOT DUP _fskSEC SFS! STR@ STRNIL
  [CHAR] ] PARSE ( " {s}") sALLOT DUP _fskKEY SFS! STR@ STRNIL 2SWAP fa fu
;
: File.Section[Key]> IniDefault (File.Section[Key]>) ;
: FileOrig.Section[Key]> IniDefaultOrig (File.Section[Key]>) ;

: (IniS@)
  File.Section[Key]>
  (IniFile@) DUP 0=
  IF DROP FREE THROW >IN 0! FileOrig.Section[Key]>
     (IniFile@)
  THEN
  OVER >R S@			\ раскрыть макросы в строке
  R> FREE THROW			\ освободить буфер
;
: (IniS!) ( va vu -- )
  File.Section[Key]> IniFile!
;
: <IniS@> ( a u -- S" value" )
  ['] (IniS@) EVALUATE-WITH
;
' <IniS@> TO IniS@
: <IniS!> ( va vu a u -- S" value" )
  ['] (IniS!) EVALUATE-WITH
;
' <IniS!> TO IniS!
: ""@ { a u -- str }
  >IN @ u - 0 MAX >IN ! POSTPONE "
;
: "S"@ { a u -- str }
  >IN @ u 1- - 0 MAX >IN ! POSTPONE S"
;
: NOTFOUND { a u -- ... }
  a u S" [" SEARCH NIP NIP
  a u S" ]" SEARCH NIP NIP AND IF a u IniS@ EXIT THEN
  a C@ [CHAR] " = >IN @ u > AND IF a u ""@ EXIT THEN
  u 1 > IF a 2 S' S"' COMPARE 0= >IN @ u > AND IF a u "S"@ EXIT THEN THEN
  a u NOTFOUND
;

( win.ini отображен в реестр, поэтому данные могут не совпадать с ini )
(
\ Server[HostName] TYPE
\ S" rainbow1.test" S" Server[HostName]" IniS!
g:\WINXP\win.ini.Mail[CMCDLLNAME32] TYPE CR CR
g:\WINXP\win.ini.Mail[] ' TYPE IniEnum CR CR
g:\WINXP\win.ini.[] TYPE CR CR
MyDomains[Domain1] TYPE CR
MyDomains[Domain2] TYPE CR
g:\Eserv3\acSMTP\log\schema.ini.200304mail.txt[MaxScanRows] TYPE CR
    "test{5 5 +}" STYPE CR
: TEST   S"test zzz" TYPE CR ; TEST

S" CMCDLLNAME32" S" Mail" S" g:\WINXP\win.ini" IniFile@ TYPE CR
0 0 S" Mail" S" g:\WINXP\win.ini" IniFile@ TYPE CR
0 0 0 0 S" g:\WINXP\win.ini" IniFile@ TYPE CR
)