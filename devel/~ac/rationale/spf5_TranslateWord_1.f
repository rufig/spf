\ ВЫКИНУТЬ

\ Вариант реализации TranslateWord ( А.Ч. 12.01.2001 )

: TranslateWord ( addr u -- | ... ) \ throwable
  STATE @ IF CompileWord ELSE ExecuteWord THEN
;
: CompileWord ( addr u -- )
  SearchCompilationSemantic ExecuteIn
;
: ExecuteWord ( addr u -- ... )
  SearchExecutionSemantic ExecuteIn
;
: SearchCompilationSemantic ( addr u -- xt wid )
;

\ ... Не нравится мне такое распараллеливание