
: FreeDocXsl ( docXsl -- ) 
  DUP 0= IF  DROP EXIT THEN 
  1 xsltFreeStylesheet DROP
; 
: LoadDocXsl ( file-a file-u -- docXsl ) (  xsltStylesheetPtr  ) 
  DROP 1 xsltParseStylesheetFile DUP 0= IF  60002 THROW THEN 
; 
: LoadXmlDocXsl ( a u -- docXsl ) 
  LoadXmlDoc 
  1 xsltParseStylesheetDoc DUP 0= IF  60002 THROW THEN 
; 
: ApplyStylesheet ( params doc docxsl -- doc2 ) 
  3 xsltApplyStylesheet DUP 0= IF  60004 THROW THEN 
; 
: XslResultToString ( doc2 docxsl -- addr u )
\ "It's up to the caller to free the memory with xmlFree()"
  SWAP  0 >R RP@  0 >R RP@ ( docxsl doc2 a-len a-addr )
  4 xsltSaveResultToString IF  60005 THROW THEN
  R> R>
;
: FreeXmlString ( addr u -- )
  DROP 1 XmlMemFree DROP
;
