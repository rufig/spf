S" ~micro/deleter/interface.f" INCLUDED
S" ~micro/deleter/sheduler.f" INCLUDED

:NONAME
  LoadList
  EXECUTE
; TO <MAIN>
FALSE TO SPF-INIT?
TRUE TO ?GUI
S" deleter.exe" SAVE
BYE
