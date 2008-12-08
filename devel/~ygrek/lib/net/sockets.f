\ $Id$
\ Redirect

REQUIRE [DEFINED] lib/include/tools.f

[DEFINED] WINAPI: [IF]
S" ~ac/lib/win/winsock/SOCKETS.F" INCLUDED
[ELSE]
S" ~ygrek/lib/linux/sockets.f" INCLUDED
: SocketsStartup ( -- ior ) 0 ;
[THEN]
