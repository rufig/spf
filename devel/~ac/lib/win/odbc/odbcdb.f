\ Аналог (сырой!) библиотеки ~ac/lib/lin/sql/sql3db.f,
\ но для ODBC. Плюс некоторые доп.расширения - db_exec_voc и db@.

\ REQUIRE EXC-DUMP2 ~pinka/spf/exc-dump.f 

REQUIRE StartSQL  ~ac/lib/win/odbc/odbc2.f
REQUIRE SqlInit   ~ac/lib/win/odbc/xmldb2.f 

: db_open ( S" sqldriver" -- fodbc )
  StartSQL 0= IF DROP 0 EXIT THEN
  DUP >R
  ConnectFile SQL_OK?
  0= IF RDROP 0 EXIT THEN
  R>
;
: db_gets ( addr u sqh -- addr u ... )
  DUP 0= IF 70101 THROW THEN
  DUP >R
  ExecSQL R@ SQL_Error
  R@ NextRow 0= IF RDROP S" " EXIT THEN
  R@ DUP ResultCols 0 ?DO
     I 1+ SWAP DUP >R Col R>
  LOOP DROP
  RDROP
;
: db_exec_ ( addr u sqh -- )
  DUP 0= IF 70102 THROW THEN
  DUP >R ExecSQL R> SQL_Error
;
: db_exec { addr u par xt q \ i -- }
\ выполнить SQL-запрос(ы) из addr u,
\ вызывая для каждого результата функцию xt с параметрами i par ppStmt
\ в запросах НЕ биндятся макроподстановки :name и $name

  q 0= IF 70103 THROW THEN

  addr u q ExecSQL q SQL_Error

  TRUE 0 -> i
  BEGIN
    IF
      q NextRow
    ELSE FALSE THEN
  WHILE
    i 1+ -> i
    i par q xt EXECUTE \ возвращает флаг продолжения
  REPEAT
;

USER SqlQT

\ ## возвращается первое поле первой строки от query

: oid_query { $query -- id }
  SqlQT @ 0= IF 70104 THROW THEN

  $query STR@ SqlQT @ db_gets 0 0 2SWAP >NUMBER 2DROP D>S \ $query STRFREE
;

\ ## выполнить первый запрос, если query вернул более 0 строк, иначе второй
\ ## возвращается первое поле первой строки от query или insert_id от query2
\ ## (т.е. условная вставка записи в базу)

: oreg_query { $query $query1 $query2 \ id -- id }
  SqlQT @ 0= IF 70105 THROW THEN

  $query oid_query DUP -> id \ $query там НЕ освободилось
  IF
    $query1 STR@ SqlQT @ db_exec_
  ELSE
    $query2 STR@ SqlQT @ db_exec_ \ SQH @ db3_insert_id -> id
    $query oid_query -> id \ повторный запрос, чтобы не зависеть от ON CONFLICT
                          \ и вставок в других потоках
  THEN
  $query1 STRFREE  $query2 STRFREE
  $query STRFREE
  id
;

: db_cols ( q -- n ) ResultCols ;
: db_colname ( i q -- addr u ) SWAP 1+ SWAP ColName ;
: db_col ( i q -- addr u ) SWAP 1+ SWAP Col ;
: db_coltype ( i q -- addr u ) SWAP 1+ SWAP ColType ;

USER SqS

: (oxquery) { i par ppStmt -- flag }
  i 1 =
  IF " <thead><tr class='sp_head'>" SqS @ S+
    ppStmt db_cols 0 ?DO
      I ppStmt db_colname 2DUP " <th class='{s}'>{s}</th>" SqS @ S+
    LOOP " </tr></thead>{CRLF}<tbody>" SqS @ S+
  THEN
  i 1 AND 0= IF S"  even" ELSE S" " THEN
  i " <tr N='{n}' class='sp_data{s}'>" SqS @ S+
  ppStmt db_cols 0 ?DO
    I ppStmt db_col DUP 1 < >R 2DUP S" NULL" COMPARE 0= R> OR IF 2DROP S" &nbsp;" THEN
    I ppStmt db_coltype 12 <> IF S"  numb" ELSE S" " THEN
    I ppStmt db_colname  " <td class='{s}{s}'>{s}</td>" SqS @ S+
  LOOP  " </tr>{CRLF}" SqS @ S+
  TRUE
