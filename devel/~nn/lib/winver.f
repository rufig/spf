REQUIRE nn-adapter ~nn/lib/adapter.f
REQUIRE EVAL-SUBST ~nn/lib/subst1.f
\ WINAPI: GetVersionExA KERNEL32.DLL

 1 CONSTANT VER_PLATFORM_WIN32_WINDOWS
 2 CONSTANT VER_PLATFORM_WIN32_NT

 DECIMAL
 156 CONSTANT /WIN-VER-EX
 148 CONSTANT /WIN-VER
\
 CREATE (WIN-VER) /WIN-VER-EX ALLOT  (WIN-VER) /WIN-VER-EX ERASE
\
 VECT (GET-VER)
\
 : GET-VER ( -- minor major platform)
     (GET-VER)
     (WIN-VER) 2 CELLS + @
     (WIN-VER) 1 CELLS + @
     (WIN-VER) 4 CELLS + @
 ;
\
 : WinVerMajor (GET-VER) (WIN-VER) 1 CELLS + @ ;
 : WinVerMinor (GET-VER) (WIN-VER) 2 CELLS + @ ;
 : WinVerPlatform (GET-VER) (WIN-VER) 4 CELLS + @ ;
\ : WinVerServicePack (GET-VER) (WIN-VER) 5 CELLS + ASCIIZ> ;
 : WinVerEx (GET-VER) (WIN-VER) /WIN-VER + ;
\ : WinVerServicePackMajor WinVerEx W@ ;
\ : WinVerServicePackMinor WinVerEx 2 + W@ ;
\ : WinVerSuiteMask   WinVerEx 4 + W@ ;
 : WinVerProductType WinVerEx 6 + C@ ;
\
 : WinNT? ( -- flag ) WinVerPlatform VER_PLATFORM_WIN32_NT = ;
\
\ : WinVerBuild (GET-VER) (WIN-VER) 3 CELLS + @ WinNT? 0= IF 0xFFFF AND THEN ;
\
 : Win2k? ( -- ?) WinNT? WinVerMajor 4 > AND ;
\
 : Win2kServ?  Win2k? WinVerProductType VER_NT_SERVER = AND ;
\
 : WinXP? ( -- ?) Win2k? WinVerMinor 0 > AND ;
\
 : Win2003? ( -- ?) Win2k? WinVerMinor 1 > AND ;
\
\ : WinTS? WinVerSuiteMask 0x010 AND 0<> ;
\
\ : WinSingleuserTS? WinTS? WinVerSuiteMask 0x0100 AND 0<> AND ;
\
\ : WIN-VER ( -- num ) GET-VER DROP NIP ;
\
 : Win9x? WinVerPlatform VER_PLATFORM_WIN32_WINDOWS = ;
 : Win95? Win9x? WinVerMinor 0= AND ;
 : Win98? Win9x? WinVerMinor 10 = AND ;
 : WinME? Win9x? WinVerMinor 90 = AND ;
\
\
WARNING @ WARNING 0!
: SAVE (WIN-VER) /WIN-VER-EX ERASE SAVE ;
WARNING !
\

: WinVerSuffix
    WinNT?
    IF
        Win2k?
        IF
            WinXP?
            IF
                Win2003?
                IF
                    S" Server 2003"
                ELSE S" XP" THEN
            ELSE S" 2000" THEN
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
\ :NONAME
\     (WIN-VER) @ 0=
\     IF /WIN-VER (WIN-VER) ! (WIN-VER) GetVersionExA ERR THROW
\         Win2k?
\         IF
\           /WIN-VER-EX (WIN-VER) ! (WIN-VER) GetVersionExA ERR THROW
\         THEN
\     THEN
\ ; TO (GET-VER)
\
WinVersionString TYPE CR

S" shell32.dll" 2DUP TYPE SPACE DllGetVersion VerM.M.B TYPE CR
