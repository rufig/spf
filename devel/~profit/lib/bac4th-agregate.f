REQUIRE >L ~profit/lib/lstack.f
REQUIRE START{ ~profit/lib/bac4th.f

: INTSTO ( n <-->x ) PRO 0 DO I CONT DROP LOOP ; \ генерирует числа от 0 до n-1

: f R> SWAP >L ['] L> >R >R ;

: r ( n -- x ) START{ f INTSTO BACK DUP L> + >L TRACKING }EMERGE ;