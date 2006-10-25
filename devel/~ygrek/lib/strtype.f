REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f

\ Весь вывод между STR{ }STR будет добавляться к строке
\ т.е. так " ds" STR{ 3 . ." as" 3 SPACES ." hello" }STR
\ даёт " ds3 as   hello" 

MODULE: STR-TYPE

0 VALUE str.this
0 VALUE TYPE.old
0 VALUE heap.this

EXPORT

: STR{ ( s -- )
   TO str.this
   THREAD-HEAP @ TO heap.this
   ['] TYPE BEHAVIOR TO TYPE.old 
   LAMBDA{ 
     THREAD-HEAP @ >R
     heap.this THREAD-HEAP ! \ thanks to ruvim (in callback the THREAD-HEAP is changed)
     str.this STR+ 
     R> THREAD-HEAP ! } TO TYPE ;

: }STR ( -- s ) 
   TYPE.old TO TYPE 
   str.this ;

;MODULE

\EOF

REQUIRE GENRAND ~ygrek/lib/neilbawd/mersenne.f

0 SGENRAND

: a 
   "" STR{
    ." Hello" CR ." Count it - "
    1000 0 DO 10 GENRANDMAX 1 + SPACES 10 0 DO 32 GENRANDMAX 32 + EMIT LOOP LOOP 
   }STR STR@ ;

a TYPE CR

: z " ds" STR{ 3 . ." as" 3 SPACES ." hello" }STR ;
z STR@ TYPE

