REQUIRE nn-adapter ~nn/lib/adapter.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
WINAPI: GetVersionExA KERNEL32.DLL

\ 1 CONSTANT VER_PLATFORM_WIN32_WINDOWS
\ 2 CONSTANT VER_PLATFORM_WIN32_NT

DECIMAL
CREATE (WIN-VER) 148 ALLOT  (WIN-VER) 148 ERASE
: (GET-VER) (WIN-VER) @ 0= IF 148 (WIN-VER) !  (WIN-VER) GetVersionExA ERR THROW THEN ;
: GET-VER ( -- minor major platform)
    (GET-VER)
    (WIN-VER) 2 CELLS + @
    (WIN-VER) 1 CELLS + @
    (WIN-VER) 4 CELLS + @
;

: WinVerMajor (GET-VER) (WIN-VER) 1 CELLS + @ ;
: WinVerMinor (GET-VER) (WIN-VER) 2 CELLS + @ ;
: WinVerPlatform (GET-VER) (WIN-VER) 4 CELLS + @ ;
: WinVerServicePack (GET-VER) (WIN-VER) 5 CELLS + ASCIIZ> ;

: WinNT? ( -- flag ) WinVerPlatform VER_PLATFORM_WIN32_NT = ;

: WinVerBuild (GET-VER) (WIN-VER) 3 CELLS + @ WinNT? 0= IF 0xFFFF AND THEN ;

: Win2k? ( -- ?) WinNT? WinVerMajor 4 > AND ;

: WinXP? ( -- ?) Win2k? WinVerMinor 0 > AND ;

: WIN-VER ( -- num ) GET-VER DROP NIP ;

: Win9x? WinVerPlatform VER_PLATFORM_WIN32_WINDOWS = ;
: Win95? Win9x? WinVerMinor 0= AND ;
: Win98? Win9x? WinVerMinor 10 = AND ;
: WinME? Win9x? WinVerMinor 90 = AND ;

WARNING @ WARNING 0!
: SAVE (WIN-VER) 148 ERASE SAVE ;
WARNING !


: WinVerSuffix
    WinNT?
    IF
        Win2k?
        IF
            WinXP? IF S" XP" ELSE S" 2000" THEN
        ELSE
            S" NT"
        THEN
    ELSE
        Win95? IF S" 95" EXIT THEN
        Win98? IF S" 98" EXIT THEN
        WinME? IF S" ME" EXIT THEN
    THEN
;

: VerM.M.B ( major minor build -- a u )
    <#
        S>D #S [CHAR] . HOLD 2DROP
        S>D #S [CHAR] . HOLD 2DROP
        S>D #S
    #>
;


: WinVersionString
    S" Windows %WinVerSuffix% (%WinVerMajor WinVerMinor WinVerBuild VerM.M.B%) %WinVerServicePack%" EVAL-SUBST
;

: LoadOrGetLibrary ( a u -- h)
    DROP DUP GetModuleHandleA ?DUP 0=
    IF
        LoadLibraryA
    ELSE
        NIP
    THEN
;

: DllGetVersion { a u \ buf -- major minor build  }
    5 CELLS ALLOCATE THROW TO buf
    5 CELLS buf !
    S" DllGetVersion" DROP a u LoadOrGetLibrary GetProcAddress ?DUP
    IF buf SWAP API-CALL DROP THEN
    buf 1 CELLS + @
    buf 2 CELLS + @
    buf 3 CELLS + @
    buf FREE DROP
;
\EOF
WinVersionString TYPE CR
S" shell32.dll" 2DUP TYPE SPACE DllGetVersion VerM.M.B TYPE CR