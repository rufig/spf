\ ForthBasic operators    by ~ketma 

REQUIRE kGetChar ~mak\FBasComp\parser.f
REQUIRE Expr ~mak\FBasComp\expr.f

WORDLIST VALUE CmdVoc

: DoCmd ( c-addr u -- )
  CmdVoc SEARCH-WORDLIST
  IF  EXECUTE  ELSE  -600 THROW  THEN
;

ALSO CmdVoc DUP CONTEXT ! CURRENT !

: ?   S" PRINT" DoCmd  ;

: REM
  BEGIN
    kGetChar
    DUP EOL? SWAP EOF? OR
  UNTIL
  NextToken
;

: PRINT
  NextToken
  FALSE  \ ";" flag
  BEGIN
    DROP
    BEGIN
      S" ," Token?
      DUP  IF  ." 9 EMIT "  THEN
      S" '" Token?
      DUP  IF  ." CR "  THEN
      OR  S" ;" Token?  OR
      DUP  IF  NextToken  THEN
    0= UNTIL
    Expr  CEmitVarLoad
    CASE
      vInt OF  ." . "  ENDOF
      vStr OF  ." TYPE "  ENDOF
    ENDCASE
    S" ;" TokenSkip?
    S" :" TokenSkip?
  UNTIL
  0=  IF  ." CR "  THEN
;

: LET
  NextToken
  TokenId tCmd <> ABORT" variable expected!"
  Token 2DUP ?Name$ IF  NewStrVar  ELSE  NewIntVar  THEN  >R
  NextToken
  S" =" Token? 0= ABORT" '=' expected!"
  NextToken
  Expr  CEmitVarLoad 
  R> DUP Var.
  VarType@ vStr = IF  ." $"  THEN  ." ! "
  S" :"  TokenSkip? 2DROP
;

: RUN
  0 TO InPos NextToken
;

: SYSTEM
  ." BYE " BYE
;

PREVIOUS DEFINITIONS
