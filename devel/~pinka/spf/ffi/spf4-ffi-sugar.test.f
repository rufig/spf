REQUIRE Require ~pinka/lib/ext/requ.f

Require CREATE-DL-SET spf4-ffi-sugar.f

`SO  ' EXEC-DLPOINT-C1 CREATE-DL-SET
`DLL ' EXEC-DLPOINT-P1 CREATE-DL-SET

: MAYBE ( i*x c-addr u -- j*x )
  SFIND IF EXECUTE EXIT THEN 2DROP
;


ALSO DLL user32.dll
ORDER WORDS

: test 0 S" test" DROP S" test passed" DROP 0  4 MessageBoxA . CR ;

WORDS

DLL kernel32.dll
CR `GetTickCount= TYPE 0 GetTickCount . CR CR
DLL ORDER WORDS PREVIOUS


ALSO SO 
  `libxml2.dll MAYBE
  `libxml2.so  MAYBE

: normalizeURI ( addr-z u1 -- addr u2 )
  OVER
  1 xmlNormalizeURIPath THROW \ work for pathnames only 
  DROP ASCIIZ>
;

SO ORDER WORDS PREVIOUS

`aaa/bbb/ccc/../../../ddd/eee/fff/../../ooo 2DUP TYPE CR normalizeURI TYPE CR
