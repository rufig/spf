: IsImmediate ( item -- flag )
  ItemFlags &Immediate AND
;
: Interpreting ( -- flag )
  STATE @ 0=
;
: AsWord ( item -- ... )
  DUP IsImmediate Interpreting OR
  IF ExecuteWord ELSE CompileWord THEN
;
: TranslateWord ( addr u -- ... )
  Where IF AsWord ELSE AsLiteral THEN
;
