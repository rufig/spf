\ Описание кучи констант без лишних слов
\ CONST комментарий
\   константа0 выражение0
\   ...
\   константаn выражениеn
\ ;
\ Пустых строк быть не должно!

: CONST  
  BEGIN
    REFILL 0= ABORT" CONST without ;" 
    NextWord S" ;" COMPARE
  WHILE
    INTERPRET  0 >IN ! CONSTANT
  REPEAT ;
