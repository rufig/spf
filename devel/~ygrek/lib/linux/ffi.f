\ $Id$
\ Correct implementation of (( )) with respect to nested calls

REQUIRE lexicon.basics-aligned ~pinka/lib/ext/basics.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: module-((-stack-fix

MODULE: module-ffi-stack

256 CELLS CONSTANT /Z

USER ZP
USER Z0
USER Z9

: close ( -- )
  Z0 @ 0= IF EXIT THEN
  Z0 @ FREE THROW
  Z0 0! ZP 0!
;
: open ( -- )
  close
  /Z ALLOCATE THROW DUP Z9 !
  /Z + DUP Z0 ! ZP !
;

S" ~pinka/samples/2004/test/zstack/zstack.immutable.f" INCLUDED

EXPORT

: FFICLEAR ( -- ) Z0 @ IF Z0 @ ZP! EXIT THEN open ;

: ?FFIP ( -- )
  Z0 @ 0= IF open EXIT THEN
  ZP@ Z0 @ U> ABORT" FFI stack undeflow"
  ZP@ Z9 @ U< ABORT" FFI stack overflow"
;

..: AT-THREAD-STARTING ?FFIP ;.. ?FFIP

: FFI@ Z@ ;
: >FFI >Z ;
: FFI> Z> ;

;MODULE

EXPORT

WARNING @
WARNING 0!

: (( ( -- ) (__ret2) @ >FFI SP@ >FFI (__ret2) 0! ;
: <( ( n -- ) (__ret2) @ >FFI 1+ 2* 2* SP@ + >FFI (__ret2) 0! ;

: ()))2 ( -- n ) SP@ FFI> SWAP - 4 U/ ;

: restore__ret2 FFI> (__ret2) ! ;

: )) ( ->bl; -- )
  BL PARSE symbol-lookup
  STATE @ IF
    ['] ()))2 COMPILE,
    compile-call
  ELSE
    ()))2 1- SWAP symbol-call
  THEN
  [COMPILE] restore__ret2
; IMMEDIATE

WARNING !

;MODULE

/TEST

(( H-STDOUT S" some text" (( H-STDOUT S" [[nested call!]]" )) write DROP )) write DROP CR
H-STDOUT 1 <( S" some text" H-STDOUT 1 <( S" [[nested call!]]" )) write DROP )) write DROP CR

