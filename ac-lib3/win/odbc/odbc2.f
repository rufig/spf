REQUIRE StartSQL ~ac/lib/win/odbc/odbc.f
REQUIRE { ~ac/lib/locals.f
\ REQUIRE Window ~ac/lib/win/window/window.f

WINAPI: SQLDataSources   ODBC32.DLL
WINAPI: SQLDriverConnect ODBC32.DLL
WINAPI: SQLTables        ODBC32.DLL


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
\ 09.01.2003: в параметре Driver= имя драйвера должно точно совпадать с тем,
\ что написано в ODBC control panel, вплоть до пробелов. 
\ В примерах MS часты опечатки!, осторожнее :)
  { fa fu fodbc \ sl2p mem }
  2048 ALLOCATE THROW -> mem
  ( SQL_DRIVER_PROMPT) 0 ^ sl2p 2048 mem fu fa 
  ( S" RichEdit20A" SPF_STDEDIT 0 Window) 0
  fodbc odbcConn @
  SQLDriverConnect mem FREE THROW
;
: ListTables ( fodbc -- ior )
  { fodbc }
  fodbc odbcStat  fodbc odbcConn @  SQLAllocStmt
  DUP SQL_OK?
  IF DROP
     S" TABLE,VIEW" SWAP  0 0 0 0 0 0
     fodbc odbcStat @ SQLTables
     fodbc ResultCols fodbc odbcResultCols !
     fodbc AffectedRows fodbc odbcAffectedRows !
     fodbc IndexResultCols
     fodbc RowSize fodbc odbcRowSize !
     fodbc BindCols
  THEN
;