\ extra

REQUIRE ConnectSQL  ~yz/lib/odbc.f

MODULE: ODBC

WINAPI: SQLGetDiagField       ODBC32.DLL

EXPORT

\ Записать последнее собщение драйвера в addr size
\ Возвращает кол-во реально записанных байт
: SQL_MESSAGE { addr size \ len -- len }
  ^ len size addr W: sql_diag_message_text 1 last-stat @ W: sql_handle_stmt SQLGetDiagField DROP
  len
;

: DisconnectSQL ( fodbc -- ) odbcConn @ SQLDisconnect DROP ;

;MODULE