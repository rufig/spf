REQUIRE db3_open     ~ac/lib/lin/sql/sqlite3.f 

USER SQH
USER SQS

\ ## возвращается первое поле первой строки от query

: id_query { $query -- id }
  $query STR@ SQH @ db3_get_id2 DROP \ $query STRFREE
;

\ ## выполнить первый запрос, если query вернул более 0 строк, иначе второй
\ ## возвращается первое поле первой строки от query или insert_id от query2
\ ## (т.е. условная вставка записи в базу)

: reg_query { $query $query1 $query2 \ id -- id }
  $query id_query DUP -> id \ $query там НЕ освободилось
  IF
    $query1 STR@ SQH @ db3_exec_
  ELSE
    $query2 STR@ SQH @ db3_exec_ \ SQH @ db3_insert_id -> id
    $query id_query -> id \ повторный запрос, чтобы не зависеть от ON CONFLICT
                          \ и вставок в других потоках
  THEN
  $query1 STRFREE  $query2 STRFREE
  $query STRFREE
  id
;
: (xquery) { i par ppStmt -- flag }
  i 1 =
  IF " <tr class='sp_head'>" SQS @ S+
    ppStmt db3_cols 0 ?DO
      I ppStmt db3_colname 2DUP " <th class='{s}'>{s}</th>" SQS @ S+
    LOOP " </tr>{CRLF}" SQS @ S+
  THEN
  i " <tr class='sp_data' N='{n}'>" SQS @ S+
  ppStmt db3_cols 0 ?DO
    I ppStmt db3_col DUP 0= >R 2DUP S" NULL" COMPARE 0= R> OR IF 2DROP S" &nbsp;" THEN
    I ppStmt db3_coltype 3 < IF S"  numb" ELSE S" " THEN
    I ppStmt db3_colname  " <td class='{s}{s}'>{s}</td>" SQS @ S+
  LOOP  " </tr>{CRLF}" SQS @ S+
  TRUE
;
: xquery ( addr u -- addr2 u2 )
  " <table class='sortable' id='sp_table' cellpadding='0' cellspacing='0'>" SQS !
  0 ['] (xquery) SQH @ db3_exec
  " </table>" SQS @ S+
  SQS @ STR@
;
