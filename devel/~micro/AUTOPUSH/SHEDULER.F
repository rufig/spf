REQUIRE ShowStatusLine ~micro/autopush/console.f
\ работа с консолью

: INCLUDED-SCRIPT
\ загрузка программы с проверкой баланса стека
  DEPTH 2- >R
  ['] INCLUDED CATCH
  DEPTH 1- R> <> OR
  ABORT" Ошибка в скрипте"
;

0 VALUE Delay
\ задержка между сканированиями окон с целью найти подходящее в мс
VECT scan
\ сканировать

: scanner
\ начало списка сканирования
  :NONAME
;

: ;scanner
\ конец списка
  POSTPONE ;
  TO scan
; IMMEDIATE

:NONAME
\ главный цикл
  DROP
  BEGIN
    scan
    ShowStatusLine
    Delay PAUSE
  AGAIN
; TASK: run
\ задача

: loadlist
\ загрузить список.
  S" autopush.cfg" INCLUDED-SCRIPT
;

100 TO Delay
