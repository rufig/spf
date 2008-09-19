REQUIRE EMBODY ~pinka/spf/forthml/index.f
REQUIRE STHROW ~pinka/spf/sthrow.f

REQUIRE  XslResultToString ~pinka/lib/lin/xml/xml-doc.f

\ see also: http://xmlsoft.org/


`xslt.L2.f.xml EMBODY

  
  `../../../proposal/io.ru.xml FILE load-xml-chunk  0. load-xml-chunk

  `../../../samples/2007/notion/xhtml.xsl  apply-xslt-result TYPE CR
