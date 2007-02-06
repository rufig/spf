\ 25.Feb.2004 ruv 
\ 25.Mar.2004 ODBC-txt2.f - переделал, тк. под Win2003 не работало..
\ $Id$
( —лово ExecSQLTxt  аналогично ExecSQL из ODBC.F,
  но само реализует команды DELETE и UPDATE
  Ќеобходимо, если используетс€ Text File Driver
  ---
  ќсобенности и ограничени€.
     оманды запроса регистро-зависимы и должны быть в верхнем регистре.
    ¬ запросе DELETE слово FROM об€зательно.
    ¬ запросе UPDATE не поддерживаетс€ вычисление значений в SET,
      поддерживаетс€ ROWID - 'номер строки' /с 22.Apr.2004/.
    «начени€ атрибутов не должны содержать кавычки ["].
    ‘айл таблицы должен находитьс€ в текущем каталоге.
    ѕри исключени€х [ бросках THROW] возможна утечка пам€ти [от строк].
)

REQUIRE INCLUDED-WITH  ~pinka\lib\ext\include.f
REQUIRE RENAME-FILE ~pinka\lib\FileExt.f
REQUIRE PARSE-FOR   ~pinka\lib\ext\parse.f
REQUIRE NextSubstring ~pinka\lib\parse.f
REQUIRE COMPARE-U   ~ac\lib\string\compare-u.f
REQUIRE HASH@       ~pinka\lib\hash-table.f
REQUIRE STR@        ~ac\lib\str2.f
REQUIRE ExecSQL     ~ac\lib\win\odbc\ODBC.F
REQUIRE ExistTable  ~ac\lib\win\odbc\odbc2.f


VOCABULARY  ODBCTxt-Support
GET-CURRENT  ALSO ODBCTxt-Support DEFINITIONS


: NextValueName ( -- a-value u-value a-name u-name true | false )
  SkipDelimiters
  S" =" PARSE-FOR  IF
    -TRAILING UnQuoted
    SkipDelimiters
    PeekChar IsCharSubs IF
    NextSubstring       ELSE
    S" , " ParseTill
    -TRAILING           THEN
    2SWAP   TRUE
  ELSE
    FALSE
  THEN
;
: SkipField ( -- )
  NextField 2DROP
;
\ --------------------------------------------

USER-VECT Action
USER-VALUE #Col
USER-VALUE RowId
USER-VALUE HashT
USER-VALUE qSql
USER-CREATE dTableName       2 CELLS USER-ALLOT
USER-CREATE dWhereCondition  2 CELLS USER-ALLOT

: HashT! ( h -- )
  TO HashT
;

\ =================================================

VOCABULARY SqlLex
GET-CURRENT ALSO SqlLex   CONTEXT @ CONSTANT SqlLexWid
DEFINITIONS

: TableName dTableName 2@ ;
: WhereCondition dWhereCondition 2@ ;

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
  " {TableName}.New" >R
  R@ STR@  FILE-EXIST         IF
  R@ STR@  DELETE-FILE THROW  THEN
  R> STRFREE
;
: CheckTbl ( -- ) 
\ THROW, if table not exist
  " {TableName}" >R
  R@ STR@ FILE-EXIST 0=
  ABORT" ODBC-txt2: Table not found"
  R> STRFREE
;
: MakeBak ( -- )
  " {TableName}"     DUP >R STR@
  " {TableName}.bak" DUP >R STR@
  COPY-FILE-OVER THROW
  R> STRFREE
  R> STRFREE
;
: MakeTbl ( -- )
  " {TableName}.New" DUP >R STR@
  " {TableName}"     DUP >R STR@
  2DUP DELETE-FILE THROW
  RENAME-FILE THROW
  R> STRFREE
  R> STRFREE
;

USER-VALUE h-tbl

: CloseNewTbl ( -- )
  h-tbl IF h-tbl CLOSE-FILE DROP 0 TO h-tbl THEN
;
: OpenNewTbl ( -- )
  CloseNewTbl
  DelPrevNew
  " {TableName}.New" DUP >R STR@
  W/O CREATE-FILE-SHARED THROW TO h-tbl
  R> STRFREE
;
: WriteTbl ( a u -- )
  h-tbl WRITE-FILE THROW
;
: WriteTbl-str ( str -- )
  DUP STR@  h-tbl WRITE-FILE THROW
  STRFREE
;
\ ===

: >NUM ( a u -- n )
  0. 2SWAP  >NUMBER 2DROP DROP
;
: TranslateWhere ( -- )
\ предполагает, что содержитс€ только одна инструкци€: ROWID=nnn
   NextValueName IF 2DROP >NUM  ELSE 0 THEN
   DUP 0= IF DROP -1 THEN
   TO RowId
;
: SelectWhere ( -- )
  dWhereCondition 2@
  DROP S" ROWID" TUCK  COMPARE IF
    " SELECT * FROM {TableName} WHERE {WhereCondition}" ExecSqlStr
  ELSE
    dWhereCondition 2@ ['] TranslateWhere EVALUATE-WITH
  THEN
;
: CmpRowById ( -- flag ) \ 0 if matched
  CURSTR @  RowId 1+ <>
;
: CmpRow ( -- flag ) \ 0 if matched
\ —опоставить строку в SOURCE с текущей строкой последней выборки.
\ ≈сли есть RowId, то сопоставить по нему, иначе по всем пол€м.
   >IN 0!
   RowId IF CmpRowById EXIT THEN

   qSql ResultCols 1+ 1 ?DO
     I qSql Col 0 MAX
     ( odbc Col убирает пробелы в конце, даже в кавычках)
     NextField -TRAILING  COMPARE
     DUP IF UNLOOP EXIT THEN DROP
   LOOP 0
;
: WriteFirstField ( a u -- )
   DUP 0 > IF " {''}{s}{''}" ELSE 2DROP "" THEN WriteTbl-str
;
: WriteOtherField ( i a u -- )
   DUP 0 > IF " ;{''}{s}{''}" ELSE 2DROP " ;" THEN WriteTbl-str
;
: WriteFieldI ( a u i -- )
  1 = IF WriteFirstField ELSE WriteOtherField THEN
;
\ ---
\ for DELETE

: SqlTxtDelete ( -- )
  qSql { q }
  MakeBak

  " SELECT * FROM {TableName} WHERE NOT({WhereCondition})" ExecSqlStr

  OpenNewTbl

  q ResultCols 1+ 1 ?DO
      I q ColName
      I WriteFieldI
  LOOP  CRLF WriteTbl

  BEGIN
   q NextRow
  WHILE
   q ResultCols 1+ 1 ?DO
     I q Col  I WriteFieldI
   LOOP  CRLF WriteTbl
  REPEAT

  CloseNewTbl
  \ q ReconnectSQL SqlThrow
  q FreeStmt

  MakeTbl
;

\ ----------------------------
\ for UPDATE

: StoreCol ( a u i -- )
( если в HashT есть ключ a u, то сохран€ет 
  его значение под ключем i )
  >R
  2DUP HashT HASH?  IF
  HashT HASH@  RP@ 4
  HashT HASH!       ELSE
  2DROP             THEN
  RDROP
;
: HasValue ( i -- a u true | false )
  >R 
  RP@ 4 HashT HASH? IF
  RP@ 4 HashT HASH@
  TRUE              ELSE
  FALSE             THEN
  RDROP
;
: StoreHeader ( -- )
  0
  BEGIN
    SkipDelimiters
    EndOfChunk 0=
  WHILE
    1+ DUP
    NextField ROT StoreCol
  REPEAT  TO #Col
;
: UpdateRowById ( -- )
  SOURCE NIP 0= IF EXIT THEN
  #Col 1+ 1 DO
    I HasValue IF  SkipField ELSE NextField THEN
    ( a u )
    I WriteFieldI
  LOOP  CRLF WriteTbl
;
: UpdateRow ( -- )
   SOURCE NIP 0= IF EXIT THEN
   qSql ResultCols 1+ 1 ?DO
     I HasValue 0= IF I qSql Col THEN ( a u )
     I WriteFieldI
   LOOP  CRLF WriteTbl
;
: WriteOtherRows ( -- )
\ записать идущие подр€д не совпадающие(другие) строки.
  BEGIN  
    REFILL
  WHILE
    CmpRow
  WHILE
    SOURCE WriteTbl
    CRLF WriteTbl
  REPEAT ELSE SOURCE DROP 0 SOURCE! THEN
  \ обнулил SOURCE на случай, если файл закончилс€,
  \  а NextRow еще нет (когда CmpRow не сработало)
;
: UpdateBodyById ( -- )
  WriteOtherRows
  UpdateRowById
  WriteOtherRows
;
: UpdateBody ( -- )
  BEGIN
    qSql NextRow
  WHILE
    WriteOtherRows
    UpdateRow
  REPEAT
  WriteOtherRows
;
: update ( -- )
  REFILL IF \ the header
    SOURCE WriteTbl  CRLF WriteTbl
    StoreHeader
  THEN
  RowId IF UpdateBodyById  ELSE UpdateBody THEN
;
: SqlTxtUpdate ( -- )    \ EXIT
  MakeBak
  SelectWhere
  OpenNewTbl

  " {TableName}.bak"
  DUP >R STR@ ['] update INCLUDED-WITH
  R> STRFREE

  CloseNewTbl
  \ qSql ReconnectSQL SqlThrow
  qSql FreeStmt

  MakeTbl

  HashT del-hash  0 HashT!
;

\ ===============================================

GET-CURRENT ALSO SqlLex DEFINITIONS

: FROM
  NextWord dTableName 2!
;
: WHERE
  SkipDelimiters
  0 PARSE dWhereCondition 2!
;
: DELETE ( -- sql_ior )
  ['] SqlTxtDelete TO Action
;
\ DELETE FROM authors WHERE au_lname = 'McBadden'

\ --------------------------------
: UPDATE ( -- sql_ior )
  NextWord dTableName 2!
  small-hash HashT!
  ['] SqlTxtUpdate TO Action
;
: SET ( -- )
  BEGIN
    SkipComma
    NextValueName
  WHILE
    HashT  HASH!
    SkipDelimiters
    PeekChar [CHAR] , <>
  UNTIL THEN
;
\ UPDATE Tbl SET f2 = 'v2',  f3 = 'v3'  WHERE f1 = 'v1'

PREVIOUS  SET-CURRENT
\ ===============================================


SET-CURRENT

: ProceedSqlTxt ( S" statement" fodbc -- sql_ior )
  TO qSql
  0. dTableName 2!
  0. dWhereCondition 2!
  ALSO SqlLex
    ['] EVALUATE CATCH ?DUP IF PREVIOUS THROW THEN
    ( ошибка трансл€ции пойдет выше, т.к. это не sql_ior )
    CheckTbl  ['] Action CATCH ( sql_ior )
  PREVIOUS
;
: (IsSQLTxt) ( -- flag )
  >IN @ >R NextWord
   SqlLexWid SEARCH-WORDLIST DUP IF NIP THEN
  R> >IN !
;
: IsSQLTxt ( a u -- flag )
  ['] (IsSQLTxt) EVALUATE-WITH
;

PREVIOUS

: ExecSQLTxt ( S" statement" fodbc -- sql_ior )
  { a u fodbc }
  a u IsSQLTxt             IF
  a u fodbc ProceedSqlTxt  ELSE
  a u fodbc ExecSQL        THEN
;

\ ALSO ODBCTxt-Support