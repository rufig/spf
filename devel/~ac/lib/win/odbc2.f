REQUIRE StartSQL ~ac/lib/win/odbc.f
REQUIRE { ~ac/lib/locals.f
REQUIRE Window ~ac/lib/win/window/window.f

WINAPI: SQLDataSources   ODBC32.DLL
WINAPI: SQLDriverConnect ODBC32.DLL

2 CONSTANT SQL_FETCH_FIRST
1 CONSTANT SQL_FETCH_NEXT
2 CONSTANT SQL_DRIVER_PROMPT

CREATE   ServerName 256 ALLOT
VARIABLE ServerNameLen
CREATE   Description 256 ALLOT
VARIABLE DescriptionLen

: DumpDS
  ServerName ServerNameLen @ TYPE ."  | "
  Description DescriptionLen @ TYPE CR
;
: ConnectFile ( S" connect string" fodbc -- ior )
  { fa fu fodbc \ sl2p mem }
  2048 ALLOCATE THROW -> mem
  ( SQL_DRIVER_PROMPT) 0 ^ sl2p 2048 mem fu fa 
  ( S" RichEdit20A" SPF_STDEDIT 0 Window) 0
  fodbc odbcConn @
  SQLDriverConnect mem FREE THROW
;

