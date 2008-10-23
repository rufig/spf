\ S" WIN32.F" INCLUDED
\ S" ~NEMNICK\LIB\WINCON.F" INCLUDED
REQUIRE nn-adapter ~nn/lib/adapter.f
REQUIRE GLOBAL ~nn/lib/globalloc.f
REQUIRE DEBUG? ~nn/lib/qdebug.f
WINAPI: OpenProcessToken ADVAPI32.DLL
\ WINAPI: OpenProcess      KERNEL32.DLL
WINAPI: AdjustTokenPrivileges ADVAPI32.DLL
WINAPI: LookupPrivilegeValueA ADVAPI32.DLL
WINAPI: GetCurrentProcess KERNEL32.DLL
WINAPI: GetCurrentThread KERNEL32.DLL
WINAPI: OpenThreadToken ADVAPI32.DLL
WINAPI: DuplicateToken ADVAPI32.DLL
WINAPI: SetThreadToken ADVAPI32.DLL
\ WINAPI: OpenProcess KERNEL32.DLL
0
1 CELLS -- TP.Count
2 CELLS -- TP.LUid
1 CELLS -- TP.Attributes
CONSTANT /TOKEN_PRIVILEGES

\ USER-CREATE TokenPriv /TOKEN_PRIVILEGES USER-ALLOT
USER-VALUE TokenPriv
USER hToken

\ CREATE TokenPriv /TOKEN_PRIVILEGES ALLOT
\ VARIABLE hToken

: open-tt ( -- h ior)
    0 SP@ TRUE
    TOKEN_ADJUST_PRIVILEGES TOKEN_QUERY OR
    GetCurrentThread
    OpenThreadToken ERR
;

: THREAD-TOKEN { \ p_token1 p_token2 -- token ior }
    open-tt
    DUP
    IF DUP 1008 =
       IF
         2DROP
         AT p_token1
         TOKEN_DUPLICATE
         GetCurrentProcess
         OpenProcessToken ERR ?DUP IF 0 SWAP EXIT THEN

         AT p_token2
         2
         p_token1
         DuplicateToken ERR
         p_token1 CLOSE-FILE DROP
         ?DUP IF 0 SWAP EXIT THEN

         p_token2 0 SetThreadToken ERR
         p_token2 CLOSE-FILE DROP
         ?DUP IF 0 SWAP EXIT THEN

         open-tt
       THEN
    THEN
;

: (PrivOn) ( S" SeShutdownPrivilege" -- )
\    [ DEBUG? ] [IF] ." PrivON: " 2DUP TYPE CR [THEN]
\    [ DEBUG? ] [IF] ." Privilege: " 2DUP TYPE CR [THEN]
    DROP TokenPriv TP.LUid SWAP 0 LookupPrivilegeValueA 0=
    IF
        [ DEBUG? ] [IF] ." Privilege not exist" CR [THEN]
        GetLastError THROW
    THEN

    THREAD-TOKEN ?DUP
    IF
        [ DEBUG? ] [IF] ." Can't open thread token: " DUP . CR [THEN]
        THROW
    THEN
    hToken !
(
    hToken
    TOKEN_ADJUST_PRIVILEGES TOKEN_QUERY OR
    GetCurrentProcess
    OpenProcessToken
)
    1 TokenPriv TP.Count !
    SE_PRIVILEGE_ENABLED TokenPriv TP.Attributes !
    0 0 0 TokenPriv 0 hToken @ AdjustTokenPrivileges  DROP
    hToken @ CloseHandle DROP
    GetLastError ?DUP
    IF [ DEBUG? ] [IF] ." Can't adjust token privelege. Error # " DUP . CR [THEN]
       THROW
    THEN
;

: PrivOn ( S" priv" -- ? )
    /TOKEN_PRIVILEGES GLOBAL ALLOCATE LOCAL THROW TO TokenPriv
    ['] (PrivOn) CATCH IF 2DROP FALSE ELSE TRUE THEN
    TokenPriv GLOBAL FREE LOCAL THROW
;