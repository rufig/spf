\ Include all the supported optional word sets and case insensitivity
\ Original idea: "Ilya S. Potrepalov" <potrepalov@asc-ural.ru>, 2006

REQUIRE CASE         lib/include/control-case.f
REQUIRE /STRING      lib/include/string.f
REQUIRE [IF]         lib/include/tools.f
REQUIRE SAVE-INPUT   lib/include/core-ext.f
REQUIRE SYNONYM      lib/include/wordlist-tools.f
REQUIRE TIME&DATE    lib/include/facil.f
REQUIRE DEFER        lib/include/defer.f
[DEFINED] WINAPI: [IF]
REQUIRE RENAME-FILE  lib/win/file.f
[ELSE]
REQUIRE RENAME-FILE  lib/posix/file.f
[THEN]
REQUIRE D0<          lib/include/double.f
REQUIRE ANSI-FILE    lib/include/ansi-file.f

[UNDEFINED] INCLUDE [IF]
: INCLUDE ( i*x "name" -- j*x )
  PARSE-NAME INCLUDED
;
[THEN]


WARNING @  0 WARNING !

: ?DUP  ?DUP ;  \ ?DUP � SP-FORTH'� state-smart, � ��� �� �� ���������
    
WARNING !


[UNDEFINED] BIN [IF]
: BIN ( fam1 -- fam2 ) ;
[THEN]

[UNDEFINED] FILE-STATUS [IF]  [DEFINED] FILE-EXIST [IF]
: FILE-STATUS ( sd.filename -- x ior )
  FILE-EXIST IF 0 0 ELSE 0 -38 THEN
;
[THEN] [THEN]
