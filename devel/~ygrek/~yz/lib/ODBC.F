\ Доступ к базам данных через ODBC
\ Ю. Жиловец, 16.10.2003

\ Некоторые фрагменты (инициализация, подключение к базе, обработка ошибок)
\ позаимствованы у А. Черезова: ~ac/lib/win/odbc/odbc.f

REQUIRE "  ~yz/lib/common.f
REQUIRE LOAD-CONSTANTS ~yz/lib/const.f
REQUIRE {  lib/ext/locals.f

S" ~yz/cons/sql.const" LOAD-CONSTANTS

MODULE: ODBC

WINAPI: SQLAllocEnv           ODBC32.DLL
WINAPI: SQLAllocConnect       ODBC32.DLL
WINAPI: SQLConnect            ODBC32.DLL
WINAPI: SQLAllocStmt          ODBC32.DLL
WINAPI: SQLFreeStmt           ODBC32.DLL
WINAPI: SQLDisconnect         ODBC32.DLL
WINAPI: SQLFreeConnect        ODBC32.DLL
WINAPI: SQLFreeEnv            ODBC32.DLL

WINAPI: SQLExecDirect         ODBC32.DLL

WINAPI: SQLNumResultCols      ODBC32.DLL
WINAPI: SQLDescribeCol        ODBC32.DLL
WINAPI: SQLBindCol            ODBC32.DLL
WINAPI: SQLFetch              ODBC32.DLL

WINAPI: SQLError              ODBC32.DLL

WINAPI: SQLGetDiagRec         ODBC32.DLL
WINAPI: SQLSetEnvAttr         ODBC32.DLL
WINAPI: SQLRowCount           ODBC32.DLL

WINAPI: SQLGetDiagField       ODBC32.DLL
WINAPI: SQLAllocHandle        ODBC32.DLL
WINAPI: SQLFreeHandle         ODBC32.DLL

0
4 -- odbcEnv
4 -- odbcConn
4 -- odbcStat
CONSTANT /ODBC

20 == args#

0
CELL -- :adr
CELL -- :len
== field-len

USER bound-names
USER binding-column

USER-CREATE fields args# field-len * USER-ALLOT

fields args# field-len * ERASE

: col>adr ( n -- a)
  1- field-len * fields +
;

: field ( n -- a) col>adr :adr @ ;
: field# ( n -- a) col>adr :len @ ;

USER last-stat
USER last-odbc

: free-laststat
  0 last-stat @ SQLFreeStmt DROP 
  last-stat 0! ;

: unbind-all (  -- )
  free-laststat
  fields args# field-len * OVER + SWAP DO
    I :adr @ ?DUP IF
      FREEMEM
      I :adr 0!
    THEN
  field-len +LOOP
;

EXPORT

WINAPI: SQLColAttribute ODBC32.DLL

: ColNumAttribute { col attr fodbc \ num -- n }
  ^ num 0 0 0 attr col fodbc odbcStat @ SQLColAttribute DROP
  num
;

\ Предполагаем, что длинней 50 символов свойств не будет
: ColStrAttribute { addr col attr fodbc \ len -- }
  0 ^ len 50 addr attr col fodbc odbcStat @ SQLColAttribute DROP
;

: ColSize ( col fodbc -- n)
  W: sql_desc_octet_length SWAP ColNumAttribute
;

: ColDisplaySize ( col fodbc -- n)
  W: sql_desc_display_size SWAP ColNumAttribute ;

: ColType ( col fodbc -- n)
  W: sql_desc_type SWAP ColNumAttribute
;

: ColCount ( fodbc -- n)
  0 W: sql_desc_count ROT ColNumAttribute
;

: ColName ( a col fodbc -- )
  >R W: sql_desc_name R> ColStrAttribute
;

: SQL_OK?
  0xFFFF AND
  DUP W: SQL_SUCCESS = SWAP W: SQL_SUCCESS_WITH_INFO = OR
;

: SQL_MESSAGE { addr size \ len -- len }
  ^ len size addr W: sql_diag_message_text 1 last-stat @ W: sql_handle_stmt SQLGetDiagField DROP
  len
;

;MODULE

MODULE: ODBC

: bind-column { col type size \ f -- }
  col col>adr TO f
  size GETMEM f :adr !
  f :len size f :adr @ type col last-stat @ SQLBindCol DROP
;

: bind-column-len ( col type -- )
  OVER last-odbc @ ColDisplaySize 1+ bind-column ;

: field-does
  DOES> DUP @ [COMPILE] LITERAL
  POSTPONE field
  CELL+ @ ?DUP IF COMPILE, THEN
;

: field#-does
  DOES> @ [COMPILE] LITERAL
  POSTPONE field# ;

: dcl-column ( ->bl ) { type size access -- }
  binding-column @ [COMPILE] LITERAL 
  type [COMPILE] LITERAL 
  size IF
    size [COMPILE] LITERAL
    POSTPONE bind-column
  ELSE
    POSTPONE bind-column-len
  THEN
  GET-CURRENT
  bound-names @ SET-CURRENT
  BL WORD DUP >R COUNT CREATED binding-column @ , access ,
  field-does
  [COMPILE] IMMEDIATE
  R> COUNT 2DUP + c: # SWAP C! 1+
  CREATED binding-column @ ,
  field#-does
  [COMPILE] IMMEDIATE
  SET-CURRENT
  binding-column 1+!
;

: prepare-handles ( fodbc -- ? )
  >R
  R@ last-odbc !
  last-stat @ 0= IF
    R@ odbcStat R@ odbcConn @ SQLAllocStmt SQL_OK?
    R@ odbcStat @ last-stat ! 
  ELSE
    TRUE
  THEN RDROP ;

EXPORT

: SQL_INTEGER ( ->bl; -- )
  W: sql_integer 4 ['] @ dcl-column
; IMMEDIATE

: SQL_SMALLINT ( ->bl; -- )
  W: sql_smallint 2 ['] W@ dcl-column
; IMMEDIATE

: SQL_TINYINT ( ->bl; -- )
  W: sql_tinyint 1 ['] C@ dcl-column
; IMMEDIATE

: SQL_FLOAT ( ->bl; -- )
  W: sql_float 4 ['] @ dcl-column
; IMMEDIATE

: SQL_DOUBLE ( ->bl; -- )
  W: sql_float 8 ['] 2@ dcl-column
; IMMEDIATE

: SQL_CHAR ( ->bl; --)
  W: sql_char 0 0 dcl-column
; IMMEDIATE

: SQL_BINARY ( ->bl; -- )
  W: sql_binary 0 0 dcl-column
; IMMEDIATE

: SQL_BIT ( ->bl; -- )
  W: sql_bit 1 ['] C@ dcl-column
; IMMEDIATE

: SQL_DATE ( ->bl; -- )
  W: sql_date 6 0 dcl-column
; IMMEDIATE

: SQL_TIME ( ->bl; -- )
  W: sql_time 6 0 dcl-column
; IMMEDIATE

: SQL_TIMESTAMP ( ->bl; -- )
  W: sql_timestamp 16 0 dcl-column
; IMMEDIATE

: BIND ( -- )
  1 binding-column !
  TEMP-WORDLIST bound-names !
  ALSO bound-names @ CONTEXT !
; IMMEDIATE

: BIND; ( -- )
  POSTPONE unbind-all
  PREVIOUS
  bound-names @ FREE-WORDLIST	
; IMMEDIATE

: ISNULL ( field-len -- ) W: sql_nts = ;

: StartSQL ( -- fodbc flag )  \ true - OK
  { \ fodbc }
  /ODBC ALLOCATE THROW -> fodbc
  fodbc /ODBC ERASE
  fodbc odbcEnv SQLAllocEnv SQL_OK?
  IF 
     W: SQL_IS_INTEGER W: SQL_OV_ODBC2 W: SQL_ATTR_ODBC_VERSION
     fodbc odbcEnv @ SQLSetEnvAttr DROP \ без этого новый ODBC работать не хочет
     fodbc odbcConn  fodbc odbcEnv @ SQLAllocConnect SQL_OK? fodbc SWAP
  ELSE fodbc FALSE THEN
;
: StopSQL ( fodbc -- )
  { fodbc }
  fodbc odbcConn @ SQLDisconnect DROP
  fodbc odbcConn @ SQLFreeConnect DROP
  fodbc odbcEnv  @ SQLFreeEnv DROP
  fodbc FREE DROP
;
: ConnectSQL ( S" data source" S" name" S" pass" fodbc -- ior )
  { ds-a ds-u login-a login-u pass-a pass-u fodbc }
  pass-u pass-a login-u login-a ds-u ds-a
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

: ExecuteSQL { z-stat fodbc -- ior }
  fodbc prepare-handles IF 
    z-stat ASCIIZ> SWAP last-stat @ SQLExecDirect ELSE W: sql_invalid_handle 
  THEN
;

: NextRowWithInfo ( fodbc -- ? ) odbcStat @ SQLFetch ;
: NextRow ( fodbc -- ? ) NextRowWithInfo SQL_OK? ;

;MODULE

\EOF 

0 VALUE s

: ttt

StartSQL DROP TO s

S" реклама" 0 0 0 0 s ConnectSQL DROP
" SELECT firstticket FROM info" s ExecuteSQL DROP
BIND
SQL_INTEGER res

s NextRow DROP

res . res# .

BIND;

s StopSQL ;

\ SEE ttt

12345678 ttt . BYE
