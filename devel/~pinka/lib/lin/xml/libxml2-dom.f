\ 29.Jan.2007 Mon 20:18 ruv
\ $Id$
( Обертка поверх libxml2, предоставляет подмножество функций DOM,
  пока все они относятся к типу R/O.

  Пример использования:
  `http://www.forth.org.ru/~ruvim/samples/ForthML/forthml.xml DefaultLSParser parseURI VALUE doc
  doc documentElement nodeName TYPE

  Убрана зависимость от libcurl.dll
)


REQUIRE [UNDEFINED]         lib/include/tools.f
REQUIRE documentElement     ~pinka/lib/lin/xml/libxml2-dom1.f

REQUIRE lib.libxml2         ~pinka/lib/lin/xml/libxml2-lib.f

[UNDEFINED] OBEY-SURE- [IF]
: OBEY-SURE ( c-addr u wid -- )
  SEARCH-WORDLIST IF EXECUTE EXIT THEN
  -321 THROW
;
: OBEY-SURE- ( wid c-addr u -- )
  ROT OBEY-SURE
;
[THEN]


\ =====
\ DOM3

lib.libxml2 PUSH-SCOPE

: normalizeURI ( addr-z u1 -- addr u2 )
  OVER >R `: SEARCH NIP IF CHAR+ THEN \ cut out a scheme
  1 xmlNormalizeURIPath THROW \ work for pathnames only 
  R> ASCIIZ>
;

: baseURI ( node -- a u )
  DUP ownerDocument  ( node doc )
  2 xmlNodeGetBase ?ASCIIZ> 
  \ "it does not return the document base (5.1.3), use xmlDocumentGetBase() for this"
  \ FIXME: "It's up to the caller to free the memory with xmlFree()"
  \ -- http://xmlsoft.org/html/libxml-tree.html#xmlNodeGetBase
  CUT-PATH \ workaround
;
: baseURI! ( addrz u node -- )
  NIP
  2 xmlNodeSetBase DROP
;
\ для слов, устанавливающих значения атрибутов, будем давать в имя суфикс '!'

: documentURI ( doc -- a u )
  DUP ownerDocument  ( node doc )
  2 xmlNodeGetBase ?ASCIIZ> \ there no "xmlDocumentGetBase" exactly
  \ see also: http://mail.gnome.org/archives/xml/2010-March/msg00004.html
;
: documentURI! ( addrz u doc -- )
  baseURI!
  \ [setting the doc URL]
  \ it's better to call xmlNodeSetBase()
  \ which will make sure it does a copy of the string to avoid memory crash
  \ when freeing the document ! 
  \ -- http://mail.gnome.org/archives/xml/2003-September/msg00112.html
;


DROP-SCOPE \ lib.libxml2



\ =====
\ DOM3 LS (Load and Save)
\ interface LSParser

\ здесь LSParser представлен словарем

lib.libxml2 PUSH-SCOPE

`DefaultLSParser WORDLIST-NAMED PUSH-DEVELOP

\ 0 VALUE xmlParserOption
 128 256 OR 16384 OR 65536 OR VALUE xmlParserOption

\ pedantic error reporting
\ remove blank nodes
\ merge CDATA as text nodes
\ XML_PARSE_COMPACT  65536 : compact small text nodes

: LOAD-XMLMEM ( addr u -- doc|0 )
  2>R xmlParserOption 0 0 R> R>
  5 xmlReadMemory
;
: LOAD-XMLMEM-ENC ( enca encu addr u -- doc|0 )
  2>R DROP xmlParserOption SWAP 0 R> R>
  5 xmlReadMemory
;
\ : LOAD-XMLDOC-VIA-CURL ( addrz u -- doc|0 )
\   2DUP
\   GET-FILE DUP >R STR@ LOAD-XMLMEM R> STRFREE
\   ( a u doc|0 )
\   DUP IF DUP >R documentURI! R> EXIT THEN
\   NIP NIP
\ ;
: LOAD-XMLDOC ( addrz u -- doc|0 )
  DROP
  xmlParserOption 0 ROT 
  3 xmlReadFile
;
: FREE-XML ( doc -- )
  1 xmlFreeDoc DROP
;
: ParseURI ( uri-a uri-u -- doc|0 ) LOAD-XMLDOC ;

: FreeDoc ( doc -- ) DUP IF 1 xmlFreeDoc THEN DROP ;

DROP-DEVELOP

PREVIOUS \ lib.libxml2


: parseURI ( uri-a uri-u LSParser -- document|0 )
  `ParseURI OBEY-SURE-
;
: freeDoc ( doc LSParser -- ) \ not standard. Proposal.
  `FreeDoc OBEY-SURE-
;

\ `test1.f.xml DefaultLSParser parseURI DUP . VALUE doc


\EOF

see also:

  xmlChar * xmlBuildURI     (const xmlChar * URI, const xmlChar * base)
  -- http://xmlsoft.org/html/libxml-uri.html#xmlBuildURI

  int   xmlNormalizeURIPath     (char * path)
  -- http://xmlsoft.org/html/libxml-uri.html#xmlNormalizeURIPath

  xmlChar * xmlURIEscape        (const xmlChar * str)
  -- http://xmlsoft.org/html/libxml-uri.html#xmlURIEscape
