( ~ac 20.08.2005
  $Id$

  ѕодключение внешних XML-файлов [по имени файла или URL] в
  качестве контекстного форт-словар€. ¬ результате поиск, 
  переключение контекстов, создание узлов в XML-файле  
  производитс€ самим интерпретатором ‘орта, без необходимости 
  использовани€ XMLDOM и прочих XML-специфичных API.

  »спользование:
  ALSO XML_DOC NEW: http://forth.org.ru/rss.xml
  - создает словарь, прив€занный к указанному URL и имеющий
  то же им€, и добавл€ет этот словарь в контекст поиска.
   огда трансл€тор форта будет осуществл€ть следующий поиск -
  этот XML автоматически загрузитс€ и поиск по его узлам будет
  производитьс€ так, как если бы это был "встроенный" форт-словарь.
  ¬ыполнение найденного узла замен€ет текущую вершину контекста
  поиска на найденный узел в документе [как если бы он сам был
  определен через VOCABULARY], и дальнейший поиск будет вестись,
  начина€ с него. “аким образом возможна запись:
  http://forth.org.ru/rss.xml /rss channel title
  котора€ в процессе исполнени€ найдет тот же узел, что и
  XPath-выражение /rss/channel/title.
  —лова "@" и "." в этих контекстах переопределены дл€ извлечени€
  и печати текстовых значений "контекстных узлов" соответственно.

  Ѕиблиотека еще в доработке, поэтому примеры в конце не отключены.
)

REQUIRE XML_READ_DOC_ROOT ~ac/lib/lin/xml/xml.f 

<<: FORTH XML_NODE

: SHEADER ( addr u -- )
\ ƒобавить xml-узел с именем addr u в текущий xml-узел "компил€ции"
  GET-CURRENT OBJ-DATA@ XML_NEW_NODE DROP
;
: SEARCH-WORDLIST { c-addr u oid -- 0 | xt 1 | xt -1 }
\ Ќайти узел с именем c-addr u в xml-узле oid

  oid OBJ-DATA@ DUP \ node
  IF c-addr u ROT node@ DUP 
     IF \ найден узел с заданным именем
        ( мен€ть в oid или в CONTEXT ?! - разные полезные свойства ...)
        \ oid
        CONTEXT @
        OBJ-DATA! ['] NOOP 1
     THEN
  THEN
  DUP 0=
  IF \ не найден в "свойствах объекта", поищем в "методах класса"
     DROP c-addr u [ GET-CURRENT ] LITERAL SEARCH-WORDLIST
  THEN
;
: setNode CONTEXT @ OBJ-DATA! ;
: getNode CONTEXT @ OBJ-DATA@ ;
: @ getNode text@ ;
: . @ TYPE ;
: WORDS getNode XML_NLIST ;
: SAVE ( addr u -- ) GET-CURRENT OBJ-DATA@ NODE>DOC XML_DOC_SAVE ;

>> CONSTANT XML_NODE-WL

: DOC>NODE
  CONTEXT @ OBJ-DATA@ XML_DOC_ROOT
  TEMP-WORDLIST >R
  R@ OBJ-DATA!
  XML_NODE-WL R@ CLASS!
  R> CONTEXT !
;
: VOC-CLONE
  TEMP-WORDLIST >R
  CONTEXT @ CELL- R@ CELL- WL_SIZE MOVE
  ALSO R> CONTEXT !
;

<<: FORTH XML_DOC

: SAVE ( addr u -- ) GET-CURRENT OBJ-DATA@ XML_DOC_SAVE ;

: SEARCH-WORDLIST { c-addr u oid -- 0 | xt 1 | xt -1 }

  c-addr C@ [CHAR] / <> IF 0 EXIT THEN \ в документе ищем только корень

  oid OBJ-DATA@ \ doc; если не загружен - загрузим
  0= IF oid OBJ-NAME@ " {s}" STR@ XML_READ_DOC oid OBJ-DATA! THEN

  oid OBJ-DATA@ DUP
  IF \ удалось загрузить xml, теперь нужно выдать xt,
     \ который заменит контекст документа на контекст корневого узла
     DROP ['] DOC>NODE 1
  THEN
;
:>>

\ ниже почти << XML_DOC libxml-parser.html , но без манипул€ций DEFINITIONS

ALSO XML_DOC NEW: libxml-parser.html
libxml-parser.html / head title .
libxml-parser.html / head style .
PREVIOUS

ALSO XML_DOC NEW: eserv.xml
eserv.xml / head link @ FORTH::TYPE
PREVIOUS

ALSO XML_DOC NEW: http://forth.org.ru/
/html head title . CR
http://forth.org.ru/ /html head link @href . CR
\ http://forth.org.ru/ /html head getNode listNodes
PREVIOUS

ALSO XML_DOC NEW: http://forth.org.ru/rss.xml
/rss channel VOC-CLONE
title . CR ( channel/title найдетс€ в клоне )
copyright . CR ( channel/copyright найдетс€ в оригинале )
getNode 1 libxml2.dll::xmlGetNodePath ASCIIZ> TYPE CR
PREVIOUS ( убрали клон )
getNode 1 libxml2.dll::xmlGetNodePath ASCIIZ> TYPE CR
PREVIOUS ( убрали оригинал )

ALSO http://forth.org.ru/rss.xml /rss channel WORDS PREVIOUS

ORDER

ALSO http://forth.org.ru/rss.xml
/rss DEFINITIONS
VOCABULARY TEST
S" ctest.xml" SAVE
