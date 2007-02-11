\ STARTLOG

REQUIRE ltcreate ~ygrek/lib/multi/msg.f

0 VALUE typer

:NONAME
  BEGIN
   DUP PAUSE
   DUP " {n}" DUP STR@ 0 typer ltsend STRFREE
  AGAIN DROP ; VALUE <roamer>

:NONAME
    DUP " created by super as {n}" >R 
    BEGIN DUP PAUSE R@ STR@ 0 typer ltsend AGAIN 
    R> STRFREE ; VALUE <created-by-super>

:NONAME 
  DROP
  600 <created-by-super> ltcreate 
  " super had created lt - {n}" 0 typer STRltsend
  700 <created-by-super> ltcreate 
  " super had created lt - {n}" 0 typer STRltsend
  800 <created-by-super> ltcreate 
  " super had created lt - {n}" 0 typer STRltsend
 ; VALUE <super>

:NONAME
  BEGIN
   DUP PAUSE
   HERE " here = {n}" 0 typer STRltsend
  AGAIN
  DROP ; VALUE <here-watcher>

:NONAME
  DROP
  BEGIN
   ltreceive
   \ DUP msg.sender .
   DUP msg.data CR TYPE
   FREE-MSG
  AGAIN ; VALUE <typer>

500 <roamer> ltcreate VALUE pid1
1000 <roamer> ltcreate VALUE pid2
1500 <roamer> ltcreate VALUE pid3
1000 <here-watcher> ltcreate VALUE pid-here-watcher
0 <typer> ltcreate TO typer
S" qua" 0 typer ltsend
0 <super> ltcreate VALUE super

S" dsds" 0 1 ltsend

2000 PAUSE
S" !!! ===== try to kill" 0 typer ltsend

\ typer ?lt " typer {n}" 0 typer STRltsend
\ 1 ?lt " 1 {n}" 0 typer STRltsend

pid2 ?lt .
pid2 ltkill
pid2 ?lt .



