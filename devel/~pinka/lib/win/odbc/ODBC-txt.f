\ 25.Feb.2004   ruv
\ $Id$
( слово ExecSQLTxt
  - эмулирует DELETE через SELECT INTO и DROP TABLE
  Необходимо, если используется Text File Driver
  ---
  В этом запросе DELETE слово FROM обязательно.
)

REQUIRE COMPARE-U   ~ac\lib\string\compare-u.f 
REQUIRE STR@        ~ac\lib\str2.f
REQUIRE ExecSQL     ~ac\lib\win\odbc\ODBC.F
REQUIRE ExistTable  ~ac\lib\win\odbc\odbc2.f

VOCABULARY SqlTxtDeleteLex
GET-CURRENT ALSO SqlTxtDeleteLex DEFINITIONS

USER SqlQ
USER-CREATE dTableName       2 CELLS USER-ALLOT
USER-CREATE dWhereCondition  2 CELLS USER-ALLOT

: TableName dTableName 2@ ;
: WhereCondition dWhereCondition 2@ ;

: FROM
  NextWord dTableName 2!
;
: WHERE
  0 PARSE dWhereCondition 2!
;
: DELETE ( -- )
;
\ DELETE FROM authors WHERE au_lname = 'McBadden'

: delete    DELETE  ;
: where     WHERE   ;
: from      FROM    ;

: Delete    DELETE  ;
: Where     WHERE   ;
: From      FROM    ;


: SqlThrow ( sql_ior -- )
  DUP SQL_OK? IF DROP ELSE SqlQ @ SQL_Error THEN
;

: ExecSqlStr { s -- }
  \ s STR@ TYPE CR \ for debug
  s STR@ SqlQ @ ExecSQL ( sql_ior )
  s STRFREE              SqlThrow
;

: SqlTxtDelete1 ( -- )
  " New{TableName}" { s }
  s STR@  SqlQ @  ExistTable ( f sql_ior )
  s STRFREE                      SqlThrow
  IF " DROP TABLE New{TableName}" ExecSqlStr
  THEN
  " SELECT * INTO New{TableName} FROM {TableName} WHERE NOT({WhereCondition})" ExecSqlStr
  SqlQ @  ReconnectSQL SqlThrow
  " DROP TABLE {TableName}" ExecSqlStr
  " SELECT * INTO {TableName} FROM New{TableName}" ExecSqlStr
  SqlQ @  ReconnectSQL SqlThrow
  " DROP TABLE New{TableName}" ExecSqlStr
;

SET-CURRENT

: SqlTxtDelete ( S" statement" fodbc -- sql_ior )
  SqlQ !
  ALSO SqlTxtDeleteLex
    ['] EVALUATE CATCH ?DUP IF PREVIOUS THROW THEN
    ['] SqlTxtDelete1 CATCH
  PREVIOUS
;

PREVIOUS


: ExecSQLTxt ( S" statement" fodbc -- sql_ior )
  { a u fodbc }
  a S" DELETE" TUCK COMPARE-U 0= IF
  a u fodbc SqlTxtDelete         ELSE
  a u fodbc ExecSQL              THEN
;
