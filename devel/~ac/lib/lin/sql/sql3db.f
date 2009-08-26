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
  IF " <thead><tr class='sp_head'>" SQS @ S+
    ppStmt db3_cols 0 ?DO
      I ppStmt db3_colname 2DUP " <th class='{s}'>{s}</th>" SQS @ S+
    LOOP " </tr></thead>{CRLF}<tbody>" SQS @ S+
  THEN
  i 1 AND 0= IF S"  even" ELSE S" " THEN
  i " <tr N='{n}' class='sp_data{s}'>" SQS @ S+
  ppStmt db3_cols 0 ?DO
    I ppStmt db3_colu DUP 0= ( >R 2DUP S" NULL" COMPARE 0= R> OR) IF 2DROP S" &#160;" THEN
    I ppStmt db3_coltype 3 < IF S"  numb" ELSE S" " THEN
    I ppStmt db3_colname  " <td class='{s}{s}'>{s}</td>" SQS @ S+
  LOOP  " </tr>{CRLF}" SQS @ S+
  TRUE
;
: xquery ( addr u -- addr2 u2 )
  " <table class='sortable' id='sp_table' cellpadding='0' cellspacing='0'>" SQS !
  0 ['] (xquery) SQH @ db3_exec
  " </tbody></table>" SQS @ S+
  SQS @ STR@
;
: xquery_style ( addr u stylea styleu -- addr2 u2 )
  " <table class='sortable {s}' id='sp_table' cellpadding='0' cellspacing='0'>" SQS !
  0 ['] (xquery) SQH @ db3_exec
  " </tbody></table>" SQS @ S+
  SQS @ STR@
;

: (mquery) { i par ppStmt -- flag }
  i 1 =
  IF " <thead><tr class='sp_head'>" SQS @ S+
    ppStmt db3_cols 0 ?DO
      I ppStmt db3_colname
      2DUP S" __" SEARCH IF NIP - ELSE 2DROP THEN
      DUP IF 2DUP " <th class='{s}'>{s}</th>" SQS @ S+ ELSE 2DROP THEN
    LOOP " </tr></thead>{CRLF}<tbody>" SQS @ S+
  THEN
  S" __tagsField" ppStmt db3_field
  i 1 AND 0= IF S"  even" ELSE S" " THEN
  i " <tr N='{n}' class='sp_data{s} sp_tag_{s}'>" SQS @ S+
  ppStmt db3_cols 0 ?DO
    I ppStmt db3_colu DUP 0= 
             IF 2DROP S" &#160;"
             ELSE
                I ppStmt db3_colname S" __" SEARCH
                IF SFIND IF ppStmt SWAP EXECUTE ELSE 2DROP THEN
                ELSE 2DROP THEN
             THEN
    I ppStmt db3_coltype 3 < IF S"  numb" ELSE S" " THEN
    I ppStmt db3_colname
    2DUP S" __" SEARCH IF NIP - ELSE 2DROP THEN
    DUP IF " <td class='{s}{s}'>{s}</td>" SQS @ S+ ELSE 2DROP 2DROP 2DROP THEN
  LOOP  " </tr>{CRLF}" SQS @ S+
  TRUE
;
: mquery ( addr u -- addr2 u2 ) \ вариант с модификаторами полей и тегами/стилями TR
  " <table class='sortable' id='sp_table' cellpadding='0' cellspacing='0'>" SQS !
  0 ['] (mquery) SQH @ db3_exec
  " </tbody></table>" SQS @ S+
  SQS @ STR@
;
: (tquery) { i par ppStmt \ n -- flag }
  ppStmt db3_cols DUP -> n
  0 ?DO
    I ppStmt db3_colu SQS @ STR+
    I n 1- = IF CRLF ELSE S"  " THEN SQS @ STR+
  LOOP
  TRUE
;
: tquery ( addr u -- addr2 u2 ) \ простейший вариант с plaintext результатом
  "" SQS !
  0 ['] (tquery) SQH @ db3_exec
  SQS @ STR@
;
: (nlquery) { i par ppStmt \ n -- flag }
  ppStmt db3_cols DUP -> n
  0 ?DO
    I ppStmt db3_colu SQS @ STR+
    S" ," SQS @ STR+
  LOOP
  TRUE
;
: nlquery ( addr u -- addr2 u2 ) \ простейший вариант с csv результатом
  "" SQS !
  0 ['] (nlquery) SQH @ db3_exec
  SQS @ STR@ 1- 0 MAX
;
