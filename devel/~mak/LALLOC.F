\ Аллокирование локального массива             Максимов М.О.
REQUIRE [IF] ~MAK\CompIF1.f
REQUIRE   { ~mak\locals.f

: L_LOCALALLOC    ( n1 -- a1 )          \ allocate n1 bytes of return stack
                                        \ return a1 the address of the array
                                        \ if no locals, setup stack frame
\ может быть только последним, но работает быстрее
 RP@ CELL+ @ ['] (LocalsExit) =
 IF DUP  RP@ - NEGATE RP!
    DUP  RP@ +
    OVER RP@
    SWAP RP@ + CELL+ CELL+ @ 3 CELLS + CMOVE
    RP@  DUP   CELL+ CELL+ @ 3 CELLS + +   \ n1 a1
    SWAP RP@   CELL+ CELL+ +!
 ELSE
     R> SWAP
     DUP RP@ - NEGATE RP!
     >R
     ['] (LocalsExit) >R
     >R RP@ 3 CELLS +
 THEN
;
: LOCALALLOC    ( n1 -- a1 )          \ allocate n1 bytes of return stack
                                        \ return a1 the address of the array
                                        \ if no locals, setup stack frame
 RP@ CELL+ @ ['] (LocalsExit) =
 IF CELL+ CELL+
    DUP RP@ - NEGATE RP!
    DUP  RP@ +
    OVER RP@
    SWAP RP@ + CELL+ CELL+ @ 3 CELLS + CMOVE
    RP@  DUP   CELL+ CELL+ @ 3 CELLS + +   \ n1 a1
    TUCK >R CELL- CELL- R>  CELL+ !   ['] (LocalsExit) SWAP !
    RP@  DUP   CELL+ CELL+ @ 5 CELLS + +
 ELSE
     R> SWAP
     DUP RP@ - NEGATE RP!
     >R
     ['] (LocalsExit) >R
     0 >R  ['] (LocalsExit) >R
     >R
     RP@ 5 CELLS +
 THEN
 ;

\ EOF

HEX
: TT0
 8  L_LOCALALLOC DUP U.
 8   1 FILL
  RP@ 20 DUMP
;
 TT0
: TT1
 8   LOCALALLOC DUP U.
 8   2 FILL
 8   LOCALALLOC DUP U.
 8   1 FILL
  RP@ 30 DUMP
  ;
  TT1
: TT2
 8   LOCALALLOC DUP U.
 8   2 FILL
 8 L_LOCALALLOC DUP U.
 8   1 FILL
  RP@ 30 DUMP
 ;
  TT2
: TST
  { \ XX YY ZZ }
  05 CELLS   LOCALALLOC -> XX
  05 CELLS   LOCALALLOC -> YY
  05 CELLS L_LOCALALLOC -> ZZ
CR  ZZ U. YY U. XX U.
  05 00 DO I      ZZ I CELLS + ! LOOP 
  05 00 DO I 05 + YY I CELLS + ! LOOP 
  05 00 DO I 0A + XX I CELLS + ! LOOP 
  RP@ 70 DUMP
 ;
TST
