\ 29.Jan.2007 Mon 20:18 ruv
\ $Id$
( Обертка поверх libxml2, предоставляет подмножество функций DOM,
  пока все они относятся к типу R/O.

  Заметка. libxml2 зачастую предоставляет структуры как есть вместо функций 
   -- это в нашем случае дает экономию на вызовах API-функций :]
)

REQUIRE [UNDEFINED] lib/include/tools.f

REQUIRE AsQName     ~pinka/samples/2006/syntax/qname.f \ понятие однословных строк в виде `abc
REQUIRE EQUAL       ~pinka/lib/ext/basics.f

REQUIRE /xmlNs      ~pinka/lib/lin/xml/libxml2-struct.f 


[UNDEFINED] ?ASCIIZ> [IF]
: ?ASCIIZ> ( c-addr -- c-addr u | 0 0 ) DUP IF ASCIIZ> EXIT THEN 0 ;
[THEN]


\ CREATE ArrayIsTextValues  0 C, 1 C, 
\ : (isTextValue) ( type -- flag )

: nodeNameOrig ( node -- c-addr u | 0 0 ) x.name @ ?ASCIIZ> ;

: name-by-typecode ( type -- c-addr u )
  \ for special names only
  \ http://www.w3.org/TR/REC-DOM-Level-1/level-one-core.html#ID-1841493061
  DUP TEXT_NODE              = IF DROP `#text               EXIT THEN
  DUP COMMENT_NODE           = IF DROP `#comment            EXIT THEN
  DUP DOCUMENT_NODE          = IF DROP `#document           EXIT THEN
  DUP CDATA_SECTION_NODE     = IF DROP `#cdata-section      EXIT THEN
  DUP DOCUMENT_FRAGMENT_NODE = IF DROP `#document-fragment  EXIT THEN
  DROP 0.
;

\ =====
\ interface of Document

: documentElement ( document -- root_element_node )
  DUP IF
  x.children @   \ firstChild
  BEGIN DUP WHILE DUP x.type @ ( nodeType ) ELEMENT_NODE <> WHILE x.next @ ( nextSibling ) REPEAT THEN
  THEN
  \ function xmlDocGetRootElement(1-1)
;

\ =====
\ interface of Node

: nodeType ( node -- type ) x.type @ ;

: nodeName ( node -- c-addr u | 0 0 ) \ libxml2: name without prefix (!)
  DUP nodeType 3 U< IF nodeNameOrig EXIT THEN
  \ i.e. return the name as is for ELEMENT_NODE or ATTRIBUTE_NODE
  DUP >R nodeType name-by-typecode DUP IF RDROP EXIT THEN 2DROP
  R> nodeNameOrig
  \ it should return target for processing instruction node
;
: nodeValue  ( node -- c-addr u | 0 0 ) x.content @ ?ASCIIZ> ;
: ownerDocument ( node -- document|0 ) x.doc @ ;
: prefix ( node -- c-addr u | 0 0 ) x.ns @ DUP IF xns.prefix @ ?ASCIIZ> EXIT THEN 0 ;
: namespaceURI ( node -- c-addr u | 0 0 ) x.ns @ DUP IF xns.href  @ ?ASCIIZ> EXIT THEN 0 ;
\ DOM2: -- "It is merely the namespace URI given at creation time"

: localName ( node -- c-addr u | 0 0 ) DUP nodeType 3 U< IF nodeName EXIT THEN DROP 0. ;
\ DOM2: For nodes of any type other than ELEMENT_NODE and ATTRIBUTE_NODE ... this is always null.

: parentNode ( node1 -- node2|0 ) x.parent @ ;
: firstChild ( node1 -- node2|0 )  x.children @ ;
: lastChild ( node1 -- node2|0 )  x.last @ ;
: nextSibling ( node1 -- node2|0 ) x.next @ ;
: previousSibling ( node1 -- node2|0 ) x.prev @ ;

: hasAttributes ( node -- flag ) x.properties @ 0<> ;
: hasChildNodes ( node -- flag ) firstChild 0<> ;

\ =====
\ interface of Element ( not any node !!! )

