\ DLL/SO - словари

REQUIRE HEAP-COPY heap-copy.f
REQUIRE DLOPEN    dlopen.f
REQUIRE NOTFOUND  notfound.f

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

USER _PAS-EXEC \ без локальных переменных неудобно ;)
: PAS-EXEC ( ... n dll-xt -- x )
\ n - число параметров на стеке для dll-функции
\ Параметры снимает вызываемый.
  _PAS-EXEC !
  ?DUP IF N>R RDROP THEN
  0 _PAS-EXEC @ EXECUTE
;
USER _C-EXEC
: C-EXEC ( ... n dll-xt -- x )
\ n - число параметров на стеке для dll/so-функции
\ Параметры снимает вызывающий.
  _PAS-EXEC ! DUP _C-EXEC !
  ?DUP IF N>R RDROP THEN
  _C-EXEC @ 0 _PAS-EXEC @ EXECUTE
  SWAP BEGIN DUP WHILE RDROP 1- REPEAT DROP
;
\ если на стеке только адрес функции и параметры,
\ то число параметров можно посчитать автоматом.

: SPAS-EXEC ( dll-xt ... -- x )
  DEPTH 1- N>R RDROP 0 SWAP EXECUTE
;
: SC-EXEC ( dll-xt ... -- x )
  DEPTH 1- _C-EXEC !
  DEPTH 1- N>R RDROP _C-EXEC @ 0 ROT EXECUTE
  SWAP BEGIN DUP WHILE RDROP 1- REPEAT DROP
;

: NEW:
\ Создать новый именованый словарь, class которого будет равен 
\ текущему контекстному словарю. Т.е. создать объект - экземпляр
\ текущего класса.
  >IN @ VOCABULARY >IN !
  CONTEXT @ ( ALSO) ' EXECUTE CONTEXT @ CLASS!
;
\ NEW: KERNEL32.DLL соответствует такому коду:
\ VOCABULARY KERNEL32.DLL
\ ( ALSO) KERNEL32.DLL
\ CONTEXT @ CLASS!


VOCABULARY DL
GET-CURRENT ALSO DL DEFINITIONS

: HEAP-COPY-U
  DUP >R HEAP-COPY R>
;
: SEARCH-WORDLIST ( c-addr u oid -- 0 | xt 1 | xt -1 )
  DUP OBJ-DATA@ ?DUP
  IF NIP ROT ROT HEAP-COPY-U OVER >R ROT DLSYM R> FREE THROW
     DUP IF 1 THEN
  ELSE
     DUP OBJ-NAME@ HEAP-COPY-U OVER >R DLOPEN R> FREE THROW
     ?DUP IF ( addr u oid h ) OVER OBJ-DATA! RECURSE
          ELSE DROP 2DROP 0 THEN \ не удалось загрузить DLL/SO
  THEN
;
SET-CURRENT PREVIOUS

: NOTFOUND \ просто для сокращения asciiz литералов "zzz" = S" zzz" DROP
  OVER C@ [CHAR] " = 
  IF NIP >IN @ SWAP - 0 MAX >IN !
     POSTPONE S" DROP
  ELSE NOTFOUND THEN
;

ALSO \ чтобы форт остался :-]
\ ===========================
DL NEW: KERNEL32.DLL

0 ' GetTickCount PAS-EXEC . CR
0 ' GetCurrentProcessId PAS-EXEC . CR
1000 PAD S" OS" DROP 3 ' GetEnvironmentVariableA PAS-EXEC PAD SWAP TYPE CR
' GetEnvironmentVariableA 1000 PAD "OS" SPAS-EXEC PAD SWAP TYPE CR

\ ===========================
DL NEW: USER32.DLL

0 ' GetDesktopWindow PAS-EXEC . CR

\ ===========================
DL NEW: libcrypt.dll

"zz" "pass" 2 ' crypt C-EXEC ASCIIZ> TYPE CR
' crypt "zz" "pass" SC-EXEC ASCIIZ> TYPE CR

\ ===========================
KERNEL32.DLL ' GetEnvironmentVariableA 
1000 PAD "USERNAME" SPAS-EXEC PAD SWAP TYPE CR

' GetCurrentThreadId SPAS-EXEC . CR
ORDER

\ ===========================
DL NEW: libcurl.dll
VARIABLE CURLH
CREATE URL S" http://xmlsearch.yandex.ru/xmlsearch?query=sp-forth" HERE SWAP DUP ALLOT MOVE 0 C,
\ curl не копирует ссылку себе

0 ' curl_easy_init C-EXEC DUP . CURLH !
URL 10002 ( CURLOPT_URL) CURLH @ 3 ' curl_easy_setopt C-EXEC .
CURLH @ 1 ' curl_easy_perform C-EXEC .
