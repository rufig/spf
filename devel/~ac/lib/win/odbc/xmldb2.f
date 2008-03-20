( ~ac 14.07.2003 )
( Функция SqlQueryXml [ S" query" -- "xml-result" ] применяется
  для формирования XML-текстов на основе выборок из баз данных.
  Далее можно XML+XSLT конвертировать в HTML.
  Функция встроена в текущую версию ForthScripter [text/xml и компрессия
  работает автоматически]

  S" select * from table" SqlQueryXml даст на выходе XML-форматированные строки
  <Row N="1"><Email>ac@eserv.ru</Email><Msgs>191650</Msgs><Size>10</Size></Row>
  пример см. в конце файла
)

REQUIRE ConnectFile ~ac/lib/win/odbc/odbc2.f
REQUIRE STR@         ~ac/lib/str5.f

VARIABLE SqlQ

: SqlInit ( S" sqldriver" -- )
  StartSQL 0= IF S" sql_init_error.html" ( FILE) TYPE BYE THEN
  SqlQ !
  SqlQ @ ConnectFile SQL_OK?
  0= IF S" sql_connect_error.html" ( FILE) TYPE BYE THEN
;

: SqlStruc { \ s }
  "" -> s
    S" <Row N='1' struct='1'>" s STR+
    SqlQ @
    SqlQ @ ResultCols 0 ?DO
      I 1+ OVER ColName 2DUP
      " <{s}></{s}>" s S+
    LOOP DROP
    " </Row>{CRLF}" s S+
  s
;
USER uDisableEscaping
: disable-output-escaping \ как в XSLT :) но de-escape не делает
  TRUE uDisableEscaping !
;
USER &escape_tmp

: &escape1
  BEGIN
    #TIB @ >IN @ >
  WHILE
    [CHAR] & PARSE
    &escape_tmp @ STR+
    CharAddr #TIB @ >IN @ - DUP -1 >
    IF 4 MIN S" amp;" COMPARE 0=
       IF S" &" ELSE S" &amp;" THEN &escape_tmp @ STR+
    ELSE 2DROP THEN
  REPEAT