\ to support:
: cdr-libxml2-name ( a u node1|0 -- a u node2|0 )
  BEGIN DUP WHILE >R
    2DUP R@ nodeName EQUAL R> SWAP 0= WHILE previousSibling
  REPEAT THEN
;
: cdr-libxml2-nameNS ( a u a1 u1 node1|0 -- a u a1 u1 node2|0 )
  -ROT 2>R BEGIN cdr-libxml2-name DUP WHILE
    DUP namespaceURI 2R@ EQUAL 0= WHILE nextSibling
  REPEAT THEN
  2R> ROT
;
: -cdr-libxml2-name ( name-a name-u node1|0 -- name-a name-u node2|0 )
  BEGIN DUP WHILE >R
    2DUP R@ nodeName EQUAL R> SWAP 0= WHILE nextSibling
  REPEAT THEN
;
: -cdr-libxml2-nameNS ( localname-a localname-u uri-a uri-u node1|0 -- localname-a localname-u uri-a uri-u node2|0 )
  -ROT 2>R BEGIN -cdr-libxml2-name DUP WHILE
    DUP namespaceURI 2R@ EQUAL 0= WHILE nextSibling
  REPEAT THEN
  2R> ROT
;

\ export:

: getAttributeNode ( name-a name-u node1 -- node2|0 ) 
  x.properties @ -cdr-libxml2-name NIP NIP
;
: getAttributeNodeNS ( localname-a localname-u uri-a uri-u node1 -- node2|0 )
  x.properties @ -cdr-libxml2-nameNS NIP NIP NIP NIP
;
: getAttribute ( c-addr u node -- c-addr2 u2 )
  getAttributeNode DUP IF firstChild DUP IF nodeValue EXIT THEN THEN DROP 0.
;
: getAttributeNS ( localname-a localname-u uri-a uri-u node -- c-addr u | 0 0 )
  getAttributeNodeNS DUP IF firstChild DUP IF nodeValue EXIT THEN THEN DROP 0.
;
: hasAttribute ( c-addr u node -- flag ) getAttributeNode 0<> ;
: hasAttributeNS ( localname-a localname-u uri-a uri-u node -- flag ) getAttributeNodeNS 0<> ;


: getAttributeNode- ( node1 name-a name-u -- node2|0 ) ROT getAttributeNode ;
: getAttributeNodeNS- ( node1 localname-a localname-u uri-a uri-u -- node2|0 ) 4 PICK getAttributeNodeNS NIP ;
: getAttribute- ( node c-addr u -- c-addr2 u2 ) ROT getAttribute ;
: getAttributeNS- ( node localname-a localname-u uri-a uri-u -- c-addr u | 0 0 ) 4 PICK getAttributeNS ROT DROP ;
: hasAttribute- ( node c-addr u -- flag ) ROT  hasAttribute ;
: hasAttributeNS- ( node localname-a localname-u uri-a uri-u -- flag ) getAttributeNodeNS- 0<> ;

\ =====
\ extentions of  Element interface

: firstChildByTagName ( name-a name-u node1 -- node2|0 )
  firstChild -cdr-libxml2-name NIP NIP
;
: firstChildByTagNameNS ( localname-a localname-u uri-a uri-u node -- node2|0 )
  firstChild -cdr-libxml2-nameNS NIP NIP NIP NIP
;
: nextSiblingByTagName ( name-a name-u node1 -- node2|0 ) 
  nextSibling -cdr-libxml2-name NIP NIP
;
: nextSiblingByTagNameNS ( localname-a localname-u uri-a uri-u node -- node2|0 )
  nextSibling -cdr-libxml2-nameNS NIP NIP NIP NIP
;
: nextSiblingEqual ( node1 -- node2|0 )
  DUP >R nodeName R> nextSiblingByTagName
;
: nextSiblingEqualNS ( node1 -- node2|0 )
  DUP >R localName R@ namespaceURI R> nextSiblingByTagNameNS
;

: lastChildByTagName ( name-a name-u node1 -- node2|0 )
  lastChild cdr-libxml2-name NIP NIP
