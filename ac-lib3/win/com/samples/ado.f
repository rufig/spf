.( Content-Type: text/plain) CR CR

REQUIRE :: ~yz/lib/automation.f

0 VALUE conn
0 VALUE rs

2 CONSTANT adClipString

: mystic-powers-of-word

COM-init DROP

  " ADODB.Connection" ?create-object 
  IF ." Не могу создать ADODB" BYE THEN
  TO conn

\  arg( " Driver={Microsoft Access Driver (*.mdb)};DBQ=c:/pro/eserv_dbms/db/eserv_msgbase.mdb" _str )arg conn :: open
\  arg( " Provider=Microsoft.Jet.OLEDB.4.0;Data Source=c:/pro/eserv_dbms/db/eserv_msgbase.mdb" _str )arg conn :: Open
  arg( " Provider=Microsoft.Jet.OLEDB.4.0;Data Source=c:/pro/eserv_dbms/db/eserv_msgbase.mdb" _str )arg conn :: Open

  " ADODB.Recordset" ?create-object 
  IF ." Не могу создать ADODB" BYE THEN
  TO rs

  arg( " SELECT * FROM sp_users" _str conn _obj )arg rs :: Open

\ rs :: EOF @
\ ." ==" . . ." =="
\ rs :: Fields Item ["nick"] Value @
\ . ASCIIZ> TYPE
." <table><tr><td>"
arg( adClipString _int 30 _int " </td><td>" _str " </tr><tr>" _str )arg rs :: GetString >
DROP ASCIIZ> TYPE
." </tr></table>"

\ rs . conn .


\ conn release
\ rs release

COM-destroy ;

mystic-powers-of-word

BYE
