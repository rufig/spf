REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS ~day/hype3/hype3.f

WINAPI: GetTickCount KERNEL32.DLL

CLASS CTimer

 VAR time
 VAR start

init: time 0! start 0! ;

: :reset time 0! ;

: :start GetTickCount start ! ;

: :stop 
    start @ DUP 0= IF DROP EXIT THEN
    GetTickCount SWAP - time +!
    start 0! ;

: :ms@ time @ ; 

;CLASS
