( 17.08.1999 Черезов А. )

( Работа с базами данных ODBC, замена библиотеки s.txt двухлетней давности.
  + обновление 19.08.1999
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
1 CONSTANT SQL_SUCCESS_WITH_INFO
\ -2125070336 CONSTANT SQL_SUCCESS_WITH_INFO
  HEX 0FFFF CONSTANT FFFF DECIMAL

 -6 CONSTANT SQL_IS_INTEGER
  2 CONSTANT SQL_OV_ODBC2
  3 CONSTANT SQL_OV_ODBC3
200 CONSTANT SQL_ATTR_ODBC_VERSION

0
4 -- odbcEnv
4 -- odbcConn
4 -- odbcStat
4 -- odbcResultCols
4 -- odbcAffectedRows
4 -- odbcColsIndex
4 -- odbcRowData
4 -- odbcRowSize
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
  fodbc odbcConn @ SQLDisconnect DROP
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
: ResultCols ( fodbc -- n )
  | ncol |
  ncol SWAP odbcStat @ SQLNumResultCols DROP ncol @
;
: AffectedRows ( fodbc -- n )
  | ncol |
  ncol SWAP odbcStat @ SQLRowCount DROP ncol @
;

0
4 -- ciLink
4 -- ciColumnNumber
4 -- ciNameLengthPtr
4 -- ciDataTypePtr
4 -- ciColumnSizePtr
4 -- ciDecimalDigitsPtr
4 -- ciNullablePtr
4 -- ciColumnData
4 -- ciColumnDataSize
128 -- ciColumnName
CONSTANT /ci

: IndexResultCol ( n fodbc -- errcode )
  || n fodbc m || (( n fodbc ))
  /ci ALLOCATE THROW -> m
  m /ci ERASE
  fodbc odbcColsIndex @ m ciLink !
  m fodbc odbcColsIndex !
  n m ciColumnNumber !

  m ciNullablePtr
  m ciDecimalDigitsPtr
  m ciColumnSizePtr
  m ciDataTypePtr
  m ciNameLengthPtr
  127
  m ciColumnName
  n fodbc odbcStat @ SQLDescribeCol
;
: IndexResultCols ( fodbc -- )
  DUP
  odbcResultCols @ 0 ?DO
    I 1+ OVER IndexResultCol DROP
  LOOP DROP
;
: RowSize ( fodbc -- n )
  || fodbc n || (( fodbc ))
  fodbc odbcColsIndex @
  BEGIN
    DUP
  WHILE
    DUP ciColumnSizePtr @ n + -> n
    ciLink @
  REPEAT DROP
  n
;
: BindCols ( fodbc -- )
  || fodbc m s addr ci size || (( fodbc ))
  fodbc odbcRowSize @ -> s
  s fodbc odbcResultCols @ SWAP OVER + ALLOCATE THROW -> m
  m s + + -> addr
  fodbc odbcColsIndex @
  BEGIN
    DUP
  WHILE
    -> ci
      ci ciColumnDataSize
      ci ciColumnSizePtr @ 1+ \ for zero
      addr OVER - DUP -> addr
      addr ci ciColumnData !
      1   \ target type
      ci ciColumnNumber @
      fodbc odbcStat @
      SQLBindCol DROP
    ci ciLink @
  REPEAT DROP
  m fodbc odbcRowData !
;

: ExecSQL ( S" statement" fodbc -- ior )
  || sta stu fodbc || (( sta stu fodbc ))
  fodbc odbcStat  fodbc odbcConn @  SQLAllocStmt
  DUP SQL_OK?
  IF DROP
     stu sta fodbc odbcStat @ SQLExecDirect
     fodbc ResultCols fodbc odbcResultCols !
     fodbc AffectedRows fodbc odbcAffectedRows !
     fodbc IndexResultCols
     fodbc RowSize fodbc odbcRowSize !
     fodbc BindCols
  THEN
;
: ExecSQLfile ( S" filename" fodbc -- ior )
  || fa fu fodbc f size mem || (( fa fu fodbc ))
  fa fu R/O OPEN-FILE-SHARED ?DUP IF NIP EXIT THEN
  -> f
  f FILE-SIZE THROW D>S -> size
  size 1+ ALLOCATE THROW -> mem  mem size ERASE
  mem size f READ-FILE THROW -> size
  f CLOSE-FILE THROW
  mem size fodbc ExecSQL
  mem FREE THROW
;
: ColFind ( n fodbc -- ci )
  || n fodbc || (( n fodbc ))
  fodbc odbcColsIndex @
  BEGIN
    DUP
  WHILE
    DUP ciColumnNumber @ n = IF EXIT THEN
    ciLink @
  REPEAT
;
: ColName ( n fodbc -- addr u )
  ColFind ?DUP 
  IF DUP ciColumnName SWAP ciNameLengthPtr @
  ELSE S" " THEN
;
: ColSize ( n fodbc -- n )
  ColFind DUP 
  IF ciColumnSizePtr @ THEN
;
: Row ( fodbc -- addr u )
  DUP odbcRowData @
  SWAP odbcRowSize @
;
: NextRow ( fodbc -- flag )
  DUP Row BL FILL
  odbcStat @ SQLFetch SQL_OK?
;
: Col ( n fodbc -- addr u )
  ColFind ?DUP
  IF DUP ciColumnData @ SWAP ciColumnDataSize @
  ELSE S" " THEN
;

: TEST ( -- )
  || q ||
  StartSQL
  IF
    -> q
    S" Ftest" S" root" ." Password: " PAD 100 ACCEPT PAD SWAP q ConnectSQL SQL_OK?

    IF
      ." Connected" CR
      S" news2.sql" q ExecSQLfile q SQL_Error
\      S" SELECT * FROM sp_vendors LIMIT 50" q ExecSQL q SQL_Error

      ." Result cols: " q ResultCols  . CR

      q
      q ResultCols 0 ?DO
         I 1+ OVER ColName TYPE ." :" I 1+ OVER ColSize .
      LOOP DROP CR

      KEY DROP

      BEGIN
         q NextRow
      WHILE
\         q Row ANSI>OEM TYPE CR
         q
         q ResultCols 0 ?DO
            I 1+ OVER Col DUP 0 > IF ANSI>OEM TYPE ELSE 2DROP THEN ." ;"
         LOOP DROP CR

      REPEAT

    ELSE ." Can't connect this Data Source" THEN
    q StopSQL
    q FREE DROP
  THEN
;