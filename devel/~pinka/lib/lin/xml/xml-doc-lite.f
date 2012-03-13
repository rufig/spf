REQUIRE lexicon.basics-aligned ~pinka/lib/ext/basics.f

REQUIRE [DEFINED]     lib/include/tools.f
REQUIRE SO            ~ac/lib/ns/so-xt.f

\ PLATFORM S" Linux" CONTAINS [IF] ... [ELSE]

ALSO SO ?NEW: libxml2.dll
ALSO SO ?NEW: libxslt.dll

S" ~pinka/lib/lin/xml/libxml2-doc.f" INCLUDED
S" ~pinka/lib/lin/xml/libxslt-doc.f" INCLUDED


PREVIOUS PREVIOUS
