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
: ConnectFile ( S" connect string" fodbc -- sql_ior )
\ 09.01.2003: в параметре Driver= имя драйвера должно точно совпадать с тем,
\ что написано в ODBC control panel, вплоть до пробелов.
\ В примерах MS часты опечатки!, осторожнее :)
  { fa fu fodbc \ sl2p mem }
  fa fu fodbc odbcDrv 2!

  2048 ALLOCATE THROW -> mem
  ( SQL_DRIVER_NOPROMPT) 0 ^ sl2p 2048 mem fu fa
  ( S" RichEdit20A" SPF_STDEDIT 0 Window ) 0
  fodbc odbcConn @
  SQLDriverConnect
\ mem sl2p TYPE CR
  mem FREE THROW
;

WARNING @ WARNING 0!

: ReconnectSQL { fodbc -- ior }
  fodbc odbcDrv 2@ DUP
  IF  fodbc FreeStmt
      fodbc odbcConn @ SQLDisconnect DROP
      fodbc ConnectFile
  ELSE 2DROP
      fodbc ReconnectSQL
  THEN
;

WARNING  !

: ListTables ( fodbc -- sql_ior )
  { fodbc }
  fodbc odbcStat  fodbc odbcConn @  SQLAllocStmt
  DUP SQL_OK?
  IF DROP
     S" TABLE,VIEW" SWAP  0 0 0 0 0 0
     fodbc odbcStat @ SQLTables
     fodbc cash-odbc-params
  THEN
;
: ExistTable ( a u fodbc -- flag sql_ior )
  { a u fodbc }
  fodbc odbcStat fodbc odbcConn @  SQLAllocStmt
  DUP SQL_OK?
  IF DROP
     S" TABLE,VIEW" SWAP  u a  0 0 0 0
     fodbc odbcStat @ SQLTables ( sql_ior ) \ is SQLRETURN
     fodbc cash-odbc-params

     fodbc NextRow SWAP
  ELSE
     FALSE SWAP
  THEN
;
: EndSqlTrans { fodbc -- sql_ior }
  0 ( SQL_COMMIT) fodbc odbcEnv @ 1 ( SQL_HANDLE_ENV) SQLEndTran
;
