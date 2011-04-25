
REQUIRE ENUM-THREADS      ~pinka/lib/win/enum-threads.f
REQUIRE GET-THREADCONTEXT ~pinka/lib/win/threadcontext.f

: (IsTlsIndex) ( tls -- flag )
  \ heuristic
  DUP 0=   IF EXIT THEN
  DUP -1 = IF DROP FALSE EXIT THEN
  >R
  ['] EXC-HANDLER BEHAVIOR R@ + @
    ['] R0          BEHAVIOR R@ + @
    OVER U> IF DROP RDROP FALSE EXIT THEN
  CELL+ CELL+ @ R> =  \ see spf_win_except.f # SET-EXC-HANDLER
;
: (ENUM-USERAREAS) ( xt thread-id -- xt ) \ xt ( addr -- )
  DUP GetCurrentThreadId = IF DROP EXIT THEN
  SWAP >R GET-THREADCONTEXT 
  8 CELLS + 80 + 11 CELLS + ( addr-edi )
  @ ( may-be-tls )
  DUP (IsTlsIndex) IF R@ EXECUTE ELSE DROP THEN R>
;
: ENUM-USERAREAS ( xt -- ) \ xt ( addr -- )
  \ except calling thread (!)
  ['] (ENUM-USERAREAS) ENUM-THREADS
  ( xt ) DROP
;

\ Внутри виндовых функций EDI может быть каким угодно, 
\ поэтому в такой реализации не мал шанс упустить tls или получить AV в (IsTlsIndex)
