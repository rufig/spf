\ Nov.2012 ruv
\ $Id$
( ќбертка поверх libxml2, 
  вывод XML
)

REQUIRE [UNDEFINED]         lib/include/tools.f
REQUIRE STHROW              ~pinka/spf/sthrow.f
REQUIRE AsQName             ~pinka/samples/2006/syntax/qname.f \ однословные строки в виде `abc
REQUIRE lib.libxml2         ~pinka/lib/lin/xml/libxml2-lib.f

: (* BEGIN PARSE-NAME DUP IF `*) EQUAL ELSE 2DROP REFILL 0= THEN UNTIL ; IMMEDIATE

lib.libxml2 PUSH-SCOPE

: freeWriter ( writer -- )
  1 xmlFreeTextWriter DROP
;
: createWriterFilename ( d-filename -- writer|0 )
  DROP 0 SWAP
  2 xmlNewTextWriterFilename
  DUP 0<> IF EXIT THEN
  `#xmlsoft.NewTextWriterFilename STHROW
;
\ see also:
\ xmlTextWriterPtr	xmlNewTextWriter	(xmlOutputBufferPtr out)
\ xmlTextWriterPtr	xmlNewTextWriterMemory	(xmlBufferPtr buf, int compression)
\ xmlTextWriterPtr	xmlNewTextWriterDoc	(xmlDocPtr * doc, int compression)
\ xmlTextWriterPtr	xmlNewTextWriterTree	(xmlDocPtr doc, xmlNodePtr node, int compression)

: setWriterIndentNumber ( n writer -- )
  2 xmlTextWriterSetIndent
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterSetIndent STHROW
;
: setWriterIndentText ( d-text writer -- )
  NIP
  2 xmlTextWriterSetIndentString
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterSetIndentString STHROW
;

(*
: setWriterQuoteChar ( code writer -- )
  2 xmlTextWriterSetQuoteChar
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterSetQuoteChar STHROW
;
: setWriterQuote ( d-text writer -- )
  DUP IF DROP C@ ELSE NIP THEN
  setWriterQuoteChar
;
\ It will be available in the first release of libxml2 after 2012-09-11
\ see also:
\ http://git.gnome.org/browse/libxml2/commit/xmlwriter.c?id=429d3a0aae2eda7ba9451f9c9f8523c61cc0368b
*)

: writeRaw ( d-content writer -- )
  >R SWAP R>
  3 xmlTextWriterWriteRawLen
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterWriteRawLen STHROW
;

: writeStartDocument ( d-encoding writer -- )
  >R DROP
  0     \ standalone (default not declared)
  SWAP  \ encoding (default not declared "UTF-8")
  0     \ version (default "1.0")
  R>    \ writer
  4 xmlTextWriterStartDocument \ retuns -1 in case of error
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterStartDocument STHROW
;
: writeEndDocument ( writer -- )
  1 xmlTextWriterEndDocument
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterEndDocument STHROW
;

: writeStartElement ( d-tagname writer -- )
  NIP
  2 xmlTextWriterStartElement \ retuns -1 in case of error
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterStartElement STHROW
;
: writeEndElement ( writer -- )
  1 xmlTextWriterEndElement
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterEndElement STHROW
;
: writeElement ( d-content d-tagname writer -- )
  >R DROP NIP R>
  3 xmlTextWriterWriteElement
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterWriteElement STHROW
;


: writeStartAttribute ( d-tagname writer -- )
  NIP
  2 xmlTextWriterStartAttribute
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterStartAttribute STHROW
;
: writeEndAttribute ( writer -- )
  1 xmlTextWriterEndAttribute
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterEndAttribute STHROW
;
: writeAttribute ( d-content d-tagname writer -- )
  >R DROP NIP R>
  3 xmlTextWriterWriteAttribute
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterWriteAttribute STHROW
;

: writeText ( d-text writer -- )
  NIP
  2 xmlTextWriterWriteString
  -1 <> IF EXIT THEN
  `#xmlsoft.TextWriterWriteString STHROW
;



DROP-SCOPE \ lib.libxml2
