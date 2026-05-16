\ Recognizer Core API
\ 2026-05-17 ruv

\ This file is included in "./spf_translate.f"

\ Note that Tick `[']`, `synonym`, `postpone`, `to`, and other similar
\ words should use the perceptor (the current recognizer) to obtain
\ nt or xt from their immediate argument.
\ All such words use `take-name` or `take-name>xt`, so only these words need to be updated.


\ In the spf4 v4.30 kernel, the perceptor initially recognizes only Forth words.
\ Numbers are translated beyond the perceptor.
\ An external module might correct that behavior by changing the vector `TRANSLATE-LEXEME`
\ (in a system-specific way).


0 [IF] \ Documentation
\ A type expression `DataType( ... )` delcares relations between formal data types.
\ A type expression `Y <: X`  means that the type `Y` is a subtype of the type `X`
\ An expression `T[ ... -- ... ]` is a refinement of the arrow-type `T`.


\ The most general data type "any"
DataType( any <: ( F: i*x ; S: j*x; C: k*x ; ) )

\ Character string
DataType( sd <: ( c-addr u | 0 0 ) )


\ General "type descriptor"
DataType( td <: xt )

\ "quialified data object"
DataType( qany <: ( any td ) )
\ Note that ( any td ) <> ( qany )

\ "recognizer" (a recognizer shall not have side effects)
DataType( rec <: xt[ sd -- qany|0 ] )

\ Type descriptor for a name token
DataType( ( nt td-nt ) <: qany ; td-nt <: td[ any nt -- any ] )

\ Type descriptor for an execution token
DataType( ( xt td-xt ) <: qany ; td-xt <: td[ any xt -- any ] )

\ Type descriptor for an immediate execution token
DataType( ( xt td-xtimm ) <: qany ; td-xtimm <: td[ any xt -- any ] )


\ Note that not all formal data types have a corresponding type identifier.
\ For example, td is a union type:  td = ( td-nt | td-xt | td-xtimm | ... )
\ and it does not have a data type identifier, only its subtypes do.


[THEN]



0 VALUE SPF4.FORTH-RECOGNIZER \ the system's default recognizer (it will be initialized bellow)

USER (PERCEPTOR) \ NB: the initial value is always 0



: SET-PERCEPTOR ( rec -- )
  \ Set the Forth system to use the recognizer rec to recognize lexemes.
  (PERCEPTOR) !
;
: PERCEPTOR ( -- rec )
  \ rec is a recognizer the Forth system is set to use.
  \ If the Forth system has not been set to use a recognizer, rec is the system's default recognizer.
  (PERCEPTOR) @ DUP IF EXIT THEN DROP
  SPF4.FORTH-RECOGNIZER DUP SET-PERCEPTOR
;
: PERCEIVE ( sd.lexeme -- qany | 0 )
  \ Recognize a lexeme using the current Forth system's recognizer
  PERCEPTOR EXECUTE
;
: PERCEIVE? ( sd.lexeme --  qany true | sd.lexeme false )
  \ Recognize a lexeme using the current Forth system's recognizer
  2DUP 2>R   PERCEIVE   DUP IF 2R> 2DROP  TRUE EXIT  THEN DROP   2R> FALSE
;


\ There are data type identifiers for basic data types.
\ Note that the type of a data type identifier is a subtype of the execution token.

['] TRANSLATE-NAME      CONSTANT TD-NT
['] TRANSLATE-XT        CONSTANT TD-XT
['] TRANSLATE-XTIMM     CONSTANT TD-XTIMM
['] TRANSLATE-LIT       CONSTANT TD-X




\ Type conversions

: QANY>NT ( qany -- nt )
  TD-NT = IF EXIT THEN
  -32 THROW \ "invalid argument"
;
: QANY>XT ( qany -- xt )
  TD-NT       OVER = IF DROP NAME> EXIT THEN
  TD-XT       OVER = IF DROP EXIT THEN
  TD-XTIMM    OVER = IF DROP EXIT THEN
  -32 THROW \ "invalid argument"
;




\ A few recognizers that are predefined in the kernel


: RECOGNIZE-NAME? ( sd.lexeme -- nt td-nt true | sd.lexeme false )
  FIND-NAME? DUP IF TD-NT SWAP THEN
;
: RECOGNIZE-NAME ( sd.lexeme -- nt td-nt | 0 )
  FIND-NAME  DUP IF TD-NT THEN
;


TRUE [IF] \ A backward compatible approach

\ For backward compatibility,
\ the default system's recognizer must use `SEARCH-WORDLIST`
\ (not `FIND-NAME-IN`) to recognize Forth words.
\ But the word `TAKE-NAME` must return nt, so `FIND-NAME-IN` should be used
\ (via `FIND-NAME`).
\ So, we need a flag to control the behavior of `RECOGNIZE-WORD` from `TAKE-NAME`.

USER (ASKEDNAME) \ a private detail

: EXECUTE-ASKINGLY-NAME ( any xt -- any )
  TRUE (ASKEDNAME) !
  EXECUTE
  FALSE (ASKEDNAME) !
;

: RECOGNIZE-WORD ( sd.lexeme -- xt td-xt | xt td-xtimm | nt td-nt | 0 )
  (ASKEDNAME) @ IF RECOGNIZE-NAME EXIT THEN
  SFIND  DUP IF  -1 = IF   TD-XT EXIT THEN   TD-XTIMM EXIT THEN
  NIP NIP ( 0 )
;


['] RECOGNIZE-WORD  TC-TO( SPF4.FORTH-RECOGNIZER )

[THEN]