;
: oxquery ( addr u -- addr2 u2 )
  SqlQT @ 0= IF 70106 THROW THEN

  " <table class='sortable' id='sp_table' cellpadding='0' cellspacing='0'>" SqS !
  0 ['] (oxquery) SqlQT @ db_exec
  " </tbody></table>" SqS @ S+
  SqS @ STR@
;


: db@Does ( a1 -- addr u ) \ 'STR@DOES
  DOES> @ ?DUP IF STR@ ELSE S" " THEN
;
: db@Set ( va vu pa pu -- )
  2DUP GET-CURRENT SEARCH-WORDLIST
  IF NIP NIP >BODY S!
  ELSE
    2DUP " CREATE {s}" STR@ EVALUATE 0 , db@Does RECURSE
  THEN
;
: db@ { addr u q -- }
\ выполнить запрос addr u и по первой строке результатов создать
\ строчные переменные в текущем словаре компиляции.

  q 0= IF 70107 THROW THEN
  addr u q ExecSQL q SQL_Error

  q
  q ResultCols 0 ?DO
     I 1+ OVER ColName " CREATE {s}" STR@
     EVALUATE 0 , db@Does
  LOOP DROP

  \ переменные могут остаться и пустыми
  q NextRow
  IF
    q ResultCols 0 ?DO
      I 1+ q Col I 1+ q ColName db@Set
    LOOP
  THEN
;

: db_FieldDoes ( a -- addr u )
  DOES> DUP @ SWAP CELL+ @ Col
  DUP 0 > IF EXIT ELSE 2DROP S" " THEN
;
: db_bindvoc { q -- } \ при использовании не забывать про временные словари ;)
  q
  q ResultCols 0 ?DO
     I 1+ OVER ColName " CREATE {s}" STR@ \ 2DUP TYPE CR
     EVALUATE I 1+ , DUP , db_FieldDoes
  LOOP DROP \ CR
;
: db_exec_voc { addr u par xt q \ i -- }
\ выполнить SQL-запрос(ы) из addr u,
\ вызывая для каждого результата функцию xt с параметрами i par ppStmt
\ в запросах НЕ биндятся макроподстановки :name и $name.
\ Внутри цикла (слову xt) поля доступны не только по номерам, но и по именам.

  q 0= IF 70108 THROW THEN

  addr u q ExecSQL q SQL_Error

  q db_bindvoc

  TRUE 0 -> i
  BEGIN
    IF
      q NextRow
    ELSE FALSE THEN
  WHILE
    i 1+ -> i
    i par q xt EXECUTE \ возвращает флаг продолжения
  REPEAT
;


\EOF

S" DRIVER=MySQL ODBC 3.51 Driver;UID=root; SERVER=localhost; DATABASE=test; PASSWORD=test" db_open SqlQT !
SqlQT @ .

S" select password span from users where email='ac@eserv.ru'" SqlQT @ db_gets TYPE CR

S" select concat(sqrt(5),'-a-',now()),cos(0.5)" SqlQT @ db_gets TYPE SPACE TYPE CR
S" select NULL"  SqlQT @ db_gets . . CR

" select 25*25" oid_query .
" select id from users where email='ac@eserv.ru'" oid_query .

" select id from users where email='ac@forth.org.ru'" " select 5" " insert into users (email) values ('ac@forth.org.ru')" oreg_query .

S" select password,5 aaa, 3.141+0 bbb, NULL nnn from users where email like '%@eserv.ru'" oxquery TYPE CR
