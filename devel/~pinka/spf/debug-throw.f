\ 26.03.2007

\ Подключать, когда непонятно, в каком месте исключение происходит:

: THROW
  DUP 0= IF THROW EXIT THEN

  
  CR OK RP@
  BEGIN DUP R0 @ U> 0= WHILE
    STACK-ADDR.
    CELL+
  REPEAT
  DROP

  THROW
;
