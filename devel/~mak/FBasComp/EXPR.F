\ ForthBasic expression calculator   by ~ketma
REQUIRE vInt ~mak\FBasComp\vars.f
REQUIRE Do+ ~mak\FBasComp\math.f

0 VALUE ('Expr)

: Term ( -- type )
  TokenId CASE
    tNum OF  TokenNum .  vInt  ENDOF
    tStr OF  ." S" 34 EMIT SPACE Token TYPE 34 EMIT SPACE  vStr  ENDOF
    tCmd OF  Token 2DUP ?Name$ IF  NewStrVar  ELSE  NewIntVar  THEN  ENDOF
    tDel OF  S" (" CheckToken  NextToken ('Expr) EXECUTE S" )" CheckToken  ENDOF
    -1 ABORT" дебил."
  ENDCASE
  NextToken
;

: "*/" ( -- type )
  Term  ( type )
  BEGIN
    TokenId tDel =
    S" *" Token?  S" /" Token?  OR  AND
   WHILE
    Token DROP C@ NextToken
    CASE
      [CHAR] * OF  Term Do*  ENDOF
      [CHAR] / OF  Term Do/  ENDOF
    ENDCASE
  REPEAT
;

: "+-" ( -- type )
  "*/"  ( type )
  BEGIN
    TokenId tDel =
    S" +" Token?  S" -" Token?  OR  AND
   WHILE
    Token DROP C@ NextToken
    CASE
      [CHAR] + OF "*/" Do+  ENDOF
      [CHAR] - OF "*/" Do-  ENDOF
    ENDCASE
  REPEAT
;

: Expr ( -- type )
  "+-"
;

' Expr TO ('Expr)
