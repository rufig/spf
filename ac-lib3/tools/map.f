REQUIRE JMP ~ac/lib/tools/jmp.f

: ADD-TO-MAP ( xt -- )
  HERE . ." : " DUP . ." : " 
  DUP >R WordByAddr 2DUP ." ==>" 2DUP TYPE SFIND
  IF DUP . ." <==" R> 2DUP ." (" . . ." ) " <> IF ."  INTERNAL!! " THEN
  ELSE ."  UNKNOWN REFERENCE!! " RDROP 2DROP THEN
  TYPE
;

BASE @ HEX

: NEW-COMPILE,
  DUP ADD-TO-MAP CR
  0E8 C,
  HERE CELL+ - ,
;
: NEW-LIT,
  DUP ADD-TO-MAP ."  (lit)" CR
  083 C, 0ED C, 4 C,
  0C7 C, 045 C, 0 C, ,
;

BASE !

' NEW-COMPILE, ' COMPILE, JMP
' NEW-LIT,     ' LIT,     JMP

: : SOURCE TYPE CR : ;

CREATE TEST

: ZZZ 6 0 DO TEST ['] TEST 2DROP LOOP [ ' TEST 1+ ] LITERAL ;
