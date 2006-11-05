REQUIRE { ~ac/lib/locals.f
REQUIRE ZPLACE ~nn/lib/az.f

WINAPI: SetEnvironmentVariableA KERNEL32.DLL
\ WINAPI: GetEnvironmentVariableA KERNEL32.DLL

: GETENV { a1 u1 \ buf len -- a2 u2 ior }
    0 a1 u1 + C!
    256 TO len
    len ALLOCATE THROW TO buf
    len buf a1 GetEnvironmentVariableA ?DUP
    IF
        DUP len >
        IF 
            buf FREE THROW
            DUP ALLOCATE THROW TO buf
            buf a1 GetEnvironmentVariableA
        THEN
        buf SWAP 0
    ELSE
        S" " GetLastError DUP 203 = 
        IF DROP 0 THEN
        buf FREE THROW 
    THEN
;

: ENV ( a u -- a1 u1)
    GETENV THROW 2DUP 512 MIN DUP >R PAD ZPLACE
    IF FREE DROP ELSE DROP THEN
    PAD R>
;


: SETENV ( aval u1 aname u2 -- ior )
    DROP NIP SetEnvironmentVariableA ERR ;

: PATH@  S" PATH" GETENV THROW ;
: PATH!  S" PATH" SETENV THROW ;
: PATH+ { a u \ buf p1 -- }
    PATH@ OVER TO p1
    DUP CELL+ u + ALLOCATE THROW TO buf
    buf ZPLACE
    S" ;" buf +ZPLACE
    a u buf +ZPLACE
    buf ASCIIZ> PATH!
    p1 FREE THROW
    buf FREE THROW
;

REQUIRE <EOF> ~nn/lib/eof.f
<EOF>
: t1
    PATH@ 2DUP TYPE CR
    S" c:\hello" PATH+
    PATH@ TYPE CR
    PATH! 
    PATH@ TYPE CR
;
t1
