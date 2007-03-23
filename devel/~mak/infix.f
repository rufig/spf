
REQUIRE [IF] ~mak/CompIF.f
REQUIRE [IFNDEF] ~nn\lib\ifdef.f

[IFNDEF]   SCAN
: SCAN ( adr len char -- adr' len' )
\ Scan for char through addr for len, returning addr' and len' of char.
        >R 2DUP R> -ROT
        OVER + SWAP
        ?DO DUP I C@ =
                IF LEAVE
                ELSE >R 1 -1 D+ R>
                THEN
        LOOP DROP ;
[THEN]

: PASS\N
  BEGIN  SkipDelimiters  EndOfChunk
  WHILE REFILL 0= IF TRUE  EXIT THEN
  REPEAT      FALSE ;

: MTOKEN ( TABL -- ADDR N )
  PASS\N
  IF DROP CharAddr  0  EXIT THEN
  DUP >R COUNT PeekChar SCAN NIP
  IF RDROP CharAddr 1 DUP >IN +! EXIT THEN
  CharAddr
  BEGIN 1 >IN +!
     EndOfChunk
     IF  TRUE
     ELSE   R@ COUNT PeekChar SCAN NIP
     THEN
  UNTIL   CharAddr OVER -
  RDROP
;

MODULE: _INF_MOD

 CREATE OP HERE 0x20 CELLS ALLOT  HERE SWAP !  \ STACK OF OPERATIONS

: >OP  ( A -- ) 0 CELL - OP +! OP @ !  ;
:  OP@ ( -- A )
   OP @ @   ;
:  OP> ( -- A )  [ OP @ ] LITERAL @ OP @ =
 ABORT" BRACKET IS EXPECTED"
   OP@  CELL OP +! ;

: >OP> ( N -- )   \ N IS PRIORITY
        DUP >R
        BEGIN OP@ > 0=
        WHILE OP> DROP
              OP>  STATE @ IF COMPILE, ELSE EXECUTE THEN
               R@
        REPEAT RDROP ;

C" 2," FIND NIP 0=
[IF] : 2, HERE 2! 2 CELLS ALLOT ;
[THEN]

:  #2-OP ( N -- )  \ N IS PRIORITY
     CREATE IMMEDIATE 2,
     DOES>  2@  >R
            DUP >R >OP>
           R> R>  >OP >OP ;

:   2-OP ( N -- )  \ N IS PRIORITY
     >IN @  ' SWAP
     >IN !  #2-OP ;

 : 1-OP 10 2-OP ;

WARNING 0!
   3 2-OP OR  3 2-OP XOR  4 2-OP AND    5 2-OP =
   6 2-OP <   6 2-OP >
   7 2-OP +   7 2-OP -
   8 2-OP *   8 2-OP /    8 2-OP MOD

: ( 0 >OP  ; IMMEDIATE
: ) 1 >OP>  OP> DROP ; IMMEDIATE
TRUE WARNING !

;MODULE


: _INF_
  C"  }"  MTOKEN DROP C@ [CHAR] { <> ABORT" ожидается {"
  [ ALSO _INF_MOD ] POSTPONE ( [ PREVIOUS ]
  BEGIN   C"  ~!@#$%^&*()+|{}:<>?`-=\[];',./" \ символы разделители
          MTOKEN DUP 
          IF  OVER  C@  [CHAR] }  = IF DROP 0 THEN
          THEN  DUP
  WHILE
   ALSO _INF_MOD    SFIND ?DUP
   PREVIOUS
    IF
         STATE @ =
         IF COMPILE, ELSE EXECUTE THEN
    ELSE
         S" NOTFOUND" SFIND
         IF EXECUTE
         ELSE 2DROP ?SLITERAL THEN
    THEN
    ?STACK
  REPEAT 2DROP
  [ ALSO _INF_MOD ] POSTPONE ) [ PREVIOUS ]
; IMMEDIATE



REQUIRE $! ~mak\place.f

CREATE _INF_BUFF 100 ALLOT
FALSE  VALUE  _INF_FLAG

: NOTFOUND
  2DUP 2>R ['] NOTFOUND CATCH ?DUP
  IF _INF_FLAG IF THROW THEN
      DROP 2DROP
     S"  _INF_  { " _INF_BUFF $!
            2R>     _INF_BUFF $+!
             S"  }" _INF_BUFF $+!
    _INF_BUFF COUNT
    TRUE TO _INF_FLAG ['] EVALUATE CATCH
   FALSE TO _INF_FLAG  THROW
  ELSE 2R> 2DROP
  THEN
;

\ TEST

5 CONSTANT FIVE
7 VALUE    TTT

 _INF_  { 1+2*(1+TTT) } .

4+FIVE*TTT .

: %  MOD  ;
   
MODULE: _INF_MOD

8 2-OP %  \

;MODULE

 (2+3)%2+6/2 TO TTT
 TTT-3-1 .

REQUIRE { ~MAK\locals4.f

: ZZZ { aa bb -- }

  (6*FIVE)/aa-3+bb DUP . TO bb
   aa+bb . ;

3 4 ZZZ

