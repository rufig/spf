( wrapper of ~ac\lib\str5.f )
( string local variables )

REQUIRE STR+ ~ac\lib\str5.f
REQUIRE HYPE ~day\hype3\hype3.f

CLASS CString
    VAR str

init: "" str ! ;
dispose: str @ ?DUP IF STRFREE THEN ;

: ! ( str -- )
    str @ STRFREE
    str !
;

: S! ( addr u -- )
    str @ STR!
;

: @ str @ ;

;CLASS

CString SUBCLASS S:

: get 
    SUPER str @
;

;CLASS

\EOF

: test
  || S: str ||
  " test" str S+
;