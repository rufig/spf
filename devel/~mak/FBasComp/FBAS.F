\ FBasic main file     by ~ketma 
WARNING 0!

S" ~ketma\FBasComp\parser.f" INCLUDED
S" ~mak\FBasComp\opdef.f" INCLUDED

.( Forth BASIC Interpreter v0.3 by dRUG // Piranha) CR
.( Apr, 2000 ) CR CR

: IsEOF? ( -- eof )
  GetChar EOF?  DUP 0=  IF  UngetChar  THEN
;

: Run ( -- )
  0 TO InPos
  IsEOF?  IF  EXIT  THEN
  NextToken
  BEGIN
\    ." \ New operator" CR
    Token \  2DUP ." $" TYPE CR 
    DoCmd CR
    IsEOF?
  UNTIL
;
