REQUIRE S>ZALLOC ~nn/lib/az.f
REQUIRE PATH@ ~nn/lib/env.f
REQUIRE GET ~nn/lib/mutex.f
CR .( this) CR
REQUIRE AllAllowedSD ~nn/lib/win/sec/sd.f
REQUIRE WinNT? ~nn/lib/winver.f
\ REQUIRE winsta-name ~nn/lib/win/windows/winsta.f
\ REQUIRE ONLYDIR ~nn/lib/filename.f
REQUIRE ThreadDesktop ~nn/lib/win/windows/desktop.f

REQUIRE GLOBAL ~nn/lib/globalloc.f

WINAPI: CreateProcessA KERNEL32.DLL
WINAPI: CreateProcessAsUserA ADVAPI32.DLL
WINAPI: GetExitCodeProcess kernel32.dll
\ WINAPI: WaitForSingleObject KERNEL32.DLL



0
4 -- cbSILength
4 -- lpReserved
4 -- lpDesktop
4 -- lpTitle
4 -- dwX
4 -- dwY
4 -- dwXSize
4 -- dwYSize
4 -- dwXCountChars
4 -- dwYCountChars
4 -- dwFillAttribute
4 -- dwFlags
2 -- wShowWindow
2 -- cbReserved2
4 -- lpReserved2
4 -- hStdInput
4 -- hStdOutput
4 -- hStdError
CONSTANT /STARTUPINFO

0
4 -- .hProcess
4 -- .hThread
4 -- .dwProcessId
4 -- .dwThreadId
CONSTANT /PROCINFO

\ HEX 00000100 CONSTANT STARTF_USESTDHANDLES DECIMAL
\ 0 CONSTANT SW_HIDE
\ 1 CONSTANT STARTF_USESHOWWINDOW
\ 7 CONSTANT SW_SHOWMINNOACTIVE

USER APP-WAIT?
USER APP-SU?
USER APP-Dir
USER APP-ENV-BLOCK
USER APP-Flags
USER APP-Wait
USER APP-Title
USER APP-Desktop
USER-CREATE APP-pi 4 CELLS USER-ALLOT
USER-VALUE  APP-si
USER-VALUE ExitCodeProc
\ USER APP-err

: PROC-ID APP-pi .dwProcessId @ ;

VARIABLE APP-Sem

\ VARIABLE <Desktop>
\ : Desktop <Desktop> @ 0= IF GLOBAL S" WinSta0\Default" S>ZALLOC LOCAL <Desktop> ! THEN <Desktop> @ ;

: (StartApp00) ( 'startup-info S" app" -- ? )
  -1 TO ExitCodeProc
  APP-pi 4 CELLS ERASE
  OVER + 0 SWAP C!  OVER >R ( si, чтобы на выходе проверить 0=)

\ PATH@, PATH+
  APP-Dir @ IF PATH@ DROP ELSE 0 THEN >R
  APP-Dir @ ?DUP IF ASCIIZ> PATH+  ( az path --) THEN
\  DUP ASCIIZ> S>ZALLOC DUP ASCIIZ> ONLYDIR ?DUP IF PATH+ ELSE DROP THEN FREE DROP

  >R
  ?DUP 0= IF /STARTUPINFO ALLOCATE THROW
            DUP /STARTUPINFO ERASE
            THEN
  TO APP-si
\  APP-si /STARTUPINFO ERASE
  /STARTUPINFO APP-si cbSILength !

\  APP-si lpDesktop @ 0= APP-SU? @ 0<> AND IF S" " DROP APP-si lpDesktop ! THEN
\  STARTF_USESHOWWINDOW APP-si dwFlags !
\  SW_SHOWNORMAL APP-si wShowWindow !

\  Desktop APP-si lpDesktop !
   APP-Desktop @ APP-si lpDesktop !
\   WinNT? IF ThreadDesktop DROP APP-si lpDesktop ! THEN

  APP-Title @   APP-si lpTitle !  APP-Title 0!
  APP-pi
  APP-si
  APP-Dir @
  APP-ENV-BLOCK @ DUP IF APP-Flags @ CREATE_UNICODE_ENVIRONMENT OR APP-Flags ! THEN
  APP-Flags @ ( ." Flags: " DUP . CR) \ APP-Flags 0! \ creation flags
  FALSE \ inherit handles
  0 0       \ process & thread security
\  WinNT? IF AllAllowedSA DUP
\         ELSE  0 0  THEN
  R>   \ command line
  0    \ application
  APP-SU? @ ?DUP
\  APP-err 0!
  IF
[ DEBUG? ] [IF] ." CreateProcessAsUserA[" DUP 1  ." ] ... " [THEN]
    CreateProcessAsUserA
[ DEBUG? ] [IF] DUP . GetLastError . CR [THEN]
  ELSE CreateProcessA THEN
\  DUP ERR APP-err !
\ PATH!
  R> ?DUP IF DUP ASCIIZ> PATH! FREE DROP THEN

  APP-si lpDesktop @ ?DUP IF FREE DROP THEN

  R> 0= IF APP-si FREE DROP THEN
\  APP-Dir @ ?DUP IF FREE DROP THEN APP-Dir 0!
;

: (epilog) ( ? -- )
\ [ DEBUG? ] [IF] 1000 PAUSE ." New thread ("  APP-pi .dwThreadId @ DUP . ." ) desk: " desk-name TYPE CR [THEN]
  APP-WAIT? @
  IF
    IF APP-Wait @ ?DUP 0= IF -1 THEN APP-Wait 0!
       APP-pi .hProcess @ WaitForSingleObject
       WAIT_TIMEOUT =
       IF
           -1 APP-pi .hProcess @ TerminateProcess DROP
           -1
       ELSE
            0 SP@ APP-pi .hProcess @ GetExitCodeProcess DROP
       THEN
       TO ExitCodeProc
    THEN
  ELSE
    DROP
  THEN
  APP-pi .hProcess @ ?DUP IF CLOSE-FILE DROP THEN
  APP-pi .hThread  @ ?DUP IF CLOSE-FILE DROP THEN
\  APP-err @ SetLastError
;

: (StartApp0)
    1000 APP-Sem TGET >R
    ['] (StartApp00) CATCH
    R> IF APP-Sem RELEASE THEN
    THROW ;

: (StartApp) ( 'startup-info S" app" -- ? )
    (StartApp0) DUP (epilog)
;

: StartApp ( 'startup-info S" application.exe" -- flag )
    APP-SU? 0!
    APP-WAIT? 0!
    (StartApp) ;

: StartAppNC ( 'si S" app" -- ?) \ no close handles
    APP-SU? 0!
    APP-WAIT? 0!
    (StartApp0) ;


: StartAppWait ( 'startup-info S" application.exe" -- flag )
    APP-SU? 0!
    TRUE APP-WAIT? !
    (StartApp) ;

: StartAppAsUser ( 'startup-info S" application.exe" user-token -- flag )
    APP-SU? !
    APP-WAIT? 0!
    (StartApp) ;

: StartAppAsUserNC ( 'startup-info S" application.exe" user-token -- flag )
    APP-SU? !
    APP-WAIT? 0!
    (StartApp0) ;

: StartAppAsUserWait ( 'startup-info S" application.exe" user-token -- flag )
    APP-SU? !
    TRUE APP-WAIT? !
    (StartApp) ;

: START-IN ( s u -- )
    APP-Dir @ ?DUP IF FREE DROP THEN
    S>ZALLOC APP-Dir !
;
