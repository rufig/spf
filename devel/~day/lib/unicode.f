REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDED  {  lib\ext\locals.f

WINAPI: MultiByteToWideChar   KERNEL32.DLL
WINAPI: WideCharToMultiByte   KERNEL32.DLL

: unicode> { addr u \ addr1 u1 }
\ u may be -1
     0 0 
     0 0
     u 0 > IF u 2/ ELSE -1 THEN addr
     0 0 
     WideCharToMultiByte u 0 > IF 1+ THEN DUP -> u1
     ALLOCATE THROW -> addr1
     0 addr1 u1 + 1- C!

     0 0 
     u1 addr1
     u 2/ addr
     0 0 
     WideCharToMultiByte u 0 < IF 1- THEN
     addr1 SWAP
;

: >unicode { addr u \ addr1 u1 }
\ u may be -1
     0 0
     u addr
     0 0
     MultiByteToWideChar
     u 0 > IF 1+ THEN DUP -> u1
     2* ALLOCATE THROW -> addr1
     0 addr1 u1 2* + 2 - W!
     u1 addr1
     u addr
     0 0
     MultiByteToWideChar u 0 < IF 1- THEN addr1 SWAP 2*
;

\EOF
: test S" Forth" >unicode unicode>
;

test
