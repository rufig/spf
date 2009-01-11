MODULE: check-control-flow
: for-words: ( xt "words" -- )
  >R BEGIN NextWord DUP WHILE R@ EXECUTE REPEAT 2DROP RDROP
;

USER cnt

: ?cnt-under ( -- )
  cnt @ 0< 0= IF EXIT THEN
  cnt 0! -22 THROW
; \ -22 control structure mismatch -- http://www.taygeta.com/forth/dpans9.htm#9.3.5
: ?cnt0 ( -- )
  cnt @ 0= IF EXIT THEN
  cnt 0! -22 THROW
;
: (make-wrapper) ( a u -- ) 2DUP SFIND 0= THROW -ROT CREATED , IMMEDIATE ;
: make-wrapper-a1 ( a u -- ) (make-wrapper) DOES> @ EXECUTE  1 cnt +! ;
: make-wrapper-s1 ( a u -- ) (make-wrapper) DOES> @ EXECUTE -1 cnt +! ?cnt-under ;
: make-wrapper-s2 ( a u -- ) (make-wrapper) DOES> @ EXECUTE -2 cnt +! ?cnt-under ;

EXPORT
WARNING @ WARNING 0!
' make-wrapper-a1 for-words: IF BEGIN WHILE
' make-wrapper-s1 for-words: THEN UNTIL AGAIN
' make-wrapper-s2 for-words: REPEAT
: ; POSTPONE ; ?cnt0 ; IMMEDIATE
WARNING !
;MODULE
