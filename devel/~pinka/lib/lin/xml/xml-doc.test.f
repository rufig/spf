\ current dir should be a location of this file

xml-doc-lite.f

: DumpDoc ( doc -- ) SerializeDoc 2DUP TYPE FreeXmlString ;


S" <root><test>passed</test>" 0. CreatePushParserCtxt VALUE p

S"  some other text </root>" p ParseChunk

0. p ParseChunk

p ParserCtxtDoc VALUE doc
doc DumpDoc CR
p FreeParserCtxt 0 TO p
doc DumpDoc CR
doc FreeDoc 0 TO doc

: stream-in ( -- addr u ) HERE DUP 100 ACCEPT 
  DUP 1 = IF OVER C@ 0x0D = IF DROP 0 THEN THEN \ workaround for UNIX-LINES on Win
;

: test ( -- )
 ." please, input xml document (ends with empty line): " CR
 ['] stream-in PerParseDoc DUP DumpDoc FreeDoc
;




0 VALUE docxsl
0 VALUE docxml
0 VALUE docxml-result

: test-xslt ( -- )
  S" ../../../samples/2007/notion/xhtml.xsl"  LoadDocXsl  TO docxsl
  S" ../../../proposal/io.ru.xml"             LoadDoc     TO docxml

  0 docxml docxsl ApplyStylesheet  TO docxml-result
  
  docxml-result docxsl XslResultToString  2DUP TYPE CR  FreeXmlString
;
