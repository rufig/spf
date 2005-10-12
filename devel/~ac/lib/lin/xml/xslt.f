WARNING @ WARNING 0!
REQUIRE SO            ~ac/lib/ns/so-xt.f
REQUIRE STR@          ~ac/lib/str5.f
REQUIRE GET-FILE      ~ac/lib/lin/xml/xml.f
REQUIRE UNICODE>UTF8  ~ac/lib/win/com/com.f
WARNING !

ALSO SO NEW: libxslt.dll

: XSLT { xaddr xu saddr su \ style doc res len str -- addr u }
\ преобразовать XML-файл с именем/url xaddr xu с использованием XSL-файла saddr su
  saddr 1 xsltParseStylesheetFile DUP -> style 0= IF 60002 THROW THEN
  xaddr xu XML_READ_DOC DUP -> doc 0= IF 60003 THROW THEN
  0 doc style 3 xsltApplyStylesheet DUP -> res 0= IF 60004 THROW THEN
  style res ^ len ^ str 4 xsltSaveResultToString DROP str len
\  0 style res S" test11.xml" DROP 4 xsltSaveResultToFilename .
;
: XSLTm { xaddr xu saddr su \ style doc res len str -- addr u }
\ преобразовать XML-строку xaddr xu с использованием XSL-файла saddr su
  saddr 1 xsltParseStylesheetFile DUP -> style 0= IF 60002 THROW THEN
  xaddr xu XML_READ_DOC_MEM DUP -> doc 0= IF 60005 THROW THEN
  0 doc style 3 xsltApplyStylesheet DUP -> res 0= IF 60004 THROW THEN
  style res ^ len ^ str 4 xsltSaveResultToString DROP str len
\  0 style res S" test11.xml" DROP 4 xsltSaveResultToFilename .
;
PREVIOUS

\ S" 1.xml" S" 1.xsl" XSLT
\ Здесь запись имя:пароль поддерживается через curl, а сам libxml не умеет.
\ И внутри XSL-файлов в document() имя:пароль не работают.
\ S" http://name:pass@localhost/rep/Domains.xml" S" dbtable.xsl" XSLT TYPE
