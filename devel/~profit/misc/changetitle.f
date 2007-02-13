\ http://fforum.winglion.ru/viewtopic.php?t=563


WINAPI: SetConsoleTitleA KERNEL32.DLL
REQUIRE STR@ ~ac/lib/str4.f

: changeTitle ( addr u -- )
"" DUP >R STR+
R@ STR@ DROP SetConsoleTitleA DROP
R> STRFREE ;

S" la-la" changeTitle

