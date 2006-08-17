\ ForthBasic variables' manager    by ~ketma 

\ variable info:
\ int init_flag
\ int PrevVarPtr  ; handle points here
\ int vtype       ; vInt or vStr   
\ cstr vname

REQUIRE $! ~ketmar\FBasComp\place.f

1 CONSTANT vInt
2 CONSTANT vStr

0 VALUE PrevVar

: .HDL ( handle -- )
  BASE @ >R HEX U. R> BASE !
;

: VarType@ ( handle -- vtype )
  DUP 10 > IF  4 + @  THEN
;

: VarInit@ ( h -- v )
  4 - @
;

: VarInit! ( v h -- )
  4 - !
;

: Var. ( handle -- )
  DUP 10 > IF
    DUP 8 + COUNT TYPE VarType@ vStr = IF  ." $"  THEN  SPACE
  ELSE
    DROP
  THEN
;

: NewVar ( c-addr u -- handle )
\ variable name can't be empty
  0 MAX 255 MIN
  268 ALLOCATE THROW
  TRUE OVER !  4 +
  DUP >R 8 + $!
  PrevVar R@ !
  R> DUP TO PrevVar
;

: FindVar ( c-addr u -- handle false | true )
  PrevVar
  BEGIN
    ?DUP
   WHILE
    >R 2DUP R@ 8 + COUNT COMPARE 0=
    IF  2DROP R> FALSE  EXIT  THEN
    R> @
  REPEAT
  2DROP TRUE
;

: NewIntVar ( c-addr u -- handle )
  ?DUP 0= IF  -667 THROW  THEN
  2DUP FindVar 
  IF  NewVar vInt OVER 4 + !  ." VARIABLE " DUP Var.
  ELSE >R 2DROP R>
  THEN
;

: NewStrVar ( c-addr u -- handle )
  ?DUP 0= IF  -667 THROW  THEN
  IF  NewVar vStr OVER 4 + !  ." VARIABLE$ " DUP Var.
  ELSE >R 2DROP R>
  THEN
;

: ?Name$ ( c-addr u -- flag )
  DUP 0 > IF  + 1- C@ 36 =  ELSE  2DROP FALSE  THEN
;
