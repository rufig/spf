\ Extensible Storage Engine API wrappers
\ http://en.wikipedia.org/wiki/Extensible_Storage_Engine
\ http://msdn.microsoft.com/en-us/library/ms684493.aspx

REQUIRE {                     ~ac/lib/locals.f

WINAPI: JetCreateInstanceA     ESENT.DLL
WINAPI: JetSetSystemParameterA ESENT.DLL
WINAPI: JetInit                ESENT.DLL
WINAPI: JetBeginSessionA       ESENT.DLL
WINAPI: JetCreateDatabaseA     ESENT.DLL
WINAPI: JetAttachDatabaseA     ESENT.DLL
WINAPI: JetOpenDatabaseA       ESENT.DLL
WINAPI: JetCreateTableA        ESENT.DLL
WINAPI: JetOpenTableA          ESENT.DLL
WINAPI: JetAddColumnA          ESENT.DLL

-1201 CONSTANT JET_errDatabaseDuplicate \ Database already exists
-1303 CONSTANT JET_errTableDuplicate    \ Table already exists


: TEST { \ ins ses db tbl }
  S" spf4" DROP ^ ins JetCreateInstanceA THROW
  ^ ins JetInit THROW \ это создает служебные edb-файлы, сходу занимающие 16Мб :)
  0 0 ^ ses ins JetBeginSessionA THROW
  0 ^ db 0 S" test_ese.edb" DROP ses JetCreateDatabaseA \ пустая БД - 1Мб
  DUP JET_errDatabaseDuplicate = 
  IF DROP
     0 S" test_ese.edb" DROP ses JetAttachDatabaseA THROW
     0 ^ db 0 S" test_ese.edb" DROP ses JetOpenDatabaseA THROW
  ELSE THROW THEN
  ^ tbl 0 0 S" test_table" DROP db ses JetCreateTableA
  DUP JET_errTableDuplicate =
  IF DROP
     ^ tbl 0 0 0 S" test_table" DROP db ses JetOpenTableA THROW
  ELSE THROW THEN
  tbl .
;
TEST