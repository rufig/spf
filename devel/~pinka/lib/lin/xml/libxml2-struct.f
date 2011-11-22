\ Nov.2011
\ $Id$

REQUIRE [UNDEFINED] lib/include/tools.f

\ REQUIRE AsQName     ~pinka/samples/2006/syntax/qname.f \ понятие однословных строк в виде `abc
\ REQUIRE [UNDEFINED] lib/include/tools.f
\ REQUIRE libxml2.dll ~ac/lib/lin/xml/xml.f 

[UNDEFINED] COMMENT_NODE [IF]
 1 CONSTANT ELEMENT_NODE
 2 CONSTANT ATTRIBUTE_NODE
 3 CONSTANT TEXT_NODE
 4 CONSTANT CDATA_SECTION_NODE
 5 CONSTANT ENTITY_REFERENCE_NODE
 6 CONSTANT ENTITY_NODE
 7 CONSTANT PROCESSING_INSTRUCTION_NODE
 8 CONSTANT COMMENT_NODE
 9 CONSTANT DOCUMENT_NODE
10 CONSTANT DOCUMENT_TYPE_NODE
11 CONSTANT DOCUMENT_FRAGMENT_NODE
12 CONSTANT NOTATION_NODE
[THEN]

[UNDEFINED] /xmlNs [IF]
0 \ struct _xmlNs {
\    struct _xmlNs *    next    : next Ns link for this node
CELL -- xns.next
\    xmlNsType  type    : global or local
CELL -- xns.type
\    const xmlChar *    href    : URL for the namespace
CELL -- xns.href
\    const xmlChar *    prefix  : prefix for the namespace
CELL -- xns.prefix
\    void * _private    : application data
CELL -- xns._private
\    struct _xmlDoc *   context : normally an xmlDoc
CELL -- xns.context
CONSTANT /xmlNs
[THEN]


[UNDEFINED] /xmlNode [IF]
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
   2 -- x.line
\    unsigned short   extra;	/* extra data for XPath/XSLT */
   2 -- x.extra
\ };
CONSTANT /xmlNode
[THEN]

  
