\ 01.Nov.2003 Sat 18:05

REQUIRE ""   ~ac\lib\str2.f

: str`
  >IN @
    NextWord
    " USER-CREATE ${s}" STR@ EVALUATE
  >IN !
  USER-CREATE
  1 CELLS USER-ALLOT
  DOES> @ TlsIndex@ +   @ DUP IF STR@ ELSE 0 THEN
;


\EOF
\ for example:

str` MyStr1
.( 1 value= ) MyStr1 TYPE CR
" qqq" $MyStr1 !
.( 2 value= ) MyStr1 TYPE CR
