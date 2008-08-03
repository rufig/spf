\ $Id$
\ Correct implementation of (( )) with respect to nested calls

REQUIRE lexicon.basics-aligned ~pinka/lib/ext/basics.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: module-((-fix

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

\ : FFICLEAR ( -- ) Z0 @ IF Z0 @ ZP! EXIT THEN open ;

: ?FFIP ( -- )
  Z0 @ 0= IF open EXIT THEN
  ZP@ Z0 @ U> ABORT" FFI stack undeflow"
  ZP@ Z9 @ U< ABORT" FFI stack overflow"
;

..: AT-THREAD-STARTING ?FFIP ;.. ?FFIP

: ())) ( -- n ) SP@ Z> SWAP - >CELLS ;
: restore__ret2 Z> (__ret2) ! ;
: remember ( sp -- ) (__ret2) @ >Z ( SP ) >Z (__ret2) 0! ;

EXPORT

WARNING @
WARNING 0!

: (( ( -- ) SP@ remember ;
: <( ( n -- ) 1+ 2* 2* SP@ + remember ;

: )) ( ->bl; -- )
  PARSE-NAME symbol-lookup
  STATE @ IF
    ['] ())) COMPILE,
    compile-call
    ['] restore__ret2 COMPILE,
  ELSE
    ())) 1- SWAP symbol-call
    restore__ret2
  THEN
; IMMEDIATE

WARNING !

;MODULE

/TEST

H-STDOUT VALUE H

: cr (( H EOLN )) write DROP ;

: text1 S"   some text  " ;
: text2 S" (nested call)" ;

: ok? text1 NIP <> ABORT" failed" ; 

(( H text1 (( H text2 )) write ok? )) write ok? cr
: nest (( H text2 )) write ok? ;
(( H text1 nest )) write ok? cr
:NONAME (( H text1 nest )) write ok? cr ; EXECUTE
H 1 <( text1 (( H text2 )) write ok? )) write ok? cr

\ EOF

S" /dev/null" W/O OPEN-FILE THROW TO H

:NONAME ( x -- )
  . 
  100 0 DO (( H text1 nest )) write ok? cr LOOP
; TASK: qqq

:NONAME cr 100 0 DO I qqq START DROP LOOP ; EXECUTE

H CLOSE-FILE THROW 
H-STDOUT TO H

