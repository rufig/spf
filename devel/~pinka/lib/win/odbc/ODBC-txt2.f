\ 25.Feb.2004 ruv 
\ 25.Mar.2004 ODBC-txt2.f - переделал, тк. под Win2003 не работало..
\ $Id$
( Слово ExecSQLTxt  аналогично ExecSQL из ODBC.F,
  но само реализует команды DELETE и UPDATE
  Необходимо, если используется Text File Driver
  ---
  Особенности и ограничения.
    Команды запроса регистро-зависимы и должны быть в верхнем регистре.
    В запросе DELETE слово FROM обязательно.
    В запросе UPDATE не поддерживается вычисление значений в SET,
      поддерживается ROWID - 'номер строки' /с 22.Apr.2004/.
    Значения атрибутов не должны содержать кавычки ["].
    Файл таблицы должен находиться в текущем каталоге.
    При исключениях [ бросках THROW] возможна утечка памяти [от строк].
)

REQUIRE INCLUDED-WITH  ~pinka\lib\ext\include.f
REQUIRE RENAME-FILE ~pinka\lib\FileExt.f
\ REQUIRE SPARSETO    ~pinka\lib\ext\parse.f
\ подключаю в ODBCTxt-Support, во избежании коллизий
REQUIRE NextSubstring ~pinka\lib\parse.f
REQUIRE COMPARE-U   ~ac\lib\string\compare-u.f
REQUIRE HASH@       ~pinka\lib\hash-table.f
REQUIRE STR@        ~ac\lib\str2.f
REQUIRE ExecSQL     ~ac\lib\win\odbc\ODBC.F
REQUIRE ExistTable  ~ac\lib\win\odbc\odbc2.f


VOCABULARY  ODBCTxt-Support
GET-CURRENT  ALSO ODBCTxt-Support DEFINITIONS

REQUIRE SPARSETO    ~pinka\lib\ext\parse.f

: NextValueName ( -- a-value u-value a-name u-name true | false )
  SkipDelimiters
  S" =" SPARSE IF
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

\ --------------------------------------------

USER-VALUE  RowId
USER-VALUE  vHashT
USER-VALUE  qSql
USER-CREATE dTableName       2 CELLS USER-ALLOT
USER-CREATE dWhereCondition  2 CELLS USER-ALLOT

: HashT ( -- h )
  vHashT DUP 0= IF
  DROP small-hash
  DUP TO vHashT THEN
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
  " New{TableName}" >R
  R@ STR@  FILE-EXIST         IF
  R@ STR@  DELETE-FILE THROW  THEN
  R> STRFREE
;
: CheckTbl ( -- ) 
\ THROW, if table not exist
  " {TableName}" >R
  R@ STR@ FILE-EXIST 0=
  ABORT" Table not found (current dir must contain the table)"
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
  " {TableName}New"  DUP >R STR@
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
  " {TableName}New" DUP >R STR@
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

: SqlTxtDelete ( -- )
  qSql { q }
  MakeBak

  " SELECT * FROM {TableName} WHERE NOT({WhereCondition})" ExecSqlStr

  OpenNewTbl

  q ResultCols 1+ 1 ?DO
      I q ColName
      I 1 = IF " {''}{s}{''}" ELSE " ;{''}{s}{''}" THEN
      WriteTbl-str
  LOOP  CRLF WriteTbl

  BEGIN
   q NextRow
  WHILE
   q ResultCols 1+ 1 ?DO
     I q Col DUP 0 >
     IF   I 1 = IF " {''}{s}{''}" ELSE " ;{''}{s}{''}" THEN
     ELSE 2DROP I 1 = IF "" ELSE " ;" THEN
     THEN WriteTbl-str
   LOOP  CRLF WriteTbl
  REPEAT

  CloseNewTbl
  q ReconnectSQL SqlThrow

  MakeTbl
;

\ ----------------------------

: StoreCol# ( a u i -- )
( если в HashT есть ключ a u, то сохраняет 
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
: CmpRowById ( -- flag )
  CURSTR @  RowId 1+ <> EXIT
;
: CmpRow ( -- flag ) \ 0 if matched
   >IN 0!
   RowId IF CmpRowById EXIT THEN

   qSql ResultCols 1+ 1 ?DO
     I qSql Col
     ( odbc Col убирает пробелы в конце, даже в кавычках)
     NextField -TRAILING  COMPARE  
     DUP IF UNLOOP EXIT THEN DROP
   LOOP 0
;
: WriteField ( i a u -- )
   DUP
   IF   ROT 1 = IF " {''}{s}{''}" ELSE " ;{''}{s}{''}" THEN
   ELSE 2DROP 1 = IF "" ELSE " ;" THEN
   THEN WriteTbl-str
;
: UpdateRowById ( -- )
  SOURCE NIP 0= IF EXIT THEN
  0  
  BEGIN
    SkipDelimiters
    EndOfChunk 0=
  WHILE ( i )
    1+ DUP DUP HasValue IF
    NextField 2DROP     ELSE
    NextField           THEN
    ( i i a u )
    WriteField
  REPEAT DROP  CRLF WriteTbl
;
: UpdateRow ( -- )
   SOURCE NIP 0= IF EXIT THEN
   qSql ResultCols 1+ 1 ?DO
     I
     I HasValue 0= IF
     I qSql Col    THEN ( i a u )
     WriteField
   LOOP  CRLF WriteTbl
;
: WriteOtherRows ( -- )
  BEGIN  
    REFILL
  WHILE
    CmpRow
  WHILE
    SOURCE WriteTbl
    CRLF WriteTbl
  REPEAT ELSE SOURCE DROP 0 SOURCE! THEN
  \ обнулил SOURCE на случай, если файл закончился, 
  \  а NextRow еще нет (когда CmpRow не сработало)
;
: UpdateById ( -- )
  WriteOtherRows
  UpdateRowById
  WriteOtherRows
;
: StoreHeader ( -- )
  0
  BEGIN
    SkipDelimiters
    EndOfChunk 0=
  WHILE
    1+ DUP
    NextField ROT StoreCol#
  REPEAT DROP
;
: update ( -- )
  REFILL IF \ the header
    SOURCE WriteTbl  CRLF WriteTbl
    StoreHeader
  THEN

  RowId IF UpdateById  EXIT THEN

  BEGIN
    qSql NextRow
  WHILE
    WriteOtherRows
    UpdateRow
  REPEAT
  WriteOtherRows
;
: >NUM ( a u -- n )
  0. 2SWAP  >NUMBER 2DROP DROP
;
: TranslateWhere ( -- )
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
: SqlTxtUpdate ( -- )    \ EXIT
  MakeBak
  SelectWhere
  OpenNewTbl

  " {TableName}.bak"
  DUP >R STR@ ['] update INCLUDED-WITH
  R> STRFREE

  CloseNewTbl
  qSql ReconnectSQL SqlThrow
  MakeTbl
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
  INTERPRET
  CheckTbl
  ['] SqlTxtDelete CATCH
;
\ DELETE FROM authors WHERE au_lname = 'McBadden'

\ --------------------------------
: UPDATE ( -- sql_ior )
  NextWord dTableName 2!
  HashT clear-hash
  INTERPRET
  CheckTbl
  ['] SqlTxtUpdate CATCH
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
\ UPDATE weather SET temp_hi = temp_hi - 2,  temp_lo = temp_lo - 2  WHERE date > '1994-11-28'

PREVIOUS  SET-CURRENT
\ ===============================================


SET-CURRENT

: ProceedSqlTxt ( S" statement" fodbc -- sql_ior )
  TO qSql
  0. dTableName 2!
  0. dWhereCondition 2!
  ALSO SqlLex
    \ ['] EVALUATE CATCH DUP IF NIP NIP THEN
    ['] EVALUATE CATCH ?DUP IF PREVIOUS THROW THEN ( sql_ior )
    ( ошибка трансляции пойдет выше, т.к. это не sql_ior )
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
