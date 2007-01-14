\ auto-memoize
\
\ memoize - сохранение промежуточных результатов вычислений функции
\ авто-memoize - это конструкция превращающая любую функцию (CELL -> CELL) в её
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
    DUP H@N IF NIP EXIT THEN
    DUP xt EXECUTE TUCK SWAP H!N ;

;MODULE
 
\EOF

: FACT ." +" DUP 2 < IF DROP 1 EXIT THEN DUP 1- S" FACT" EVALUATE * ;

memoize: FACT

 CR 11 DUP . FACT DROP
 CR 10 DUP . FACT DROP
 CR 15 DUP . FACT DROP
