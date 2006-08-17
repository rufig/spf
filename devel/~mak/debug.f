( interactive debugger for )
( Mihail Maksimov 2001     )
REQUIRE [IF] lib\include\tools.f 

VECT  DBG-DO

0 VALUE DBG_FLAG

: DBG[  TRUE TO DBG_FLAG
  BEGIN REFILL DBG_FLAG AND
  WHILE
    STATE @
    IF    SOURCE POSTPONE SLITERAL POSTPONE DBG-DO
    THEN  INTERPRET 
  REPEAT
;  IMMEDIATE

: ]DBG  FALSE TO DBG_FLAG
;  IMMEDIATE

: -DBG  ['] 2DROP TO DBG-DO ; -DBG

0 VALUE Nest

: SetNest TRUE TO Nest ;

: TRACE 2>R CR ." ( " DEPTH .SN ." )" CR 2R> TYPE
  FALSE TO Nest
   KEY 
   DUP [CHAR] R = IF -DBG    THEN
   DUP [CHAR] Q = IF ABORT   THEN
       [CHAR] N = IF SetNest THEN
; 

: +DBG  ['] TRACE TO DBG-DO SetNest ;

: ;;  POSTPONE ; ; IMMEDIATE

0 
[IF]

: RE-DBG  R> TO DBG-DO ;

: NestDo
  R>   Nest 0= 
  IF   ['] DBG-DO >BODY @  >R
               ['] RE-DBG  >R -DBG
  ELSE         ['] SetNest >R
  THEN
  >R ;

[ELSE]

\ ƒопускаетс€ отладка программ передающих параметры
\ через стек возвратов

VARIABLE SSS
1000 ALLOT HERE SSS ! 0 ,

C" -CELL" FIND NIP 0= 
[IF] -1 CELLS CONSTANT -CELL
[THEN]

: >SSS -CELL SSS +!  SSS @ ! ;
: SSS> SSS @ @   CELL SSS +! ;

: RE-DBG  SSS> TO DBG-DO ;

: NestDo
  Nest 0= 
  IF   ['] DBG-DO >BODY @  >SSS
               ['] RE-DBG  >SSS -DBG
  ELSE         ['] SetNest >SSS
  THEN
  ;

: S>EXEC  SSS>  EXECUTE ;

: ; POSTPONE S>EXEC POSTPONE ;
; IMMEDIATE

: EXIT S>EXEC RDROP ;;

[THEN]

: : :
 DBG_FLAG IF
   POSTPONE NestDo
   SOURCE POSTPONE SLITERAL POSTPONE DBG-DO
 THEN ;;

\ Test
\ EOF

DBG[ 
: XX 3
 4  +
 . \ EXIT
 ;

: XX1 3
 4  +
 . EXIT
 ;

: ZZZ   \
        \
  XX ." QQQQ"
  XX1 ." WWW"
  XX ." QEEE"
;
]DBG
+DBG
ZZZ


