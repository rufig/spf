\ 03.Feb.2007 ruv
\ 30.Jan.2008 -- moved from index.f

S" ALLOT" GET-CURRENT SEARCH-WORDLIST [IF] DROP [ELSE]
\ дополнения, чтобы весь лексикон кодогенератора был в одном списке

: ,      , ;
: C,    C, ;
: S,    S, ;
: ALLOT ALLOT ;
: HERE  HERE  ;

: LIT,  LIT,  ;
: SLIT, SLIT, ;

[THEN]


: DEFER-LIT, ( -- addr )
  -1 LIT,  \  т.к. для 0  оптимизатор сделает  XOR  EAX, EAX
  HERE 3 - CELL-
;
: EXEC, ( xt -- )
  GET-COMPILER? IF EXECUTE EXIT THEN COMPILE,
;
: EXIT, ( -- )
  RET,
;

: 2LIT, ( x x -- )
  SWAP LIT, LIT,
;



USER GERM-A

: GERM  GERM-A @ ;
: GERM! GERM-A ! ;

S" xt.immutable.f" Included

: BFW, ( -- ) ( CS: -- a )
  0 BRANCH, >MARK >CS
;
: BFW2, ( -- ) ( CS: a1 -- a2 a1 )
  CS> BFW, >CS
;
: ZBFW, ( -- ) ( CS: -- a )
  0 ?BRANCH, >MARK >CS
;
: ZBFW2, ( -- ) ( CS: a1 -- a2 a1 )
  CS> ZBFW, >CS
;
: RFW ( -- ) ( CS: a -- )
  CS> >RESOLVE1
;

: MBW ( -- ) ( CS: -- a )
  HERE >CS
;
: BBW, ( -- ) ( CS: a -- )
  CS> BRANCH,
;
: ZBBW, ( -- ) ( CS: a -- )
  CS> ?BRANCH,
;

