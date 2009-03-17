( Разбор XML через библиотеку LIBXML2
  ~ac: переписал через so-xt.f 18.08.2005
  $Id$

  Для компиляции нужны следующие dll:
  libxml2.dll iconv.dll zlib1.dll   
  libcurl.dll zlibwapi.dll
)  
  
WARNING @ WARNING 0!
REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE STR@          ~ac/lib/str5.f
REQUIRE GET-FILE      ~ac/lib/lin/curl/curl.f
REQUIRE 1-!           ~pinka/lib/ext/basics.f 
WARNING !

REQUIRE UNICODE>UTF8  ~ac/lib/lin/iconv/iconv.f

ALSO SO NEW: libxml2.dll
ALSO SO NEW: libxml2.so.2

\ struct _xmlNode {
0
\    void           *_private;	/* application data */
CELL -- x._private
\    xmlElementType   type;	/* type number, must be second ! */
CELL -- x.type
\    const xmlChar   *name;      /* the name of the node, or the entity */
CELL -- x.name
\    struct _xmlNode *children;	/* parent->childs link */
CELL -- x.children
\    struct _xmlNode *last;	/* last child link */
CELL -- x.last
\    struct _xmlNode *parent;	/* child->parent link */
CELL -- x.parent
\    struct _xmlNode *next;	/* next sibling link  */
CELL -- x.next
\    struct _xmlNode *prev;	/* previous sibling link  */
CELL -- x.prev
\    struct _xmlDoc  *doc;	/* the containing document */
CELL -- x.doc
\    /* End of common part */
\    xmlNs           *ns;        /* pointer to the associated namespace */
CELL -- x.ns
\    xmlChar         *content;   /* the content */
CELL -- x.content
\    struct _xmlAttr *properties;/* properties list */
CELL -- x.properties
\    xmlNs           *nsDef;     /* namespace definitions on this node */
CELL -- x.nsDef
\    void            *psvi;	/* for type/PSVI informations */
CELL -- x.psvi
\    unsigned short   line;	/* line number */
CELL -- x.line
\    unsigned short   extra;	/* extra data for XPath/XSLT */
CELL -- x.extra
\ };
CONSTANT /xmlNode

1 CONSTANT XML_ELEMENT_NODE

0
CELL -- xpo.type       \ xmlXPathObjectType
CELL -- xpo.nodesetval \ xmlNodeSetPtr
CELL -- xpo.boolval    \ int
[DEFINED] WINAPI: [IF]
  12 -- xpo.floatval   \ double
[ELSE]
   8 -- xpo.floatval   \ double
[THEN]
CELL -- xpo.stringval  \ xmlChar
CELL -- xpo.user       \ void
CELL -- xpo.index      \ int
CELL -- xpo.user2      \ void
CELL -- xpo.index2     \ int
CONSTANT /xmlXPathObject

0
CELL -- xns.nodeNr     \ int : number of nodes in the set
CELL -- xns.nodeMax    \ int : size of the array as allocated
CELL -- xns.nodeTab    \ xmlNodePtr : array of nodes in no particular order @
CONSTANT /xmlNodeSet

0 \ Structure xmlBuffer
CELL -- xb.content  \    xmlChar *   content : The buffer content UTF8
CELL -- xb.use      \    unsigned int    use : The buffer size used
CELL -- xb.size     \    unsigned int    size : The buffer size
CELL -- xb.alloc    \    xmlBufferAllocationScheme   alloc : The realloc method
CONSTANT /xmlBuffer

\ The realloc methods:
1 CONSTANT XML_BUFFER_ALLOC_DOUBLEIT
2 CONSTANT XML_BUFFER_ALLOC_EXACT
3 CONSTANT XML_BUFFER_ALLOC_IMMUTABLE


USER RECURSE-LEVEL
\ : 1-! DUP @ 1- SWAP ! ;
VECT vlistNodes
VARIABLE XML_GS \ GlobalState потока, вызвавшего XML_INIT
                \ а вообще xmlGetGlobalState свой у каждого потока

: nextNode
\ пропуск текстовых узлов, атрибутов, комментариев и т.д.
  BEGIN
    x.next @ DUP
  WHILE
    DUP x.type @ XML_ELEMENT_NODE = IF EXIT THEN
  REPEAT
;
: 1stNode
  BEGIN
    DUP x.type @ XML_ELEMENT_NODE = IF EXIT THEN
    x.next @ DUP 0=
  UNTIL
;
: attrDump ( node -- )
  x.properties @
  BEGIN
    DUP
  WHILE
\    DUP x.type @ . \ 2
    DUP x.name @ ASCIIZ> SPACE TYPE 
    DUP x.children @ ?DUP 
        IF \ x.name -> "text"
           x.content @ ?DUP IF ." ='" ASCIIZ> TYPE ." '" THEN 
        THEN
        x.next @
  REPEAT DROP
