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
WARNING !

ALSO SO NEW: libxml2.dll

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
  12 -- xpo.floatval   \ double
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

USER RECURSE-LEVEL
: 1-! DUP @ 1- SWAP ! ;
VECT vlistNodes

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

: XML_LIST_NODES { addr u \ s doc -- }
  addr u GET-FILE -> s
\  s STR@ SWAP 2 xmlRecoverMemory -> doc
  97 ( noerror|nowarning|recover) 0 0 s STR@ SWAP 5 xmlReadMemory -> doc
\  addr 1 xmlRecoverFile -> doc \ встроенный http-клиент слабее curl'а
  doc 1 xmlDocGetRootElement listNodes
  doc 1 xmlFreeDoc DROP
  0 xmlCleanupParser DROP
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
: dumpBool xpo.boolval @ . ;
: dumpFloat xpo.floatval 12 DUMP ;
: dumpString xpo.stringval @ ASCIIZ> TYPE ;

CREATE xpathTypes ' dumpNodeSet , ' dumpBool , ' dumpFloat , ' dumpString ,

: XML_XPATH { addr u xpaddr xpu \ s doc ctx res -- }
  addr u GET-FILE -> s
\  s STR@ SWAP 2 xmlRecoverMemory -> doc
  97 ( noerror|nowarning|recover) 0 0 s STR@ SWAP 5 xmlReadMemory -> doc
  doc 1 xmlXPathNewContext -> ctx
  ctx xpaddr 2 xmlXPathEvalExpression -> res
  ctx 1 xmlXPathFreeContext DROP
  res IF res xpo.type @ 1- 0 MAX CELLS xpathTypes + @ res SWAP EXECUTE THEN
  res 1 xmlXPathFreeObject DROP
  doc 1 xmlFreeDoc DROP
  0 xmlCleanupParser DROP
;

\ S" http://www.w3schools.com/xpath/xpath_functions.asp" 
\ S" http://www.forth.org.ru/xpath_functions.asp.htm" S" //td[@valign='top' and starts-with(.,'fn:')]" XML_XPATH
\ S" http://forth.org.ru/log/SpfDevChangeLog.xml" S" //entry[position()<11]/*/name" XML_XPATH
\ S" http://forth.org.ru/log/SpfDevChangeLog.xml" S" string(123)" XML_XPATH
\ S" http://forth.org.ru/log/SpfDevChangeLog.xml" S" number(5.5)" XML_XPATH
\ S" http://forth.org.ru/log/SpfDevChangeLog.xml" S" boolean(1)" XML_XPATH
\ S" http://www.forth.org.ru/rss.xml" S" //link" XML_XPATH
\ S" http://www.forth.org.ru/rss.xml" S" //item/description" XML_XPATH
\ S" http://www.forth.org.ru/rss.xml" S" /rss/channel/image/url" XML_XPATH

\ S" http://www.forth.org.ru/rss.xml" XML_LIST_NODES
\ 0 0 S" http://localhost:8989/dsf3.rem?wsdl" DROP 3 xmlReadFile .
