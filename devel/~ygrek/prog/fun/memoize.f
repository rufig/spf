\ пример к ~ygrek/lib/fun/memoize.f

REQUIRE memoize: ~ygrek/lib/fun/memoize.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE STR{ ~ygrek/lib/strtype.f

 : FACT ." +" DUP 2 < IF DROP 1 EXIT THEN DUP 1- S" FACT" EVALUATE * ;
 : FIB  ." +" DUP 2 < IF DROP 1 EXIT THEN DUP 1- S" FIB" EVALUATE SWAP 2- S" FIB" EVALUATE + ;

 memoize: FACT

 : ? 0= ABORT" haha" ;
 : one CR OVER . "" STR{ EXECUTE >R }STR STR@ 2DUP TYPE SPACE COMPARE 0= ? R> DUP U. = ? ." ok" ;

 CR .( FACT:)
 39916800   S" +++++++++++" 11 ' FACT one 
 3628800    S" "            10 ' FACT one
 2192834560 S" +++++++++"   20 ' FACT one

 CR .( FIB:)
 8 S" +++++++++++++++" 5 ' FIB one

 memoize: FIB

 8 S" ++++++" 5 ' FIB one
 8 S" " 5 ' FIB one
