\ Аллокирование локального массива             Максимов М.О.
REQUIRE [IF] ~MAK\CompIF1.f
REQUIRE   { ~mak\locals4.f

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

[DEFINED] vocLocalsSupport_M
[IF]
USER-VALUE NLOC_U
USER-VALUE uCnt_U

: {LOCALALLOC} ( n n1 -- RP@ )
  TO uCnt_U TO NLOC_U
  RP@ NLOC_U   CELL+ CELL+ -  RP!  \ 
  RP@ NLOC_U + CELL+ CELL+ RP@ uCnt_U   CMOVE
  ['] (LocalsExit) RP@ uCnt_U       + !
  NLOC_U           RP@ uCnt_U + CELL+ !
\  RP@ 70 DUMP
  RP@ uCnt_U + CELL+ CELL+ 
;

: LOCALALLOC    ( n -- a )          \ allocate n1 bytes of return stack
[IFDEF] DBG_POST DBG_POST  S_DBG_RP@ [THEN]
  VM'; S" ;" SFIND DROP  =  
  IF [  ALSO vocLocalsSupport_M ]
       uLocalsCnt  @ 1+ CELLS LIT,
       POSTPONE {LOCALALLOC}
      [ PREVIOUS ]
  ELSE POSTPONE LOCALALLOC
  THEN
[IFDEF] DBG_POST DBG_POST  R_DBG_RP@ [THEN]
;     IMMEDIATE

: L_LOCALALLOC    ( n -- a )          \ allocate n1 bytes of return stack
  VM'; S" ;" SFIND DROP  =  
  IF [  ALSO vocLocalsSupport_M ]
       uLocalsCnt  @ 1+ CELLS LIT,
       POSTPONE {LOCALALLOC}
      [ PREVIOUS ]
  ELSE
          POSTPONE L_LOCALALLOC
  THEN
;     IMMEDIATE

[THEN]

: LOCALALLOC:   ( n1 -<name>- )   \ allocate a local n1 byte buffer to local "name"
        ?COMP
        POSTPONE LOCALALLOC
	PARSE-NAME
	DUP   6 + L_LOCALALLOC >R
	S"  TO "  R@  $!   
	R@  $+!    R>  COUNT EVALUATE
;   IMMEDIATE

: NestedObject { Obj \ rem$ -- class 'Obj } (* returns obj AND class, rewritten *)
            MAXSTRING LOCALALLOC: rem$
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
 F7_ED
 { \ XX YY ZZ }
  05 CELLS   LOCALALLOC  TO XX
  CR  RP@ 40 DUMP \  ABORT
  05 CELLS   LOCALALLOC  -> YY
  05 CELLS   LOCALALLOC  -> ZZ
  CR  RP@ 40 DUMP \  ABORT
CR  ZZ U. YY U. XX U.
  05 00 DO I      ZZ I CELLS + ! LOOP 
  05 00 DO I 05 + YY I CELLS + ! LOOP 
  05 00 DO I 0A + XX I CELLS + ! LOOP 

  CR  RP@ 100 DUMP \ ABORT
  RP@ 70 DUMP
 ;
     TST