;
: nodeDump ( node -- )
  CR DUP x.name @ ASCIIZ> RECURSE-LEVEL @ 4 * SPACES ." <" TYPE
  DUP attrDump
  ." >"
\    DUP x.line ." line=" @ .
    DUP x.children @ ?DUP IF RECURSE-LEVEL 1+! vlistNodes RECURSE-LEVEL 1-! THEN

  CR DUP x.name @ ASCIIZ> RECURSE-LEVEL @ 4 * SPACES ." </" TYPE ." >"
  DROP
;
: listNodes ( node -- )
  BEGIN
    DUP
  WHILE
    DUP x.type @ XML_ELEMENT_NODE =
    IF DUP nodeDump
    ELSE
       DUP x.children @ ?DUP IF RECURSE-LEVEL 1+! RECURSE RECURSE-LEVEL 1-! THEN
    THEN
        x.next @
  REPEAT DROP
;
' listNodes TO vlistNodes

: attr@ { addr u node -- node2 }
  node x.properties @
  BEGIN
    DUP
  WHILE
    DUP x.name @ ASCIIZ> addr u COMPARE 0= IF EXIT THEN
    x.next @
  REPEAT
;
\ : attr@ ( addr u node -- node2 )
\ в т.ч. из DTD
\   NIP 2 xmlHasProp
\ ;

: node@ { addr u node -- node2 }
  addr C@ [CHAR] @ = IF addr 1+ u 1- 0 MAX node attr@ EXIT THEN
  node x.children @
  BEGIN
    DUP
  WHILE
    DUP x.type @ XML_ELEMENT_NODE =
    IF DUP x.name @ ASCIIZ> addr u COMPARE 0= IF EXIT THEN
    THEN
    x.next @
  REPEAT
;
: text@ ( node -- addr u )
  1 xmlNodeGetContent ASCIIZ> UTF8>UNICODE OVER >R UNICODE> R> FREE THROW
;
: nodeText ( addr u node -- addr2 u2 )
  node@ ?DUP IF text@
             ELSE S" " THEN
;

: dumpNodeSet { res -- }
  res xpo.nodesetval @ ?DUP
  IF xns.nodeNr @ 0
     ?DO
        res xpo.nodesetval @ xns.nodeTab @ I CELLS + @
        x.children @ ( listNodes)
\          1 SWAP doc 3 xmlNodeListGetString ASCIIZ> TYPE CR \ ниже то же самое, без выделения памяти
        ?DUP IF x.content @ ?DUP IF ASCIIZ> TYPE CR THEN THEN
     LOOP
  THEN
;
USER uLastNodeSetStr
: LNSFREE uLastNodeSetStr @ ?DUP IF STRFREE THEN uLastNodeSetStr 0! ;

: dumpNodeSet@ { res \ s -- addr u }
  "" -> s
  res xpo.nodesetval @ ?DUP
  IF xns.nodeNr @ 0
     ?DO
        res xpo.nodesetval @ xns.nodeTab @ I CELLS + @
        x.children @ ( listNodes)
        1 xmlNodeGetContent ?DUP
        IF
          ASCIIZ> UTF8>UNICODE OVER >R UNICODE> R> FREE THROW
          OVER >R
          s STR+ CRLF s STR+
          R> FREE THROW
        ELSE
          CRLF s STR+
        THEN
     LOOP
  THEN
  s uLastNodeSetStr !
  s STR@ 2- 0 MAX
;
: dumpBool xpo.boolval @ . ;
: dumpBool@ xpo.boolval @ ;
: dumpFloat xpo.floatval 12 DUMP ;
: dumpFloat@ xpo.floatval ;
: dumpString xpo.stringval @ ASCIIZ> TYPE ;
: dumpString@ xpo.stringval @ ASCIIZ> ;

CREATE xpathTypes ' dumpNodeSet , ' dumpBool , ' dumpFloat , ' dumpString ,
CREATE xpathTypes@ ' dumpNodeSet@ , ' dumpBool@ , ' dumpFloat@ , ' dumpString@ ,

: XML_NLIST ( node -- )
  x.children @
  BEGIN
    DUP
  WHILE
     DUP x.type @ XML_ELEMENT_NODE =
     IF \ т.е. ищутся только элементы, то и печатаем только их,
        \ а текстовые узлы не выводим
       DUP x.name @ ?DUP IF ASCIIZ> TYPE SPACE ELSE DUP . THEN
     THEN
     x.next @
  REPEAT DROP
;

: XML_READ_DOC_MEM { addr u -- doc }
  97 ( noerror|nowarning|recover) 0 0 u addr 5 xmlReadMemory
