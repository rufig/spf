\ Динамический буфер: расширяется по мере необходимости
\ Ю. Жиловец, 13.04.2003

MODULE: DYNBUF

EXPORT

0
\ смещения от начала данных
CELL -- :dynptr  \ текущий указатель
CELL -- :dynsize \ текущий размер буфера
== /dynbufheader

: CREATE-DYNBUF ( initsize -- dyn)
  DUP /dynbufheader + GETMEM >R
  R@ :dynptr 0!
  R@ :dynsize !
  R> /dynbufheader + ;

: DEL-DYNBUF ( dyn -- ) /dynbufheader - FREEMEM ;

: DYNSIZE ( dyn -- size) /dynbufheader - :dynptr @ ;

: DYNALLOC ( size dyn -- dataptr newdyn) /dynbufheader - >R
  ( size) R@ :dynptr @ OVER + R@ :dynsize @ > IF
    \ изменяем размер буфера, добавляя к нему size*5 байт
    ( size) DUP 5 * DUP R@ :dynsize +! R> SWAP RESIZE THROW >R
  THEN
  ( size) R@ :dynptr @ R@ + /dynbufheader + 
  SWAP R@ :dynptr +! R> /dynbufheader + ;

;MODULE
