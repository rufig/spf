REQUIRE lexicon.basics-aligned ~pinka/lib/ext/basics.f

REQUIRE [DEFINED]     lib/include/tools.f
REQUIRE SO            ~ac/lib/ns/so-xt.f

\ PLATFORM S" Linux" CONTAINS [IF] ... [ELSE]

[DEFINED] libxml2.dll       [IF]
ALSO libxml2.dll            [ELSE]
ALSO SO NEW: libxml2.dll    [THEN]

[DEFINED] libxslt.dll       [IF]
ALSO libxslt.dll            [ELSE]
ALSO SO NEW: libxslt.dll    [THEN]



S" ~pinka/lib/lin/xml/libxml2-doc.f" INCLUDED
S" ~pinka/lib/lin/xml/libxslt-doc.f" INCLUDED


PREVIOUS PREVIOUS
