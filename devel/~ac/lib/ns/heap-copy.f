\ HEAP-COPY для SPF/Linux

: HEAP-COPY ( addr u -- addr1 )
\ скопировать строку в хип и вернуть её адрес в хипе
  DUP 0< IF 8 THROW THEN
  DUP 1+ ALLOCATE THROW DUP >R
  SWAP DUP >R MOVE
  0 R> R@ + C! R>
;
