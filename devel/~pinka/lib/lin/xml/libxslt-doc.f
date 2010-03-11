
\ ior codes are compatiable with ~ac/lib/lin/xml/xslt.f

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
\ Serialize the result doc2 obtained by applying the docxsl stylesheet 
\ "It's up to the caller to free the memory with xmlFree()" -- FreeXmlString
  SWAP  0 >R RP@  0 >R RP@ ( docxsl doc2 a-len a-addr )
  4 xsltSaveResultToString IF  60007 THROW THEN
  R> R>
;
