\ $Id$
\ Redirect

REQUIRE [DEFINED] lib/include/tools.f

[DEFINED] WINAPI: [IF]
S" ~pinka/lib/multi/critical.f" INCLUDED
[ELSE]
S" ~ygrek/lib/linux/pthread_mutex.f" INCLUDED
[THEN]

: WITH-CRIT-CATCH ( xt crit -- ior ) >R R@ ENTER-CRIT CATCH R> LEAVE-CRIT ;
: WITH-CRIT ( xt crit -- ) WITH-CRIT-CATCH THROW ;

