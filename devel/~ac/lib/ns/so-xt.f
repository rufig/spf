( ~ac 18.08.2005
  $Id$
  Измененный вариант DLL-XT.F для упрощения работы с DLL/SO
  с сишными соглашениями о связях [параметры снимает вызывающий].

  Из определенных здесь слов рекомендуется к использованию только
  словарь SO, остальные работают за кадром [SO NEW:] как системное 
  расширение транслятора.

  xt, возвращаемые SEARCH-WORDLIST в словаре SO, пригодны для
  обычного EXECUTE - не требуют API-CALL или C-EXEC в отличие от ns.f.
  И использовать имена из DLL/SO [без предварительного определения]
  можно не только в режиме интерпретации, но и в режиме компиляции.

  См. примеры в конце этого файла, а доп.комментарии в DLL-XT.F.
)

VARIABLE vSOdebug
WARNING @ WARNING 0!
REQUIRE NEW: ~ac/lib/ns/ns.f

: SO-INIT ( addr -- ) \ = DLL-INIT
  DUP >R 6 CELLS + ASCIIZ> R@ CELL+ CELL+ @
  [ ALSO DL ] SEARCH-WORDLIST [ PREVIOUS ]
  0= IF ABORT THEN R> CELL+ !
;
: SO-CALL ( на стеке возвратов адрес структуры импорта вызываемой функции )
  \ C-EXEC вместо API-CALL
  \ на стеке данных параметры _и_ число параметров
  vSOdebug @ IF R@ 6 CELLS + ASCIIZ> TYPE ." :" DUP . THEN
  R@ CELL+ @ vSOdebug @ IF DUP . CR THEN
  DUP 0= IF DROP R@ SO-INIT R@ CELL+ @ THEN
  R@ @ R> + >R C-EXEC
;
: SO-CALL, ( funa funu n dll-wid xt -- addr )
  ['] SO-CALL _COMPILE,

  HERE >R
  0 , \ size
    , \ address of winproc
    , \ address of library name
  HERE CELL+ CELL+ CELL+ , \ address of function name
    , \ # of parameters ( здесь тоже не используется )
  IS-TEMP-WL 0=
  IF
    HERE WINAPLINK @ , WINAPLINK ! ( связь )
  ELSE 0 , THEN
  HERE SWAP DUP ALLOT MOVE 0 C, \ имя функции
  HERE R@ - R@ !
  R>
;

\ S" function" 5 0xDDD 0xCCC DLL-CALL, 80 DUMP

<<: FORTH SO
ALSO DL

: ?VOC DROP FALSE ;
: CAR ( wid -- item )
  ." SO exports enumeration isn't supported now." CR
  DROP 0
;
: SHEADER ( addr u -- )
  ." Can't insert " TYPE ."  into " GET-CURRENT VOC-NAME. ."  SharedObject ;)" CR
  5 THROW
;
: SEARCH-WORDLIST ( c-addr u oid -- 0 | xt 1 | xt -1 )
  >R 2DUP ( c-addr u c-addr u )
  0 ROT ROT R@ ROT ROT R> ( c-addr u 0 oid  c-addr u oid )
  SEARCH-WORDLIST
  ?DUP
  IF ( c-addr u 0 oid xt [-]1 )
     >R HERE >R SO-CALL, DROP 
     STATE @ 0= IF RET, THEN
     R> STATE @ IF DROP ['] NOOP THEN
     R>
  ELSE 2DROP 2DROP 0 THEN
;

PREVIOUS
>> CONSTANT SO-WL

: ERASE-SO-HANDLES
  VOC-LIST @
  BEGIN
    DUP
  WHILE
    DUP CELL+ DUP CLASS@ SO-WL =
              IF 0 OVER OBJ-DATA! THEN DROP
    @
  REPEAT DROP
;

GET-CURRENT FORTH-WORDLIST SET-CURRENT
: SAVE
  ERASE-SO-HANDLES SAVE
;
SET-CURRENT

WARNING !

( примеры

ALSO SO NEW: libxml2.dll

S" text.xml" DROP 1 xmlRecoverFile .

: TEST
  S" text.xml" DROP 1 xmlRecoverFile .
;

\ ==============================
ALSO SO NEW: libcurl.dll
VARIABLE CURLH
10002 CONSTANT CURLOPT_URL
10004 CONSTANT CURLOPT_PROXY

\ CREATE URL S" http://xmlsearch.yandex.ru/xmlsearch?query=sp-forth" HERE SWAP DUP ALLOT MOVE 0 C,
\ curl не копирует ссылку себе
\ 0 curl_easy_init DUP . CURLH !
\ URL CURLOPT_URL CURLH @ 3 curl_easy_setopt .
\ CURLH @ 1 curl_easy_perform . \ 7 = CURLE_COULDNT_CONNECT

: CURLTEST
  0 curl_easy_init CURLH !
  S" http://xmlsearch.yandex.ru/xmlsearch?query=sp-forth" DROP CURLOPT_URL CURLH @ 3 curl_easy_setopt DROP
  S" http://otradnoe:3128/" DROP CURLOPT_PROXY CURLH @ 3 curl_easy_setopt DROP
  CURLH @ 1 curl_easy_perform
  ?DUP IF 1 curl_easy_strerror ASCIIZ> TYPE CR THEN
;
)
