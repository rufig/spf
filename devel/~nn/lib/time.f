REQUIRE { ~ac/lib/locals.f
REQUIRE /STRING lib/include/string.f
REQUIRE S>NUM ~nn/lib/s2num.f

S" LIB\include\FACIL.F" INCLUDED

CREATE LTIME /SYSTEMTIME ALLOT

: GET-CUR-TIME LTIME GetLocalTime DROP ;
: Min@ LTIME wMinute W@ ;
: Hour@ LTIME wHour W@ ;
: Sec@ LTIME wSecond W@ ;
: Day@ LTIME wDay W@ ;
: Mon@ LTIME wMonth W@ ;
: Year@ LTIME wYear W@ ;
: WDay@ LTIME wDayOfWeek W@ ?DUP 0= IF 7 THEN ;

: TimeMin@ ( -- CurrentTime_in_minutes)  Hour@ 60 * Min@ + ;
: TimeSec@ ( -- Time_in_seconds) TimeMin@ 60 * Sec@ + ;

\ : S>NUM ( addr u - u1)  0 0 2SWAP >NUMBER 2DROP D>S ;
: S>US ( addr u - u1 addr1 u1)
    0 0 2SWAP >NUMBER 2SWAP D>S ROT ROT ;
\ : SKIP-CHAR ( addr u -- addr1 u1) DUP 1 MIN >R R@ - SWAP R> + SWAP ;
: SKIP-CHAR ( addr u -- addr1 u1) 1 /STRING ;

\ : SHH:MM ( addr u -- hh mm )
\    S>US ( hh addr1 u1 )
\    SKIP-CHAR
\    S>US ( hh mm addr2 u2)
\    2DROP
\ ;


: SHH:MM:SS ( addr u -- hh mm ss)
    S>US SKIP-CHAR
    S>US OVER C@ [CHAR] : =
    IF SKIP-CHAR S>US 2DROP ELSE 2DROP 0 THEN
;

: SHH:MM ( addr u -- hh mm ) SHH:MM:SS DROP ;

: SH:M>Min SHH:MM SWAP 60 * + ;

: SH:M:S>Sec SHH:MM:SS SWAP 60 * + SWAP 3600 * + ;

: S>MS ( a u -- u)
    2DUP S" :" SEARCH NIP NIP
    IF SH:M:S>Sec 1000 * ELSE S>NUM THEN ;

CREATE MON-LENGTH 31 C, 28 C, 31 C, 30 C, 31 C, 30 C,
                  31 C, 31 C, 30 C, 31 C, 30 C, 31 C, 
: MonLength ( year month -- days-of-month )
    DUP 2 =
    IF
        DROP
        4 MOD 0= IF 29 ELSE 28 THEN
    ELSE
        NIP 1- MON-LENGTH + C@ 
    THEN
;

:NONAME ( a u -- y m d a u)
    S>US ( d a1 u1 -- ) SKIP-CHAR
    S>US ( d m a2 u2 -- ) SKIP-CHAR
    S>US ( d m y a3 u3 -- )
    2>R SWAP ROT 2R> ;
: SDD.MM.YYYY ( addr u -- y m d)  [ DUP COMPILE, ] 2DROP ;
: SDD.MM.YYYY/hh:mm:ss ( a u -- y m d hh mm ss)
    [ COMPILE, ]
    ?DUP IF SKIP-CHAR SHH:MM:SS ELSE DROP 0 0 0 THEN ;

: DAYS ( y m d -- days)
\  оличество дней от начала летоисчислени€ по григорианскому календарю
    SWAP DUP 2 > IF 1+ ELSE 13 + ROT 1- ROT ROT THEN
    306 * 10 / + SWAP 36525 * 100 / +
;

: SD.M.Y>Day ( addr u -- days)
    SDD.MM.YYYY DAYS ;

: Days@ Year@ Mon@ Day@ DAYS ;

: .TIME
    GET-CUR-TIME
    Sec@ S>D
    <#          # # [CHAR] : HOLD 2DROP
       Min@ S>D # # [CHAR] : HOLD 2DROP
       Hour@ S>D # # #>
    TYPE SPACE ;

CREATE WDAYS C" SunMonTueWedThuFriSat" ", 
CREATE MONNAMES C" JunFebMarAprMayJunJulAugSepOctNovDec" ", \ "


WINAPI: FileTimeToSystemTime KERNEL32.DLL
WINAPI: FileTimeToLocalFileTime KERNEL32.DLL
WINAPI: SystemTimeToFileTime KERNEL32.DLL
WINAPI: LocalFileTimeToFileTime KERNEL32.DLL
WINAPI: CompareFileTime KERNEL32.DLL

: YMD>DATE ( y m d -- u)  SWAP 5 LSHIFT + SWAP 9 LSHIFT + ;

: FT>DATE ( d -- u)
    SP@ >R 
    0 0 SP@ R@ FileTimeToLocalFileTime ERR THROW
    2SWAP 2DROP
    0 0 0 0 SP@ R> FileTimeToSystemTime ERR THROW
    SP@ >R
    R@ wYear  W@ 
    R@ wMonth W@ 
    R> wDay W@ YMD>DATE >R
    2DROP 2DROP 2DROP R>
;

: YMDHMS>FT ( y m d h m s -- du )
    /SYSTEMTIME RALLOT >R
    R@ /SYSTEMTIME ERASE
    R@ wSecond W!   R@ wMinute W!   R@ wHour W!
    R@ wDay W!      R@ wMonth W!    R@ wYear W!
    0 0 SP@ R> SystemTimeToFileTime ERR THROW
    SP@ >R 0 0 SP@ R> LocalFileTimeToFileTime ERR THROW
    2SWAP 2DROP
    /SYSTEMTIME RFREE
;

: DATE>YMD ( u -- y m d)
    DUP 9 RSHIFT SWAP
    DUP 5 RSHIFT 15 AND SWAP
    31 AND ;

CHAR - VALUE DATE-SEP

: DATE>S ( u -- a u)
    DATE>YMD SWAP ROT
    <#
       S>D # # # # 2DROP DATE-SEP HOLD
       S>D # # 2DROP DATE-SEP HOLD
       S>D # # 
    #>
;

: DATE- ( u1 u2 -- )
    SWAP DATE>YMD DAYS SWAP
    DATE>YMD DAYS -
;

: CUR-DATE  ( -- u)
    GET-CUR-TIME
    Year@ Mon@ Day@ YMD>DATE
;

: DAY+ { y m d days -- y1 m1 d1 }
    d days + DUP 0 > 0=
    IF
        BEGIN DUP 0 > 0= WHILE
            m 1- DUP 0= IF DROP 12 y 1- TO y THEN TO m
            y m MonLength +
        REPEAT
    ELSE
        BEGIN DUP y m MonLength > WHILE
            y m MonLength -
            m 1+ DUP 13 = IF DROP 1 y 1+ TO y THEN TO m
        REPEAT
    THEN
    y m ROT         
;

: WEEK-DAY ( y m d -- wd[1-7] )
    SWAP ROT
    SWAP DUP 2 > IF 2- ELSE 10 + SWAP 1- SWAP THEN SWAP
    100 /MOD DUP 4 / SWAP 5 * + SWAP DUP 4 / + +
    ROT + SWAP 26 * 2- 10 / + ABS 7 MOD
    ?DUP 0= IF 7 THEN
;