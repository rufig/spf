
\ TRY ( i*x i -- )
\  ...
\ TRAP ( -- i*x u ) \ u - 0 если все нормально или номер exception

\ : NDROP 1+ CELLS SP@ + SP! ;

: TRY ( x*i i -- )
\ Сохранить перед вызовом CATCH u параметров стека данных на
\ стеке возвратов.
   POSTPONE NRCOPY
   POSTPONE DROP
   0 BRANCH, >MARK HERE SWAP
; IMMEDIATE

: TRAP ( -- x*i u )
\ Поймать исключение, восстановить i параметров, сохраненных TRY
\ Возвратить u - номер исключения, 0 если не было.
   RET,
   1 >RESOLVE
\   S" LITERAL CATCH DUP IF R@ SWAP >R NDROP R> NR> ROLL ELSE NR> NDROP THEN" EVALUATE
   S" LITERAL CATCH TRAP-CODE" EVALUATE
; IMMEDIATE

(
: test
  1 2 3 3
  TRY
    DROP DROP DROP
    -2003 THROW
  TRAP
; test )