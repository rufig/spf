\ Libraries for spf4e

\ Include all avaialble standard words (except the BLOCK word set)
\ Include some other useful words
\ Turn on the case-insensitivity (in ASCII charset) dictionary search

\ In `included` (and other words that use `included`),
\ if the file name starts with "./", resolve it against the current source-path


S" lib/include/ansi.f" INCLUDED

MODULE: disasm-voc
  REQUIRE-WORD SEE            lib/ext/disasm.f
EXPORT
  SYNONYM VOCS VOCS
ALSO DISASSEMBLER
  : SEE-CODE-WITHIN ( addr1 addr2 -- )  REST-AREA ;
  : DUMP-CODE ( addr u -- ) OVER + SEE-CODE-WITHIN ;
  : SEE-XT ( xt -- )  DUP FIND-REST-END ( xt addr|0 )  ['] SEE-CODE-WITHIN CATCH IF 2DROP THEN ;
  : SEE-NAME ( name -- )  NAME> SEE-XT ;
  : SEE ( "name" -- )  TAKE-NAME SEE-NAME ;
PREVIOUS
;MODULE


REQUIRE-WORD FCONSTANT      lib/include/float2.f
REQUIRE-WORD [:             lib/include/quotations.f


REQUIRE-WORD CASE-INS       lib/ext/caseins.f



\ Correct processing of -1 throw code
:noname ( 0|ior -- )
  dup -1 = if drop ." (aborted)" cr exit then
  [ action-of error compile, ]
; is error



[undefined] equals [if]
: equals ( sd1 sd2 -- flag )
  dup 3 pick <> if 2drop 2drop false exit then
  compare 0=
;
[then]

[undefined] match-head [if]
: match-head ( sd1 sd.head -- sd.tail true | sd1 false )
  2 pick over u< if 2drop false exit then
  dup >r
  3 pick r@ equals 0= if rdrop false exit then
  swap r@ + swap r> - true
;
[then]

[undefined] filename-existing [if]
\ or, maybe `is-filename-existing`
synonym filename-existing file-exist
[then]


\ If a file name starts with "./", resolve it against the current source-basepath
:noname ( sd.filename1 -- sd.filename2.transient )
  s" ./" match-head 0= if [ action-of find-fullname compile, ] exit then
  source-basepath dup 0= if 2drop -2 /string \ revert "./"
  else \ resolve sd.filename1 against the source-basepath
    ( sd1 sd.basepath )
    path-prefix (prepend-errmsg) 2dup + 0 swap c!
  then
  2dup filename-existing if exit then -38 throw \ "non-existent file"
; is find-fullname \ spf4-specific

