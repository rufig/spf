REQUIRE CONT ~profit/lib/bac4th.f 
\ REQUIRE MemReport ~day/lib/memreport.f


: FREEB ( addr --> addr \ <-- addr ) R> EXECUTE FREE THROW ;
: FREEB2 ( addr --> addr \ <-- ) R> OVER >R EXECUTE R> FREE THROW ;

: BALLOCATE ( n --> addr \ <-- addr ) PRO ALLOCATE THROW FREEB CONT ;
: BALLOCATE ( n --> addr \ <-- addr ) PRO ALLOCATE THROW FREEB2 CONT ;


\EOF

: r
100 ALLOCATE THROW FREEB2 .
100 BALLOCATE .
; r
MemReport