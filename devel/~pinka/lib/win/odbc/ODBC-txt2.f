\ 25.Feb.2004 ruv 
\ 25.Mar.2004 ODBC-txt2.f - переделал, тк. под Win2003 не работало..
\ $Id$
( слово ExecSQLTxt
  реализует DELETE
  Необходимо, если используется Text File Driver
  ---
  Особенности и ограничения.
    В этом запросе DELETE слово FROM обязательно.
    Значения атрибутов не должны содержать кавычки ["].
    При исключениях [ бросках THROW] возможна утечка памяти [от строк].
    Файл таблицы должен находиться в текущем каталоге.
)

REQUIRE RENAME-FILE  ~pinka\lib\FileExt.f

REQUIRE COMPARE-U   ~ac\lib\string\compare-u.f
REQUIRE STR@        ~ac\lib\str2.f
REQUIRE ExecSQL     ~ac\lib\win\odbc\ODBC.F
REQUIRE ExistTable  ~ac\lib\win\odbc\odbc2.f


VOCABULARY  ODBCTxt-Support
GET-CURRENT  ALSO ODBCTxt-Support DEFINITIONS


USER-VALUE  qSql
USER-CREATE dTableName       2 CELLS USER-ALLOT
USER-CREATE dWhereCondition  2 CELLS USER-ALLOT

\ =================================================

VOCABULARY SqlTxtDeleteLex
GET-CURRENT ALSO SqlTxtDeleteLex DEFINITIONS

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

PREVIOUS SET-CURRENT

\ =================================================


: SqlThrow ( sql_ior -- )
  DUP SQL_OK? IF DROP ELSE qSql SQL_Error THEN
;
: ExecSqlStr { s -- }
  \ s STR@ TYPE CR \ for debug
  s STR@ qSql ExecSQL ( sql_ior )
  s STRFREE              SqlThrow
;
: DelPrevNew ( -- )
  " New{TableName}" >R
  R@ STR@  FILE-EXIST         IF
  R@ STR@  DELETE-FILE THROW  THEN
  R> STRFREE
;
: DelPrevBak ( -- )
  " {TableName}.bak" >R
  R@ STR@  FILE-EXIST         IF
  R@ STR@  DELETE-FILE THROW  THEN
  R> STRFREE
;
: CheckTbl ( -- )
  " {TableName}" >R
  R@ STR@ FILE-EXIST 0=
  ABORT" Table not found (current dir must contain the table)"
  R> STRFREE
;
: MakeBak ( -- )
  " {TableName}"     DUP >R STR@
  " {TableName}.bak" DUP >R STR@
  RENAME-FILE THROW
  R> STRFREE
  R> STRFREE
;
: MakeTbl ( -- )
  " New{TableName}"  DUP >R STR@
  " {TableName}"     DUP >R STR@
  RENAME-FILE THROW
  R> STRFREE
  R> STRFREE
;

USER-VALUE h-tbl
: CloseTbl ( -- )
  h-tbl IF h-tbl CLOSE-FILE THROW 0 TO h-tbl THEN
;
: OpenTbl ( -- )
  CloseTbl
  " New{TableName}" DUP >R STR@
  W/O CREATE-FILE THROW TO h-tbl
  R> STRFREE
;
: WriteTbl-str ( str -- )
  DUP STR@  h-tbl WRITE-FILE THROW
  STRFREE
;


: SqlTxtDelete1 ( -- )
  qSql { q }

  CheckTbl
  DelPrevNew

  " SELECT * FROM [{TableName}] WHERE NOT({WhereCondition})" ExecSqlStr

  OpenTbl

  q ResultCols 1+ 1 ?DO
      I q ColName
      I 1 = IF " {''}{s}{''}" ELSE " ;{''}{s}{''}" THEN
      WriteTbl-str
  LOOP " {CRLF}" WriteTbl-str

  BEGIN
   q NextRow
  WHILE
   q ResultCols 1+ 1 ?DO
     I q Col DUP 0 >
     IF   I 1 = IF " {''}{s}{''}" ELSE " ;{''}{s}{''}" THEN
     ELSE 2DROP I 1 = IF "" ELSE " ;" THEN
     THEN WriteTbl-str
   LOOP  " {CRLF}" WriteTbl-str
  REPEAT

  CloseTbl
  q ReconnectSQL SqlThrow

  DelPrevBak
  MakeBak  MakeTbl
;

SET-CURRENT

: SqlTxtDelete ( S" statement" fodbc -- sql_ior )
  TO qSql
  0. dTableName 2!
  0. dWhereCondition 2!
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
