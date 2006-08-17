\ Создание AutoPusher-а

S" ~micro/autopush/interface.f" INCLUDED
\ интерфейс
S" ~micro/autopush/sheduler.f" INCLUDED
\ собственная оболочка с интерпретатором конфига
S" ~micro/autopush/add.f" INCLUDED

:NONAME
  ['] MyOk TO OK
  GetDesktopWindow CurrentWindow !
  Lines LinesLeft !
  loadlist
  0 run START DROP
  OK
; MAINX !
S" autopush.exe" SAVE
BYE