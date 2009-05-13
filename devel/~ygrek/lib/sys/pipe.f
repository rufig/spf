\ $Id$
\ CREATE-ANON-PIPE ( -- hRead hWrite ior )

REQUIRE [UNDEFINED] lib/include/tools.f

[DEFINED] WINAPI: [IF]

S" ~ygrek/lib/win/pipes.f" INCLUDED

[ELSE]

: CREATE-ANON-PIPE ( -- hRead hWrite ior ) 0 0 (( SP@ )) pipe ?ERR NIP ;

[THEN]
