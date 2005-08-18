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
  s STR@ SWAP 2 xmlRecoverMemory -> doc
\  addr 1 xmlRecoverFile -> doc \ встроенный http-клиент слабее curl'а
  doc 1 xmlDocGetRootElement listNodes
  doc 1 xmlFreeDoc DROP
  0 xmlCleanupParser DROP
;

\ S" http://www.forth.org.ru/rss.xml" XML_LIST_NODES
\ 0 0 S" http://localhost:8989/dsf3.rem?wsdl" DROP 3 xmlReadFile .
