\ auto-memoize
\
\ memoize - сохранение промежуточных результатов вычислений рекурсивной функции
\ авто-memoize - это конструкция превращающая каждую рекурсивную функцию в её
\                memoize'ованную версию
\ 
\ restrictions of this implementation:
\ recursive function must use run-time lookup and the name of the
\ memoized version overlaps the name of the original func

REQUIRE hash-table ~pinka/lib/hash-table.f

MODULE: auto-memoize

0 VALUE xt
0 VALUE h

: H@N ( key -- val -1 | 0 ) >R RP@ CELL h HASH@N RDROP ;
: H!N ( val key -- ) >R RP@ CELL h HASH!N RDROP ;

EXPORT 

: memoize: ( "name" -- )
   PARSE-NAME 2DUP SFIND 0= IF ABORT" Name must be defined already!" THEN 
   WARNING @ >R WARNING 0!
   -ROT CREATED , 
   R> WARNING !
   small-hash ,
   DOES> ( n a )
    DUP @ TO xt CELL+ @ TO h
    DUP H@N IF ." *" NIP EXIT THEN
    DUP xt EXECUTE TUCK SWAP H!N ;

;MODULE
 

 ~ygrek/lib/test.f

\ test{

 : FACT ." +" DUP 2 < IF DROP 1 EXIT THEN DUP 1- S" FACT" EVALUATE * ;
 : FIB  ." +" DUP 2 < IF DROP 1 EXIT THEN DUP 1- S" FIB" EVALUATE SWAP 2- S" FIB" EVALUATE + ;

 memoize: FACT

 : one CR OVER . "" STR{ EXECUTE >R }STR STR@ 2DUP TYPE SPACE COMPARE 0= ? R> DUP U. = ? ." ok" ;

 CR .( FACT:)
 39916800   S" +++++++++++" 11 ' FACT one 
 3628800    S" *"           10 ' FACT one
 2192834560 S" +++++++++*"  20 ' FACT one

 CR .( FIB:)
 8 S" +++++++++++++++" 5 ' FIB one
 memoize: FIB
 8 S" ++++++***" 5 ' FIB one
 8 S" *" 5 ' FIB one

\ }test

\ test
