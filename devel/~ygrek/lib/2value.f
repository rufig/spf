\ Thanks ~profit for digging asm

: _2CONSTANT-CODE R@ 5 + @ R> 9 + @ ;
: _2TOVALUE-CODE R@ CELL+ ! R> ! ;

: 2VALUE ( a1 a2 "<spaces>name" -- )
  HEADER
  ['] _2CONSTANT-CODE COMPILE,
  ['] _2TOVALUE-CODE COMPILE,
  SWAP , \ first cell
  , \ second cell
  236560997 , \ marker for compile-time checking
;

: 2TO
  '
  DUP 5 + 5 + CELL + CELL + @ 236560997 <> ABORT" Not a 2VALUE"
  5 + STATE @
  IF COMPILE, ELSE EXECUTE THEN
; IMMEDIATE


\EOF

\ lib/ext/disasm.f

0 0 2VALUE s
HERE S" booo" S", COUNT 2TO s
s CR TYPE 

HERE S" far" S", COUNT 2TO s
s CR TYPE 

\ 0 VALUE r HERE S" quaa" S", COUNT 2TO r \ this should fail
