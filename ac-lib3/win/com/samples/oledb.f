.( Content-Type: text/plain) CR CR

REQUIRE :: ~yz/lib/automation.f
WARNING @ WARNING 0!
: Z" POSTPONE " ; IMMEDIATE
REQUIRE STR@ ~ac/lib/str2.f
WARNING !

2 CONSTANT adClipString

: DBconnect ( str -- conn )
  STR@ DROP arg( SWAP _str )arg
  Z" ADODB.Connection" create-object THROW
  SWAP OVER :: Open
;
: DBquery ( conn str -- rs )
  arg( ROT ROT STR@ DROP _str ROT _obj )arg
  Z" ADODB.Recordset" create-object THROW
  SWAP OVER :: Open
;
: DBshow_table ( conn str  -- )
  DBquery
  ." <table border=1><tr>"
  DUP
  :: Fields @
  DROP FOREACH 
      OBJ-I DROP :: Name @
      DROP ASCIIZ> ." <th>" TYPE ." </th>"
  NEXT
  ." </tr><tr><td>"
  arg( adClipString _int 100 _int Z" </td><td>" _str Z" </td></tr>\n<tr><td>" _str Z" &nbsp;" _str )arg 
  SWAP :: GetString >
  _str = IF ASCIIZ> TYPE THEN
  ." </tr></table>"
;
: DBclose ( conn -- )
  arg() SWAP :: Close
;
: DBcommand DBquery DROP ;

: TEST
  COM-init THROW

  " Provider=Microsoft.Jet.OLEDB.4.0;Data Source=cgi-bin/test.mdb" DBconnect
  DUP " DELETE FROM Customers WHERE CustomerID='DSFT'" DBcommand
  DUP " INSERT INTO Customers (CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Region, PostalCode, Country, Phone, Fax) 
      VALUES ('DSFT','Delosoft','Andrey Cherezov','Owner','47-6 ,International Str','Kaliningrad','RU','236011','Russia','58-01-31','-')" 
      DBcommand
  DUP " SELECT * FROM Customers" DBshow_table
\  DBclose
  DROP

  COM-destroy
;

TEST
