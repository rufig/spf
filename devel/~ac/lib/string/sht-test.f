REQUIRE ST-FOREACH-HASHED ~ac/lib/string/sht.f 
\ тесты и примеры для sht.f

USER TSHT TSHT . CR
: TEST DUP sht.keyhash 32 TYPE SPACE sht.valhash 32 TYPE SPACE TYPE ."  === " TYPE CR ;
: ST-SIG-CONCAT ( s vala valu keya keyu node -- s )
  DROP " {s}{s}" OVER S+
;
: ST-URL-CONCAT ( s vala valu keya keyu node -- s )
  DROP " {s}={s}&" OVER S+
;

WINAPI: GetTickCount KERNEL32.DLL
GetTickCount
S" 222" S" 2test" TSHT ST!
S" 111" S" 1test" TSHT ST!
S" 333" S" 3test" TSHT ST!
S" 444" S" 3test" TSHT ST!

S" 2test" TSHT ST@ TYPE CR
S" 3test" TSHT ST@ TYPE CR

' TEST TSHT ST-FOREACH-SORTED CR
"" ' ST-URL-CONCAT TSHT ST-FOREACH-SORTED STYPE CR

: ADD-FILE
  BEGIN
    NextWord DUP
  WHILE
    NextWord 2SWAP TSHT ST!
  REPEAT 2DROP
;
S" test.txt" FILE DUP . CR CR ' ADD-FILE EVALUATE-WITH

' TEST TSHT ST-FOREACH-SORTED
uST-MAXRECLEVEL @ .

CR CR
uST-MAXRECLEVEL 0!
' TEST TSHT ST-FOREACH-HASHED
uST-MAXRECLEVEL @ .

CR CR
uST-MAXRECLEVEL 0!
' TEST TSHT ST-FOREACH-VHASHED
uST-MAXRECLEVEL @ .

CR GetTickCount SWAP - . CR

: ST1 ( vala valu keya keyu node -- )
  DROP TSHT ST@
  2DROP 2DROP
;
: ST2 ( vala valu keya keyu node -- )
  DROP TSHT ST? DROP
  2DROP 2DROP
;

GetTickCount
' ST1 TSHT ST-FOREACH-HASHED
CR GetTickCount SWAP - . CR

GetTickCount
' ST1 TSHT ST-FOREACH-HASHED
CR GetTickCount SWAP - . CR

GetTickCount
' ST2 TSHT ST-FOREACH-HASHED
CR GetTickCount SWAP - . CR

GetTickCount
' ST1 TSHT ST-FOREACH-SORTED
CR GetTickCount SWAP - . CR

GetTickCount
' ST2 TSHT ST-FOREACH-SORTED
CR GetTickCount SWAP - . CR