;
: lastChildByTagNameNS ( localname-a localname-u uri-a uri-u node -- node2|0 )
  lastChild cdr-libxml2-nameNS NIP NIP NIP NIP
;
: previousSiblingByTagName ( name-a name-u node1 -- node2|0 )
  previousSibling cdr-libxml2-name NIP NIP
;
: previousSiblingByTagNameNS ( localname-a localname-u uri-a uri-u node -- node2|0 )
  previousSibling cdr-libxml2-nameNS NIP NIP NIP NIP
;

: firstChildByTagName- ( node1 name-a name-u -- node2|0 ) ROT firstChildByTagName ;
: firstChildByTagNameNS- ( node1 localname-a localname-u uri-a uri-u -- node2|0 ) 4 PICK firstChildByTagNameNS NIP ;
: nextSiblingByTagName- ( node1 name-a name-u -- node2|0 )  ROT nextSiblingByTagName ;
: nextSiblingByTagNameNS- ( node1 localname-a localname-u uri-a uri-u -- node2|0 ) 4 PICK nextSiblingByTagNameNS NIP ;
: lastChildByTagName- ( node1 name-a name-u -- node2|0 ) ROT lastChildByTagName ;
: lastChildByTagNameNS- ( node1 localname-a localname-u uri-a uri-u -- node2|0 )  4 PICK lastChildByTagNameNS NIP ;
: previousSiblingByTagName- ( node1 name-a name-u -- node2|0 ) ROT previousSiblingByTagName ;
: previousSiblingByTagNameNS- ( node1 localname-a localname-u uri-a uri-u -- node2|0 ) 4 PICK previousSiblingByTagNameNS NIP ;

: foreachChild ( xt node -- ) \ xt ( node -- )
  SWAP >R
  firstChild BEGIN DUP WHILE R@ OVER >R EXECUTE R> nextSibling REPEAT DROP RDROP
;

: searchNamespaceLocal ( prefix-a prefix-u node -- ns-a ns-u TRUE | prefix-a prefix-u FALSE )
  x.ns @
  BEGIN DUP WHILE >R
    2DUP R@ xns.prefix @ ?ASCIIZ> EQUAL IF 2DROP R> xns.href @ ?ASCIIZ> TRUE EXIT THEN
    R> xns.next @
  REPEAT ( a u 0 )
;
\ namespaceByPrefix | searchNamespaceURI | searchPrefixURI 
: searchNamespace ( prefix-a prefix-u node -- ns-a ns-u TRUE | prefix-a prefix-u FALSE )
\ libxml2: список xmlns есть только у корневого элемента,
\ определенные локально пространства имен таким путем недоступны (кроме xmlns самого узла)
  DUP >R searchNamespaceLocal IF RDROP TRUE EXIT THEN
  R> ownerDocument documentElement searchNamespaceLocal
;
: foreachNamespace ( xt node -- ) \ xt ( uri-a uri-u prefix-a prefix-u -- )
  SWAP >R
  ownerDocument documentElement
  x.ns @ BEGIN DUP WHILE
    DUP xns.href   @ ?ASCIIZ>  ROT
    DUP xns.prefix @ ?ASCIIZ>  ROT
    R@ SWAP >R EXECUTE R> xns.next @
  REPEAT DROP RDROP
;
: namespace-uri-for-prefix ( prefix-a prefix-u node -- uri-a uri-u | 0 0 )
  DUP ownerDocument
  BEGIN 2DUP <> WHILE \ document-element has't the x.ns property
  >R DUP >R searchNamespaceLocal IF RDROP RDROP EXIT THEN
  R> parentNode R>
  REPEAT 2DROP 2DROP 0.
;

: firstChildValue ( element -- c-addr u )
  firstChild DUP IF nodeValue EXIT THEN 0
;
: nodeLineNumber ( node -- line_in_source_file|0 )
  \ Номер строки узла в исходном файле xml-документа.
  \ Именованно по аналогии с nodeName.
  \ libxml2: 
  \  для текстовых узлов всегда дает 0
  \  для узлов-комментариев номер строки, где комментарий заканчивается
  x.line W@
;
