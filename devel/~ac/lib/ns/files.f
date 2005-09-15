REQUIRE FIND-FILES-R      ~ac/lib/win/file/findfile-r.f 
REQUIRE ForEachDirWRstr   ~ac/lib/ns/iter.f

: FileExists ( addr u -- flag )
  R/O OPEN-FILE-SHARED ?DUP
  IF NIP DUP 2 =
        OVER 3 = OR
        OVER 206 = OR 
        SWAP 123 = OR
        0=
  ELSE CLOSE-FILE THROW TRUE
  THEN
;
WINAPI: GetFileAttributesA KERNEL32.DLL

16 CONSTANT FILE_ATTRIBUTE_DIRECTORY

: IsDirectory ( addr u -- flag )
  DROP GetFileAttributesA DUP FILE_ATTRIBUTE_DIRECTORY AND
  0<> SWAP -1 <> AND
;

<<: FORTH FIL
>> CONSTANT FIL-WL

: DIR>DIR ( addr u -- )
  VOC-CLONE CONTEXT @ >R PREVIOUS
  R@ OBJ-NAME!
  CONTEXT @ R@ PAR!
  R> CONTEXT !
;
: DIR>FIL ( addr u -- )
  TEMP-WORDLIST >R
  R@ OBJ-NAME!
  FIL-WL R@ CLASS!
  CONTEXT @ R@ PAR!
  R> CONTEXT !
;

<<: FORTH DIR
: SHEADER ( addr u -- )
\ Создать файл [или лучше каталог?] с именем addr u в текущем DIR-узел "компиляции"
  GET-CURRENT OBJ-NAME@ " {s}\{s}" DUP >R
  STR@ 2DUP R/W CREATE-FILE THROW >R
  TEMP-WORDLIST >R
  R@ OBJ-NAME!
  FIL-WL R@ CLASS!
  R> R> SWAP >R
  R@ OBJ-DATA! \ хэндл
  GET-CURRENT R@ PAR!
  R> SET-CURRENT
  R> STRFREE
;
: SEARCH-WORDLIST { c-addr u oid \ f -- 0 | xt 1 | xt -1 }

\ сначала ищем в методах класса
  c-addr u [ GET-CURRENT ] LITERAL SEARCH-WORDLIST ?DUP IF EXIT THEN

  c-addr u oid OBJ-NAME@ " {s}\{s}" DUP -> f STR@ 2DUP
  IsDirectory IF DIR>DIR ['] NOOP 1 f STRFREE EXIT THEN
  2DUP FileExists IF DIR>FIL ['] NOOP 1 f STRFREE EXIT THEN
  2DROP f STRFREE FALSE
;
>> CONSTANT DIR-WL

ALSO DIR NEW: c:
WINDOWS system32 drivers etc hosts 
ORDER CONTEXT @ CLASS.
CONTEXT @ OBJ-NAME@ R/O OPEN-FILE THROW DUP . CLOSE-FILE THROW CR
\ Приведет к печати:
\ Context: c:\WINDOWS\system32\drivers\etc\hosts FORTH
\ Current: FORTH
\ FIL2036
PREVIOUS

ALSO c: DEFINITIONS PREVIOUS CREATE TEST_FILE.TXT
ORDER
GET-CURRENT CLASS. GET-CURRENT OBJ-DATA@ DUP . CLOSE-FILE THROW CR
\ Создаст файл c:\TEST_FILE.TXT (вместо "словарной статьи")
\ и приведет к печати:
\ Context: FORTH
\ Current: c:\TEST_FILE.TXT
\ FIL2036
DEFINITIONS
