( 17.08.1999 Черезов А. )

( Работа с базами данных ODBC, замена библиотеки s.txt двухлетней давности.
)

REQUIRE || ~ac/lib/temps.f

WINAPI: SQLAllocEnv           ODBC32.DLL
WINAPI: SQLAllocConnect       ODBC32.DLL
WINAPI: SQLConnect            ODBC32.DLL
WINAPI: SQLAllocStmt          ODBC32.DLL
WINAPI: SQLFreeStmt           ODBC32.DLL
WINAPI: SQLDisconnect         ODBC32.DLL
WINAPI: SQLFreeConnect        ODBC32.DLL
WINAPI: SQLFreeEnv            ODBC32.DLL

WINAPI: SQLSetParam           ODBC32.DLL
WINAPI: SQLExecDirect         ODBC32.DLL

WINAPI: SQLNumResultCols      ODBC32.DLL
WINAPI: SQLDescribeCol        ODBC32.DLL
WINAPI: SQLBindCol            ODBC32.DLL
WINAPI: SQLFetch              ODBC32.DLL

WINAPI: SQLError              ODBC32.DLL

WINAPI: SQLGetDiagRec         ODBC32.DLL
WINAPI: SQLSetEnvAttr         ODBC32.DLL
WINAPI: SQLRowCount           ODBC32.DLL

          0 CONSTANT SQL_SUCCESS
-2125070336 CONSTANT SQL_SUCCESS_WITH_INFO
  HEX 0FFFF CONSTANT FFFF DECIMAL

 -6 CONSTANT SQL_IS_INTEGER
  2 CONSTANT SQL_OV_ODBC2
  3 CONSTANT SQL_OV_ODBC3
200 CONSTANT SQL_ATTR_ODBC_VERSION

0
4 -- odbcEnv
4 -- odbcConn
4 -- odbcStat
CONSTANT /ODBC

: SQL_OK?
  FFFF AND
  DUP SQL_SUCCESS = SWAP SQL_SUCCESS_WITH_INFO = OR
;
: SQL_Error ( ior fodbc -- )
  | ErrLen ErrNat mem ior fodbc |
  OVER SQL_OK? IF 2DROP EXIT THEN
  2000 ALLOCATE THROW mem !
  fodbc ! ior !
  ErrLen 1000 mem @
  ErrNat mem @ 1000 +
  0  fodbc @ odbcConn @  fodbc @ odbcEnv @ 
  SQLError ." ERR: " mem @ 1000 + 5 TYPE SPACE
  100 <>
  IF mem @ ErrLen @ TYPE CR THEN
  mem @ FREE THROW
  ior @ THROW
;
: StartSQL ( -- fodbc flag )  \ true - OK
  || fodbc ||
  /ODBC ALLOCATE THROW -> fodbc
  fodbc /ODBC ERASE
  fodbc odbcEnv SQLAllocEnv SQL_OK?
  IF 
     SQL_IS_INTEGER SQL_OV_ODBC2 SQL_ATTR_ODBC_VERSION fodbc odbcEnv @ SQLSetEnvAttr DROP \ без этого новый ODBC работать не хочет
     fodbc odbcConn  fodbc odbcEnv @ SQLAllocConnect SQL_OK? fodbc SWAP
  ELSE fodbc FALSE THEN
;
: StopSQL ( fodbc -- ior )
  || fodbc || (( fodbc ))
  fodbc odbcConn @ SQLFreeConnect DROP
  fodbc odbcEnv  @ SQLFreeEnv DROP
  fodbc FREE DROP
;
: ConnectSQL ( S" data source" S" name" S" pass" fodbc -- ior )
  || ds-a ds-u login-a login-u pass-a pass-u fodbc ||
  (( ds-a ds-u login-a login-u pass-a pass-u fodbc ))
  pass-u pass-a login-u login-a ds-u ds-a
  fodbc odbcConn @
  SQLConnect
;
: ExecSQL ( S" statement" fodbc -- ior )
  || sta stu fodbc || (( sta stu fodbc ))
  fodbc odbcStat  fodbc odbcConn @  SQLAllocStmt
  DUP SQL_OK?
  IF DROP
     stu sta fodbc odbcStat @ SQLExecDirect
  THEN
;
: ResultCols ( fodbc -- n )
  | ncol |
  ncol SWAP odbcStat @ SQLNumResultCols DROP ncol @
;
: AffectedRows ( fodbc -- n )
  | ncol |
  ncol SWAP odbcStat @ SQLRowCount DROP ncol @
;

: TEST ( -- )
  StartSQL
  IF
    >R
    S" MySQL1" S" root" S" " R@ ConnectSQL SQL_OK? \ Error PAD ErrLen @ TYPE CR
    IF
      S" SELECT * FROM thing LIMIT 50" R@ ExecSQL R@ SQL_Error
      R@ ResultCols  . KEY DROP
      R@
      R@ ResultCols 0 ?DO
          PAD I 1000 * + OVER 1000 SWAP
          PAD I 1000 * + CELL+ SWAP
          1 SWAP I 1+ SWAP
          CELL+ CELL+ @ SQLBindCol DROP
      LOOP DROP
      BEGIN
        R@ CELL+ CELL+ @ SQLFetch SQL_OK?
      WHILE
        R@ ResultCols 0 ?DO
          PAD I 1000 * + CELL+
          PAD I 1000 * + @ DUP 0 > IF ANSI>OEM TYPE ELSE 2DROP THEN ." , "
        LOOP CR
      REPEAT
    THEN
    R> StopSQL
  ELSE R> FREE DROP THEN
;