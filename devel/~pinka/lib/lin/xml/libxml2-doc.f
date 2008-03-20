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
