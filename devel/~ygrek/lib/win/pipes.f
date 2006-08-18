
REQUIRE [UNDEFINED] lib/include/tools.f

[UNDEFINED] CreatePipe [IF]
WINAPI: CreatePipe KERNEL32.DLL
[THEN]

: CREATE-ANON-PIPE ( -- hRead hWrite ior )
   0 >R 0 >R
   0 \ buffer size hint - automatic
   0 \ security attrbutes - no
   RP@ CELL+ 
   RP@
   CreatePipe ERR
   R> R> ROT ;
