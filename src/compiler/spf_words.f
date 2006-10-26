( Печать списка слов словаря - WORDS.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

USER >OUT
USER W-CNT

: NLIST ( A -> )
  @
  >OUT 0! CR W-CNT 0!
  BEGIN
    DUP KEY? 0= AND
  WHILE
    W-CNT 1+! 
    DUP C@ >OUT @ + 74 >
    IF CR >OUT 0! THEN
    DUP ID.
    DUP C@ >OUT +!
    15 >OUT @ 15 MOD - DUP >OUT +! SPACES
    CDR
  REPEAT DROP KEY? IF KEY DROP THEN
  CR CR ." Words: " BASE @ DECIMAL W-CNT @ U. BASE ! CR
;

: WORDS ( -- ) \ 94 TOOLS
\ Список имен определений в первом списке слов порядка поиска. Формат зависит 
\ от реализации.
\ WORDS может быть реализован с использованием слов форматного преобразования 
\ чисел. Соответственно, он может испортить перемещаемую область, 
\ идентифицируемую #>.
  CONTEXT @ NLIST
;
