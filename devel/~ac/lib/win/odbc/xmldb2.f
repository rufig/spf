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
REQUIRE STR@         ~ac/lib/str2.f

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
      ColName 2SWAP Col DUP 1 < IF 2DROP S" 0" THEN 2OVER
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
      ColName 2SWAP Col DUP 1 < IF 2DROP S" 0" THEN S@ 2OVER
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

\  S" Driver={Microsoft Text Driver (*.txt; *.csv)};DefaultDir=G:\Eserv3\CONF\lists" SqlInit
\ S" select * from [AS.txt]" SqlQueryXml TYPE
\ CR CR
\ S" select EMAIL_TO as Email, COUNT(EMAIL_TO) as Msgs, SUM(SIZE) as Total from [200307mail-spam.txt] group by EMAIL_TO order by COUNT(EMAIL_TO)" SqlQueryXml TYPE
\ SqlExit
