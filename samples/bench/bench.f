.( Wait a bit while benchmarking...) CR

S" bubble.f" INCLUDED
S" queens.f" INCLUDED

WINAPI: GetTickCount KERNEL32.DLL

: (bench) ( -- n )
   GetTickCount
    MAIN
    test
   GetTickCount SWAP -
;


: bench ( -- n )
    0
    100 0
    DO (bench) + LOOP
;

bench . .(  ms) CR