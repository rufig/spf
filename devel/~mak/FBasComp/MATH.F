.( ForthBasic math operations  by ~ketma )

REQUIRE vInt ~mak\FBasComp\vars.f 

: CEmitVarLoad ( h -- vt )
  DUP 10 > IF
    DUP Var.
    DUP VarInit@ IF  ." DUP 0! "  THEN
    0 OVER VarInit!
    VarType@  DUP vStr = IF  ." $@ "  ELSE  ." @ "  THEN  
  THEN
;

: LoadPars ( vh1 vh2 -- vt1 vt2 )
  OVER 10 > OVER 10 > AND IF
    SWAP CEmitVarLoad SWAP CEmitVarLoad
  ELSE
    CEmitVarLoad
    OVER 10 >
    IF
      DUP vInt = IF  ." >R "  ELSE  ." 2>R "  THEN
      SWAP CEmitVarLoad SWAP
      DUP vInt = IF  ." R> "  ELSE  ." 2R> "  THEN
    THEN
  THEN
;

: Do+ ( vh1 vh2 -- vhres )
  LoadPars
  2DUP - IF  -666 THROW  THEN
  vInt = IF  ." + "  ELSE  ." $+ "  THEN
;

: Do- ( vh1 vh2 -- vhres )
  LoadPars
  2DUP - IF  -666 THROW  THEN
  vInt = IF  ." - "  ELSE -666 THROW THEN
;

: Do* ( vh1 vh2 -- vhres )
  LoadPars
  2DUP - IF  -666 THROW  THEN
  vInt = IF  ." * "  ELSE -666 THROW THEN
;

: Do/ ( vh1 vh2 -- vhres )
  LoadPars
  2DUP - IF  -666 THROW  THEN
  vInt = IF  ." / "  ELSE -666 THROW THEN
;
