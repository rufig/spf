: FindItem (  addr u wid -- addr u false | item true )
  @
  BEGIN
    DUP
  WHILE
    >R 2DUP R@ COUNT COMPARE 0=
    IF 2DROP R> TRUE EXIT THEN
    R> CDR
  REPEAT
;
: ItemXT ( item -- xt )
  NAME>
;
: ItemFlags ( item -- flags )
  NAME>F C@
;
1 CONSTANT &Immediate

: ExecuteWord ( item -- ... )
  ."  Execute:" DUP ID.
  ItemXT EXECUTE
;
: CompileWord ( item -- ... )
  ."  Compile:" DUP ID.
  ItemXT COMPILE,
;

VARIABLE ContextTop
VARIABLE ContextBottom
CREATE ContextStack
8 CELLS ALLOT HERE ContextTop !
GET-CURRENT , 
CONTEXT @ ,   HERE ContextBottom !

: SearchContext ( -- addr u )
  ContextTop @ ContextBottom @ OVER -
;
: Where ( addr u -- wid item true | addr u false )
  ['] FindItem SearchContext ArrayForEach              \ см. array.f
;
: AsLiteral ( addr u -- )
  ."  Literal:" 2DUP TYPE
  0 0 2SWAP
  OVER C@ [CHAR] - = IF 1- SWAP 1+ SWAP TRUE ELSE FALSE THEN >R
  >NUMBER
  DUP 1 > ABORT" -?"
  IF C@ [CHAR] . <> ABORT" -??"
       R> IF DNEGATE THEN
       [COMPILE] 2LITERAL
  ELSE DROP D>S
       R> IF NEGATE THEN
       [COMPILE] LITERAL
  THEN
;