;
: XML_READ_DOC_MEM_ENC { enca encu addr u -- doc }
  97 ( noerror|nowarning|recover) enca 0 u addr 5 xmlReadMemory
;
: XML_READ_DOC ( addr u -- doc )
  GET-FILE DUP STR@ XML_READ_DOC_MEM SWAP STRFREE
;
: XML_READ_DOC_ENC { enca encu addr u -- doc }
  addr u GET-FILE DUP STR@ enca encu 2SWAP XML_READ_DOC_MEM_ENC SWAP STRFREE
;
: XML_DOC_ROOT ( doc -- node )
  1 xmlDocGetRootElement
;
: XML_READ_DOC_ROOT ( addr u -- node )
  XML_READ_DOC XML_DOC_ROOT
;
: XML_XPATH_MEM_XT { addr u xpaddr xpu xt \ doc ctx res -- }
  addr u XML_READ_DOC_MEM -> doc
  doc 1 xmlXPathNewContext -> ctx
  ctx xpaddr 2 xmlXPathEvalExpression -> res
  ctx 1 xmlXPathFreeContext DROP
  res IF res xpo.type @ 1- 0 MAX CELLS xt + @ res SWAP EXECUTE THEN
  res 1 xmlXPathFreeObject DROP
  doc 1 xmlFreeDoc DROP
;
: XML_XPATH_MEM ( addr u xpaddr xpu -- )
  xpathTypes XML_XPATH_MEM_XT
;
: XML_XPATH_XT { addr u xpaddr xpu xt \ s -- }
  addr u GET-FILE -> s
  s STR@ xpaddr xpu xt XML_XPATH_MEM_XT
  s STRFREE
;
: XML_XPATH ( addr u xpaddr xpu -- )
  xpathTypes XML_XPATH_XT
;
: XML_XPATH@ ( addr u xpaddr xpu -- addr2 u2 )
  xpathTypes@ XML_XPATH_XT
;
: XML_XPATH_MEM@ ( addr u xpaddr xpu -- addr2 u2 )
  xpathTypes@ XML_XPATH_MEM_XT
;
: XML_SERIALIZE { doc \ mem size -- addr2 u2 }
  ^ size ^ mem doc 3 xmlDocDumpMemory DROP mem size
;
: XML_SERIALIZE_ENC { enca encu doc \ mem size -- addr2 u2 }
  enca ^ size ^ mem doc 4 xmlDocDumpMemoryEnc DROP mem size
;
: XML_SERIALIZE_NODE ( node -- addr u ) \ encoding is UTF-8
  0 xmlBufferCreate  { node buf }
  0 0 node node x.doc @ buf
  5 xmlNodeDump ( len )
  \ buf xb.content @  buf xb.use @
  buf 1 xmlBufferContent SWAP
;
: XML_SERIALIZE_NODE_ENC ( encz-a encz-u node -- addr2 u2 ) \ ~ruv
  0 xmlBufferCreate  >R
  NIP 0 ROT R@ 3 xmlSaveToBuffer DUP 0= IF ABORT THEN ( options encoding-z buff -- ctxt )
  DUP >R 2 xmlSaveTree -1 = IF ABORT THEN ( node ctxt -- )
  R> 1 xmlSaveClose DUP -1 = IF ABORT THEN ( len )
  DROP \ т.к. врет иногда.
  \ R@ 1 xmlBufferContent
  R@ xb.content @ R> xb.use @
;
\ see also:
\   xmlBufferFree ( xmlBufferPtr -- void )
\   xmlNodeDumpOutput ( encoding format level node doc xmlOutputBufferPtr -- void )
\   xmlOutputBufferCreateBuffer ( xmlCharEncodingHandlerPtr|0 xmlBufferPtr -- xmlOutputBufferPtr )
\   xmlOutputBufferClose ( xmlOutputBufferPtr -- int )

: XML_LIST_NODES { addr u \ doc -- }
  addr u XML_READ_DOC -> doc
  doc 1 xmlDocGetRootElement listNodes
  doc 1 xmlFreeDoc DROP
;
: XML_DOC_SAVE ( addr u doc -- )
  NIP SWAP 2 xmlSaveFile DROP
;
: XML_DUMP_NODES ( addr u -- ) { \ doc }
  XML_READ_DOC -> doc
  doc S" -" DROP 2 xmlSaveFile DROP
  doc 1 xmlFreeDoc DROP
;
: XML_SAVE_URL { uaddr uu faddr fu \ doc -- }
  uaddr uu XML_READ_DOC -> doc
  doc faddr 2 xmlSaveFile DROP
  doc 1 xmlFreeDoc DROP
