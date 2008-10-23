REQUIRE WalkProc95 ~nn/lib/proc95.f
REQUIRE PrivOn ~nn/lib/win/sec/priv.f
REQUIRE WinNT? ~nn/lib/winver.f
REQUIRE WC|RE-COMPARE ~nn/lib/wcre.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
( MARKER PROC
 ~nn/lib/wincon.f
 win32.f
 agents/wcmatch.f
 FALSE VALUE DEBUG?
 WINAPI: OpenProcess KERNEL32.DLL
)

WINAPI: EnumProcesses PSAPI.DLL
WINAPI: GetModuleBaseNameA PSAPI.DLL
WINAPI: EnumProcessModules PSAPI.DLL
WINAPI: GetModuleFileNameExA PSAPI.DLL

DECIMAL
512 CONSTANT PAD-SIZE

USER hModule
USER hProcess
USER-VALUE MOD-NAME-BUF
USER xtWalkProc
USER enumProcBuf
1024 CELLS CONSTANT enumProcBufSize

0 [IF]
: (PROC-NAME) { pid buf full? \ hModule hProcess -- a u }
    pid FALSE PROCESS_QUERY_INFORMATION PROCESS_VM_READ + OpenProcess
    ?DUP
    IF
         TO hProcess
         0 SP@ 1 CELLS AT hModule hProcess EnumProcessModules NIP
         IF
             MAX_PATH buf hModule @ hProcess @
             full? IF GetModuleFileNameExA ELSE GetModuleBaseNameA  THEN
             ?DUP IF buf SWAP THEN
             hModule @ CloseHandle DROP
         ELSE
           S" "
         THEN
         hProcess @ CloseHandle DROP
    ELSE S" " THEN ;

: (PROC-NAME2) ( pid full? -- a u)  MAX_PATH ALLOCATE THROW SWAP (PROC-NAME) ;

: PROC-FULLNAME WinNT?  IF PROC-NAME-NT ELSE PROC-NAME-9x THEN ;
: PROC-NAME     WinNT?  IF PROC-NAME-NT ELSE PROC-NAME-9x THEN ;

[THEN]

: WalkProcNT ( xt -- )
    xtWalkProc !
    enumProcBufSize ALLOCATE THROW enumProcBuf !
    0 SP@ enumProcBufSize enumProcBuf @ EnumProcesses DUP 0= SWAP enumProcBuf @ = OR
    IF
\        [ DEBUG? ] [IF] ." Can't enum processes. "
\                       GetLastError ." Error # " . CR
\                   [THEN]
        enumProcBuf @ FREE DROP
        DROP GetLastError THROW
    THEN
    256 ALLOCATE THROW TO MOD-NAME-BUF
    enumProcBuf @ SWAP OVER + SWAP
    ?DO
        I @
        FALSE PROCESS_QUERY_INFORMATION PROCESS_VM_READ + OpenProcess
        ?DUP
        IF
            hProcess !
            0 SP@ 1 CELLS hModule hProcess @ EnumProcessModules NIP
            IF

                255 MOD-NAME-BUF hModule @ hProcess @ ( GetModuleBaseNameA ?DUP)
                PROC-FULLPATH? @ IF GetModuleFileNameExA ELSE GetModuleBaseNameA  THEN
\                255 MOD-NAME-BUF hModule @ hProcess @ GetModuleFileNameExA ?DUP
                ?DUP
                IF
\                     [ DEBUG? ] [IF] ." Proc name: " MOD-NAME-BUF OVER TYPE CR [THEN]
                     ( addr len len --)
                     MOD-NAME-BUF SWAP I @ xtWalkProc @ EXECUTE 0=
                     IF UNLOOP
                        hProcess @ CloseHandle DROP
                        hModule @ CloseHandle DROP
                        MOD-NAME-BUF FREE DROP
                        enumProcBuf @ FREE DROP
                        EXIT
                     THEN
\                ELSE
\                    [ DEBUG? ] [IF] ." Can't get name of module " I @ .
\                                    GetLastError ."  Error # " . CR
\                               [THEN]
                THEN
                hModule @ CloseHandle DROP
            ELSE
\              [ DEBUG? ] [IF] ." Can't enum modules for process " I @ .
\                              GetLastError ."  Error # " . CR
\                         [THEN]
            THEN
            hProcess @ CloseHandle DROP
        ELSE
\            [ DEBUG? ] [IF] ." Can't open process " I @ .
\                            GetLastError ." Error # " . CR
\                       [THEN]
        THEN
    1 CELLS +LOOP
    MOD-NAME-BUF FREE DROP
    enumProcBuf @ FREE DROP
;

: GetDebugPriv S" SeDebugPrivilege" PrivOn DROP ;

: WalcProcXT
    WinNT?
    IF
        GetDebugPriv
        ['] WalkProcNT
\        Win2k? IF ['] WalkProc95 ELSE ['] WalkProcNT THEN
    ELSE
        ['] WalkProc95
    THEN ;

: ?SET-PROC-FULLPATH S" \" SEARCH NIP NIP IF PROC-FULLPATH THEN ;

: PROC-EXIST? ( addr u -- proc-id/0)
    2DUP S>NUM <ProcID> !
    2DUP ?SET-PROC-FULLPATH
    WalcProcXT ['] (PROC-EXIST?) CATCH IF 2DROP DROP 0 THEN
    PROC-FULLPATH? OFF
;

: GetProcName { a u id \ continue -- ? } \ false - terminate loop
    TRUE TO continue
    <ProcID> @ id =
    IF FALSE TO continue THEN
    continue
;

: (PROC-NAME) ( id -- a u)
    ProcFound OFF
    <ProcID> !
    [NONAME
        <ProcID> @ =
        IF EVAL-SUBST ProcPattern 2! ProcFound ON FALSE ELSE 2DROP TRUE THEN
    NONAME] WalcProcXT EXECUTE
    ProcFound @ IF ProcPattern 2@ ELSE S" " THEN
;


: PROC-FULLNAME ( pid -- a u)
    PROC-FULLPATH? ON
    (PROC-NAME)
    PROC-FULLPATH? OFF
;

: PROC-NAME ( pid -- a u)
    PROC-FULLPATH? OFF
    (PROC-NAME)
;

: ACTIVE-PROC-PID 0 SP@ GetForegroundWindow GetWindowThreadProcessId DROP ;
: ACTIVE-PROC-NAME ACTIVE-PROC-PID PROC-NAME ;

\ S" ICQ" PROC-EXIST? .
\ S" NNCRON"  PROC-EXIST? .

: kill ( id -- )
   ?DUP
   IF
     0 PROCESS_TERMINATE OpenProcess ?DUP
     IF 0 OVER TerminateProcess DROP
        CloseHandle DROP
     THEN
   THEN ;

\ : KILL ( a u -- ) PROC-EXIST? kill ;

: KILL ( a u -- ) PROC-EXIST? kill ;


: NICE ( priority )
;