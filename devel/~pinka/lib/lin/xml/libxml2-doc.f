\ REQUIRE SO            ~ac/lib/ns/so-xt.f
\ ALSO SO NEW: libxml2.dll

128 256 OR 16384 OR VALUE xmlParserOption
\ pedantic error reporting
\ remove blank nodes
\ merge CDATA as text nodes
\ XML_PARSE_COMPACT  65536 : compact small text nodes

: FreeDoc ( doc -- )
  DUP 0= IF  DROP EXIT THEN
  1 xmlFreeDoc DROP
;
: LoadDoc ( file-a file-u -- doc )
  DROP
  xmlParserOption 0 ROT
  3 xmlReadFile
  DUP 0= IF  60002 THROW THEN 
; 
: LoadXmlDoc ( a u -- doc ) 
  2>R xmlParserOption 0 0 R> R>
  5 xmlReadMemory
  DUP 0= IF  60005 THROW THEN 
; 



\ m.b.

: CreatePushParserCtxt ( d-first-chunk d-filename -- ctxt|0 )
  DROP -ROT SWAP 0 0
  5 xmlCreatePushParserCtxt
  DUP IF EXIT THEN
  ABORT" error on CreatePushParserCtxt"
;
: ParseChunk ( d-chunk ctxt -- )
  >R
  DUP 0= -ROT SWAP R> \ ( terminate size chunk ctxt )
  4 xmlParseChunk 0= IF EXIT THEN
  ABORT" error on xmlParseChunk"
;
: ClearPushParserCtxt ( ctxt -- )
  >R 
  0 \ encoding
  0 \ filename
  0 \ size
  0 \ chunk
  R> \ ctxt
  5 xmlCtxtResetPush 0= IF EXIT THEN
  ABORT" error on xmlCtxtResetPush"
;
: FreeParserCtxt ( ctxt -- )
  1 xmlFreeParserCtxt DROP
  \ the parsed document in ctxt->myDoc is not freed.
;
: XmlDocFromCtxt ( ctxt -- doc )
  2 CELLS + @ 
;
: DumpDoc ( doc -- )
  XML_SERIALIZE TYPE
;

\EOF

: DumpDoc ( doc -- )
  H-STDOUT \ see http://xmlsoft.org/examples/io1.c
  2 xmlDocDump
  -1 <> IF EXIT THEN
  ABORT" error on xmlDocDump"
  \ ???  not work
;

