\ $Id$
\ find windows constant by number

~ygrek/lib/data/const.f
~profit/lib/bac4th-str.f
~ygrek/lib/typestr.f
~pinka/spf/string-equal.f
~ygrek/lib/wid.f

: STARTS-WITH? { a1 u1 a2 u2 -- ? }
  u1 u2 < IF FALSE EXIT THEN
  a1 u2 a2 u2 CEQUAL ;

: equal|| ( n2 n1 -- ) PRO = IF CONT THEN ;
: prefix|| ( a u a2 u2 -- ) PRO STARTS-WITH? IF CONT THEN ;

: iter=> PRO DUMP-CONST-FILE=> CONT DROP DROP DROP ;

: search
  iter=> 
   2 PICK 44 equal|| 
   2DUP S" WM_" prefix|| 
   2 PICK . 2DUP TYPE CR ;

S" lib/win/winconst/windows.const" +ModuleDirName search

BYE

\EOF

DUP STR@ :NONAME byRows split 2DUP TYPE CR ; EXECUTE
STRFREE
BYE

\EOF
MODULE: qqq
SWAP
DUP STR@ EVALUATE
STRFREE
;MODULE

[WID] qqq :NONAME DUP COUNT S" WM_" STARTS-WITH? IF COUNT TYPE CR ELSE DROP THEN ; FOR-WORDLIST
