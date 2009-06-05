.( Wait a bit while benchmarking...) CR

S" bubble.f" INCLUDED
S" queens.f" INCLUDED

REQUIRE ms@ lib/include/facil.f

: (bench) ( -- n )
   ms@
    MAIN
    test
   ms@ SWAP -
;


: bench ( -- n )
    0
    100 0
    DO (bench) + LOOP
;

bench . .(  ms) CR
