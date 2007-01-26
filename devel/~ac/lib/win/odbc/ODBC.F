( 17.08.1999 Черезов А. )

( Работа с базами данных ODBC, замена библиотеки s.txt двухлетней давности.
  + обновление 19.08.1999
  + замена temps на locals 7.12.2000
)

REQUIRE { ~ac/lib/locals.f

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

WINAPI: SQLCloseCursor        ODBC32.DLL
WINAPI: SQLEndTran            ODBC32.DLL

\ WINAPI: SQLConfigDataSource   ODBC32.DLL

0 CONSTANT SQL_SUCCESS
1 CONSTANT SQL_SUCCESS_WITH_INFO
\ -2125070336 CONSTANT SQL_SUCCESS_WITH_INFO
  HEX 0FFFF CONSTANT FFFF DECIMAL

 -6 CONSTANT SQL_IS_INTEGER
  2 CONSTANT SQL_OV_ODBC2
  3 CONSTANT SQL_OV_ODBC3
200 CONSTANT SQL_ATTR_ODBC_VERSION
\ 65532 CONSTANT SQL_LONGVARBINARY \ -4
\ 65535 CONSTANT SQL_LONGVARCHAR \ -1
\ 65530 CONSTANT SQL_TINYINT \ -6
\ : SqlIsBinary ( type -- flag ) DUP 65531 65535 WITHIN SWAP 5 = OR ;
: SqlIsBinary ( type -- flag ) 65531 65535 WITHIN ;

0
4 -- odbcEnv
4 -- odbcConn
4 -- odbcStat
4 -- odbcResultCols
4 -- odbcAffectedRows
4 -- odbcColsIndex
4 -- odbcRowData
4 -- odbcRowSize
2 CELLS -- odbcDrv
2 CELLS -- odbcSrc
2 CELLS -- odbcLogin
2 CELLS -- odbcPassw
CONSTANT /ODBC

: SQL_OK?
  FFFF AND
  DUP SQL_SUCCESS = SWAP SQL_SUCCESS_WITH_INFO = OR
;
: SQL_Error_old ( ior fodbc -- )
  { \ ErrLen ErrNat mem ior fodbc }
  OVER SQL_OK? IF 2DROP EXIT THEN
  2000 ALLOCATE THROW -> mem
  -> fodbc -> ior
  ^ ErrLen 1000 mem
  ^ ErrNat mem 1000 +
  0  fodbc odbcConn @  fodbc odbcEnv @
  SQLError ." ERR: " mem 1000 + 5 TYPE SPACE
  100 <>
  IF mem ErrLen TYPE CR THEN
  mem FREE THROW
  ior THROW
;
: SQLDumpError ( addr u -- )
  OVER >R
  CR ANSI>OEM TYPE ."  ( " R> 1900 + @ . ." )" CR
;
VECT vSQLDumpError ' SQLDumpError TO vSQLDumpError

: SQL_Error { ior fodbc \ pcbErrorMsg ErrNat mem -- }
  ior SQL_OK? IF EXIT THEN
  2000 ALLOCATE THROW -> mem

  ^ pcbErrorMsg 1000 mem 6 + \ pDiagInfo
  mem 1900 + ( pfNativeError ) mem ( pszSqlState)
  1 fodbc odbcStat @ 3 ( SQL_HANDLE_STMT)
  SQLGetDiagRec 100 <>
  IF BL mem 5 + C! mem pcbErrorMsg 6 + vSQLDumpError
  THEN
  mem FREE THROW
  ior THROW
;
: SQL_ConnError { ior fodbc \ pcbErrorMsg ErrNat mem -- }
  ior SQL_OK? IF EXIT THEN
  2000 ALLOCATE THROW -> mem

  ^ pcbErrorMsg 1000 mem 6 + \ pDiagInfo
  mem 1900 + ( pfNativeError ) mem ( pszSqlState)
  1 fodbc odbcConn @ 2 ( SQL_HANDLE_DBC)
  SQLGetDiagRec 100 <>
  IF BL mem 5 + C! mem pcbErrorMsg 6 + vSQLDumpError
  THEN
  mem FREE THROW
  ior THROW
;
: StartSQL ( -- fodbc flag )  \ true - OK
  { \ fodbc }
  /ODBC ALLOCATE THROW -> fodbc
  fodbc /ODBC ERASE
  fodbc odbcEnv SQLAllocEnv SQL_OK?
  IF
     SQL_IS_INTEGER SQL_OV_ODBC2 SQL_ATTR_ODBC_VERSION
     fodbc odbcEnv @ SQLSetEnvAttr DROP \ без этого новый ODBC работать не хочет
     fodbc odbcConn  fodbc odbcEnv @ SQLAllocConnect SQL_OK? fodbc SWAP
  ELSE fodbc FALSE THEN
;
: ConnectSQL ( S" data source" S" name" S" pass" fodbc -- ior )
  { ds-a ds-u login-a login-u pass-a pass-u fodbc }
  ds-a ds-u         fodbc odbcSrc   2!
  login-a login-u   fodbc odbcLogin 2!
  pass-a pass-u     fodbc odbcPassw  2!

  pass-u pass-a login-u login-a ds-u ds-a
  fodbc odbcConn @
  SQLConnect
;
: ReconnectSQL { fodbc -- ior }
  fodbc odbcConn @ SQLDisconnect DROP

  fodbc odbcPassw 2@
  fodbc odbcLogin 2@
  fodbc odbcSrc   2@

  fodbc odbcConn @
  SQLConnect
;

: ResultCols ( fodbc -- n )
  { \ ncol }
  ^ ncol SWAP odbcStat @ SQLNumResultCols DROP ncol
;
: AffectedRows ( fodbc -- n )
  { \ ncol }
  ^ ncol SWAP odbcStat @ SQLRowCount DROP ncol
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
  { n fodbc \ m }
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
  m ciDataTypePtr @ SqlIsBinary \ BLOB
  IF m ciColumnSizePtr @ 2* m ciColumnSizePtr ! THEN
  m ciColumnSizePtr @ DUP -1 < IF DROP 200000 THEN
  200000 MIN m ciColumnSizePtr ! \ баги в некоторых ODBC
;
: IndexResultCols ( fodbc -- )
  0 OVER odbcColsIndex !
  DUP
  odbcResultCols @ 0 ?DO
    I 1+ OVER IndexResultCol DROP
  LOOP DROP
;
: RowSize ( fodbc -- n )
  { fodbc \ n }
  fodbc odbcColsIndex @
  BEGIN
    DUP
  WHILE
    DUP ciColumnSizePtr @
        0 MAX \ NULL выдает размер -1
        n + -> n
    ciLink @
  REPEAT DROP
  n
;
: BindCols ( fodbc -- )
  { fodbc \ m s addr ci size }
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
: UnbindCols ( fodbc -- )
  { fodbc \ m s addr ci size }
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
\      addr OVER - DUP -> addr
\      addr ci ciColumnData !
0
      1   \ target type
      ci ciColumnNumber @
      fodbc odbcStat @
      SQLBindCol DROP
    ci ciLink @
  REPEAT DROP
  m fodbc odbcRowData !
;

: cash-odbc-params { fodbc -- }
     fodbc ResultCols fodbc odbcResultCols !
     fodbc AffectedRows fodbc odbcAffectedRows !
     fodbc IndexResultCols
     fodbc RowSize fodbc odbcRowSize !
     fodbc BindCols
;
0 VALUE qSQLDebug

: SQLLastQuery ( addr u -- )
  qSQLDebug IF TYPE CR ELSE 2DROP THEN
;
VECT vSQLLastQuery ' SQLLastQuery TO vSQLLastQuery

: FreeStmt { fodbc -- }
  fodbc odbcStat @ ?DUP IF 0 SWAP SQLFreeStmt DROP fodbc odbcStat 0! THEN
;
: ExecSQL ( S" statement" fodbc -- ior )
  { sta stu fodbc }
  sta stu vSQLLastQuery
  fodbc FreeStmt \ освободим предыдущий запрос, если был
  fodbc odbcStat  fodbc odbcConn @  SQLAllocStmt
  DUP SQL_OK?
  IF DROP
     stu sta fodbc odbcStat @ SQLExecDirect DUP SQL_OK?
     IF
       fodbc cash-odbc-params
     THEN
  THEN
;
: FreeExec { fodbc -- }
\  fodbc odbcStat @ SQLCloseCursor DROP
\  0 ( SQL_COMMIT) fodbc odbcEnv @ 1 ( SQL_HANDLE_ENV) SQLEndTran DROP
  fodbc FreeStmt
  fodbc odbcConn @ ?DUP IF SQLDisconnect DROP fodbc odbcConn 0! THEN
( disconnect нужен после каждого UPDATE для некоторых ODBC-драйверов...
  но при нескольких запросах per connect лучше не пользоваться FreeExec )
;
: StopSQL ( fodbc -- )
  { fodbc }
\  fodbc odbcConn @ SQLDisconnect DROP
  fodbc FreeStmt
  fodbc odbcConn @ ?DUP IF DUP SQLDisconnect DROP SQLFreeConnect DROP THEN
  fodbc odbcEnv  @ SQLFreeEnv DROP
  fodbc FREE DROP
;

: ExecSQLfile ( S" filename" fodbc -- ior )
  { fa fu fodbc \ f size mem }
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
  { n fodbc }
  fodbc odbcColsIndex @
  BEGIN
    DUP
  WHILE
    DUP ciColumnNumber @ n = IF EXIT THEN
    ciLink @
  REPEAT
;
: ColName { n fodbc \ ci -- addr u }
  n fodbc ColFind ?DUP
  IF DUP -> ci ciColumnName ci ciNameLengthPtr @
     DUP 2 < IF DROP [CHAR] f SWAP C!
                n 0 <# #S #> DUP 1+ ci ciNameLengthPtr !
                ci ciColumnName 1+ SWAP MOVE
                ci ciColumnName ci ciNameLengthPtr @
             THEN
  ELSE S" " THEN
;
: ColSize ( n fodbc -- n )
  ColFind DUP
  IF ciColumnSizePtr @ THEN
;
: ColType ( n fodbc -- n )
  ColFind DUP
  IF ciDataTypePtr @ THEN
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
\ : ConfigDSN ( attra attru drivera driveru
\   SQLConfigDataSource
\ ...
\ ;

(
: TEST \ --
  { \ q }
  StartSQL
  IF
    -> q
    S" Ftest" S" root" ." Password: " PAD 100 ACCEPT PAD SWAP q ConnectSQL SQL_OK?

    IF
      ." Connected" CR
\      S" news2.sql" q ExecSQLfile DUP . q SQL_Error
\      S" SELECT * FROM sp_vendors LIMIT 50" q ExecSQL DUP . q SQL_Error
\ S" SET NAMES 'cp1251'" q ExecSQL DUP . q SQL_Error

      S" latest_orders.sql" q ExecSQLfile q SQL_Error
\      S" test.sql" q ExecSQLfile q SQL_Error

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
)