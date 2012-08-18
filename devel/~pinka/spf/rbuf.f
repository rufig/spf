\ 2012

\ –аспределение пам€ти на стеке возвратов с автоматическим освобождением при выходе.
\ —лово RBUF ( u -- addr u ) возвращает распределеный блок пам€ти.
\ ѕам€ть освобождаетс€ при выходе из того слова, в котором вызвано RBUF
\ ƒопускаетс€ запрашивать произвольное число буферов.
\ ≈сли свободного пространства недостаточно, то произойдет аппаратное исключение STACK_OVERFLOW


: (FREE-RBUF) 
  R> RFREE
;
: RBUF ( u -- addr u )
  R>
  OVER CELL+ 1- >CELLS DUP RALLOT SWAP >R  ( u r a )
  ['] (FREE-RBUF) >R
  SWAP >R
  SWAP
;

\EOF

: test
    RP@ .
  12 RBUF ( addr u )
    OVER . DUP . 2DUP + . CR
    RP@ . CR
  2DUP DUMP
  2DUP ERASE
;

  test DUMP
