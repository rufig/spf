( ~ac 20.08.2005
  $Id$

  Подключение внешних XML-файлов [по имени файла или URL] в
  качестве контекстного форт-словаря. В результате поиск, 
  переключение контекстов, создание узлов в XML-файле  
  производится самим интерпретатором Форта, без необходимости 
  использования XMLDOM и прочих XML-специфичных API.

  Использование:
  ALSO XML_DOC NEW: http://forth.org.ru/rss.xml
  - создает словарь, привязанный к указанному URL и имеющий
  то же имя, и добавляет этот словарь в контекст поиска.
  Когда транслятор форта будет осуществлять следующий поиск -
  этот XML автоматически загрузится и поиск по его узлам будет
  производиться так, как если бы это был "встроенный" форт-словарь.
  Выполнение найденного узла заменяет текущую вершину контекста
  поиска на найденный узел в документе [как если бы он сам был
  определен через VOCABULARY], и дальнейший поиск будет вестись,
  начиная с него. Таким образом возможна запись:
  http://forth.org.ru/rss.xml /rss channel title
  которая в процессе исполнения найдет тот же узел, что и
  XPath-выражение /rss/channel/title.
  Слова "@" и "." в этих контекстах переопределены для извлечения
  и печати текстовых значений "контекстных узлов" соответственно.

  Библиотека еще в доработке, поэтому примеры в конце не отключены.
)

REQUIRE XML_READ_DOC_ROOT ~ac/lib/lin/xml/xml.f 
REQUIRE ForEachDirWRstr   ~ac/lib/ns/iter.f

: VOC-CLONE
  TEMP-WORDLIST >R
  CONTEXT @ CELL- R@ CELL- WL_SIZE MOVE
  ALSO R> CONTEXT !
;
<<: FORTH XML_NODE

: CAR { node -- node }
  node OBJ-DATA@ DUP
  IF firstNode
     DUP node OBJ-DATA! 0= IF 0 ELSE node THEN
  THEN
;
: CDR { node -- node }
  node OBJ-DATA@ DUP 
  IF nextNode
     DUP node OBJ-DATA! 0= IF 0 ELSE node THEN 
  THEN
;
: NAME ( node -- addr u )
  OBJ-DATA@ DUP x.type @ XML_ELEMENT_NODE =
  IF
    x.name @ ASCIIZ>
  ELSE DROP S" noname" THEN
;
: ?VOC DROP TRUE ; \ OBJ-DATA@ x.children @ 0<> ;

: >WID ( node -- node )
  ALSO CONTEXT !
  CONTEXT @ OBJ-DATA@ x.children @
  VOC-CLONE CONTEXT @ OBJ-DATA!
  CONTEXT @ PREVIOUS PREVIOUS
;

: SHEADER ( addr u -- )
\ Добавить xml-узел с именем addr u в текущий xml-узел "компиляции"
  GET-CURRENT OBJ-DATA@ XML_NEW_NODE DROP
;
: SEARCH-WORDLIST { c-addr u oid -- 0 | xt 1 | xt -1 }
\ Найти узел с именем c-addr u в xml-узле oid

  oid OBJ-DATA@ DUP \ node
  IF c-addr u ROT node@ DUP 
     IF \ найден узел с заданным именем
        ( менять в oid или в CONTEXT ?! - разные полезные свойства ...)
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

<<: FORTH XML_DOC

: CAR { doc -- node }
  doc OBJ-DATA@ \ если не загружен - загрузим
  0= IF doc OBJ-NAME@ " {s}" STR@ XML_READ_DOC doc OBJ-DATA! THEN
  
  doc OBJ-DATA@ DUP
  IF  ALSO CONTEXT @ OBJ-DATA! DOC>NODE CONTEXT @ PREVIOUS THEN
;
: CDR ( node -- node )
  DROP 0 \ корневой узел только один
;
: ?VOC ( node -- flag )
  DROP TRUE
;
: NAME ( node -- addr u )
  XML_NODE::NAME
;
: >WID ( node -- node )
  XML_NODE::>WID
;
: SAVE ( addr u -- ) GET-CURRENT OBJ-DATA@ XML_DOC_SAVE ;

: SEARCH-WORDLIST { c-addr u oid -- 0 | xt 1 | xt -1 }

\ сначала ищем в методах класса
  c-addr u [ GET-CURRENT ] LITERAL SEARCH-WORDLIST ?DUP IF EXIT THEN

  c-addr C@ [CHAR] / <> IF 0 EXIT THEN \ в документе ищем только корень

  oid OBJ-DATA@ \ doc; если не загружен - загрузим
  0= IF oid OBJ-NAME@ " {s}" STR@ XML_READ_DOC oid OBJ-DATA! THEN

  oid OBJ-DATA@ DUP
  IF \ удалось загрузить xml, теперь нужно выдать xt,
     \ который заменит контекст документа на контекст корневого узла
     DROP ['] DOC>NODE 1
  THEN
;
: WORDS "" ['] swid. CONTEXT @ ForEachDirWRstr ;
:>>

\ ниже почти << XML_DOC libxml-parser.html , но без манипуляций DEFINITIONS

100 TO WL_SIZE

\EOF

ALSO XML_DOC NEW: libxml-parser.html
libxml-parser.html / head title .
libxml-parser.html / head style .
libxml-parser.html WORDS
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
title . CR ( channel/title найдется в клоне )
copyright . CR ( channel/copyright найдется в оригинале )
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
