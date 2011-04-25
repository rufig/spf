REQUIRE STHROW  ~pinka/spf/sthrow.f


WINAPI: GetCurrentThreadId          kernel32.dll ( -- id )

WINAPI: OpenThread                  kernel32.dll ( tid inherit access -- handle|0 )

WINAPI: GetThreadContext            kernel32.dll ( context h-thread -- bool )
\ MSDN: The function retrieves a selective context based on the value 
\ of the ContextFlags member of the context structure.
\ You cannot get a valid context for a running thread. 


0x10000 CONSTANT CONTEXT_i386
0x10000 CONSTANT CONTEXT_i486
CONTEXT_i386 0x00000001L OR CONSTANT CONTEXT_CONTROL
CONTEXT_i386 0x00000002L OR CONSTANT CONTEXT_INTEGER
CONTEXT_i386 0x00000004L OR CONSTANT CONTEXT_SEGMENTS
CONTEXT_i386 0x00000008L OR CONSTANT CONTEXT_FLOATING_POINT
CONTEXT_i386 0x00000010L OR CONSTANT CONTEXT_DEBUG_REGISTERS
CONTEXT_i386 0x00000020L OR CONSTANT CONTEXT_EXTENDED_REGISTERS
CONTEXT_CONTROL CONTEXT_INTEGER CONTEXT_SEGMENTS OR OR CONSTANT CONTEXT_FULL
512 CONSTANT MAXIMUM_SUPPORTED_EXTENSION  


0x0008 CONSTANT THREAD_GET_CONTEXT
0x0002 CONSTANT THREAD_SUSPEND_RESUME


: GET-THREADCONTEXT ( thread-id -- context_in_system-pad )
  \ can not be used for the current thread (!)
  DUP GetCurrentThreadId = IF S" THREADCONTEXT" STHROW THEN
  0 THREAD_SUSPEND_RESUME THREAD_GET_CONTEXT OR
  OpenThread DUP ERR THROW ( h-thread )
  DUP >R SUSPEND
    SYSTEM-PAD 16 ALIGN-TO 
    CONTEXT_FULL OVER ! \ set ContextFlags
    DUP R@ ( context  context h-thread )
    GetThreadContext ERR THROW ( context )
  R@ RESUME
  R> CloseHandle ERR THROW
;

: FOREACH-THREADCONTEXT ( xt thread-id -- ) \ xt ( context -- )
  \ can not be used for the current thread (!)
  DUP GetCurrentThreadId = IF DROP EXIT THEN
  0 THREAD_SUSPEND_RESUME THREAD_GET_CONTEXT OR
  OpenThread DUP ERR THROW ( xt h-thread )
  DUP >R SUSPEND
    SYSTEM-PAD 16 ALIGN-TO 
    CONTEXT_FULL OVER ! \ set ContextFlags
    DUP R@ ( xt context  context h-thread )
    GetThreadContext ERR THROW ( xt context )
    SWAP EXECUTE
  R@ RESUME
  R> CloseHandle ERR THROW
;

\ the CONTEXT structure see winnt.h

\EOF

REQUIRE ENUM-THREADS ~pinka/lib/win/enum-threads.f

: ttt ( thread-id -- )
  DUP .
  DUP GetCurrentThreadId = IF DROP ." current " ELSE 
    GET-THREADCONTEXT  8 CELLS + 80 + 11 CELLS + @ ( edi ) . 
  THEN CR 
;
  ' ttt ENUM-THREADS