;
: XML_SAVE_URL_ENC { enca encu uaddr uu faddr fu \ doc -- }
  enca encu uaddr uu XML_READ_DOC_ENC -> doc
  enca doc faddr 3 xmlSaveFileEnc DROP
  doc 1 xmlFreeDoc DROP
;
: XML_DOC_TEXT  ( addr u -- addr2 u2 ) { \ doc }
  XML_READ_DOC -> doc
  doc 1 xmlDocGetRootElement
\  doc H-STDOUT 3 xmlElemDump DROP
  1 xmlNodeGetContent ASCIIZ> \ выдает UTF-8
;
: NODE>DOC
  x.doc @
;
: XML_NEW_NODE { addr u node \ s -- new_node }
  addr u " {s}" -> s
  0 s STR@ DROP 0 node NODE>DOC 4 xmlNewDocNode DUP
  node 2 xmlAddChild DROP s STRFREE
;
: XML_INIT
\  XML_GS @ IF EXIT THEN
  0 xmlInitParser DROP
  0 xmlInitThreads DROP
\  0 xmlLockLibrary DROP
  0 xmlGetGlobalState XML_GS !
;
: XML_CLEAN
  0 xmlCleanupParser DROP
;

VARIABLE XML-ERR

: XML-GLOBAL-INIT ['] XML_INIT CATCH XML-ERR !
\  DUP 126 = IF DROP ELSE THROW THEN
;
..: AT-PROCESS-STARTING XML-GLOBAL-INIT ;..
XML-GLOBAL-INIT

\ S" http://www.w3schools.com/xpath/xpath_functions.asp" XML_LIST_NODES
\ S" http://www.forth.org.ru/xpath_functions.asp.htm" S" //td[@valign='top' and starts-with(.,'fn:')]" XML_XPATH
\ S" http://forth.org.ru/log/SpfDevChangeLog.xml" S" //entry[position()<11]/*/name" XML_XPATH
\ S" <dummy/>" S" string(123)" XML_XPATH_MEM
\ S" <dummy/>" S" number(5.5)" XML_XPATH_MEM
\ S" <dummy/>" S" boolean(1)" XML_XPATH_MEM
\ S" http://www.forth.org.ru/rss.xml" S" //link" XML_XPATH
\ S" http://www.forth.org.ru/rss.xml" S" //item/description" XML_XPATH
\ S" http://www.forth.org.ru/rss.xml" S" /rss/channel/image/url" XML_XPATH

\ S" http://www.forth.org.ru/rss.xml" XML_LIST_NODES
\ S" http://www.forth.org.ru/rss.xml" XML_DUMP_NODES
\ S" http://www.forth.org.ru/rss.xml" XML_DOC_TEXT TYPE CR
\ 0 0 S" http://localhost:8989/dsf3.rem?wsdl" DROP 3 xmlReadFile .
\ S" windows-1251" S" http://www.eserv.ru/" S" eserv.xml" XML_SAVE_URL_ENC

\ S" <text attr='zz'>test</text>" XML_READ_DOC_MEM XML_SERIALIZE TYPE
\ S" http://www.forth.org.ru/rss.xml" XML_READ_DOC XML_SERIALIZE TYPE
\ S" UTF-8" S" http://www.forth.org.ru/rss.xml" XML_READ_DOC XML_SERIALIZE_ENC TYPE
\ S" windows-1251" S" D:\ac\mm\1.xml" S" test1.xml" XML_SAVE_URL_ENC
\ S" D:\ac\mm\1.xml" S" //node/@TEXT" XML_XPATH@ TYPE
\ S" D:\ac\mm\1.xml" S" //node/@CREATED" XML_XPATH@ TYPE
\ S" <text attr='zz'>test</text>" XML_READ_DOC_MEM XML_DOC_ROOT S" attr" ROT attr@ text@ TYPE
\ S" <text attr='zz'>test</text>" XML_READ_DOC_MEM XML_DOC_ROOT S" @attr" ROT node@ text@ TYPE
(
: TEST { \ doc root }
  S" 1.0" DROP 1 xmlNewDoc -> doc
 \ doc XML_DOC_ROOT .
  S" this is content рус, " >UTF8 DROP
  S" node_name" DROP 0 doc 4 xmlNewDocNode  -> root
  root doc 2 xmlDocSetRootElement DROP
  S" this is comment" DROP doc 2 xmlNewDocComment doc 2 xmlAddChild DROP
  S" это добавочный <text>текст</text>" >UTF8 SWAP doc 3 xmlNewDocTextLen root 2 xmlAddChild DROP
  S" windows-1251" DROP doc S" create_test.xml" DROP 3 xmlSaveFileEnc DROP
; TEST
)
\ ALSO libxml2.dll DEFINITIONS : TEST ; \ должно вызвать 5 THROW
PREVIOUS PREVIOUS
