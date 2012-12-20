REQUIRE libxml2.dll  ~ac/lib/lin/xml/xml.f
REQUIRE libxslt.dll  ~ac/lib/lin/xml/xslt.f
\ It brings dependence on cURL
\ Use xml-doc-lite.f to avoid this dependence.

ALSO libxml2.dll
ALSO libxslt.dll

S" ~pinka/lib/lin/xml/libxml2-doc.f" INCLUDED
S" ~pinka/lib/lin/xml/libxslt-doc.f" INCLUDED

PREVIOUS PREVIOUS
