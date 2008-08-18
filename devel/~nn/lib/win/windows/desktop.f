REQUIRE nn-adapter ~nn/lib/adapter.f


: OPEN-DESKTOP ( a u -- h ior )
    DROP >R
    0x1FF ( DESKTOP_ALL_ACCESS) 0 DF_ALLOWOTHERACCOUNTHOOK R>
    OpenDesktopA DUP ERR ;

: CREATE-DESKTOP ( a u -- h ior )
    DROP >R
    0 0x1FF ( DESKTOP_ALL_ACCESS) DF_ALLOWOTHERACCOUNTHOOK 0 0 R>
    CreateDesktopA DUP ERR ;


USER hDesktop

: DESKTOP { a u -- }
    a u OPEN-DESKTOP DUP 2 =
    IF 2DROP a u CREATE-DESKTOP THEN
    0= IF hDesktop @ ?DUP IF CloseDesktop DROP THEN
          DUP hDesktop !
          SetThreadDesktop DROP
\          SwitchDesktop DROP
    ELSE DROP THEN
;

: TO-DESKTOP ( a u -- )
    OPEN-DESKTOP 0= IF DUP SwitchDesktop DROP CloseDesktop DROP ELSE DROP THEN
;

: ThreadDesktop ( -- a u )
    128 ALLOCATE THROW >R R@ 0!
    0 SP@ 128 R@ UOI_NAME GetCurrentThreadId GetThreadDesktop GetUserObjectInformationA
    2DROP
    R> ASCIIZ>
;

\ REQUIRE <EOF> ~nn/lib/eof.f
\ <EOF>
\EOF
: test
    1 2 3 4 5
    ThreadDesktop TYPE CR
    S" Desktop1" DESKTOP
    S" Desktop1" TO-DESKTOP
    ThreadDesktop TYPE CR
    0 S" xxxxxxxxxxx" DROP DUP 0 MessageBoxA DROP
    5000 PAUSE
    S" Default" TO-DESKTOP
    ThreadDesktop TYPE CR
;
test
BYE
