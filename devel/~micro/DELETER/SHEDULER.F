VARIABLE DeleteTime
\ время между удалениями в мс

: Time
\ задание времени между удалениями
  0.
  NextWord
  >NUMBER ABORT" Bad number"
  DROP
  D>S
  DeleteTime !
; IMMEDIATE

: ms ; IMMEDIATE
: sec DeleteTime @ 1000 * DeleteTime ! ; IMMEDIATE
: min DeleteTime @ 60000 * DeleteTime ! ; IMMEDIATE
\ масштабирование с учётом единицы измерения

: Wait
\ остановка на заданное время
  DeleteTime @ PAUSE
;

: LoadList ( -- xt )
\ загрузка конфига
  :NONAME
  POSTPONE BEGIN
  S" deleter.cfg" INCLUDED
  POSTPONE Wait
  POSTPONE AGAIN
  POSTPONE ;
;

