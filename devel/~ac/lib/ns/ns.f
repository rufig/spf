: OBJ-DATA@ ( oid -- data )
\ Данные объекта (instance).
\ Для форт-словарей возвращает указатель на имя последнего слова в списке (канон),
\ для dll - хэндл от LoadLibrary
  @
;
: OBJ-DATA! ( data oid -- )
  !
;
: OBJ-NAME@ ( oid -- addr-u )
\ "Родное" имя объекта, присвоенное VOCABULARY (в других namespaces может быть
\ под другим именем.)
  CELL+ @ ?DUP IF COUNT ELSE S" FORTH" THEN
;

: INVOKE ( ... oid addr u -- ... )
\ выполнить метод с именем addr u для объекта oid
  ROT ( addr u oid )
  DUP CLASS@ DUP 0= IF DROP FORTH-WORDLIST THEN ( addr u oid class-oid )
  SWAP >R ( addr u class-oid )
  SEARCH-WORDLIST1
  IF R> SWAP EXECUTE ELSE -2004 THROW THEN
;

: SEARCH-WORDLIST-V ( c-addr u wid -- 0 | xt 1 | xt -1 ) \ 94 SEARCH
\ Найти определение, заданное строкой c-addr u в списке слов, идентифицируемом 
\ wid. Если определение не найдено, вернуть ноль.
\ Если определение найдено, вернуть выполнимый токен xt и единицу (1), если 
\ определение немедленного исполнения, иначе минус единицу (-1).
  DUP CLASS@
  IF S" SEARCH-WORDLIST" INVOKE
  ELSE SEARCH-WORDLIST1 THEN
;
' SEARCH-WORDLIST-V TO SEARCH-WORDLIST

VOCABULARY DLL-CLASS
GET-CURRENT ALSO DLL-CLASS DEFINITIONS

: SEARCH-WORDLIST-DLL ( c-addr u oid -- 0 | xt 1 | xt -1 )
  DUP OBJ-DATA@ ?DUP
  IF NIP ROT ROT HEAP-COPY DUP >R SWAP GetProcAddress R> FREE THROW
     DUP IF 1 THEN
  ELSE
     DUP OBJ-NAME@ HEAP-COPY DUP >R LoadLibraryA R> FREE THROW
     ?DUP IF ( addr u oid h ) OVER OBJ-DATA! RECURSE
          ELSE DROP 2DROP 0 THEN \ не удалось загрузить DLL
  THEN
;
USER LATEST-FOUND
: EXECUTE-LATEST-FOUND ( ... n -- ... )
\ n - число параметров на стеке для dll-функции
  ?DUP IF N>R RDROP THEN
  0 LATEST-FOUND @ EXECUTE
;
: SEARCH-WORDLIST
  SEARCH-WORDLIST-DLL DUP 
  IF SWAP LATEST-FOUND ! ['] EXECUTE-LATEST-FOUND SWAP THEN
;
GET-CURRENT SWAP
SET-CURRENT PREVIOUS

VOCABULARY KERNEL32.DLL
ALSO KERNEL32.DLL
CONTEXT @ CLASS!


0 GetTickCount . CR
0 GetCurrentProcessId . CR
1000 PAD S" OS" DROP 3 GetEnvironmentVariableA PAD SWAP TYPE CR
0 GetZzz .
