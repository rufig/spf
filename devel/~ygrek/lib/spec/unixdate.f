\ timestamp в дату

REQUIRE d01011970 ~ac/lib/win/date/unixdate.f

: Num>Date ( n -- s m h d m1 y )
   60 /MOD \ секунды
   60 /MOD \ минуты
   24 /MOD \ часы
   100 * 36525 /MOD
   >R
   100 / \ дней от начала года
   ћес€цƒень \ день мес€ц
   R> 1970 + \ год
   ;
