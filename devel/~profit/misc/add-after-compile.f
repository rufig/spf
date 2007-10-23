REQUIRE RTRACE ~ygrek/lib/debug/rtrace.f
REQUIRE COPY-CODE ~profit/misc/movecode2.f
REQUIRE REPLACE-WORD lib/ext/patch.f

MODULE: add-after-compile

: CALL, ( ADDR -- ) \ скомпилировать инструкцию ADDR CALL
  ?SET SetOP 0xE8 C,
  DUP IF DP @ CELL+ - THEN ,    DP @ TO LAST-HERE
;

EXPORT

: add: ( "word" -- )
:NONAME
0 CALL, >MARK
>IN @
' COPY-CODE RET,
>IN !
1 >RESOLVE
' REPLACE-WORD
;

;MODULE

/TEST
add: OK1 ." Hello!" ;