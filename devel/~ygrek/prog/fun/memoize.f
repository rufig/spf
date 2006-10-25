\ concept: auto-memoize
\ 
\ restrictions:
\ recursive function must use run-time lookup and the name of the
\ memoized version overlaps the name of the original func

REQUIRE hash-table ~pinka/lib/hash-table.f

MODULE: auto-memoize

0 VALUE xt
0 VALUE h
VARIABLE a

: H@N ( key ) a ! a CELL h HASH@N ;
: H!N ( val key ) a ! a CELL h HASH!N ;

EXPORT 

: memoize: ( "name" -- )
   PARSE-NAME 2DUP SFIND 0= IF ABORT" Name must be defined already!" THEN 
   -ROT CREATED , small-hash ,
   DOES> ( n a )
   DUP @ TO xt CELL+ @ TO h
    DUP H@N IF ." *" NIP EXIT THEN
    DUP xt EXECUTE TUCK SWAP H!N ;

;MODULE

~ygrek/lib/test.f

test{

: FACT ." +" DUP 2 < IF DROP 1 EXIT THEN DUP 1- S" FACT" EVALUATE * ;

memoize: FACT

: one CR DUP . "" STR{ FACT }STR SWAP >R STR@ 2DUP TYPE SPACE COMPARE 0= ? R> DUP U. = ? ." ok" ;

39916800   S" +++++++++++" 11 one 
3628800    S" *"           10 one
2192834560 S" +++++++++*"  20 one
}test
