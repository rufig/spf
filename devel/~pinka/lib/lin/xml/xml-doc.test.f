xml-doc.f

S" <root><test>passed</test>" 0. CreatePushParserCtxt VALUE p

S"  some other text </root>" p ParseChunk

0. p ParseChunk

p ParserCtxtDoc VALUE doc
doc DumpDoc CR
p FreeParserCtxt 0 TO p
doc DumpDoc CR
doc FreeDoc 0 TO doc

: stream-in ( -- addr u ) HERE DUP 100 ACCEPT ;

: test
 ." please, input xml document: " CR
 ['] stream-in PerParseDoc DUP DumpDoc FreeDoc
;