;
: &escape
  uDisableEscaping @ IF EXIT THEN
  2DUP S" &" SEARCH NIP NIP 0= IF EXIT THEN \ если нет &, то не трогаем
  2DUP S" &amp;" SEARCH NIP NIP IF EXIT THEN \ если уже &amp;, то не трогаем
  2DUP S" &lt;" SEARCH NIP NIP IF EXIT THEN \ если &lt;, то не трогаем
  "" &escape_tmp !
  ['] &escape1 EVALUATE-WITH
  &escape_tmp @ STR@
;
USER <escape_tmp
: <escape1
  BEGIN
    #TIB @ >IN @ >
  WHILE
    [CHAR] < PARSE
    <escape_tmp @ STR+
    #TIB @ >IN @ - -1 >
    IF S" &lt;" <escape_tmp @ STR+ THEN
  REPEAT
;
: <escape
  uDisableEscaping @ IF EXIT THEN
  2DUP S" <" SEARCH NIP NIP 0= IF EXIT THEN
  "" <escape_tmp !
  ['] <escape1 EVALUATE-WITH
  <escape_tmp @ STR@
;
VARIABLE DeBlobDebug
USER uDisableDeblob
: disable-deblob
  TRUE uDisableDeblob !
;

: DeBlob { addr u -- a2 u2 }
  uDisableDeblob @ IF addr u EXIT THEN
  DeBlobDebug @ IF ." DeBlob: " addr u . . addr u DUMP CR THEN
  u 2 < IF addr u EXIT THEN
  u 0 ?DO
    addr I +    C@ 16 DIGIT
                      0= IF addr u UNLOOP DeBlobDebug @ IF ." DeBlobResult: " 2DUP TYPE CR CR THEN EXIT THEN \ mysql обманул, это не blob, а например кириллица...
                      4 LSHIFT
    addr I + 1+ C@ 16 DIGIT 
                      0= IF DROP addr u UNLOOP DeBlobDebug @ IF ." DeBlobResult: " 2DUP TYPE CR CR THEN EXIT THEN
                      OR
    addr I 2/ + C!
  2 +LOOP addr u 2/
  2DUP S" " 1+ \ ищем нулевые байты
  SEARCH NIP NIP
  IF " <![CDATA[{s}]]>" STR@ THEN
  DeBlobDebug @ IF ." DeBlobResult: " 2DUP TYPE CR CR THEN
;
: SqlIsBinary ( type -- flag )
  DeBlobDebug @ IF ." Type: " DUP . THEN
  SqlIsBinary
  DeBlobDebug @ IF ." Result: " DUP . CR THEN
;
: SqlQueryResult
  { \ n s }
  "" -> s
  BEGIN
    SqlQ @ NextRow
  WHILE
    n 1+ DUP -> n " <Row N={''}{n}{''}>" s S+
\   SqlQ @ Row ANSI>OEM TYPE CR
    SqlQ @
    SqlQ @ ResultCols 0 ?DO
      I 1+ OVER 2DUP
      ColName 2SWAP Col 
      OVER C@ 0= IF 2DROP S" " THEN
      DUP 1 < 
      IF 2DROP S" 0" 
      ELSE
        I 1+ SqlQ @ ColType SqlIsBinary IF DeBlob THEN
        &escape <escape 
      THEN 
      2OVER
      " <{s}>{s}</{s}>" s S+
    LOOP DROP
    " </Row>{CRLF}" s S+
  REPEAT
  n 0= IF SqlStruc s S+ THEN
  s STR@
  SqlQ @ UnbindCols
  0 SqlQ @ odbcStat @ SQLFreeStmt DROP
;
: SqlQueryResult@
  { \ n s }
  "" -> s
  BEGIN
    SqlQ @ NextRow
  WHILE
    n 1+ DUP -> n " <Row N={''}{n}{''}>" s S+
\   SqlQ @ Row ANSI>OEM TYPE CR
    SqlQ @
    SqlQ @ ResultCols 0 ?DO
      I 1+ OVER 2DUP
      ColName 2SWAP Col DUP 1 < 
      IF 2DROP S" 0"
      ELSE &escape THEN 
      S@ 2OVER
      " <{s}>{s}</{s}>" s S+
    LOOP DROP
    " </Row>{CRLF}" s S+
  REPEAT s STR@
  SqlQ @ UnbindCols
  0 SqlQ @ odbcStat @ SQLFreeStmt DROP
;
: SqlQueryXml ( S" sql_query" -- S" xml-result" )
  SqlQ @ ExecSQL SqlQ @ SQL_Error
  SqlQueryResult
;
: SqlQueryXml@ ( S" sql_query" -- S" xml-result" )
  SqlQ @ ExecSQL SqlQ @ SQL_Error
  SqlQueryResult@
;
: SqlQueryXmlFile ( S" file" -- S" xml-result" )
  EVAL-FILE SqlQueryXml
;
: SqlQueryXmlFile@ ( S" file" -- S" xml-result" )
  EVAL-FILE SqlQueryXml@
;
: SqlExit
  SqlQ @ StopSQL
  SqlQ @ FREE DROP
; 

\ S" Driver={Microsoft Access Driver (*.mdb)};DBQ=G:\PRO\my-web\ds_new\db\eserv_msgbase.mdb" SqlInit
\ S" select * from sp_text" SqlQueryXml TYPE
\ S" Driver={Microsoft Text Driver (*.txt; *.csv)};DefaultDir=G:\Eserv3\CONF.orig\lists" SqlInit
\ S" select * from [LocalDomains.txt]" SqlQueryXml TYPE
\ CR CR
\ S" select EMAIL_TO as Email, COUNT(EMAIL_TO) as Msgs, SUM(SIZE) as Total from [200307mail-spam.txt] group by EMAIL_TO order by COUNT(EMAIL_TO)" SqlQueryXml TYPE
\ SqlExit
\ S" DSN=FTest" SqlInit
\ S" Driver={MySQL ODBC 3.51 Driver};server=localhost;port=3307;DB=db16009a;user=root;stmt=SET NAMES 'cp1251';" SqlInit
\ disable-output-escaping
\ S" latest_orders.sql" SqlQueryXmlFile TYPE
\ S" test.sql" SqlQueryXmlFile TYPE
