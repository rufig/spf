\ все WINAPI-функции будут оставл€ть след в uLastApiFunc,
\ чтобы в случае EXCEPTION'а вне тела форта иметь намЄк на сбойнувшую функцию

USER uLastApiFunc

: _WINAPI-TRACE
  uLastApiFunc !
;
: WINAPI: ( "»м€ѕроцедуры" "»м€Ѕиблиотеки" -- )

  >IN @ NextWord SFIND
  IF DROP
     DROP NextWord 2DROP EXIT
  ELSE 2DROP >IN ! THEN

  NEW-WINAPI?
  IF HEADER
  ELSE -1 >IN @ HEADER >IN ! THEN
  LATEST LIT,                      \  LATEST ] POSTPONE LITERAL POSTPONE [  :)
  POSTPONE _WINAPI-TRACE
  POSTPONE _WINAPI-CODE
  __WIN:
;
