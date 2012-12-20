REQUIRE EMBODY ~pinka/spf/forthml/index.f
REQUIRE STHROW ~pinka/spf/sthrow.f

REQUIRE  XslResultToString ~pinka/lib/lin/xml/xml-doc-lite.f
REQUIRE FILENAME-CONTENT   ~pinka/lib/files-ext.f

\ see also: http://xmlsoft.org/


`xslt.L2.f.xml EMBODY

  
  `../../../proposal/io.ru.xml FILENAME-CONTENT load-xml-chunk  0. load-xml-chunk
  \ buffer has been leaked ;)

  `../../../samples/2007/notion/xhtml.xsl  apply-xslt-result TYPE CR
