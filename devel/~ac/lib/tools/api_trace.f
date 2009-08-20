\ все WINAPI-функции будут оставл€ть след в uLastApiFunc,
\ чтобы в случае EXCEPTION'а вне тела форта иметь намЄк на сбойнувшую функцию

USER uLastApiFunc

: _WINAPI-TRACE
  uLastApiFunc !
;
: (__WIN:)  ( params "»м€ѕроцедуры" "»м€Ѕиблиотеки" -- )
  HERE >R
  0 , \ address of winproc
  0 , \ address of library name
  0 , \ address of function name
  , \ # of parameters
  IS-TEMP-WL 0=
  IF
    HERE WINAPLINK @ , WINAPLINK ! ( св€зь )
  THEN
  HERE DUP R@ CELL+ CELL+ !
  PARSE-NAME CHARS HERE SWAP DUP ALLOT MOVE 0 C, \ им€ функции
  HERE DUP R> CELL+ !
  PARSE-NAME CHARS HERE SWAP DUP ALLOT MOVE 0 C, \ им€ библиотеки
\  LoadLibraryA DUP 0= IF -2009 THROW THEN \ ABORT" Library not found"
\  GetProcAddress 0= IF -2010 THROW THEN \ ABORT" Procedure not found"
  2DROP
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
  (__WIN:)
;
